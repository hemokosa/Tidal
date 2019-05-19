include("SuperDirt");
s.options.device_("Soundflower (2ch)");
Platform.userExtensionDir

SuperDirt.start();

MIDIClient.init;
~midiOut = MIDIOut.newByName("IAC Driver", "Bus 1");
~dirt.soundLibrary.addMIDI(\piano, ~midiOut);
~midiOut.latency = 0.05;

~dirt = SuperDirt(2, s);
~dirt.start();
~dirt.loadSoundFiles;
~dirt.start(57120, [0, 0]);

(
s.options.numBuffers = 1024 * 32;
s.options.memSize = 8192 * 32;
s.options.maxNodes = 1024 * 64;
s.options.numWireBufs = 1024 * 8;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
s.recSampleFormat = "int16";
s.recChannels = 2;

// boot the server and start SuperDirt
s.waitForBoot {
	~dirt = SuperDirt(2, s);
	~dirt.loadSoundFiles;
	s.sync;
	~dirt.start(57120, [0, 0]);
}
)

// create a proxyspace
(
p = ProxySpace.push(s);
p.fadeTime = 0.01;
p.clock = TempoClock.default;
)

// the end
p.end(30);
p.clear.pop;
p.free;

(
~raw.ar(2);
~out.ar(2);
~out.play;
~out.vol = 0.1;
)

~out.stop;

// test
~out = { Impulse.ar(0.5, 0, 0.5, 0).dup };
~out = { SinOsc.ar(441, 0, 0.1, 0).dup };


////////////////////////////
// Matrix Hamony

(
~raw = {arg dur = 10, base1 = 441, base2 = 441, level = 0.8;
		var farray1, farray2, aarray1, aarray2, parray1, parray2;
		farray1 = Control.names(\farray1).kr(Array.fill(64, 0));
		farray2 = Control.names(\farray2).kr(Array.fill(64, 0));
		aarray1 = Control.names(\aarray1).kr(Array.fill(64, 0));
		aarray2 = Control.names(\aarray2).kr(Array.fill(64, 0));
		parray1 = Control.names(\parray1).kr(Array.fill(64, 0));
		parray2 = Control.names(\parray2).kr(Array.fill(64, 0));
		Mix.new(
			Pan2.ar(
				SinOsc.ar(
					Line.kr(farray1 * base1, farray2 * base2, dur),
					0.0,
					Line.kr(aarray1, aarray2, dur),
					0.0),
				Line.kr(parray1, parray2, dur), level))};
)


(
~out = {arg mix = 0.5, room = 0.5, damp = 0.5, amp = 1.0;
	var signal;
	signal = ~raw.ar;
//	signal = ~raw.ar + SinOsc.ar(440, 0, 0.05, 0).dup;
	FreeVerb2.ar( signal[0], signal[1], mix, room, damp, amp)};
)

////////////////////////////

// TaskProxy

x = TaskProxy.new;
x.play;
x.stop;

~out.vol = 0.3;
p.fadeTime = 0.1;

////////////////

(
var dur = 30;
var dt = 30;
var base1, base2 = 40;

var fmatrix1, fmatrix2 = Array.geom(8, 1, 1.5) *.t Array.series(8, 1, 1);
var amatrix1, amatrix2 = Array.fill(8, 1) *.t Array.series(8, 1, 1).reciprocal;

var farray1, farray2 = fmatrix2.flat;
var aarray1, aarray2 = amatrix2.flat;
var parray1, parray2 = Array.fill(64, {1.0.rand2});

var ratio = [6/5, 5/6, 5/4, 4/5, 4/3, 3/4, 3/2, 2/3];

base1 = base2;
x.source = {
	loop{

		fmatrix1 = fmatrix2;
		amatrix1 = amatrix2;

		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;

		fmatrix2 = if ( 0.9.coin,
			{ fmatrix1 * Array.fill2D(8, 8, {ratio.choose}) },
			{ Array.geom(8, 1, 1.5) *.t Array.series(8, 1, 1) }
		);

		amatrix2 = if ( 0.9.coin,
			{ amatrix1 * Array.fill2D(8, 8, {ratio.choose}) },
			{ Array.fill(8, 1) *.t Array.series(8, 1, 1).reciprocal }
		);

		farray2 = fmatrix2.flat;
		aarray2 = amatrix2.flat;
		parray2 = Array.fill(64, {1.0.rand2});

		~raw.setn(
			\dur, dur,
			\base1, base1,
			\base2, base2,
			\farray1, farray1.postln,
			\farray2, farray2.postln,
			\aarray1, aarray1.normalizeSum,
			\aarray2, aarray2.normalizeSum,
			\parray1, parray1,
			\parray2, parray2 ).rebuild;
		dt.wait;

	}
}
)






