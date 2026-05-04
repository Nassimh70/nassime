defmodule BackendWeb.TicketController do
  use BackendWeb, :controller

  import Ecto.Query, warn: false

  alias Backend.Accounts
  alias Backend.Repo
  alias Backend.Support
  alias Backend.Support.Commentaire
  alias Backend.Support.Notification
  alias Backend.Support.Ticket

  action_fallback(BackendWeb.FallbackController)

  def index(conn, params) do
    current = conn.assigns.account

    tickets =
      Ticket
      |> maybe_filter_status(params["status"])
      |> maybe_filter_owner(params["mine"], current.id)
      |> Repo.all()
      |> Repo.preload(:utilisateur)

    json(conn, %{data: Enum.map(tickets, &ticket_payload/1)})
  end

  def show(conn, %{"id" => id}) do
    ticket =
      id
      |> Support.get_ticket!()
      |> Repo.preload([:utilisateur, [commentaires: :utilisateur], :notifications])

    json(conn, %{data: ticket_payload(ticket, true)})
  end

  def create(conn, %{"ticket" => ticket_params}) do
    current = conn.assigns.account

    params =
      ticket_params
      |> Map.put_new("statut_ticket", "en_attente")
      |> Map.put_new("cree_le_ticket", DateTime.utc_now())
      |> Map.put("utilisateur_id", current.id)
      |> Map.put_new("portee_ticket", "local")
      |> Map.put_new("type_ticket", "general")
      |> Map.put_new("referance_ticket", "T-" <> Ecto.UUID.generate())

    with {:ok, %Ticket{} = ticket} <- Support.create_ticket(params) do
      json(conn, %{data: ticket_payload(ticket)})
    end
  end

  def update(conn, %{"id" => id, "ticket" => ticket_params}) do
    ticket = Support.get_ticket!(id)
    current = conn.assigns.account

    if can_manage_ticket?(current, ticket) do
      with {:ok, %Ticket{} = updated_ticket} <- Support.update_ticket(ticket, ticket_params) do
        json(conn, %{data: ticket_payload(updated_ticket)})
      end
    else
      raise(BackendWeb.Auth.ErrorResponse.Forbidden)
    end
  end

  def delete(conn, %{"id" => id}) do
    ticket = Support.get_ticket!(id)
    current = conn.assigns.account

    if can_manage_ticket?(current, ticket) do
      with {:ok, %Ticket{}} <- Support.delete_ticket(ticket) do
        json(conn, %{message: "Ticket supprime"})
      end
    else
      raise(BackendWeb.Auth.ErrorResponse.Forbidden)
    end
  end

  def add_comment(conn, %{"id" => id, "commentaire" => commentaire_params}) do
    ticket = Support.get_ticket!(id)
    current = conn.assigns.account

    unless can_comment?(current) do
      raise(BackendWeb.Auth.ErrorResponse.Forbidden)
    end

    params =
      commentaire_params
      |> Map.put("ticket_id", ticket.id)
      |> Map.put("utilisateur_id", current.id)

    with {:ok, %Commentaire{} = commentaire} <- Support.create_commentaire(params) do
      commentaire = Repo.preload(commentaire, :utilisateur)
      json(conn, %{data: commentaire_payload(commentaire)})
    end
  end

  def comments(conn, %{"id" => id}) do
    comments =
      Commentaire
      |> where([c], c.ticket_id == ^id)
      |> order_by([c], asc: c.inserted_at)
      |> Repo.all()
      |> Repo.preload(:utilisateur)

    json(conn, %{data: Enum.map(comments, &commentaire_payload/1)})
  end

  def decide(conn, %{"id" => id, "decision" => decision_params}) do
    current = conn.assigns.account

    if admin?(current) do
      ticket = Support.get_ticket!(id)
      decision = decision_params["action"]
      motif = decision_params["motif"]

      statut =
        case String.downcase(to_string(decision)) do
          "accepter" -> "acceptee"
          "refuser" -> "refusee"
          _ -> nil
        end

      with true <-
             not is_nil(statut) or {:error, "Action invalide. Utilisez accepter ou refuser."},
           {:ok, %Ticket{} = updated_ticket} <-
             Support.update_ticket(ticket, %{"statut_ticket" => statut}),
           {:ok, _commentaire} <-
             maybe_add_decision_comment(updated_ticket, current.id, motif, statut),
           {:ok, %Notification{}} <- notify_decision(updated_ticket, statut, motif) do
        json(conn, %{data: ticket_payload(updated_ticket), message: "Decision enregistree"})
      end
    else
      raise(BackendWeb.Auth.ErrorResponse.Forbidden)
    end
  end

  def stats(conn, _params) do
    current = conn.assigns.account

    if admin?(current) do
      tickets = Support.list_tickets()

      stats = %{
        total: length(tickets),
        en_attente: count_status(tickets, "en_attente"),
        acceptee: count_status(tickets, "acceptee"),
        refusee: count_status(tickets, "refusee"),
        en_cours: count_status(tickets, "en_cours")
      }

      json(conn, %{data: stats})
    else
      raise(BackendWeb.Auth.ErrorResponse.Forbidden)
    end
  end

  def status_mine(conn, _params) do
    current = conn.assigns.account

    tickets =
      Ticket
      |> where([t], t.utilisateur_id == ^current.id)
      |> select([t], %{
        id: t.id,
        referance_ticket: t.referance_ticket,
        statut_ticket: t.statut_ticket
      })
      |> Repo.all()

    json(conn, %{data: tickets})
  end

  def by_professeur_modules(conn, _params) do
    current = conn.assigns.account

    if professeur?(current) do
      professeur = Accounts.get_professeur_by_utilisateur_id(current.id)

      if professeur do
        module_ids =
          from(e in Backend.Academics.Enseigner,
            where: e.professeur_id == ^professeur.id,
            select: e.module_id
          )
          |> Repo.all()

        tickets =
          Ticket
          |> where([t], t.module_id in ^module_ids)
          |> Repo.all()

        json(conn, %{data: Enum.map(tickets, &ticket_payload/1)})
      else
        {:error, "Profil professeur introuvable"}
      end
    else
      raise(BackendWeb.Auth.ErrorResponse.Forbidden)
    end
  end

  defp ticket_payload(ticket, include_relations \\ false) do
    base = %{
      id: ticket.id,
      portee_ticket: ticket.portee_ticket,
      referance_ticket: ticket.referance_ticket,
      type_ticket: ticket.type_ticket,
      categorie_ticket: ticket.categorie_ticket,
      object_ticket: ticket.object_ticket,
      description_ticket: ticket.description_ticket,
      statut_ticket: ticket.statut_ticket,
      priorite_ticket: ticket.priorite_ticket,
      note_satisfaction_ticket: ticket.note_satisfaction_ticket,
      cree_le_ticket: ticket.cree_le_ticket,
      module_id: ticket.module_id,
      utilisateur_id: ticket.utilisateur_id,
      inserted_at: ticket.inserted_at,
      updated_at: ticket.updated_at
    }

    if include_relations do
      base
      |> Map.put(:commentaires, Enum.map(ticket.commentaires || [], &commentaire_payload/1))
      |> Map.put(:notifications, Enum.map(ticket.notifications || [], &notification_payload/1))
    else
      base
    end
  end

  defp commentaire_payload(commentaire) do
    %{
      id: commentaire.id,
      contenu_commentaires: commentaire.contenu_commentaires,
      interne_commentaires: commentaire.interne_commentaires,
      ticket_id: commentaire.ticket_id,
      utilisateur_id: commentaire.utilisateur_id,
      auteur_nom: get_commentaire_auteur(commentaire.utilisateur),
      inserted_at: commentaire.inserted_at
    }
  end

  defp get_commentaire_auteur(nil), do: "Utilisateur"

  defp get_commentaire_auteur(utilisateur) do
    "#{utilisateur.prenom_utilisateurs || ""} #{utilisateur.nom_utilisateurs || ""}" |> String.trim()
  end

  defp notification_payload(notification) do
    %{
      id: notification.id,
      type_notifications: notification.type_notifications,
      message_notifications: notification.message_notifications,
      cree_le_notifications: notification.cree_le_notifications,
      lien_notifications: notification.lien_notifications,
      pour_tous: notification.pour_tous,
      ticket_id: notification.ticket_id,
      utilisateur_id: notification.utilisateur_id
    }
  end

  defp maybe_add_decision_comment(ticket, user_id, motif, statut) do
    if is_binary(motif) and String.trim(motif) != "" do
      Support.create_commentaire(%{
        "ticket_id" => ticket.id,
        "utilisateur_id" => user_id,
        "interne_commentaires" => true,
        "contenu_commentaires" => "Decision: #{statut}. Motif: #{motif}"
      })
    else
      {:ok, :skipped}
    end
  end

  defp notify_decision(ticket, statut, motif) do
    message =
      if is_binary(motif) and String.trim(motif) != "" do
        "Votre ticket #{ticket.referance_ticket} a ete #{statut}. Motif: #{motif}"
      else
        "Votre ticket #{ticket.referance_ticket} a ete #{statut}."
      end

    Support.create_notification(%{
      "type_notifications" => "decision_ticket",
      "message_notifications" => message,
      "cree_le_notifications" => DateTime.utc_now(),
      "lien_notifications" => "/api/auth/tickets/#{ticket.id}",
      "ticket_id" => ticket.id,
      "utilisateur_id" => ticket.utilisateur_id,
      "pour_tous" => false
    })

    # also create a broadcast notification for all users announcing the decision
    Support.create_notification(%{
      "type_notifications" => "decision_ticket_broadcast",
      "message_notifications" => "Ticket #{ticket.referance_ticket} a ete #{statut}.",
      "cree_le_notifications" => DateTime.utc_now(),
      "lien_notifications" => "/api/auth/tickets/#{ticket.id}",
      "ticket_id" => ticket.id,
      "pour_tous" => true
    })
  end

  defp maybe_filter_status(query, nil), do: query
  defp maybe_filter_status(query, ""), do: query

  defp maybe_filter_status(query, status) do
    where(query, [t], t.statut_ticket == ^status)
  end

  defp maybe_filter_owner(query, "true", user_id),
    do: where(query, [t], t.utilisateur_id == ^user_id)

  defp maybe_filter_owner(query, true, user_id),
    do: where(query, [t], t.utilisateur_id == ^user_id)

  defp maybe_filter_owner(query, _mine, _user_id), do: query

  defp can_manage_ticket?(account, ticket) do
    account.id == ticket.utilisateur_id or admin?(account) or professeur?(account)
  end

  defp can_comment?(account) do
    admin?(account) or professeur?(account) or delegue?(account) or not etudiant?(account)
  end

  defp admin?(account), do: role?(account, ["admin", "administration"])
  defp professeur?(account), do: role?(account, ["professeur"])
  defp delegue?(account), do: role?(account, ["delegue"])
  defp etudiant?(account), do: role?(account, ["etudiant"])

  defp role?(%{role: %{nom_roles: role}}, allowed_roles) when is_binary(role) do
    String.downcase(role) in allowed_roles
  end

  defp role?(_, _), do: false

  defp count_status(tickets, status) do
    Enum.count(tickets, &(&1.statut_ticket == status))
  end
end
