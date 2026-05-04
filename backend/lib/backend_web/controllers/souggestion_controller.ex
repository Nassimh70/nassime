defmodule BackendWeb.SouggestionController do
  use BackendWeb, :controller

  alias Backend.Accounts
  alias Backend.Communication
  alias Backend.Communication.Souggestion
  alias Backend.Repo
  require Logger

  action_fallback(BackendWeb.FallbackController)

  def index(conn, _params) do
    souggestions = Communication.list_souggestions()
    current_user_id = conn.assigns.account.id

    json(conn, %{
      data: Enum.map(souggestions, fn s ->
        souggestion_payload(s, current_user_id)
      end)
    })
  end

  def show(conn, %{"id" => id}) do
    souggestion = Communication.get_souggestion!(id)
    current_user_id = conn.assigns.account.id
    json(conn, %{data: souggestion_payload(souggestion, current_user_id)})
  end

  def create(conn, %{"souggestion" => souggestion_params}) do
    current = conn.assigns.account

    with etudiant when not is_nil(etudiant) <- Accounts.get_etudiant_by_utilisateur_id(current.id),
         params <-
           souggestion_params
           |> Map.put("etudiant_id", etudiant.id)
           |> Map.put_new("like_souggestion", 0)
           |> Map.put_new("dislike_souggestion", 0),
         {:ok, %Souggestion{} = souggestion} <- Communication.create_souggestion(params) do
      # Preload associations so souggestion_payload can access etudiant.utilisateur
      souggestion = Repo.preload(souggestion, etudiant: :utilisateur)

      # create a broadcast notification for all users
      try do
        Backend.Support.create_notification(%{
          "type_notifications" => "nouvelle_souggestion",
          "message_notifications" => "Nouvelle suggestion: #{souggestion.titre_souggestion}",
          "cree_le_notifications" => DateTime.utc_now(),
          "lien_notifications" => "/api/auth/souggestions/#{souggestion.id}",
          "pour_tous" => true,
          "utilisateur_id" => current.id
        })
      rescue
        _ ->
          Logger.debug(
            "[SouggestionController] failed to create notification for souggestion=#{souggestion.id}"
          )
      end

      conn
      |> put_status(:created)
      |> json(%{data: souggestion_payload(souggestion, current.id)})
    else
      nil -> {:error, "Profil etudiant introuvable"}
    end
  end

  def update(conn, %{"id" => id, "souggestion" => souggestion_params}) do
    souggestion = Communication.get_souggestion!(id)
    current_user_id = conn.assigns.account.id

    with {:ok, %Souggestion{} = updated} <-
           Communication.update_souggestion(souggestion, souggestion_params) do
      updated = Repo.preload(updated, etudiant: :utilisateur)
      json(conn, %{data: souggestion_payload(updated, current_user_id)})
    end
  end

  def delete(conn, %{"id" => id}) do
    souggestion = Communication.get_souggestion!(id)

    with {:ok, %Souggestion{}} <- Communication.delete_souggestion(souggestion) do
      json(conn, %{message: "Suggestion supprimee"})
    end
  end

  def vote(conn, %{"id" => id, "vote" => vote_type}) do
    souggestion = Communication.get_souggestion!(id)
    current_user_id = conn.assigns.account.id

    with {:ok, %Souggestion{} = updated} <-
           Communication.vote_souggestion(souggestion, current_user_id, vote_type) do
      updated = Repo.preload(updated, etudiant: :utilisateur)
      json(conn, %{data: souggestion_payload(updated, current_user_id)})
    end
  end

  defp souggestion_payload(souggestion, current_user_id) do
    user_vote = Communication.get_user_vote_for_souggestion(souggestion.id, current_user_id)

    %{
      id: souggestion.id,
      titre_souggestion: souggestion.titre_souggestion,
      contenu_souggestion: souggestion.contenu_souggestion,
      like_souggestion: souggestion.like_souggestion || 0,
      dislike_souggestion: souggestion.dislike_souggestion || 0,
      category: souggestion.category || "Général",
      etudiant_id: souggestion.etudiant_id,
      auteur: get_auteur_name(souggestion.etudiant),
      user_vote: if(user_vote, do: user_vote.vote_type, else: nil),
      inserted_at: souggestion.inserted_at,
      updated_at: souggestion.updated_at
    }
  end

  defp get_auteur_name(nil), do: "Inconnu"

  defp get_auteur_name(etudiant) do
    case etudiant.utilisateur do
      nil -> "Inconnu"
      utilisateur -> "#{utilisateur.prenom_utilisateurs} #{utilisateur.nom_utilisateurs}"
    end
  end
end
