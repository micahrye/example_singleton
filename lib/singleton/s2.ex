defmodule Singleton.S2 do
  use GenServer
  require Logger

  @delay 6_000

  def start_link() do
    # This way you can put the singleton under supervision if yuo want.
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start() do
    # This way you ths singleton is not linked to any other process and
    # outside of supervsion.
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  def start_timer() do
    GenServer.call(__MODULE__, :start_timer)
  end

  def stop_timer() do
    GenServer.cast(__MODULE__, :stop_timer)
  end

  def shutdown() do
    GenServer.cast(__MODULE__, :shutdown)
  end

  def init([]) do
    state = %{timer_pid: nil, msg: "just a string"}
    {:ok, state}
  end

  def handle_call(:start_timer, _from, state) do
    if !state.timer_pid do
      timer_pid = spawn(fn -> reset_config() end)
      Logger.info("started timer_pid = #{inspect timer_pid}")
      new_state = %{state | timer_pid: timer_pid}
      Logger.info("start_timer. GenServer = #{inspect self()}")
      {:reply, new_state, new_state}
    else
      {:reply, {:error, "Timer already running"}, state}
    end
  end

  def handle_call(:timer_up, _from, state) do
    new_state = kill_timer_pid(state)
    Logger.info("timer_up. GenServer = #{inspect self()}")
    {:reply, new_state, new_state}
  end

  def handle_cast(:stop_timer, state) do
    new_state = kill_timer_pid(state)
    Logger.info("stop_timer. GenServer = #{inspect self()}")
    {:noreply, new_state}
  end

  def handle_cast(:shutdown, state) do
    Process.exit(self(), :normal)
    {:noreply, state}
  end

  defp reset_config() do
    :timer.sleep(@delay)
    Logger.info("Reset network config.")
    GenServer.call(__MODULE__, :timer_up)
  end

  defp kill_timer_pid(state) do
    if state.timer_pid do
      timer_pid = state.timer_pid
      new_state = %{state | timer_pid: nil}
      Logger.info("killed timer_pid = #{inspect timer_pid}")
      Process.exit(timer_pid, :kill)
      new_state
    else
      Logger.info("no timer to kill")
      state
    end
  end
end
