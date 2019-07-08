defmodule Agala.Provider.Viber.Helpers.Send do
  @viber_auth_header_name "X-Viber-Auth-Token"
  @send_message_url "https://chatapi.viber.com/pa/send_message"

  defp bootstrap(bot) do
    case bot.config() do
      %{bot: ^bot} = bot_params ->
        get_bot_params(bot_params)

      error ->
        error
    end
  end

  defp bootstrap(_bot_, bot_params), do: get_bot_params(bot_params)

  defp get_bot_params(bot_params) do
    {:ok,
     Map.put(bot_params, :private, %{
       http_opts:
         (get_in(bot_params, [:provider_params, :hackney_opts]) || [])
         |> Keyword.put(
           :recv_timeout,
           get_in(bot_params, [:provider_params, :response_timeout]) || 5000
         )
     })}
  end

  defp body_encode(body) when is_bitstring(body), do: body
  defp body_encode(body) when is_map(body), do: body |> Jason.encode!()
  defp body_encode(_), do: ""

  def perform_request(%Agala.Conn{
        responser: bot,
        response: %{method: method, payload: %{body: body, url_path: url_path} = payload},
        private: private
      }) do
    {:ok, bot_params} =
      case private do
        %{agala_bot_config: agala_bot_config} -> bootstrap(bot, agala_bot_config)
        _res -> bootstrap(bot)
      end

    case HTTPoison.request(
           method,
           @send_message_url,
           body_encode(body),
           request_headers(bot_params.provider_params.app_secret),
           Map.get(payload, :http_opts) || Map.get(bot_params.private, :http_opts) || []
         ) do
      {:ok, %HTTPoison.Response{body: body}} -> {:ok, Jason.decode!(body)}
      error -> error
    end
  end

  defp request_headers(app_secret) do
    [
      {"Content-Type", "application/json"},
      {@viber_auth_header_name, app_secret}
    ]
  end

  @spec message(conn :: Agala.Conn.t(), recipient_id :: String.t(), text :: String.t()) ::
          Agala.Conn.t()
  def message(conn, receiver_id, text) do
    Map.put(conn, :response, %{
      method: :post,
      payload: %{
        body: %{receiver: receiver_id, type: "text", text: text}
      }
    })
    |> perform_request()
  end
end
