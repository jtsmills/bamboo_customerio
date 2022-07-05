defmodule Bamboo.CustomerIOAdapter do
  @moduledoc """
  Sends email using Customer.io's API.

  Use this adapter to send emails through Customer.io's API.
  Requires that an API key was set in the config.

  ## Example config

      # In config/config.exs, or config.prod.exs, etc.
      config :my_app, MyApp.Mailer,
        adapter: Bamboo.CustomerIOAdapter,
        api_key: "my_api_key"

      # Define a Mailer. Maybe in lib/my_app/mailer.ex
      defmodule MyApp.Mailer do
        use Bamboo.Mailer, otp_app: :my_app
      end
  """

  @service_name "CustomerIO"
  @default_base_uri "https://api.customer.io/v1"
  @send_message_path "/send/email"
  @behaviour Bamboo.Adapter

  alias Bamboo.{Email, AdapterHelper}
  import Bamboo.ApiError

  def deliver(email, config) do
    api_key = Map.get(config, :api_key)
    body = email |> to_customerio_params |> Bamboo.json_library().encode!()
    url = [base_uri(), @send_message_path]

    case :hackney.post(url, generate_headers(api_key), body, AdapterHelper.hackney_opts(config)) do
      {:ok, status, _headers, response} when status > 299 ->
        filtered_params = body |> Bamboo.json_library().decode!() |> Map.put("key", "[FILTERED]")

        {:error, build_api_error(@service_name, response, filtered_params)}

      {:ok, status, headers, response} ->
        {:ok, %{status_code: status, headers: headers, body: response}}

      {:error, reason} ->
        {:error, build_api_error(inspect(reason))}
    end
  end

  @doc false
  def handle_config(config) do
    if config[:api_key] in [nil, ""] do
      raise_api_key_error(config)
    end

    config
  end

  @doc false
  def supports_attachments?, do: true

  defp raise_api_key_error(config) do
    raise ArgumentError, """
    There was no API key set for the CustomerIO adapter.
    * Here are the config options that were passed in:
    #{inspect(config)}
    """
  end

  defp generate_headers(api_key) do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer " <> api_key}
    ]
  end

  defp to_customerio_params(%Email{} = email) do
    %{}
    |> put_from(email)
    |> put_to(email)
    |> put_cc(email)
    |> put_bcc(email)
    |> put_subject(email)
    |> put_html_body(email)
    |> put_text_body(email)
    |> put_transactional_message_id(email)
    |> put_message_data(email)
    |> put_identifiers(email)
    |> put_attachments(email)
  end

  # https://customer.io/docs/transactional-api/#list-of-supported-parameters
  defp put_from(body, %Email{from: address}) when is_binary(address),
    do: Map.put(body, :from, address)

  defp put_from(body, %Email{from: {name, address}}) when name in [nil, "", ''],
    do: Map.put(body, :from, address)

  defp put_from(body, %Email{from: {name, address}}),
    do: Map.put(body, :from, "#{name}<#{address}>")

  defp put_to(body, %Email{to: []}), do: body

  defp put_to(body, %Email{to: to}) do
    Map.put(body, :to, to |> transform_email)
  end

  defp put_cc(body, %Email{cc: []}), do: body

  defp put_cc(body, %Email{cc: cc}) do
    Map.put(body, :cc, cc |> transform_email)
  end

  defp put_bcc(body, %Email{bcc: []}), do: body

  defp put_bcc(body, %Email{bcc: bcc}) do
    Map.put(body, :bcc, bcc |> transform_email)
  end

  defp put_subject(body, %Email{subject: nil}), do: body

  defp put_subject(body, %Email{subject: subject}), do: Map.put(body, :subject, subject)

  defp put_html_body(body, %Email{html_body: nil}), do: body

  defp put_html_body(body, %Email{html_body: html_body}),
    do: Map.put(body, "body", html_body)

  defp put_text_body(body, %Email{text_body: nil}), do: body

  defp put_text_body(body, %Email{text_body: text_body}),
    do: Map.put(body, "plaintext_body", text_body)

  defp put_transactional_message_id(body, %Email{private: %{message_id: id}}),
    do: Map.put(body, :transactional_message_id, id)

  defp put_transactional_message_id(body, _email), do: body

  defp put_message_data(body, %Email{private: %{vars: vars}}),
    do: Map.put(body, "message_data", vars)

  defp put_message_data(body, _email), do: body

  defp put_identifiers(body, %Email{private: %{identifiers_id: id}}),
    do: Map.put(body, :identifiers, %{id: id})

  defp put_identifiers(body, %Email{private: %{identifiers_email: email}}),
    do: Map.put(body, :identifiers, %{email: email})

  defp put_identifiers(body, %Email{private: %{identifiers_cio: cio_id}}),
    do: Map.put(body, :identifiers, %{cio_id: cio_id})

  defp put_attachments(body, %Email{attachments: []}), do: body

  defp put_attachments(body, %Email{attachments: attachments}) do
    encoded =
      Enum.reduce(attachments, %{}, fn attachment, acc ->
        Map.put(acc, attachment.filename, Base.encode64(attachment.data))
      end)

    Map.put(body, :attachments, encoded)
  end

  defp transform_email(list) when is_list(list) do
    list
    |> Enum.map(&transform_email/1)
    |> Enum.join(",")
  end

  defp transform_email(address) when is_binary(address), do: [address]
  defp transform_email({name, email}) when name in [nil, '', ""], do: [email]
  defp transform_email({name, email}), do: [name <> " <" <> email <> ">"]

  defp base_uri do
    Application.get_env(:bamboo, :customerio_base_uri) || @default_base_uri
  end
end
