defmodule Singleton do
  @moduledoc """
  Documentation for Singleton.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Singleton.hello
      :world

  """
  def s1_start do
    Singleton.S1.start_timer()
  end

  def s1_start_stop do
    Singleton.S1.start_timer()
    Singleton.S1.stop_timer()
  end

  def s2_start do
    # Start the Singleton process if not already started
    case Singleton.S2.start_link() do
      %{msg: _msg, timer_pid: _timer_pid} ->
        Singleton.S2.start_timer()

      {:error, {:already_started, _singleton_pid}} ->
        Singleton.S2.start_timer()
    end

    # Could also write without issue.
    # Singleton.S2.start_link()
    # Singleton.S2.start_timer()
  end

  def s2_start_stop do
    # Since it is a singleton it can be started anywhere.
    Singleton.S2.start()
    Singleton.S2.start_timer()
    Singleton.S2.stop_timer()
  end

end
