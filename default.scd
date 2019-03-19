(
// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html
//s.options.outDevice = "Soundflower (64ch)";
//s.options.inDevice = "Soundflower (64ch)";
s.options.numBuffers = 1024 * 16; // increase this if you need to load more samples
s.options.memSize = 8192 * 16; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numOutputBusChannels = 8; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
s.latency = 0.05; // latency controls are helpful for fixing late messages
// boot the server and start SuperDirt
s.waitForBoot {
	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
	s.sync; // wait for samples to be read
	~dirt.start(57120, [0,2,4,6,8,10,12,14]);   // start listening on port 57120, create four busses each sending audio to channel 0
	// ---------------------------------------------------------------------- //
	// -- POINT THE FOLLOWING LINE AT THE SAMPLES DIRECTORY IN THIS FOLDER -- //
	// ---------------------------------------------------------------------- //
	~dirt.loadSoundFiles("~/Downloads/tidal_midi_harmony_tutorial/samples/*");
	// ---------------------------------------------------------------------- //
	// ------------------------------- OK? ------------- (synths below) ----- //
	// ---------------------------------------------------------------------- //
	SynthDef(\donk, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0], [0.01, 1], curve:-3);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		var modulator = (SinOsc.ar(freq*[1.0001,0.9999]*abs(speed))*2).tanh;
		var carrier = (SinOsc.ar((freq/4)+(modulator*1000*envGen))*0.8).tanh;
		var sound = DirtPan.ar(carrier, ~dirt.numChannels, pan, envGen);
		Out.ar(out, sound);
	}).add;
	SynthDef(\wub, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0],[1,5], curve:2);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		// --- //
		var speedFreq = freq*abs(speed)/4;
		var mod = Latch.ar((SinOsc.ar(speedFreq*[7,11,13,5])*5).tanh*2000*envGen, Saw.ar(21000*envGen));
		var car =  Latch.ar(((SinOsc.ar(speedFreq+mod)*10)+(SinOsc.ar(speedFreq)!2)).tanh, Saw.ar(21000*envGen));
		var sound = LPF.ar(car, DC.ar(20000)*envGen+DC.ar(10))*(-11.dbamp);
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	SynthDef(\sawpluck, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		var sound = Saw.ar(freq*abs(speed));
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	SynthDef(\vibsawpluck, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		var sound = Saw.ar(freq*abs(speed)+(SinOsc.ar(10)*(freq*0.06)*line*line));
		sound = RLPF.ar(sound, Clip.ar(envGen*freq*48, 0, 20000), 0.5);
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	(
		SynthDef(\plucklead, {
			|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
			var line = Line.ar(begin, end, sustain, doneAction:2);
			var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);
			var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
			var speedFreq = freq*abs(speed);
			var pulseLfo = SinOsc.ar(Rand(-1,1));
			var sound = RLPF.ar(Pulse.ar([speedFreq*Rand(0.99,1.01)*2,speedFreq*Rand(0.99,1.01)*2],pulseLfo)*0.5+Saw.ar(speedFreq), (20000*(envGen**2.8))+DC.ar(10), 0.5);
			Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
		}).add;
	);
	SynthDef(\wob, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0],[1, 1]);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		// --- //
		var speedFreq = freq*abs(speed)/4;
		var mod = Latch.ar((SinOsc.ar(speedFreq*[7,11,13,5])*5).tanh*2000*envGen, Saw.ar(21000*envGen));
		var car =  Latch.ar(((SinOsc.ar(speedFreq+mod)*10)+(SinOsc.ar(speedFreq)!2)).tanh, Saw.ar(21000*envGen));
		var sound = car*(-10.dbamp);
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	SynthDef(\noisebuild, {
		|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
		var line = Line.ar(begin, end, sustain, doneAction:2);
		var env = Env([0, 1, 0],[127, 1],curve:4);
		var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
		// --- //
		var sound = HPF.ar(BPF.ar(WhiteNoise.ar()*envGen, 10+(20000*envGen), 0.8), 1000);
		Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
	}).add;
	// let's set up our orbits (these first steps are just so we can redefine them on the fly if they're already there)
	~modBus.free;
	~carBus.free;
	~dirt.orbits[0].outBus = 0;
	~dirt.orbits[1].outBus = 0;
	// --- //
	~modBus = Bus.audio(s, numChannels:2); // assuming stereo, expand if needed
	~carBus = Bus.audio(s, numChannels:2);
	~dirt.orbits[0].outBus = ~modBus; // play into that bus.
	~dirt.orbits[1].outBus = ~carBus;
	(
		// effects processing on the busses
		Ndef(\x, {
			var modBus = In.ar(~modBus, 2);
			var carBus = In.ar(~carBus, 2);
			var out = modBus+carBus;
			carBus = carBus+((-7).dbamp*Compander.ar(FreeVerb.ar(carBus, 0.9), carBus, -30.dbamp, 1, 0.01, 0.01, 0.07));
			carBus = Compander.ar(carBus,carBus,-20.dbamp,1,0.5,0.01,0.35)*(-5).dbamp;
			out = Compander.ar(carBus, modBus, -30.dbamp, 1, 0.01, 0.01, 0.07)+modBus;
			out = Compander.ar(out, out, -15.dbamp, 1, 0.2)*4;
			Out.ar(0, out);
		});
	);
	(
		// here's the bit that sends MIDI data from all controllers to TidalCycles via OSC
		MIDIClient.init;
		MIDIIn.connectAll;
		~tidalSocket = NetAddr("127.0.0.1", 6010);
		~notes=[];
		MIDIFunc.cc({|val, num, chan, src| ~tidalSocket.sendMsg('/ctrl', num, val/127.0);}, nil, nil, nil);
		MIDIFunc.noteOn({|veloc, num, chan, src| ~notes=~notes.add(num); ~notes=~notes.sort({|a,b| a>b}).reverse; ~tidalSocket.sendMsg('/ctrl', "notes", format("%", ~notes-60)); ~notes.postln;});
		MIDIFunc.noteOff({|veloc, num, chan, src| ~notes=~notes.takeThese({|x| x==num}); ~tidalSocket.sendMsg('/ctrl', "notes", format("%", ~notes-60)); ~notes.postln;});
	);
};
);
