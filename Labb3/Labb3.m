% Frekvens och tidsvariabler
Fs = 44100;
freq = 130; 
len = 0.5;
t = (0:(1/Fs):1/len);

% Fade
fadeInVektor= [0:(1/4410):1];
fadeOutVektor= fliplr(fadeInVektor);
onesVektor= ones(1,size(t,2)-size(fadeInVektor,2)*2);
fadeVektor=[fadeInVektor onesVektor fadeOutVektor];


% Fundamentalfrekvens för mansröst
F0 = sin(2*pi*freq.*t);

% FM-modulation (rosa brus ish)
%sinOsc = sin(2*pi*freq.*t + sin(2*pi*640.*t + sin(2*pi*1190.*t +
%sin(2*pi*2390.*t)))); %Gamla oscillatorn

sinOsc = sin(2*pi*freq.*t*2 + sin(2*pi*505.*t + sin(2*pi*615.*t) + sin(2*pi*2600.*t))); %Nya oscillatorn

% Vitt brus
whiteNoise = wgn(size(t,2),1,1);

%Band-Limited Pulse Generator
BLP = 0;
for i = 1:29:1
    pulse = sin(2*pi*(freq*(i+1)).*t);
    BLP =+ pulse;
end


% Bandpassfilter

% Sätt invariabel till filter
%noiseIn = whiteNoise';
%noiseIn = sinOsc;
noiseIn = BLP/(29);

% Filterbredd
Wn = [576,704,1106.5,1273.5,2270.5,2509.5]/(Fs/2);

% F1
[b1,a1] = butter(2,Wn(1:2),'bandpass');
F1 = filter(b1,a1,noiseIn);
F1=F1*db2mag(-1);

% F2
[b2,a2] = butter(2,Wn(3:4),'bandpass');
F2 = filter(b2,a2,noiseIn);
F2=F2*db2mag(-10);

% F3
[b3,a3] = butter(2,Wn(5:6),'bandpass');
F3 = filter(b3,a3,noiseIn);
F3=F3*db2mag(-27);

%Envelopevektor - Enkel stigning
envelopeVektor= [1:0.03/(length(t)-1):1.03];
F0Envelope= sin(2*pi*freq.*envelopeVektor.*t);

%Amplitudvektor - Sinus
envelopeVektor= (sin(pi.*t*2))/7+0.85;


% Resultat utan envelope
%result=F1+F2+F3+F0;

% Resultat med envelopes
result=F1+F2+F3+F0Envelope;

% Lägger på fades in/out
%a=result.*fadeVektor;

% Lägger på amplitudmodulering
a=result.*envelopeVektor;

% Spelar upp ljudet
p= audioplayer(a,Fs);
playblocking(p);