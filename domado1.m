clear all; close all;
%--  APB  - arterines pulsines bangos reiksmiu vektorius
%--  Td   - diskretizavimo periodas =125Hz
%--  N    - is laikmenos nuskaitytu reiksmiu skaicius
Td = 0.008; 

kelias = 'C:\Users\Dominykas\Desktop\inzinerinis\XX1_039.dat'
kelias_RR = 'C:\Users\Dominykas\Desktop\inzinerinis\RR1_039.dat'

%--  Nuskaitomi duomenys
fid = fopen(kelias);
   [signalas,N2] = fread(fid,'float32');
fclose(fid);

%--  Nuskaitomi duomenys
fid = fopen(kelias_RR,'r');
   [R_adr, N1]= fread(fid,'uint32');
fclose(fid);

figure(1)
plot(signalas); title('Pradinis signalas')
figure(2); 
stem(diff(R_adr,1),'.-'); title('Periodograma')

%% Kintamieji
fd = 1/Td; % diskretizavimo daznis
fdd = fd/2; % puse signalo diskretizavimo daznio
t = (0:N2-1)*Td; % laiko asis
T = N2*Td; % signalo periodas
z = 1/T; % periodo zingsnis
df = 1/T; % dazniu asies zingsnis
Nf = fix(fd/z); % reiksmiu kiekis spektre
Nff = fix(Nf/2); % puse reiksmiu kiekio spektre
fasis = (0:Nf-1)*df; % daznio asies reiksmes
M = 160; % filtro eile

%% Uzduotis 1
%mean(signalas)
signaloSpektras = abs(fft(signalas-mean(signalas),Nf)); % Pradinio signalo spektras
figure(3);
stem(fasis(1:Nff),signaloSpektras(1:Nff),'.');
axis tight; title('Pradinio signalo spektras')


% Zemo daznio filtro realizacija ir jo dažninės ir fazinės charakteristikos grafiko sudarymas
% pfd = 62.5000
figure(4)
Wn = 6.95/fdd;
b = fir1(M, Wn, 'low');
[h, fn, s] = freqz(b, 1, fd, fd);
s.plot  = 'both';
s.xunits = 'hz';
s.yunits = 'linear';
freqzplot(h, fn, s);
title('Filtro dažninė (viršuje) ir fazinė (apačioje) charakteristikos')

%Filtravimas, spektro skaiciavimas (zemas)
zemasFiltras = filter(b,1,signalas);
zemasFiltrasSpektras = abs(fft(zemasFiltras-mean(zemasFiltras),Nf)); %Nf reiksmiu kiekis spektre

%Nufiltruoto signalo zemo daznio filtru spektro ir signalo vaizdavimas
figure(5)
subplot(2,1,1)
stem(fasis(1:Nf),zemasFiltrasSpektras(1:Nf),'.'); axis tight
title('Nufiltruotas žemo dažnio filtru spektras')
subplot(2,1,2)
plot(t(1:Nf), zemasFiltras(1:Nf)); axis tight
title('Nufiltruotas žemo dažnio filtru signalas')

%Auksto daznio filtro realizacija ir jo dažninės ir fazinės charakteristikos grafiko sudarymas
figure(6)
b = fir1(M, 2/fdd, 'high');
[h, fn, s] = freqz(b, 1, fd, fd);
s.plot  = 'both';
s.xunits = 'hz';
s.yunits = 'linear';
freqzplot(h, fn, s);
title('Filtro dažninė (viršuje) ir fazinė (apačioje) charakteristikos')

%Filtravimas, spektro skaiciavimas (aukstas)
aukstasFiltras = filter(b,1,zemasFiltras);
aukstasFiltrasSpektras = abs(fft(aukstasFiltras-mean(aukstasFiltras),Nf));  %Nf reiksmiu kiekis spektre

%Nufiltruoto signalo zemo ir auksto daznio filtru spektro ir signalo vaizdavimas
figure(7)
subplot(2,1,1)
stem(fasis(1:Nf),aukstasFiltrasSpektras(1:Nf),'.'); axis tight
title('Nufiltruotas žemo ir aukšto dažnio filtrų spektras')
subplot(2,1,2)
plot(t(1:Nf), aukstasFiltras(1:Nf)); box('off'); axis tight;
title('Nufiltruotas žemo ir aukšto dažnio filtrų signalas')

%% Uzduotis 2
figure(8);
[PKS,LOCS] = findpeaks(-aukstasFiltras, 'MinPeakProminence', 60, 'MinPeakDistance', 0.3/Td); %Suranda ir pažymi vieta signale kur prasideda banga
plot(t,aukstasFiltras,t(LOCS),aukstasFiltras(LOCS),'or') %Atvaizduoja signalą nufiltruota su zemo ir auksto daznio filtrais ir pazymi bangu pradzias
xlabel('Tp(i), s'); ylabel('i')
title('Nufiltruotas žemo ir aukšto dažnio filtrų signalas su bangų pradžiomis')