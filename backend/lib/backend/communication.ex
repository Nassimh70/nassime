defmodule Backend.Communication do
  @moduledoc """
  The Communication context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Communication.Annonce

  @doc """
  Returns the list of annonces.

  ## Examples

      iex> list_annonces()
      [%Annonce{}, ...]

  """
  def list_annonces do
    Repo.all(Annonce) |> Repo.preload(utilisateur: :role)
  end

  @doc """
  Gets a single annonce.

  Raises `Ecto.NoResultsError` if the Annonce does not exist.

  ## Examples

      iex> get_annonce!(123)
      %Annonce{}

      iex> get_annonce!(456)
      ** (Ecto.NoResultsError)

  """
  def get_annonce!(id), do: Repo.get!(Annonce, id) |> Repo.preload(utilisateur: :role)

  @doc """
  Creates a annonce.

  ## Examples

      iex> create_annonce(%{field: value})
      {:ok, %Annonce{}}

      iex> create_annonce(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_annonce(attrs \\ %{}) do
    %Annonce{}
    |> Annonce.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a annonce.

  ## Examples

      iex> update_annonce(annonce, %{field: new_value})
      {:ok, %Annonce{}}

      iex> update_annonce(annonce, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_annonce(%Annonce{} = annonce, attrs) do
    annonce
    |> Annonce.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a annonce.

  ## Examples

      iex> delete_annonce(annonce)
      {:ok, %Annonce{}}

      iex> delete_annonce(annonce)
      {:error, %Ecto.Changeset{}}

  """
  def delete_annonce(%Annonce{} = annonce) do
    Repo.delete(annonce)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking annonce changes.

  ## Examples

      iex> change_annonce(annonce)
      %Ecto.Changeset{data: %Annonce{}}

  """
  def change_annonce(%Annonce{} = annonce, attrs \\ %{}) do
    Annonce.changeset(annonce, attrs)
  end



  alias Backend.Communication.Souggestion

  @doc """
  Returns the list of souggestions.

  ## Examples

      iex> list_souggestions()
      [%Souggestion{}, ...]

  """
  def list_souggestions do
    Repo.all(Souggestion) |> Repo.preload(etudiant: :utilisateur)
  end

  @doc """
  Gets a single souggestion.

  Raises `Ecto.NoResultsError` if the Souggestion does not exist.

  ## Examples

      iex> get_souggestion!(123)
      %Souggestion{}

      iex> get_souggestion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_souggestion!(id), do: Repo.get!(Souggestion, id) |> Repo.preload(etudiant: :utilisateur)

  @doc """
  Creates a souggestion.

  ## Examples

      iex> create_souggestion(%{field: value})
      {:ok, %Souggestion{}}

      iex> create_souggestion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_souggestion(attrs \\ %{}) do
    %Souggestion{}
    |> Souggestion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a souggestion.

  ## Examples

      iex> update_souggestion(souggestion, %{field: new_value})
      {:ok, %Souggestion{}}

      iex> update_souggestion(souggestion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_souggestion(%Souggestion{} = souggestion, attrs) do
    souggestion
    |> Souggestion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a souggestion.

  ## Examples

      iex> delete_souggestion(souggestion)
      {:ok, %Souggestion{}}

      iex> delete_souggestion(souggestion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_souggestion(%Souggestion{} = souggestion) do
    Repo.delete(souggestion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking souggestion changes.

  ## Examples

      iex> change_souggestion(souggestion)
      %Ecto.Changeset{data: %Souggestion{}}

  """
  def change_souggestion(%Souggestion{} = souggestion, attrs \\ %{}) do
    Souggestion.changeset(souggestion, attrs)
  end

  def vote_souggestion(%Souggestion{} = souggestion, utilisateur_id, vote_type) do
    alias Backend.Communication.SuggestionVote

    vote = String.downcase(to_string(vote_type || ""))

    case vote do
      v when v in ["like", "dislike"] ->
        existing = Repo.get_by(SuggestionVote, utilisateur_id: utilisateur_id, souggestion_id: souggestion.id)

        cond do
          # No existing vote — create one
          is_nil(existing) ->
            %SuggestionVote{}
            |> SuggestionVote.changeset(%{vote_type: v, utilisateur_id: utilisateur_id, souggestion_id: souggestion.id})
            |> Repo.insert()

          # Same vote type — toggle off (remove vote)
          existing.vote_type == v ->
            Repo.delete(existing)

          # Different vote type — switch (e.g. like -> dislike)
          true ->
            existing
            |> SuggestionVote.changeset(%{vote_type: v})
            |> Repo.update()
        end

        # Recalculate counts from the votes table
        recalculate_souggestion_votes(souggestion)

      _ ->
        {:error, "Vote invalide. Utilisez like ou dislike."}
    end
  end

  def recalculate_souggestion_votes(%Souggestion{} = souggestion) do
    alias Backend.Communication.SuggestionVote

    likes =
      from(v in SuggestionVote,
        where: v.souggestion_id == ^souggestion.id and v.vote_type == "like",
        select: count(v.id)
      )
      |> Repo.one() || 0

    dislikes =
      from(v in SuggestionVote,
        where: v.souggestion_id == ^souggestion.id and v.vote_type == "dislike",
        select: count(v.id)
      )
      |> Repo.one() || 0

    update_souggestion(souggestion, %{"like_souggestion" => likes, "dislike_souggestion" => dislikes})
  end

  def get_user_vote_for_souggestion(souggestion_id, utilisateur_id) do
    alias Backend.Communication.SuggestionVote
    Repo.get_by(SuggestionVote, souggestion_id: souggestion_id, utilisateur_id: utilisateur_id)
  end
end
