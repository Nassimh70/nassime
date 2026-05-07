# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Backend.Repo.insert!(%Backend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Create an admin user if it doesn't exist
alias Backend.Repo
alias Backend.Accounts
alias Backend.Academics

admin_email = "admin@univ-bejaia.dz"

unless Accounts.get_utilisateur_by_email(admin_email) do
  IO.puts("Creating default admin: #{admin_email}")

  admin_attrs = %{
    "email_utilisateurs" => admin_email,
    "password" => "Password123!",
    "prenom_utilisateurs" => "Admin",
    "nom_utilisateurs" => "Root",
    "role" => "admin"
  }

  case Accounts.create_utilisateur(admin_attrs) do
    {:ok, _user} -> IO.puts("Admin created successfully")
    {:error, changeset} -> IO.inspect(changeset, label: "Failed to create admin")
  end
else
  IO.puts("Admin already exists: #{admin_email}")
end

# Create test professor
prof_email = "prof1@univ-bejaia.dz"

unless Accounts.get_utilisateur_by_email(prof_email) do
  IO.puts("Creating test professor: #{prof_email}")

  prof_attrs = %{
    "email_utilisateurs" => prof_email,
    "password" => "Password123!",
    "prenom_utilisateurs" => "Jean",
    "nom_utilisateurs" => "Dupont",
    "role" => "professeur"
  }

  case Accounts.create_utilisateur(prof_attrs) do
    {:ok, prof_user} ->
      Accounts.create_professeur(
        %{
          grade_professeurs: "Docteur",
          telephone_professeurs: "+33123456789",
          specialite_professeurs: "Mathématiques"
        },
        prof_user.id
      )

      IO.puts("Professor created successfully")

    {:error, changeset} ->
      IO.inspect(changeset, label: "Failed to create professor")
  end
else
  IO.puts("Professor already exists: #{prof_email}")
end

# Create modules if they don't exist
math_module =
  Repo.get_by(Backend.Academics.Module, code_cours: "MATH-101") ||
    Repo.insert!(
      Backend.Academics.Module.changeset(%Backend.Academics.Module{}, %{
        code_cours: "MATH-101",
        intitule_cours: "Mathématiques Fondamentales",
        semestre_module: "S1",
        credits_module: 6,
        description_module: "Cours de mathématiques de base"
      })
    )

phys_module =
  Repo.get_by(Backend.Academics.Module, code_cours: "PHYS-101") ||
    Repo.insert!(
      Backend.Academics.Module.changeset(%Backend.Academics.Module{}, %{
        code_cours: "PHYS-101",
        intitule_cours: "Physique Classique",
        semestre_module: "S1",
        credits_module: 5,
        description_module: "Introduction à la physique classique"
      })
    )

# Create INFO3 groups if they don't exist
info3_groups = [
  %{code_groupes: "INFO3-A1", libele_groupes: "A1"},
  %{code_groupes: "INFO3-A2", libele_groupes: "A2"},
  %{code_groupes: "INFO3-A3", libele_groupes: "A3"},
  %{code_groupes: "INFO3-A4", libele_groupes: "A4"}
]

Enum.each(info3_groups, fn group_attrs ->
  Repo.get_by(Backend.Academics.Groupe, code_groupes: group_attrs.code_groupes) ||
    Repo.insert!(
      Backend.Academics.Groupe.changeset(%Backend.Academics.Groupe{}, %{
        code_groupes: group_attrs.code_groupes,
        libele_groupes: group_attrs.libele_groupes,
        annee_academique_groupes: "2025-2026",
        filier_groupe: "Informatique",
        niveau_groupe: "Licence 3"
      })
    )
end)

  student_group = Repo.get_by(Backend.Academics.Groupe, code_groupes: "INFO3-A1")

# Create test students
student_data = [
  %{email: "student1@univ-bejaia.dz", prenom: "Ahmed", nom: "Idrissi", phone: "+212612345678"},
  %{email: "student2@univ-bejaia.dz", prenom: "Fatima", nom: "Bennani", phone: "+212612345679"},
  %{email: "student3@univ-bejaia.dz", prenom: "Karim", nom: "Alami", phone: "+212612345680"}
]

students =
  Enum.map(student_data, fn data ->
    case Accounts.get_utilisateur_by_email(data.email) do
      nil ->
        {:ok, user} =
          Accounts.create_utilisateur(%{
            "email_utilisateurs" => data.email,
            "password" => "Password123!",
            "prenom_utilisateurs" => data.prenom,
            "nom_utilisateurs" => data.nom,
            "role" => "etudiant"
          })

        {:ok, etudiant} =
          Accounts.create_etudiant(
            %{
              telephone_etudiant: data.phone,
              date_naissance_etudiant: Date.new!(2005, 1, 1),
              groupe_id: student_group.id
            },
            user.id
          )
        IO.puts("Student created: #{data.email}")
        etudiant

      _existing ->
        IO.puts("Student already exists: #{data.email}")
        nil
    end
  end)
  |> Enum.filter(&(&1 != nil))

# Create grades if professor exists
case Accounts.get_utilisateur_by_email(prof_email) do
  nil ->
    IO.puts("Skipping grades - professor not found")

  prof_user ->
    prof = Accounts.get_professeur_by_utilisateur_id(prof_user.id)

    if prof do
      Enum.each(students, fn etudiant ->
        if etudiant do
          # Create grade for MATH module
          Repo.insert_or_update!(
            Backend.Academics.Grade.changeset(%Backend.Academics.Grade{}, %{
              note_td_tp: Decimal.new("16.5"),
              note_examen: Decimal.new("14.0"),
              etudiant_id: etudiant.id,
              module_id: math_module.id,
              professeur_id: prof.id
            })
          )
        end
      end)

      IO.puts("Test grades created successfully")
    end
end

IO.puts("Seed data completed!")
