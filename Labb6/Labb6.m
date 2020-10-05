% ---------- Labb 6 -----------%
% Mål att reproducera delay/reverb på ljudfil %

%Global samplingstakt
Fs = 44100;

%Läser ljud med effekter
[y,Fs] = audioread("OriginalFX.wav");

%Plottar ljud m effekter för att se antalet delay
figure(1);
%plot(y);

% Spectrogram
window = 512;
noverlap = 256;
nfft = 0;
spectrogram(y(:,1),window,noverlap,"yaxis");
ylim([0 0.2]);

%Läser originalljud för att börja bearbeta
[org,Fs] = audioread("Original.wav");
%figure(2);
%plot(org);

% Delay, 2 delay samples
zeroArray = zeros(1,16000);
delayResult = cat(2,org(:,1)', zeroArray(1,:), zeroArray(1,:));
delay1 = cat(2,zeroArray(1,:), org(:,1)',zeroArray(1,:));
delay2 = cat(2,zeroArray(1,:),zeroArray(1,:),org(:,1)');

%Slår ihop delayen, lågpassfiltrerar och sänker volymen.
delayRes = (delayResult+lowpass(delay1,5000,Fs)/1.5+lowpass(delay2,3000,Fs)/2)'/3;
%Konkatenerar delay till "stereo"
delayRes = cat(2,delayRes,delayRes);

% Schroeders Reverberator
reverbGain = 0.7;
reverbTime = 80;
numberOfAllpass = 3;
signalForReverb = delayRes;

for i = 0:numberOfAllpass-1
 reverbLength = ceil((reverbTime/1000)*Fs / (3^i));
 signalForReverb = [signalForReverb;zeros(abs(reverbTime/100)*Fs,2)];

% Allpass
b = zeros(1, reverbLength+1);
b(1) = -reverbGain;
b(reverbLength+1) = 1;

a = zeros(1, reverbLength+1);
a(1) = 1;
a(reverbLength+1) = -reverbGain;

signalForReverb = filter(b,a,signalForReverb);

end

%Paddar originalljudet för att få plats för reverben
org = cat(1, org, zeros((length(signalForReverb(:,1))-length(org(:,1))),2));

%Mixar med originalljudet
result = (org + 0.5*signalForReverb)/1.5;

% Enkel förstärkning
ampLevel = 2;
result = result.*ampLevel;
%max(abs(result)) %Kollar maxnivån

% Tillför distortion för att minska dynamiken
distLevel = 2;
result = (distLevel*result)./(1+distLevel*abs(result));

% Använder expansion
%for i = 1:length(result(:,1))
%    result(i,1) = result(i,1)*abs(result(i,1));
%end

% Använder kompression (Förmodligen använt i målljudet)
for i = 1:length(result(:,1))
    result(i,1) = result(i,1)*(2-abs(result(i,1)));
end

player = audioplayer(result(:,1),Fs);
play(player);