////////////////

(
var dur = 10;
var dt = 10;
var base1, base2 = 50;

var fmatrix1, fmatrix2 = Array.geom(8, 1, 1.5) *.t Array.series(8, 1, 1);
var amatrix1, amatrix2 = Array.fill(8, 1) *.t Array.series(8, 1, 1).reciprocal;

var farray1, farray2 = fmatrix2.flat;
var aarray1, aarray2 = amatrix2.flat;
var parray1, parray2 = Array.fill(64, {1.0.rand2});

base1 = base2;
x.source = {
	loop{

		fmatrix1 = fmatrix2;
		amatrix1 = amatrix2;

		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;

		fmatrix2 = fmatrix1.swap(8.rand, 8.rand).swap(8.rand, 8.rand).swap(8.rand, 8.rand).swap(8.rand, 8.rand);
		amatrix2 = amatrix1.flop.swap(8.rand, 8.rand).swap(8.rand, 8.rand).swap(8.rand, 8.rand).swap(8.rand, 8.rand).flop;

		farray2 = fmatrix2.flat;
		aarray2 = amatrix2.flat;
		parray2 = Array.fill(64, {1.0.rand2});

		~raw.setn(
			\dur, dur,
			\base1, base1,
			\base2, base2,
			\farray1, farray1.postln,
			\farray2, farray2.postln,
			\aarray1, aarray1.normalizeSum,
			\aarray2, aarray2.normalizeSum,
			\parray1, parray1,
			\parray2, parray2 ).rebuild;
		dt.wait;

	}
}
)

////////////////

(
var dur = 30;
var dt = 30;
var base1, base2 = 50;

var fmatrix1, fmatrix2 = Array.geom(8, 1, 1.5) *.t Array.series(8, 1, 1);
var amatrix1, amatrix2 = Array.fill(8, 1) *.t Array.series(8, 1, 1).reciprocal;

var farray1, farray2 = fmatrix2.flat;
var aarray1, aarray2 = amatrix2.flat;
var parray1, parray2 = Array.fill(64, {1.0.rand2});

var ratio = [6/5, 5/6, 5/4, 4/5, 4/3, 3/4, 3/2, 2/3];

base1 = base2;
x.source = {
	loop{

		fmatrix1 = fmatrix2;
		amatrix1 = amatrix2;

		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;

		fmatrix2 = fmatrix1 * Array.fill2D(8, 8, {ratio.choose});
		amatrix2 = amatrix1 * Array.fill2D(8, 8, {ratio.choose});

		farray2 = fmatrix2.flat;
		aarray2 = amatrix2.flat;
		parray2 = Array.fill(64, {1.0.rand2});

		~raw.setn(
			\dur, dur,
			\base1, base1,
			\base2, base2,
			\farray1, farray1.postln,
			\farray2, farray2.postln,
			\aarray1, aarray1.normalizeSum,
			\aarray2, aarray2.normalizeSum,
			\parray1, parray1,
			\parray2, parray2 ).rebuild;
		dt.wait;

		fmatrix1 = fmatrix2;
		amatrix1 = amatrix2;

		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;

		fmatrix2 = Array.geom(8, 1, [1.5, 1.4].choose) *.t Array.series(8, 1, 1);
		amatrix2 = Array.fill(8, 1) *.t Array.series(8, 1, 1).reciprocal;

		farray2 = fmatrix2.flat;
		aarray2 = amatrix2.flat;
		parray2 = Array.fill(64, {1.0.rand2});

		~raw.setn(
			\dur, dur,
			\base1, base1,
			\base2, base2,
			\farray1, farray1.postln,
			\farray2, farray2.postln,
			\aarray1, aarray1.normalizeSum,
			\aarray2, aarray2.normalizeSum,
			\parray1, parray1,
			\parray2, parray2 ).rebuild;
		dt.wait;
	}
}
)

////////////////

