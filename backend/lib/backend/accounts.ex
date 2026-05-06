defmodule Backend.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Accounts.Role

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(Role, id)

  def get_role_by_name(name) do
    Repo.get_by(Role, nom_roles: name)
  end

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{data: %Role{}}

  """
  def change_role(%Role{} = role, attrs \\ %{}) do
    Role.changeset(role, attrs)
  end

  alias Backend.Accounts.Utilisateur

  @doc """
  Returns the list of utilisateurs.

  ## Examples

      iex> list_utilisateurs()
      [%Utilisateur{}, ...]

  """
  def list_utilisateurs do
    Repo.all(Utilisateur)
    |> Repo.preload([:role, :tickets, :professeur, etudiant: [:groupe]])
  end

  @doc """
  Gets a single utilisateur.

  Raises `Ecto.NoResultsError` if the Utilisateur does not exist.

  ## Examples

      iex> get_utilisateur!(123)
      %Utilisateur{}

      iex> get_utilisateur!(456)
      ** (Ecto.NoResultsError)

  """
  def get_utilisateur!(id), do: Repo.get!(Utilisateur, id)

  @doc """
  Gets a single utilisateur by email.

  Returns nil if no utilisateur found.
  """
  def get_utilisateur_by_email(email) do
    Repo.get_by(Utilisateur, email_utilisateurs: email)
    |> Repo.preload(:role)
  end

  @doc """
  Creates a utilisateur.

  ## Examples

      iex> create_utilisateur(%{field: value})
      {:ok, %Utilisateur{}}

      iex> create_utilisateur(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_utilisateur(attrs) do
    Repo.transaction(fn ->
      role_name = Map.get(attrs, :role) || Map.get(attrs, "role")

      role =
        case get_role_by_name(role_name) do
          nil ->
            # create role if missing to allow onboarding from frontend
            case create_role(%{nom_roles: role_name}) do
              {:ok, r} -> r
              {:error, _changeset} -> Repo.rollback("Role is required")
            end

          r ->
            r
        end

      case role
           |> Ecto.build_assoc(:utilisateurs)
           |> Utilisateur.changeset(attrs)
           |> Repo.insert() do
        {:ok, utilisateur} -> utilisateur
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a utilisateur.

  ## Examples

      iex> update_utilisateur(utilisateur, %{field: new_value})
      {:ok, %Utilisateur{}}

      iex> update_utilisateur(utilisateur, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_utilisateur(%Utilisateur{} = utilisateur, attrs) do
    utilisateur
    |> Utilisateur.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a utilisateur.

  ## Examples

      iex> delete_utilisateur(utilisateur)
      {:ok, %Utilisateur{}}

      iex> delete_utilisateur(utilisateur)
      {:error, %Ecto.Changeset{}}

  """
  def delete_utilisateur(%Utilisateur{} = utilisateur) do
    Repo.delete(utilisateur)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking utilisateur changes.

  ## Examples

      iex> change_utilisateur(utilisateur)
      %Ecto.Changeset{data: %Utilisateur{}}

  """
  def change_utilisateur(%Utilisateur{} = utilisateur, attrs \\ %{}) do
    Utilisateur.changeset(utilisateur, attrs)
  end

  alias Backend.Accounts.Etudiant

  @doc """
  Returns the list of etudiants.

  ## Examples

      iex> list_etudiants()
      [%Etudiant{}, ...]

  """
  def list_etudiants do
    Repo.all(Etudiant)
  end

  @doc """
  Gets a single etudiant.

  Raises `Ecto.NoResultsError` if the Etudiant does not exist.

  ## Examples

      iex> get_etudiant!(123)
      %Etudiant{}

      iex> get_etudiant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_etudiant!(id), do: Repo.get!(Etudiant, id)

  def get_etudiant_by_utilisateur_id(utilisateur_id) do
    Repo.get_by(Etudiant, utilisateur_id: utilisateur_id)
  end

  @doc """
  Creates a etudiant.

  ## Examples

      iex> create_etudiant(%{field: value})
      {:ok, %Etudiant{}}

      iex> create_etudiant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_etudiant(attrs, user_id) do
    # Extract group code sent by the frontend (e.g. "A1", "A2") before converting keys
    groupe_code = Map.get(attrs, "groupe") || Map.get(attrs, :groupe)

    # Resolve group code to a groupe_id by looking up the DB
    groupe =
      if groupe_code && to_string(groupe_code) != "" do
        code = to_string(groupe_code)
        # Try exact match on code_groupes first, then fall back to libele_groupes
        case Repo.get_by(Backend.Academics.Groupe, code_groupes: code) do
          nil -> Repo.get_by(Backend.Academics.Groupe, libele_groupes: code)
          g -> g
        end
      else
        nil
      end

    attrs =
      attrs
      |> Map.put(:utilisateur_id, user_id)
      |> Map.delete(:groupe)
      |> Map.delete("groupe")
      |> Enum.into(%{}, fn {k, v} -> {String.to_atom(to_string(k)), v} end)

    # Attach groupe_id only when a matching group was found in the DB
    attrs = if groupe, do: Map.put(attrs, :groupe_id, groupe.id), else: attrs

    Repo.transaction(fn ->
      %Etudiant{}
      |> Etudiant.changeset(attrs)
      |> Repo.insert()
      |> case do
        {:ok, etudiant} -> etudiant
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a etudiant.

  ## Examples

      iex> update_etudiant(etudiant, %{field: new_value})
      {:ok, %Etudiant{}}

      iex> update_etudiant(etudiant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_etudiant(%Etudiant{} = etudiant, attrs) do
    etudiant
    |> Etudiant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a etudiant.

  ## Examples

      iex> delete_etudiant(etudiant)
      {:ok, %Etudiant{}}

      iex> delete_etudiant(etudiant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_etudiant(%Etudiant{} = etudiant) do
    Repo.delete(etudiant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking etudiant changes.

  ## Examples

      iex> change_etudiant(etudiant)
      %Ecto.Changeset{data: %Etudiant{}}

  """
  def change_etudiant(%Etudiant{} = etudiant, attrs \\ %{}) do
    Etudiant.changeset(etudiant, attrs)
  end

  alias Backend.Accounts.Professeur

  @doc """
  Returns the list of professeurs.

  ## Examples

      iex> list_professeurs()
      [%Professeur{}, ...]

  """
  def list_professeurs do
    Repo.all(Professeur)
  end

  @doc """
  Gets a single professeur.

  Raises `Ecto.NoResultsError` if the Professeur does not exist.

  ## Examples

      iex> get_professeur!(123)
      %Professeur{}

      iex> get_professeur!(456)
      ** (Ecto.NoResultsError)

  """
  def get_professeur!(id), do: Repo.get!(Professeur, id)

  def get_professeur_by_utilisateur_id(utilisateur_id) do
    Repo.get_by(Professeur, utilisateur_id: utilisateur_id)
  end

  @doc """
  Creates a professeur.

  ## Examples

      iex> create_professeur(%{field: value})
      {:ok, %Professeur{}}

      iex> create_professeur(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_professeur(attrs, user_id) do
    attrs =
      attrs
      |> Map.put(:utilisateur_id, user_id)
      |> Enum.into(%{}, fn {k, v} -> {String.to_atom(to_string(k)), v} end)

    Repo.transaction(fn ->
      case Professeur.changeset(%Professeur{}, attrs) |> Repo.insert() do
        {:ok, professeur} -> professeur
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a professeur.

  ## Examples

      iex> update_professeur(professeur, %{field: new_value})
      {:ok, %Professeur{}}

      iex> update_professeur(professeur, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_professeur(%Professeur{} = professeur, attrs) do
    professeur
    |> Professeur.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a professeur.

  ## Examples

      iex> delete_professeur(professeur)
      {:ok, %Professeur{}}

      iex> delete_professeur(professeur)
      {:error, %Ecto.Changeset{}}

  """
  def delete_professeur(%Professeur{} = professeur) do
    Repo.delete(professeur)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking professeur changes.

  ## Examples

      iex> change_professeur(professeur)
      %Ecto.Changeset{data: %Professeur{}}

  """
  def change_professeur(%Professeur{} = professeur, attrs \\ %{}) do
    Professeur.changeset(professeur, attrs)
  end

  alias Backend.Accounts.Administration

  @doc """
  Returns the list of administration.

  ## Examples

      iex> list_administration()
      [%Administration{}, ...]

  """
  def list_administration do
    Repo.all(Administration)
  end

  @doc """
  Gets a single administration.

  Raises `Ecto.NoResultsError` if the Administration does not exist.

  ## Examples

      iex> get_administration!(123)
      %Administration{}

      iex> get_administration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_administration!(id), do: Repo.get!(Administration, id)

  @doc """
  Creates a administration.

  ## Examples

      iex> create_administration(%{field: value})
      {:ok, %Administration{}}

      iex> create_administration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_administration(attrs \\ %{}) do
    %Administration{}
    |> Administration.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a administration.

  ## Examples

      iex> update_administration(administration, %{field: new_value})
      {:ok, %Administration{}}

      iex> update_administration(administration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_administration(%Administration{} = administration, attrs) do
    administration
    |> Administration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a administration.

  ## Examples

      iex> delete_administration(administration)
      {:ok, %Administration{}}

      iex> delete_administration(administration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_administration(%Administration{} = administration) do
    Repo.delete(administration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking administration changes.

  ## Examples

      iex> change_administration(administration)
      %Ecto.Changeset{data: %Administration{}}

  """
  def change_administration(%Administration{} = administration, attrs \\ %{}) do
    Administration.changeset(administration, attrs)
  end

  @doc """
  Returns the list of students for a professeur based on their taught modules.

  ## Examples

      iex> list_students_for_professeur(professeur_id)
      [%Etudiant{}, ...]

  """
  def list_students_for_professeur(professeur_id) do
    from(e in Etudiant,
      join: g in assoc(e, :groupe),
      join: m in assoc(g, :modules),
      join: en in assoc(m, :professeurs),
      where: en.id == ^professeur_id,
      where:
        not fragment(
          "EXISTS (SELECT 1 FROM professeur_student_exclusions WHERE professeur_id = ? AND etudiant_id = ?)",
          ^professeur_id,
          e.id
        ),
      distinct: true,
      preload: [:groupe, :utilisateur]
    )
    |> Repo.all()
  end

  def delete_student_for_professeur(professeur_id, etudiant_id) do
    students = list_students_for_professeur(professeur_id)

    case Enum.find(students, fn s -> s.id == etudiant_id end) do
      nil ->
        {:error, "Étudiant introuvable pour ce professeur"}

      student ->
        # 1. Add exclusion so the student no longer appears in this professor's list
        Ecto.Adapters.SQL.query(
          Repo,
          "INSERT INTO professeur_student_exclusions (professeur_id, etudiant_id, inserted_at, updated_at) VALUES ($1, $2, NOW(), NOW()) ON CONFLICT (professeur_id, etudiant_id) DO NOTHING",
          [professeur_id, etudiant_id]
        )

        # 2. Detach the student's group from the professor's modules (groupes_modules)
        student = Repo.preload(student, :groupe)

        if student.groupe do
          # Find all module IDs taught by this professor
          prof_module_ids =
            from(e in Backend.Academics.Enseigner,
              where: e.professeur_id == ^professeur_id,
              select: e.module_id
            )
            |> Repo.all()

          if length(prof_module_ids) > 0 do
            # Check if other students in the same group still need these modules
            # (i.e., other students in this group that are NOT excluded for this professor)
            other_students_in_group =
              from(e in Etudiant,
                where: e.groupe_id == ^student.groupe.id and e.id != ^etudiant_id,
                where:
                  not fragment(
                    "EXISTS (SELECT 1 FROM professeur_student_exclusions WHERE professeur_id = ? AND etudiant_id = ?)",
                    ^professeur_id,
                    e.id
                  ),
                select: e.id
              )
              |> Repo.all()

            # Only detach the group-module link if no other active students remain in the group
            if length(other_students_in_group) == 0 do
              Enum.each(prof_module_ids, fn module_id ->
                Ecto.Adapters.SQL.query(
                  Repo,
                  "DELETE FROM groupes_modules WHERE groupe_id = $1 AND module_id = $2",
                  [student.groupe.id, module_id]
                )
              end)
            end
          end
        end
        # 3. Delete all grades assigned by this professor for this student
        from(g in Backend.Academics.Grade,
          where: g.etudiant_id == ^etudiant_id and g.professeur_id == ^professeur_id
        )
        |> Repo.delete_all()

        {:ok, :deleted}
    end
  end

  def search_students_by_email(email_query) do
    from(e in Etudiant,
      join: u in assoc(e, :utilisateur),
      where: ilike(u.email_utilisateurs, ^"%#{email_query}%"),
      preload: [:utilisateur, :groupe]
    )
    |> Repo.all()
  end

  def attach_student_to_module(etudiant_id, module_id, professeur_id) do
    # Clear any previous exclusion so the student appears again
    Ecto.Adapters.SQL.query!(
      Repo,
      "DELETE FROM professeur_student_exclusions WHERE professeur_id = $1 AND etudiant_id = $2",
      [professeur_id, etudiant_id]
    )

    # Check if student exists and preload their group
    student = Repo.get(Etudiant, etudiant_id)

    if is_nil(student) do
      {:error, "Étudiant introuvable"}
    else
      student = Repo.preload(student, :groupe)

      # Check if module exists
      case Repo.get(Backend.Academics.Module, module_id) do
        nil ->
          {:error, "Module introuvable"}

        _module ->
          groupe =
            if is_nil(student.groupe) do
              # Create or find default group "A" if student has no group
              g =
                case Repo.get_by(Backend.Academics.Groupe, libele_groupes: "A") do
                  nil ->
                    %Backend.Academics.Groupe{libele_groupes: "A", code_groupes: "GRP-A"}
                    |> Repo.insert!()
                  g -> g
                end

              # Assign student to this group
              student |> Etudiant.changeset(%{groupe_id: g.id}) |> Repo.update!()
              g
            else
              student.groupe
            end

          # Check if the module is already attached to the student's group
          existing =
            Repo.one(
              from(gm in "groupes_modules",
                where: gm.groupe_id == ^groupe.id and gm.module_id == ^module_id,
                select: 1
              )
            )

          case existing do
            nil ->
              # Module not attached yet, insert it using raw SQL
              case Ecto.Adapters.SQL.query(
                     Repo,
                     "INSERT INTO groupes_modules (groupe_id, module_id) VALUES ($1, $2) ON CONFLICT (groupe_id, module_id) DO NOTHING",
                     [groupe.id, module_id]
                   ) do
                {:ok, _} ->
                  {:ok,
                   %{
                     student_id: etudiant_id,
                     module_id: module_id,
                     group_id: groupe.id,
                     message: "Étudiant rattaché au module avec succès"
                   }}

                {:error, reason} ->
                  {:error, "Impossible de rattacher le module: #{inspect(reason)}"}
              end

            _existing ->
                # Module already attached
                {:ok,
                 %{
                   student_id: etudiant_id,
                   module_id: module_id,
                   group_id: groupe.id,
                   message: "Module déjà rattaché à ce groupe"
                 }}
            end
      end
    end
  end
end
