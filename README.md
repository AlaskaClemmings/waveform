# Waveform

Supercollider live coding with Elixir

## Installation

Install supercollider:

`brew install supercollider`

or point to the `sclang` executable with the `SCLANG_PATH` environment variable

Download repo and: 

`iex -S mix`

```elixir
play chord(:d4, :minor)

ii_V_I = [chord(:d4, :minor7), chord(:g5, :dominant7), chord(:c5, :major7)]

progression = fn -> Enum.map(Stream.cycle(ii_V_I), fn c ->
    play c
    Process.sleep 2
  end)
end

pid = spawn progression

Process.exit(pid, :kill)
```