(
var dur = 30;
var dt = 30;
var base1, base2 = 50;

var fmatrix1, fmatrix2 = Array.geom(8, 1, 1.5) *.t Array.series(8, 1, 1);
var amatrix1, amatrix2 = Array.fill(8, 1) *.t Array.series(8, 1, 1).reciprocal;

var farray1, farray2 = fmatrix2.flat;
var aarray1, aarray2 = amatrix2.flat;
var parray1, parray2 = Array.fill(64, {1.0.rand2});

var ratio = [6/5, 5/6, 5/4, 4/5, 4/3, 3/4, 3/2, 2/3];

base1 = base2;
x.source = {
	loop{

		fmatrix1 = fmatrix2;
		amatrix1 = amatrix2;

		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;

		fmatrix2 = Array.series(8, 1, 1) *.t Array.geom(8, 1, [1.5, 1.4].choose);
		amatrix2 = Array.series(8, 1, 1).reciprocal *.t Array.fill(8, 1);

		farray2 = fmatrix2.flat;
		aarray2 = amatrix2.flat;
		parray2 = Array.fill(64, {1.0.rand2});

		~raw.setn(
			\dur, dur,
			\base1, base1,
			\base2, base2,
			\farray1, farray1.postln,
			\farray2, farray2.postln,
			\aarray1, aarray1.normalizeSum,
			\aarray2, aarray2.normalizeSum,
			\parray1, parray1,
			\parray2, parray2 ).rebuild;
		dt.wait;

		fmatrix1 = fmatrix2;
		amatrix1 = amatrix2;

		farray1 = farray2;
		aarray1 = aarray2;
		parray1 = parray2;

		fmatrix2 = Array.geom(8, 1, [1.5, 1.4].choose) *.t Array.series(8, 1, 1);
		amatrix2 = Array.fill(8, 1) *.t Array.series(8, 1, 1).reciprocal;

		farray2 = fmatrix2.flat;
		aarray2 = amatrix2.flat;
		parray2 = Array.fill(64, {1.0.rand2});

		~raw.setn(
			\dur, dur,
			\base1, base1,
			\base2, base2,
			\farray1, farray1.postln,
			\farray2, farray2.postln,
			\aarray1, aarray1.normalizeSum,
			\aarray2, aarray2.normalizeSum,
			\parray1, parray1,
			\parray2, parray2 ).rebuild;
		dt.wait;
	}
}
)

//////////////////

(
~raw.setn(
	\dur, 30,
	\base1, 882,
	\base2, 441,
	\farray1, (Array.series(16, 1, 1) *.x [15/16, 9/8, 4/3, 3/2]).postln,
	\farray2, (Array.series(16, 1, 1) *.x [15/16, 1, 5/4, 3/2]).postln,
	\aarray1, (Array.series(16, 1, 1).reciprocal *.x Array.fill(4, 1)).normalizeSum.postln,
	\aarray2, (Array.series(16, 1, 1).reciprocal *.x Array.fill(4, 1)).normalizeSum.postln,
	\parray1, Array.fill(64, {1.0.rand2}).postln,
	\parray2, Array.fill(64, {1.0.rand2}).postln).rebuild;
)


///////////////////////////////////////////////////////////

// midi
(
MIDIClient.init;
m = MIDIOut(0, MIDIClient.destinations.at(0).uid);
)


// test
m.noteOn(1, 60, 60);
m.noteOff(1, 60, 0);

m.allNotesOff(1);

// parameters
m.control(1, 64, 127); // sustain pedal
m.control(1, 66, 127); // sostenuto pedal
m.control(1, 67, 127); // soft pedal
m.control(1, 69, 127); // harmonic pedal

////////////////////////////////////////////////////////////
//
// pure-tempered 21-tone scale
//

// {2, 3, 5, 7, 11} limit otonality/utonality
(
b = 63;
o = [[  0,  13,  27,  39,  51],  // 0:2oo  A   E   C#  G-  D+
	[-13,   0,  16,  25,  41],  // 1:3oo  D   A   F#  B+  G+
	[-27, -16,   0,  10,  23],  // 2:5oo  F   C   A   D#  B-
	[-39, -25, -10,   0,  14],  // 3:7oo  B+  G-  D#  A   F
	[-51, -41, -23, -14,   0],  // 4:11oo E-  B-  G+  C#  A
	[  0,   6,   9,  13,  18],  // 5:2oc
	[  0,   4,   8,  16,  20],  // 6:3oc
	[  0,   2,   5,  10,  15],  // 7:5oc
	[  0,   3,  11,  14,  17],  // 8:7oc
	[  0,   1,   7,  12,  19]]; // 9:11oc
u = [[  0, -13, -27, -39, -51],  // 0:2uo
	[ 13,   0, -16, -25, -41],  // 1:3uo
	[ 27,  16,   0, -10, -23],  // 2:5uo
	[ 39,  25,  10,   0, -14],  // 3:7uo
	[ 51,  41,  23,  14,   0],  // 4:11uo
	[  0,   3,   8,  12,  15],  // 5:2uc
	[  0,   1,   5,  13,  17],  // 6:3uc
	[  0,   6,  11,  16,  19],  // 7:5uc
	[  0,   4,   7,  10,  18],  // 8:7uc
	[  0,   2,   9,  14,  20]]; // 9:11uc
l = [0, 2, 3, 5, 6, 8, 10, 13, 15, 16, 18, 20, 21]; // 12-tone scale
)

