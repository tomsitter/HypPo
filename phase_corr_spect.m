%% *Select .SPAR file*
% someone feel free to make this script less crap!

clear all
close all
clc

path = 'C:\Users\Owner\Documents\MRI_research\';
cd(path);

[filename,pathname] = uigetfile('*.SPAR','Select *.SPAR file');
sparfile = [pathname filename];

%% *Postprocessing methods*
zeropad = 1;
DC_Offset = 1;
plotfid = 1;
plotspect = 1;
phaseplot = 1;
%% *Read in spectroscopy data*
[spec_data,parms,dims] = GetData_sparsdat(sparfile,'info');

%% *FID characteristics*
Re_FID = real(spec_data);
Im_FID = imag(spec_data);
mag_FID = abs(spec_data);

if DC_Offset

Re_FID = Re_FID - mean(Re_FID(length(Re_FID)*3/4:end));
Im_FID = Im_FID - mean(Im_FID(length(Im_FID)*3/4:end));
mag_FID = mag_FID - mean(mag_FID(length(mag_FID)*3/4:end));

end

complex_data = Re_FID + 1i*Im_FID;

%% *Acquire plot axes*
samples = parms.samples;
rows = parms.rows;
dwell = parms.dim1_step;                                                   % us
%spec_band = parms.sample_frequency;
spec_band = 1 / parms.dim1_step;

time = (samples*dwell)*1000;                                               % total acquisition time in ms
t = linspace(0,samples*dwell,samples)*1000;  
f = (0:samples-1)*spec_band/samples;                                       % frequency spectrum range
f_centre = (-samples/2:samples/2-1)*spec_band/samples;                     % zero centred frequency range

%% *Zero pad FID*
if zeropad

n = 4;                                                                     % zero pad factor n*samples   
    
Re_FID = padarray(Re_FID,[0 n*samples],'post');
Im_FID = padarray(Im_FID,[0 n*samples],'post');
mag_FID = padarray(mag_FID,[0 n*samples],'post');

t = linspace(0,(n+1)*samples*dwell,(n+1)*samples)*1000;  
f = (0:(n+1)*samples-1)*spec_band/(n+1)*samples;                           % frequency spectrum range
f_centre = (-(n+1)*samples/2:(n+1)*samples/2-1)*spec_band/(n+1)*samples;   % zero centred frequency range

complex_data = Re_FID + 1i*Im_FID;

end
%% *1D FFT in sample dimension*
spect = fft(complex_data,[],2);
y = fftshift(spect);                                                       % complex spectra
freq = (0:length(spect)-1)/length(spect);  
%% *Spectral characteristics*
Re = real(y);                                                              % real data
im = imag(y);                                                              % imaginary data
mag = abs(y);                                                              % magnitude data
power = (abs(y).^2)/samples;                                               % power spectrum data
phase = angle(spect);                                                      % phase (degs)

%% *Zero order phase correction*
guess = input('Provide a Phase Offset Value in Degrees...');

if isempty(guess)
    guess = 360;                                                           % error catching
end

phase_corr = guess * pi / 180;
y_phased = y.*exp(-1i.*phase_corr);

Re_ph = real(y_phased);                                                    % phased real data
im_ph = imag(y_phased);                                                    % phased imaginary data
mag_ph = abs(y_phased);                                                    % phased magnitude data
power_ph = (abs(y_phased).^2)/samples;                                     % phased power spectrum data
true_phase = angle(ifftshift(y_phased));                                   % phase (degs)

%% *Plot FID*
if plotfid
    
figure(1)
plot(t,Re_FID,'b'); hold on;
plot(t,Im_FID,'r');
plot(t,mag_FID,'g');
xlabel('time (msec)')
ylabel('Signal (arb units)')
legend('real','imaginary', 'modulus','Location','NorthEast')
axis tight

end

%% *Plot spectrum*
if plotspect

scale = 16;                                                                % axis scaling factor - i.e zoom in very crudely  
    
figure(2)
subplot(1,2,1)
plot(f_centre,Re,'b-','LineWidth',1); hold on;
plot(f_centre,im,'r-','LineWidth',1);
plot(f_centre,mag,'g-','LineWidth',1);
% plot(f_centre,power,'y-','LineWidth',1);
xlabel('Frequency (Hz)')
ylabel('Signal (arb units)')
title('Unphased')
xlim([min(f_centre)/scale max(f_centre)/scale])
legend('real','imaginary','modulus','Location','NorthEast')
grid on
% axis tight

subplot(1,2,2)
plot(f_centre,Re_ph,'b-','LineWidth',1); hold on;
plot(f_centre,im_ph,'r-','LineWidth',1);
plot(f_centre,mag_ph,'g-','LineWidth',1);
% plot(f_centre,power_ph,'y-','LineWidth',1);
title('Phased')
xlabel('Frequency (Hz)')
ylabel('Signal (arb units)')
xlim([min(f_centre)/scale max(f_centre)/scale])
legend('real','imaginary','modulus','Location','NorthEast')
grid on
% axis tight

end

%% *Phase plot*
if phaseplot

figure(3)
plot(f,unwrap(phase*180/pi),'b'); hold on;
plot(f,unwrap(true_phase*180/pi),'r');
% polar(phase,mag,'b'); hold on
% polar(true_phase,mag_ph,'r');
% plot(freq,unwrap(phase*180/pi),'b'); hold on;
% plot(freq,unwrap(true_phase*180/pi),'r');
% plot(freq,unwrap(phase-true_phase)*180/pi,'k');
grid on
axis tight

end