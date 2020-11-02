%-- Labb 9 --%

clearvars;
close all;

Fs = 44100;

%Läser ljud med effekter
[og,Fs] = audioread("loop.wav");

%Spelar upp del av ljud
og= og(5*Fs:9*Fs,1);

%Speed & pitch
speed=1;
pitch = 1.5;

if (pitch == 1)
    Fs2 = Fs;
else
    Fs2 = Fs * pitch;
end


windowSize=4410;

stepSize= round(windowSize*speed);

%Ny index-array voco
voco=zeros(round(length(og)*(windowSize/stepSize)+windowSize),1);

k=1;

for i = (0:stepSize:length(og)-1)
    
    for j= (0:windowSize-1)
        voco(k)=i+j+1;
        k=k+1;
    end
    
end

%Klipper nollor
ix=voco>0;
voco=voco(ix);

%Kollar längden
ix=voco<length(og);
voco=voco(ix);

%Tillägnar ny index till originalljudet
result=og(voco);

%Plottar
figure;
subplot(211);
plot(og);
subplot(212);
plot(result);

%Spelar upp
player = audioplayer(result,Fs2);
play(player);