//    ----- -----    -----    --------       ----- -----    -----
// 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84
//  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21
// A  B- B-  B  B+ C  C# C# D  D+ D# D# E- E  F  F  F# G- G  G  G+ A
// A     B-  B     C  C#    D     D#       E     F  F#    G     G# A
// C     C#  D     D# E     F     F#       G     G# A     A#    B  C
//
//     2   3   5   7   11
// 2   A   E   C#  G  D+
// 3   D   A   F#  B+  G+
// 5   F   C   A   D#  B-
// 7   B   G-  D#  A   F
// 11  E-  B-  G   C#  A


b = 60;

(
m.noteOn(1, b, 60);
m.noteOn(1, b+42, 60);
m.noteOn(1, b+63, 60);
)
m.allNotesOff(1);


// tone/interval/chord
o.at(0).do({ arg item; m.noteOn(1, (item + b), 80); });
o.at(1).do({ arg item; m.noteOn(1, (item + b), 80); });
o.at(2).do({ arg item; m.noteOn(1, (item + b + 21), 80); });
o.at(3).do({ arg item; m.noteOn(1, (item + b + 21), 80); });
o.at(4).do({ arg item; m.noteOn(1, (item + b + 42), 80); });

o.at(5).do({ arg item; m.noteOn(1, (item + b + [-21, 0, 21, 42].choose), 80); });
o.at(6).do({ arg item; m.noteOn(1, (item + b + [-21, 0, 21, 42].choose), 80); });
o.at(7).do({ arg item; m.noteOn(1, (item + b + [-21, 0, 21, 42].choose), 80); });
o.at(8).do({ arg item; m.noteOn(1, (item + b + [-21, 0, 21, 42].choose), 80); });
o.at(9).do({ arg item; m.noteOn(1, (item + b + [-21, 0, 21, 42].choose), 80); });

o.at([2, 3, 4].choose).do({ arg item; m.noteOn(1, (item + b + [21, 42].choose), 80); });
o.at(3).do({ arg item; m.noteOn(1, (item + b + [13, 21, 42].choose), 80); });
o.at(4).do({ arg item; m.noteOn(1, (item + b + [13, 21, 42].choose), 80); });
o.at(3).do({ arg item; m.noteOn(1, (item + b + [21, 42].choose + rand(2)), 80); });

u.at(9).do({ arg item; m.noteOn(1, (item + b), 80); });
3.do({ m.noteOn(1, o.at(4).at(5.rand) + b + 21, [90, 70, 60].choose); });
o.at(5).do({ arg item; m.noteOn(1, (item + b + 42), 80); });
[0, rand(21), rand(21), 21].do({ arg item; m.noteOn(1, (item + b + rrand(-1, 2)), 80); });
[0, rand(21), 13, 21].do({ arg item; m.noteOn(1, (item + b + rand(3)), 80); });

m.allNotesOff(1);


// event loop
(
Tdef(\x, {
	inf.do {
		u.at(2).do({ arg item; m.noteOn(1, (item + b + 13), 80); });
		1.wait;
		m.allNotesOff(1);
		10.wait };
})
)

Tdef(\x).play;
Tdef(\x).stop;

(
Tdef(\xx, {
	inf.do {
		m.noteOn(1, [80, 81].choose, 10.rrand(10));
		0.1.rrand(0.11).wait;
		m.noteOn(1, [89, 90, 91].choose, 10.rrand(10));
		0.1.rrand(0.11).wait;
		if(rrand(0.0, 1.0) > 0.8, {m.allNotesOff(1)}) };
})
)

Tdef(\xx).play;
Tdef(\xx).stop;

// arpeggio
(
Pdef(\y,
	Pchain(
		Pbind(
			\midinote, Prand([o.at(0), o.at(1)], inf),
			\ctranspose, b,
			\detune, Prand([-10, 0, 10], inf),
			\dur, 10,
			\legato, 1.2,
			\amp, Pwhite(0.3, 0.5, inf)),
		(type: \midi, midiout: m)
	)
)
)

Pdef(\y).play;
Pdef(\y).stop;


////////////////////////


(
a = (0..100) ++ (100..50) / 100; // distribution
a = a.asRandomTable;
)


