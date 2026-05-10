defmodule BackendWeb.SpaController do
  use BackendWeb, :controller

  def index(conn, _params) do
    # Serve the Vue SPA index.html for all non-API routes
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> send_file(200, Path.join(:code.priv_dir(:backend), "static/index.html"))
  end
end
