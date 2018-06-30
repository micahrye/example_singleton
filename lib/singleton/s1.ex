defmodule Singleton.S1 do

  use GenServer
  require Logger

  @delay 6_000

  def start_timer() do
    Logger.info("Start request received")
    # Check if timer is already running.
    if GenServer.whereis(__MODULE__) == nil do
      start_link()
      Logger.info("Fallback timer started")
      :ok
    else
      Logger.warn(" Timer already running")
      :error
    end
  end

  def stop_timer() do
    Logger.info("Stop request received")

    unless GenServer.whereis(__MODULE__) == nil do
      Process.send(__MODULE__, :stop, [])
      :ok
    else
      :error
    end
  end

  def start_link() do
    {:ok, pid} = GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_ignore) do
    timer_ref = schedule_work()
    state = {timer_ref, "Just a string"}
    {:ok, state}
  end

  def handle_info(:time_up, state) do
    Logger.info("Timer expired.")
    Logger.info("Reset network config.")
    # Stop the process.
    GenServer.stop(__MODULE__)
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    Logger.info("Timer stopped. Glad things worked out :)")
    # 1st element of the state tuple has the timer reference
    Process.cancel_timer(elem(state, 0))
    # Stop the process.
    GenServer.stop(__MODULE__)
    {:noreply, nil}
  end

  defp schedule_work() do
    # in 1 minute
    Logger.info("")
    Process.send_after(__MODULE__, :time_up, @delay)
  end
end
