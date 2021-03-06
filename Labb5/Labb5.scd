(
//s.options.inDevice = "ZoomAudioD";
//s.options.outDevice = "ZoomAudioD";
//s.options.sampleRate = 48000;
s.boot;
)

/*----- Synth Def -----*/
(
var detune = 0.1;
FreqScope(400, 200, 0, server: s);
SynthDef(\synth1, {arg inputFrequency, gate, bufnum;

	var freq = 220;

	//Modulation Waveforms
	var modSin = SinOsc.kr(1, 0, 0.9);
	var modSaw = LFSaw.kr(0.1).range(0.001,1); //sätt högre range
	var modTri = LFTri.kr(1).range(-10,10);
	var modSquare = LFPulse.kr(1,0,0.5).range(-10,10);

	//Enveleop
	var envelope= EnvGen.kr(Env.adsr(0.01, 0.3, 0.5, 1.0, 1, -0.4),gate);

	//Sin Waveforms
	var sin2= SinOsc.ar(inputFrequency);
	var sin3 = SinOsc.ar(329.63);

	//Other Waveforms
	var saw1 = LFSaw.ar(inputFrequency);
	var saw2 = LFSaw.ar(inputFrequency+60.midicps);
	var saw3 = LFSaw.ar((inputFrequency-12.midicps));
	var tri = LFTri.ar(inputFrequency);
	var square = LFPulse.ar(inputFrequency,0,0);

	//Ring modulation
	var ringSin = SinOsc.ar(100).range(-1,1);
	var ring = sin3 * ringSin;

	//FM modulator
	var fmSin = SinOsc.ar(329.63 * modSin);

	//Distortion
	var dist = sin3.softclip(-0.2,0.2);

	//Noise
	var pnoise= PinkNoise.ar();

	//Output
	var output = (saw3+saw2+saw1+pnoise)/4;

	//Filter
	var lpfilter= LPF.ar(output,modSaw*4000.0);
	var hpfilter= HPF.ar(output,440.0);
	var rlpfilter= RLPF.ar(output,4000,0.9);
	var bpfilter= BPF.ar(output,1000,0.9);
	var bbsfilter= BBandStop.ar(output, modSaw*10000, 6);

	//Högre ordningen filter
	var filteredOutput= BLowPass.ar(output, inputFrequency,0.01);

	//Mic som input
	var mic= SoundIn.ar(0,1.0,0.0);

	//Fil som input
	var audioFile = PlayBuf.ar(2, bufnum);

	//Reverb eller delay
	var reverbed=audioFile;
	//var reverbed=filteredOutput;
	var delay = audioFile;


	//Delay
	delay = AllpassC.ar(delay, 0.2,0.2,1,1,0);

	//Schroeder reverb
	//3.do({ reverbed = AllpassC.ar(reverbed, 0.6, { Rand(0.001, 6) }.dup, 1, 1,0)});

	//output=bbsfilter*envelope; //Output med Bandstopfilter
	//output= filteredOutput*envelope*0.01*mic; //Output med ljudingång
	//output= reverb3;
	output= delay*0.1;
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
var envelope= Env.adsr(0.01, 0.3, 0.5, 5.0, 1, 0.0, 0.0).plot;
)


/* ---- Noise synth -----*/
/*
(
SynthDef(\noiseSynth, {
	Out.ar(0,{GrayNoise.ar()}!2);
}).play;
s.scope;
FreqScope(400, 200, 0, server: s);
)
*/

(
var notes = [57, 60, 64, 69];
~synth1 = Synth.new(\synth1).register;
//~synth1.set(\inputFrequency,440);



fork{
	var soundFileBuffer = Buffer.read(s,"/Users/mac/Music/BanjoGalore.wav"); //Läser in fil
	(1.0).wait;
	~synth1.set(\bufnum, soundFileBuffer.bufnum);
	/*
	loop{
		for (0,notes.size-1, { arg index;
			~synth1.set(\inputFrequency, 57.midicps); //notes[index].midicps

			~synth1.set(\gate, 1);
			(1.0).wait;
			~synth1.set(\gate, 0);
			(1.0).wait;
		});
	};
	*/
};

)

