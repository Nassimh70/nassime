defmodule BackendWeb.AnnonceController do
  use BackendWeb, :controller

  alias Backend.Communication
  alias Backend.Communication.Annonce
  alias Backend.Repo

  action_fallback(BackendWeb.FallbackController)

  def index(conn, _params) do
    annonces = Communication.list_annonces()
    json(conn, %{data: Enum.map(annonces, &annonce_payload/1)})
  end

  def show(conn, %{"id" => id}) do
    annonce = Communication.get_annonce!(id)
    json(conn, %{data: annonce_payload(annonce)})
  end

  def create(conn, %{"annonce" => annonce_params}) do
    current = conn.assigns.account
    # Only allow delegated roles (délégués), professors and admins to publish
    require Logger

    Logger.debug(
      "[AnnonceController] create called, conn.assigns.account=#{inspect(conn.assigns[:account])}, params=#{inspect(annonce_params)}"
    )

    utilisateur = Backend.Accounts.get_utilisateur!(current.id) |> Repo.preload(:role)
    role_name = (utilisateur.role && utilisateur.role.nom_roles) || ""
    allowed = ["delegue", "professeur", "admin", "administration"]

    if String.downcase(String.trim(role_name)) in allowed do
      params =
        annonce_params
        |> Map.put("utilisateur_id", current.id)
        |> Map.put_new("date_publication_annonce", DateTime.utc_now())

      with {:ok, %Annonce{} = annonce} <- Communication.create_annonce(params) do
        # create a broadcast notification for all users
        try do
          Backend.Support.create_notification(%{
            "type_notifications" => "annonce_publie",
            "message_notifications" => "Nouvelle annonce: #{annonce.titre_annonce}",
            "cree_le_notifications" => DateTime.utc_now(),
            "lien_notifications" => "/api/auth/annonces/#{annonce.id}",
            "pour_tous" => true,
            "utilisateur_id" => annonce.utilisateur_id
          })
        rescue
          _ ->
            Logger.debug(
              "[AnnonceController] failed to create notification for annonce=#{annonce.id}"
            )
        end

        annonce = Repo.preload(annonce, utilisateur: :role)

        conn
        |> put_status(:created)
        |> json(%{data: annonce_payload(annonce)})
      end
    else
      Logger.debug(
        "[AnnonceController] create forbidden for user=#{current.id} role=#{role_name}"
      )

      raise(BackendWeb.Auth.ErrorResponse.Forbidden)
    end
  end

  def update(conn, %{"id" => id, "annonce" => annonce_params}) do
    annonce = Communication.get_annonce!(id)

    with {:ok, %Annonce{} = updated} <- Communication.update_annonce(annonce, annonce_params) do
      updated = Repo.preload(updated, utilisateur: :role)
      json(conn, %{data: annonce_payload(updated)})
    end
  end

  def delete(conn, %{"id" => id}) do
    annonce = Communication.get_annonce!(id)

    with {:ok, %Annonce{}} <- Communication.delete_annonce(annonce) do
      json(conn, %{message: "Annonce supprimee"})
    end
  end



  defp annonce_payload(annonce) do
    %{
      id: annonce.id,
      titre_annonce: annonce.titre_annonce,
      contenu_annonce: annonce.contenu_annonce,
      type_annonce: annonce.type_annonce || "Pédagogique",

      date_publication_annonce: annonce.date_publication_annonce,
      utilisateur_id: annonce.utilisateur_id,
      auteur: get_auteur_name(annonce.utilisateur),
      role_auteur: get_auteur_role(annonce.utilisateur),
      inserted_at: annonce.inserted_at,
      updated_at: annonce.updated_at
    }
  end

  defp get_auteur_name(nil), do: "Inconnu"

  defp get_auteur_name(utilisateur) do
    "#{utilisateur.prenom_utilisateurs} #{utilisateur.nom_utilisateurs}"
  end

  defp get_auteur_role(nil), do: "Inconnu"

  defp get_auteur_role(utilisateur) do
    cond do
      is_nil(utilisateur.role) ->
        "Inconnu"

      true ->
        role = String.downcase(String.trim(utilisateur.role.nom_roles || ""))

        case role do
          r when r in ["professeur", "enseignant"] -> "Professeur"
          r when r in ["admin", "administration"] -> "Admin"
          r when r in ["delegue", "delegate"] -> "Délégué"
          r when r in ["etudiant"] -> "Étudiant"
          _ -> utilisateur.role.nom_roles || "Inconnu"
        end
    end
  end
end
