defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
  end

  pipeline :auth do
    plug(BackendWeb.Auth.Pipeline)
    plug(BackendWeb.Auth.SetAccount)
  end

  pipeline :auth_etudiant do
    plug(BackendWeb.Auth.RequireRole, ["etudiant", "delegue"])
  end

  pipeline :auth_professeur do
    plug(BackendWeb.Auth.RequireRole, ["professeur", "enseignant"])
  end

  pipeline :auth_admin do
    plug(BackendWeb.Auth.RequireRole, ["admin", "administration"])
  end

  scope "/api", BackendWeb do
    pipe_through(:api)

    post("/etudiant/register", AccountController, :create_etudiant)
    post("/professeur/register", AccountController, :create_professeur)
    post("/login", AccountController, :login)
    get("/meta", MetaController, :index)
  end

  scope "/api/auth/etudiant", BackendWeb do
    pipe_through([:api, :auth, :auth_etudiant])

    post("/souggestions", SouggestionController, :create)
    put("/souggestions/:id", SouggestionController, :update)
    delete("/souggestions/:id", SouggestionController, :delete)

    get("/modules/progress", ModuleController, :progress_for_student)
  end

  scope "/api/auth/professeur", BackendWeb do
    pipe_through([:api, :auth, :auth_professeur])

    post("/modules", ModuleController, :create)
    post("/annonces", AnnonceController, :create)
    put("/annonces/:id", AnnonceController, :update)
    delete("/annonces/:id", AnnonceController, :delete)

    get("/modules/progress", ModuleController, :professeur_progress)
    put("/modules/:module_id/progress", ModuleController, :update_course_progress)

    get("/tickets/modules", TicketController, :by_professeur_modules)

    get("/grades", GradeController, :index)
    get("/grades/module/:module_id", GradeController, :list_by_module)
    post("/grades", GradeController, :create)
    get("/grades/:id", GradeController, :show)
    put("/grades/:id", GradeController, :update)
    delete("/grades/:id", GradeController, :delete)

    get("/chapters/module/:module_id", ChapterController, :index)
    post("/chapters/module/:module_id", ChapterController, :create)
    get("/chapters/:id", ChapterController, :show)
    put("/chapters/:id", ChapterController, :update)
    delete("/chapters/:id", ChapterController, :delete)
  end

  scope "/api/auth/admin", BackendWeb do
    pipe_through([:api, :auth, :auth_admin])

    post("/tickets/:id/decide", TicketController, :decide)
    get("/tickets/stats", TicketController, :stats)
    get("/utilisateurs", AccountController, :index)
    delete("/utilisateurs/:id", AccountController, :delete_utilisateur)
    # Allow admins to manage annonces as well
    post("/annonces", AnnonceController, :create)
    put("/annonces/:id", AnnonceController, :update)
    delete("/annonces/:id", AnnonceController, :delete)
    put("/etudiants/:etudiant_id/delegate", DelegationController, :designate)
  end

  scope "/api/auth", BackendWeb do
    pipe_through([:api, :auth])

    get("/accounts/profile", AccountController, :profile)
    post("/accounts/update", AccountController, :update)
    delete("/sign_out", AccountController, :sign_out)
    get("/accounts/refresh", AccountController, :refresh_session)

    get("/notifications", NotificationController, :index)

    get("/tickets/status", TicketController, :status_mine)
    get("/tickets/stats", TicketController, :stats)
    get("/tickets", TicketController, :index)
    post("/tickets", TicketController, :create)
    get("/tickets/:id", TicketController, :show)
    put("/tickets/:id", TicketController, :update)
    delete("/tickets/:id", TicketController, :delete)
    get("/tickets/:id/comments", TicketController, :comments)
    post("/tickets/:id/comments", TicketController, :add_comment)

    get("/annonces", AnnonceController, :index)
    post("/annonces", AnnonceController, :create)
    get("/annonces/:id", AnnonceController, :show)

    get("/souggestions", SouggestionController, :index)
    get("/souggestions/:id", SouggestionController, :show)
    post("/souggestions/:id/vote", SouggestionController, :vote)

    # keep these routes authenticated; controller enforces professeur ownership
    get("/professeur/students", AccountController, :professeur_students)
    post("/professeur/students", AccountController, :professeur_create_student)
    delete("/professeur/students/:id", AccountController, :professeur_delete_student)
    get("/professeur/search-students", AccountController, :search_students)
    post("/professeur/attach-student", AccountController, :attach_student_to_module)
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through([:fetch_session, :protect_from_forgery])

      live_dashboard("/dashboard", metrics: BackendWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
