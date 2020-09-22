(
s.options.inDevice = "ZoomAudioD";
s.options.outDevice = "ZoomAudioD";
s.options.sampleRate = 48000;
s.boot;
)

/*----- Synth Def -----*/
(
var detune = 0.1;
FreqScope(400, 200, 0, server: s);
SynthDef(\synth1, {arg inputFrequency;

	var freq = 220;

	//Modulation Waveforms
	var modSin = SinOsc.kr(1, 0, 0.9);
	var modSaw = LFSaw.kr(1).range(-10,10);
	var modTri = LFTri.kr(1).range(-10,10);
	var modSquare = LFPulse.kr(1,0,0.5).range(-10,10);

	//Sin Waveforms
	var sin2= SinOsc.ar(inputFrequency);
	var sin3 = SinOsc.ar(329.63);

	//Other Waveforms
	var saw = LFSaw.ar(inputFrequency);
	var tri = LFTri.ar(inputFrequency);
	var square = LFPulse.ar(inputFrequency,0,0);

	//Ring modulation
	var ringSin = SinOsc.ar(100).range(-1,1);
	var ring = sin3 * ringSin;

	//FM modulator
	var fmSin = SinOsc.ar(329.63 * modSin);

	//Distortion
	var dist = sin3.softclip(-0.2,0.2);

	//Output
	var output = sin2*0.001;
	Out.ar(0, [output,output]);
}).add;
)

/* Main loops */

(
// Display
s.scope;
~synth1 = Synth.new(\synth1).register;
~synth1.set(\inputFrequency, 220);
)

(
var notes = [57, 60, 64, 69];
~synth1 = Synth.new(\synth1).register;
//~synth1.set(\inputFrequency,440);

fork{
	loop{
		for (0,notes.size-1, { arg index;
			~synth1.set(\inputFrequency, notes[index].midicps);
			(0.3).wait;
		});
	};
};
)

