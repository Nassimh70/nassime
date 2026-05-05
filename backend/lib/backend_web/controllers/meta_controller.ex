defmodule BackendWeb.MetaController do
  use BackendWeb, :controller

  def index(conn, _params) do
    # Load real groups from DB
    groupes =
      Backend.Academics.list_groupes()
      |> Enum.map(fn g ->
        %{
          value: g.code_groupes,
          label: if(g.libele_groupes && g.libele_groupes != g.code_groupes,
            do: "#{g.libele_groupes} - #{g.code_groupes}",
            else: g.code_groupes
          )
        }
      end)

    data = %{
      groupes: groupes,
      annonce_types: [
        %{value: "info", label: "Information"},
        %{value: "cours", label: "Cours"},
        %{value: "exam", label: "Examen"},
        %{value: "autre", label: "Autre"}
      ],
      annonce_filters: [
        %{key: "all", label: "Tout"},
        %{key: "courses", label: "Cours"},
        %{key: "events", label: "Événements"}
      ],
      ticket_priorities: ["low", "medium", "high"],
      ticket_statuses: ["open", "in_progress", "closed"],
      suggestion_categories: [
        %{value: "informatique", label: "Informatique"},
        %{value: "administration", label: "Administration"},
        %{value: "infrastructure", label: "Infrastructure"}
      ],
      hero: %{
        badges: [
          %{title: "Gratuit", desc: "Accès libre"},
          %{title: "Sécurisé", desc: "Données protégées"}
        ],
        features: [
          %{title: "Support", desc: "Assistance 24/7"},
          %{title: "Cours", desc: "Ressources pédagogiques"}
        ]
      },
      footer: %{
        socials: [
          %{label: "Twitter", url: "https://twitter.com"},
          %{label: "Facebook", url: "https://facebook.com"}
        ],
        links: [
          %{label: "À propos", url: "/about"},
          %{label: "Contact", url: "/contact"}
        ]
      },
      aide: %{
        faqs: [
          %{q: "Comment créer un compte ?", a: "Cliquez sur Créer un compte."},
          %{q: "Mot de passe oublié ?", a: "Utilisez le lien Mot de passe oublié."}
        ],
        contacts: [
          %{label: "Support", value: "support@univ.example"}
        ]
      }
    }

    conn
    |> put_status(:ok)
    |> json(data)
  end
end
