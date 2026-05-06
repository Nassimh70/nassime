defmodule BackendWeb.AccountController do
  use BackendWeb, :controller

  alias Backend.Accounts
  alias Backend.Accounts.Utilisateur
  alias BackendWeb.Auth.Guardian
  plug(:is_authorized when action in [:update, :delete])

  action_fallback(BackendWeb.FallbackController)

  defp is_authorized(conn, _opt) do
    %{params: %{"account" => params}} = conn
    utilisateur = Accounts.get_utilisateur!(params["id"])

    if conn.assigns.account.id == utilisateur.id do
      conn
    else
      raise(BackendWeb.Auth.ErrorResponse.Forbidden)
    end
  end

  def create_etudiant(conn, %{"account" => account_params}) do
    with {:ok, %Utilisateur{} = utilisateur} <- Accounts.create_utilisateur(account_params),
         {:ok, _etudiant} <-
           Accounts.create_etudiant(account_params, utilisateur.id) do
      authorize_user(conn, account_params["email_utilisateurs"], account_params["password"])
    end
  end

  def create_professeur(conn, %{"account" => account_params}) do
    with {:ok, %Utilisateur{} = utilisateur} <- Accounts.create_utilisateur(account_params),
         {:ok, _professeur} <-
           Accounts.create_professeur(account_params, utilisateur.id) do
      authorize_user(conn, account_params["email_utilisateurs"], account_params["password"])
    end
  end

  def refresh_session(conn, %{}) do
    with token when is_binary(token) <- Guardian.Plug.current_token(conn),
         {:ok, utilisateur, new_token} <- Guardian.authenticate(token) do
      conn
      |> Plug.Conn.put_session(:id, utilisateur.id)
      |> put_status(:ok)
      |> render(:show, utilisateur: utilisateur, token: new_token)
    else
      _ ->
        {:error, :invalid_credentials, message: "Session invalide ou expirée"}
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    authorize_user(conn, email, password)
  end

  def profile(conn, _params) do
    # reload utilisateur with associations to include etudiant, professeur, groupe and role data
    utilisateur =
      conn.assigns.account
      |> (fn a -> Accounts.get_utilisateur!(a.id) end).()
      |> Backend.Repo.preload([:role, :professeur, etudiant: [:groupe]])

    conn
    |> put_status(:ok)
    |> render(:profile, utilisateur: utilisateur)
  end

  def index(conn, _params) do
    utilisateurs =
      Accounts.list_utilisateurs()
      |> Enum.map(fn u ->
        %{
          id: u.id,
          nom: u.nom_utilisateurs || "",
          email: u.email_utilisateurs,
          role: (u.role && u.role.nom_roles) || "",
          filiere: (u.etudiant && u.etudiant.groupe && u.etudiant.groupe.libele_groupes) || "",
          grade: (u.professeur && u.professeur.grade_professeurs) || "",
          status: "Actif",
          reclamations: length(u.tickets || []),
          actif: (u.etudiant && u.etudiant.est_delegue_etudiant) || false
        }
      end)

    # Debugging: log delegate counts and entries marked actif
    require Logger
    delegates_count = Enum.count(utilisateurs, fn u -> u[:actif] == true end)

    Logger.debug(
      "[AccountController] /utilisateurs count=#{length(utilisateurs)} delegates=#{delegates_count}"
    )

    Logger.debug(
      "[AccountController] utilisateurs with actif=true: #{inspect(Enum.filter(utilisateurs, fn u -> u[:actif] == true end))}"
    )

    json(conn, %{data: utilisateurs})
  end

  def delete_utilisateur(conn, %{"id" => id}) do
    utilisateur = Accounts.get_utilisateur!(id)

    with {:ok, _} <- Accounts.delete_utilisateur(utilisateur) do
      send_resp(conn, :no_content, "")
    end
  end

  defp authorize_user(conn, email, password) do
    with {:ok, utilisateur, token} <- Guardian.authenticate_user(email, password) do
      conn
      |> put_status(:ok)
      |> render(:show, utilisateur: utilisateur, token: token)
    end
  end

  def update(conn, %{"account" => account_params}) do
    utilisateur = Accounts.get_utilisateur!(account_params["id"])

    with {:ok, %Utilisateur{} = updated_utilisateur} <-
           Accounts.update_utilisateur(utilisateur, account_params) do
      conn
      |> put_status(:ok)
      |> render(:show_update, utilisateur: updated_utilisateur)
    end
  end

  def sign_out(conn, _params) do
    with token when is_binary(token) <- Guardian.Plug.current_token(conn),
         {:ok, _claims} <- Guardian.revoke(token) do
      conn
      |> Plug.Conn.clear_session()
      |> put_status(:ok)
      |> json(%{message: "Déconnexion réussie"})
    else
      _ ->
        {:error, :invalid_credentials, message: "Token invalide ou déjà révoqué"}
    end
  end

  def professeur_students(conn, _params) do
    with {:ok, professeur} <- ensure_professeur_profile(conn.assigns.account) do
      students =
        Accounts.list_students_for_professeur(professeur.id)
        |> Backend.Repo.preload(groupe: [modules: :professeurs])

      data =
        Enum.map(students, fn student ->
          prof_modules =
            if student.groupe && Ecto.assoc_loaded?(student.groupe.modules) do
              student.groupe.modules
              |> Enum.filter(fn m ->
                Ecto.assoc_loaded?(m.professeurs) and
                  Enum.any?(m.professeurs, &(&1.id == professeur.id))
              end)
              |> Enum.map(& &1.intitule_cours)
              |> Enum.join(", ")
            else
              ""
            end

          # Fallback to group name if no module found
          course_display =
            if prof_modules != "",
              do: prof_modules,
              else: (student.groupe && student.groupe.libele_groupes) || ""

          %{
            id: student.id,
            name:
              "#{student.utilisateur.prenom_utilisateurs} #{student.utilisateur.nom_utilisateurs}",
            email: student.utilisateur.email_utilisateurs,
            phone: student.telephone_etudiant || "",
            group: course_display,
            is_delegate: student.est_delegue_etudiant || false
          }
        end)

      json(conn, %{data: data})
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def professeur_create_student(conn, %{"account" => account_params}) do
    with {:ok, professeur} <- ensure_professeur_profile(conn.assigns.account) do
      email =
        account_params
        |> Map.get("email_utilisateurs", "")
        |> to_string()
        |> String.trim()
        |> String.downcase()

      if email == "" do
        {:error, "Email étudiant requis"}
      else
        case Accounts.get_utilisateur_by_email(email) do
          nil ->
            {:error, "L'étudiant n'existe pas dans la base de données"}

          %Utilisateur{} = utilisateur ->
            case Accounts.get_etudiant_by_utilisateur_id(utilisateur.id) do
              nil ->
                {:error, "Ce compte existe mais n'est pas un profil étudiant"}

              etudiant ->
                students = Accounts.list_students_for_professeur(professeur.id)

                if Enum.any?(students, fn s -> s.id == etudiant.id end) do
                  json(
                    conn,
                    student_created_payload(
                      etudiant,
                      utilisateur,
                      "Étudiant déjà présent dans votre liste"
                    )
                  )
                else
                  {:error,
                   "Cet étudiant existe déjà. Veuillez utiliser la barre de recherche 'Ajouter un Étudiant Existant' pour le rattacher à votre module."}
                end
            end
        end
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def professeur_delete_student(conn, %{"id" => id}) do
    etudiant_id = String.to_integer(id)

    with {:ok, professeur} <- ensure_professeur_profile(conn.assigns.account),
         {:ok, :deleted} <- Accounts.delete_student_for_professeur(professeur.id, etudiant_id) do
      json(conn, %{message: "Étudiant supprimé avec succès"})
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def search_students(conn, %{"q" => query}) do
    students = Accounts.search_students_by_email(query)

    data =
      Enum.map(students, fn student ->
        %{
          id: student.id,
          name:
            "#{student.utilisateur.prenom_utilisateurs} #{student.utilisateur.nom_utilisateurs}",
          email: student.utilisateur.email_utilisateurs,
          phone: student.telephone_etudiant || "",
          group: (student.groupe && student.groupe.libele_groupes) || ""
        }
      end)

    json(conn, %{data: data})
  end

  def attach_student_to_module(conn, %{"student_id" => student_id, "module_id" => module_id}) do
    student_id_int = parse_id(student_id)
    module_id_int = parse_id(module_id)

    with {:ok, professeur} <- ensure_professeur_profile(conn.assigns.account),
         true <- student_id_int != :error and module_id_int != :error,
         {:ok, result} <-
           Accounts.attach_student_to_module(student_id_int, module_id_int, professeur.id) do
      json(conn, %{data: result, message: "Étudiant rattaché au module avec succès"})
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Paramètres invalides"}
    end
  end

  defp parse_id(id) when is_integer(id), do: id

  defp parse_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {num, ""} -> num
      _ -> :error
    end
  end

  defp parse_id(_), do: :error

  defp ensure_professeur_profile(account) do
    utilisateur =
      account.id
      |> Accounts.get_utilisateur!()
      |> Backend.Repo.preload(:role)

    role_name =
      case utilisateur.role do
        %{nom_roles: role} when is_binary(role) -> normalize_role(role)
        _ -> ""
      end

    if role_name not in ["", "professeur", "enseignant", "prof", "teacher"] do
      require Logger

      Logger.warning(
        "[professeur_students] unexpected role '#{role_name}' for user #{utilisateur.id}, proceeding with professeur profile auto-provisioning"
      )
    end

    case Accounts.get_professeur_by_utilisateur_id(utilisateur.id) do
      nil ->
        Accounts.create_professeur(
          %{
            grade_professeurs: "Enseignant",
            telephone_professeurs: "N/A",
            specialite_professeurs: "Général"
          },
          utilisateur.id
        )

      professeur ->
        {:ok, professeur}
    end
  end

  defp normalize_role(role) do
    role
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.downcase()
    |> String.trim()
  end

  defp student_created_payload(etudiant, utilisateur, message) do
    %{
      data: %{
        id: etudiant.id,
        utilisateur_id: utilisateur.id,
        email_utilisateurs: utilisateur.email_utilisateurs,
        prenom_utilisateurs: utilisateur.prenom_utilisateurs,
        nom_utilisateurs: utilisateur.nom_utilisateurs
      },
      message: message
    }
  end
end
