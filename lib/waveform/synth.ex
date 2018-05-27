defmodule Waveform.Synth do
  alias Waveform.Music, as: Music

  def play(note) when is_atom(note), do: play(Music.to_midi(note))
  def play(note) when is_number(note) do
    node_id = Waveform.OSC.Node.ID.next_id
    group_id = 0
    synth_name = 'sonic-pi-prophet'
    add_action = 0
    group_id = 0

    # http://doc.sccode.org/Reference/Server-Command-Reference.html#/s_new
    Waveform.OSC.send_command(['/s_new', synth_name, node_id, add_action, group_id, :note, note])
  end
end
