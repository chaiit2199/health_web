defmodule KPartners.Rpc.Macros do
  @timeout 10_000

  @doc """
  gen_call(name, worker_fn, module, remote_fn)

  Example: gen_call(
    :gen_otp,
    :k_partners,
    KSalesApi.TemporaryPartners,
    :gen_otp
  )

  Example: gen_call(
    :gen_otp,
    KPartners.Worker.CallWorker.node(:k_partners),
    KSalesApi.TemporaryPartners,
    :gen_otp
  )
  """
  defmacro gen_call(name, atom, module, remote_fn) when is_atom(atom) do
    quote do
      def unquote(name)(params \\ []) do
        params =
          cond do
            is_map(params) -> [Map.to_list(params)]
            is_list(params) -> params
            true -> [params]
          end

        :rpc.call(
          KPartners.Worker.CallWorker.node(unquote(atom)),
          unquote(module),
          unquote(remote_fn),
          [params],
          unquote(Application.get_env(:k_partners, :rpc_timeout, @timeout))
        )
      end
    end
  end

  defmacro gen_call(name, worker_fn, module, remote_fn) do
    quote do
      def unquote(name)(params \\ []) do
        params =
          cond do
            is_map(params) -> [Map.to_list(params)]
            is_list(params) -> params
            true -> [params]
          end

        :rpc.call(
          unquote(worker_fn),
          unquote(module),
          unquote(remote_fn),
          [params],
          unquote(Application.get_env(:k_partners, :rpc_timeout, @timeout))
        )
      end
    end
  end
end
