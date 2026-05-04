defmodule Backend.Auth.PasswordManager do
  @moduledoc """
  Gestionnaire de mots de passe indépendant.
  Utilise SHA256 pour le développement (non sécurisé).
  Pour la production, installer bcrypt_elixir ou argon2_elixir et adapter ce module.
  """

  def hash_pwd_salt(password) do
    # Format: "v1_" + SHA256 du mot de passe
    # NB: À NE JAMAIS utiliser en production telle quelle !
    "v1_" <> Base.encode64(:crypto.hash(:sha256, password))
  end

  def verify_pass(password, hash) do
    case hash do
      "v1_" <> encoded_hash ->
        Base.encode64(:crypto.hash(:sha256, password)) == encoded_hash
      _ ->
        false
    end
  end

  def no_user_verify do
    # Opération factice pour éviter les timing attacks
    :timer.sleep(10)
  end
end
