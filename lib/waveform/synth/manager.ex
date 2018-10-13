defmodule Waveform.Synth.Manager do
  use GenServer

  @me __MODULE__

  @synth_names %{
    beep: 'sonic-pi-beep',
    bnoise: 'sonic-pi-bnoise',
    chipbass: 'sonic-pi-chipbass',
    chiplead: 'sonic-pi-chiplead',
    chipnoise: 'sonic-pi-chipnoise',
    cnoise: 'sonic-pi-cnoise',
    dark_ambience: 'sonic-pi-dark_ambience',
    dpulse: 'sonic-pi-dpulse',
    dsaw: 'sonic-pi-dsaw',
    dtri: 'sonic-pi-dtri',
    dull_bell: 'sonic-pi-dull_bell',
    fm: 'sonic-pi-fm',
    gnoise: 'sonic-pi-gnoise',
    growl: 'sonic-pi-growl',
    hollow: 'sonic-pi-hollow',
    hoover: 'sonic-pi-hoover',
    mod_dsaw: 'sonic-pi-mod_dsaw',
    mod_fm: 'sonic-pi-mod_fm',
    mod_pulse: 'sonic-pi-mod_pulse',
    mod_saw: 'sonic-pi-mod_saw',
    mod_sine: 'sonic-pi-mod_sine',
    mod_tri: 'sonic-pi-mod_tri',
    noise: 'sonic-pi-noise',
    piano: 'sonic-pi-piano',
    pluck: 'sonic-pi-pluck',
    pnoise: 'sonic-pi-pnoise',
    pretty_bell: 'sonic-pi-pretty_bell',
    prophet: 'sonic-pi-prophet',
    pulse: 'sonic-pi-pulse',
    saw: 'sonic-pi-saw',
    square: 'sonic-pi-square',
    subpulse: 'sonic-pi-subpulse',
    supersaw: 'sonic-pi-supersaw',
    synth_violin: 'sonic-pi-synth_violin',
    tb303: 'sonic-pi-tb303',
    tech_saws: 'sonic-pi-tech_saws',
    tri: 'sonic-pi-tri',
    zawa: 'sonic-pi-zawa'
  }
  @default_synth_name :prophet
  @default_synth @synth_names[:prophet]

  defmodule State do
    defstruct(user_defined: %{}, current: %{})
  end

  def create_synth(name, bytes) do
    GenServer.call(@me, {:create, name, bytes})
  end

  def use_last_synth(pid) do
    GenServer.call(@me, {:rollback, pid})
  end

  def reset() do
    GenServer.call(@me, {:reset})
  end

  def set_current_synth(pid, next) do
    GenServer.call(@me, {:set_current, pid, next})
  end

  def current_synth_name(pid) do
    current_name = GenServer.call(@me, {:current, pid})

    {name, _} =
      Enum.find(@synth_names, fn {_key, value} ->
        value == current_name
      end)

    name
  end

  def current_synth_value(pid) do
    GenServer.call(@me, {:current, pid})
  end

  def start_link(_state) do
    GenServer.start_link(@me, default_state(), name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:set_current, pid, new}, _from, %State{user_defined: ud, current: current} = state) do
    name = ud[new] || @synth_names[new]

    if name do
      pid_synths = current[pid] || []
      current = Map.put(current, pid, [name | pid_synths])
      {:reply, name, %{state | current: current}}
    else
      {:reply, nil, state}
    end
  end

  def handle_call({:create, name, bytes}, _from, %State{user_defined: ud} = state) do
    OSC.send_synthdef(bytes)
    %{ state | user_defined: Map.put(ud, :"#{Recase.to_snake(name)}", name) }
  end

  def handle_call({:current, pid}, _from, state) do
    current =
      case state.current[pid] do
        [current | _] -> current
        [] -> @default_synth
        nil -> @default_synth
      end

    {:reply, current, state}
  end

  def handle_call({:reset}, _from, _state) do
    {:reply, :ok, default_state()}
  end

  def handle_call({:rollback, pid}, _from, %State{current: current} = state) do
    case current[pid] do
      [h | t] ->
        current = Map.put(current, pid, t)
        {:reply, h, %{state | current: current}}

      [] ->
        {:reply, nil, state}

      nil ->
        {:reply, nil, state}
    end
  end

  defp default_state do
    %State{current: %{}}
  end
end
