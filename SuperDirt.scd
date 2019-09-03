SuperDirt.start();

(
MIDIClient.init;
~midiOut = MIDIOut.newByName("IAC Driver", "Bus 1");
~dirt.soundLibrary.addMIDI(\piano, ~midiOut);
~midiOut.latency = 0.05;
)

(
~midiOut2 = MIDIOut.newByName("MocoLUFA", "MocoLUFA");
~dirt.soundLibrary.addMIDI(\sole, ~midiOut2);
~midiOut2.latency = 0.05;
)
