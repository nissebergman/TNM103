Fs = 44100;

[y,Fs] = audioread("forensisktljud.wav");

%Kolla på del av ljudet
from = 3; %sekund
to = 8; %sekund
y = y(from*Fs:to*Fs,:);

%Plottar enkel graf
plot(y);

%Fasvänder vänster kanal och summerar, tog mest bort ljudet för oss
% left=y(:,1).*-1;
% right=y(:,2);
% y=left+right;

% %-- Utövar svart magi på ljudet --

%Högpass, 80Hz pga nedre frekvensens för mansröst
y=highpass(y,80,Fs);

%Lågpass 5000Hz, ta bort "onödiga" frekvenser över 5000Hz
y=lowpass(y,5000,Fs);

%Bandpass filter av 8:e graden för att skarpt skära bort övre och undre
%frekvenser
 Wn=[400, 5000]/(Fs/2);
 [B,A] = butter(8,Wn,'bandpass');
 y = filter(B,A,y);

   
%Brusreducering med sgolay
y= sgolayfilt(y,120,201);

% Tillför distortion för att minska dynamiken
distLevel = 2;
y = (distLevel*y)./(1+distLevel*abs(y));
  
% Enkel förstärkning
ampLevel = 10;
y = y.*ampLevel;
% %max(abs(result)) %Kollar maxnivån

%-- Isolerar jordbrum, för äkthetsbevis --

% for i = 0:3
%     Wn=[40, 60]/(Fs/2);
%     [B,A] = butter(2,Wn,'bandpass');
%     y = filter(B,A,y);
%     
%     Wn=[40, 60]/(Fs/2);
%     [B,A] = butter(2,Wn,'bandpass');
%     y = filter(B,A,y);
%     
%      Wn=[40, 60]/(Fs/2);
%     [B,A] = butter(2,Wn,'bandpass');
%     y = filter(B,A,y);
% end

% 
% 
% %-- Tittar på ljudet --
% 
% Spectrogram
spectrogram(y(:,2),441,220,1000,Fs,"yaxis");
% 
% %hold on;
% %plot(y);
% 
% Frekvensinnehåll med fft
% % m = length(y);
% % n = pow2(nextpow2(m));
% % fftAnalys = fft(y,n);
% % power = fftAnalys.*conj(fftAnalys)/n;
% % f = (0:n-1)*(Fs/n);
% % loglog(f,power);
% % xlim([1,20000]);
% % ylabel('Power');
% % xlabel("Frekvens (Hz)");
% % title("Effektspektrum av ljudet");
% 
% %Spela upp ljudet
 player = audioplayer(y,Fs);
 play(player);