[[1, 2, 3], [4, 5, 6], [7, 8, 9]].scramble;
[[1, 2, 3], [4, 5, 6], [7, 8, 9]].reverse;
[[1, 2, 3], [4, 5, 6], [7, 8, 9]].rotate(1);
[[1, 2, 3], [4, 5, 6], [7, 8, 9]].flop;


////////////////////////

シ：15/16＝0.9375
ド：1
ド＃：16/15＝1.066
レ：9/8＝1.125
ミ♭：6/5＝1.2, √√2＝1.189
ミ：5/4＝1.25
ファ：4/3＝1.33
ファ＃：45/32=1.40, √2＝1.4142
ソ：3/2＝1.5
ソ＃：25/16＝1.5625
ラ：5/3＝1.66, √√2*√2＝1.682
シ♭：9/5=1.8
シ：15/16*2＝15/8=1.875
ド：2

ランダム音程（和音）：
Array.fill(8, {[16/15, 10/9, 9/8, 6/5, 5/4, 4/3, 2.sqrt, 3/2, 8/5, 5/3, 7/4, 16/9, 15/8].choose}).sort;
ランダムクラスター：
Array.fill(8, {[8/9, 9/10, 15/16, 1.0, 16/15, 10/9, 9/8, 16/9, 9/5, 15/8, 2.0, 32/15, 20/9, 9/4].choose}).sort;
ランダム音程列：Array.geom(8, 1, [1.2, 1.25, 1.5].choose)

広帯域音程：
Array.linrand(8, 20.0, 20000.0).sort
Array.exprand(8, 20.0, 20000.0).sort


ランダム振幅：Array.rand(64, 0.0, 1.0)
ランダム振幅：Array.fill(64, {rrand(0.0, 1.0)})
発音率：Array.fill(64, {[0, 1].wchoose([0.3, 0.7])})

Array.fill2D(8, 8, {1.0.sum3rand});


倍音列：Array.series(8, 1, 1)
奇数次倍音：Array.series(8, 1, 2)
部分倍音列：Array.series(8, 10, 1)

対称倍音列：(Array.series(4, 1, 1) ++ Array.series(4, 1, 1).reciprocal)


ノコギリ波（倍音）：Array.series(8, 1, 1).normalizeSum
矩形波（奇数次倍音）：Array.series(8, 1, 2).reciprocal.normalizeSum
三角波(奇数次倍音）：Array.series(8, 1, 2).squared.reciprocal.normalizeSum

公差の変化：Array.series(8, 1, rrand(0.01, 0.1))
初項の変化：Array.series(8, rrand(0.5, 2.0),1.0)
初項と公差を変化：Array.series(8, rrand(0.5, 2.0), rrand(0.5, 2.0))

下方倍音列：Array.series(8, 1, 1).reciprocal

等比数列による和音：Array.geom(8, 1, 5/4)

五音音程和音：Array.geom(8, 1, 2**(1/5))
全音音程和音：Array.geom(8, 1, 2**(1/6))
四分音音程和音：Array.geom(8, 1, 2**(1/24))

下降音程列（下降和音）：Array.geom(8, 1, 4/5)

5度構成の音響和音：Array.series(8, 1, 1) * .x Array.geom(8, 1, 3/2)
下方音響和音：
Array.series(8, 1, 1).reciprocal * .x Array.geom(8, 4, 3/2)
Array.series(8, 1, 1) * .x Array.geom(8, 4, 4/5)

乱数和音：
Array.linrand(8, 1000.0, 1200.0).sort
Array.exprand(8, 1000.0, 1200.0).sort

ゆらぎ：
(Array.series(8, 500.0, 400.0) + Array.rand2(8, 50.0)).sort
(Array.series(6, 400.0, 400.0) ++ Array.linrand(2, 400.0, 4800.0)).sort
(Array.series(4, 400.0, 400.0) ++ Array.linrand(4, 3200.0, 6400.0)).sort
(Array.geom(8, 1, 5/4) + Array.rand2(8, 0.1))

狭い音程と広い音程による音響和音：
Array.geom(8, 1, rrand(1.0, 1.1)) * .x Array.geom(8, 1, rrand(1.9, 2.0))

短2度×長7度：Array.geom(8, 1, 16/15) * .x Array.geom(8, 1, 15/8)
長2度×短7度：Array.geom(8, 1, 9/8) * .x Array.geom(8, 1, 16/9)
クラスター：[16/15, 9/8, 16/9, 15/8]
古典的長7和音：(Array.series(16, 1, 1) * .x [1, 4/3, 3/2, 15/8])
増3和音と減3和音：(Array.geom(8, 1, 5/4) * .x Array.geom(8, 1, 6/5))
