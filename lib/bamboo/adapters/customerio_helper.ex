defmodule Bamboo.CustomerIOHelper do
  @moduledoc """
  Functions to attach data for CustomerIO
  """

  alias Bamboo.Email

  @doc """
  Set the transactional message ID to use for the email contents.

  ## Example

      email
      |> message_id("2")
  """
  def put_message_id(email, message_id) do
    Email.put_private(email, :message_id, message_id)
  end

  @doc """
  Set the transactional message customer ID identifier.

  ## Example

      email
      |> identifiers_id("1234")
  """
  def put_identifiers_id(email, id) do
    Email.put_private(email, :identifiers_id, id)
  end

  @doc """
  Set the transactional message customer email identifier.

  ## Example

      email
      |> identifiers_email("me@jtsmills.com")
  """
  def put_identifiers_email(email, address) do
    Email.put_private(email, :identifiers_email, address)
  end

  @doc """
  Set the transactional message customer CIO identifier.

  ## Example

      email
      |> identifiers_cio("12345")
  """
  def put_identifiers_cio(email, cio) do
    Email.put_private(email, :identifiers_cio, cio)
  end

  @doc """
  Add a transactional variables trigger data.

  This is used to customize an email and fill variables in the template.

  ## Example

      email
      |> put_var("name", "Justin")
  """
  def add_var(email, key, value) do
    vars = Map.get(email.private, :vars, %{})
    Email.put_private(email, :vars, Map.put(vars, key, value))
  end
end
