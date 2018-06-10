defmodule MidiConversion do
  @conversions [
    {127, "G9"},
    {126, "F#9/Gb9"},
    {125, "F9"},
    {124, "E9"},
    {123, "D#9/Eb9"},
    {122, "D9"},
    {121, "C#9/Db9"},
    {120, "C9"},
    {119, "B8"},
    {118, "A#8/Bb8"},
    {117, "A8"},
    {116, "G#8/Ab8"},
    {115, "G8"},
    {114, "F#8/Gb8"},
    {113, "F8"},
    {112, "E8"},
    {111, "D#8/Eb8"},
    {110, "D8"},
    {109, "C#8/Db8"},
    {108, "C8"},
    {107, "B7"},
    {106, "A#7/Bb7"},
    {105, "A7"},
    {104, "G#7/Ab7"},
    {103, "G7"},
    {102, "F#7/Gb7"},
    {101, "F7"},
    {100, "E7"},
    {99, "D#7/Eb7"},
    {98, "D7"},
    {97, "C#7/Db7"},
    {96, "C7"},
    {95, "B6"},
    {94, "A#6/Bb6"},
    {93, "A6"},
    {92, "G#6/Ab6"},
    {91, "G6"},
    {90, "F#6/Gb6"},
    {89, "F6"},
    {88, "E6"},
    {87, "D#6/Eb6"},
    {86, "D6"},
    {85, "C#6/Db6"},
    {84, "C6"},
    {83, "B5"},
    {82, "A#5/Bb5"},
    {81, "A5"},
    {80, "G#5/Ab5"},
    {79, "G5"},
    {78, "F#5/Gb5"},
    {77, "F5"},
    {76, "E5"},
    {75, "D#5/Eb5"},
    {74, "D5"},
    {73, "C#5/Db5"},
    {72, "C5"},
    {71, "B4"},
    {70, "A#4/Bb4"},
    {69, "A4"},
    {68, "G#4/Ab4"},
    {67, "G4"},
    {66, "F#4/Gb4"},
    {65, "F4"},
    {64, "E4"},
    {63, "D#4/Eb4"},
    {62, "D4"},
    {61, "C#4/Db4"},
    {60, "C4"},
    {59, "B3"},
    {58, "A#3/Bb3"},
    {57, "A3"},
    {56, "G#3/Ab3"},
    {55, "G3"},
    {54, "F#3/Gb3"},
    {53, "F3"},
    {52, "E3"},
    {51, "D#3/Eb3"},
    {50, "D3"},
    {49, "C#3/Db3"},
    {48, "C3"},
    {47, "B2"},
    {46, "A#2/Bb2"},
    {45, "A2"},
    {44, "G#2/Ab2"},
    {43, "G2"},
    {42, "F#2/Gb2"},
    {41, "F2"},
    {40, "E2"},
    {39, "D#2/Eb2"},
    {38, "D2"},
    {37, "C#2/Db2"},
    {36, "C2"},
    {35, "B1"},
    {34, "A#1/Bb1"},
    {33, "A1"},
    {32, "G#1/Ab1"},
    {31, "G1"},
    {30, "F#1/Gb1"},
    {29, "F1"},
    {28, "E1"},
    {27, "D#1/Eb1"},
    {26, "D1"},
    {25, "C#1/Db1"},
    {24, "C1"},
    {23, "B0"},
    {22, "A#0/Bb0"},
    {21, "A0"}
  ]

  defmacro define_midi_conversions() do
    @conversions
    |> Enum.with_index()
    |> Enum.map(fn {{midi, notes}, _midi_idx} ->
      toks = String.split(notes, "/")
      no_sharp = Enum.count(toks) == 1

      toks
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.map(fn {note, note_idx} ->
        is_first = note_idx == 0
        quality = if is_first, do: :flat, else: :sharp

        quote location: :keep do
          unquote do
            if is_first do
              quote do
                unquote do
                  if no_sharp do
                    quote do
                      def to_atom(unquote(midi), :sharp), do: to_atom(unquote(midi))
                    end
                  end
                end

                def to_atom(unquote(midi)), do: to_atom(unquote(midi), :flat)
              end
            end
          end

          def to_atom(unquote(midi), unquote(quality)), do: unquote(String.to_atom(note))
          def to_midi(unquote(note |> String.to_atom())), do: unquote(midi)
          def to_midi(unquote(note |> String.downcase() |> String.to_atom())), do: unquote(midi)
        end
      end)
    end)
  end
end

defmodule Waveform.Music.Note do
  require MidiConversion

  MidiConversion.define_midi_conversions()
end
