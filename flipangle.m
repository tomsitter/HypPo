function [ angle ] = flipangle( handles )
%FLIPANGLE Summary of this function goes here
%   Detailed explanation goes here
%plots all spectra
%data is the set of all spectra
%part is a string for what you want to see ('real', 'imag', 'mag', 'all')

angle = 1.0;
hypData = getappdata(handles.figure1, 'data');
part = 'mag';
numspec = hypData.parms.rows;
%numsamples = hypData.parms.samples;
dpts = ones(numspec, 1);

switch part
    case 'real'
       for n=1:numspec
            dpts(n) = max(real(hypData.getFFT(n)));
       end
       plot(1:numspec, dpts);
    case 'mag'
       for n=1:numspec
            dpts(n) = max(abs(hypData.getFFT(n)));
       end
%        plot(1:numspec, dpts, 'bo');
    case 'all'
       dptsreal = ones(numspec, 1);
       dptsmag = ones(numspec, 1);
       for n=1:numspec
            dpts = hypData.getFFT(n);
            dptsmag(n) = max(abs(dpts));
            dptsreal(n) = max(real(dpts));
            plot(1:numspec, dptsmag);
            plot(1:numspec, dptsreal);
       end
end

% xlabel('Acquisition')
% ylabel('Peak Signal')
% 
% xlim([0 numspec]);

%index = [1 6 11 16 21 26 31 36 41 46];
start = 1;
spacing = 1;

multib = questdlg('Is this a multiple B value series?', '', 'Yes', 'No', 'No');
if strcmpi(multib, 'Yes')
     series = inputdlg({'Enter starting position:', 'Enter spacing: '}, ...
                   'Input series parametrs', 1, {'1', '5'});
    start = abs(str2double(cell2mat(series(1))));
    spacing = abs(str2double(cell2mat(series(2))));
    
    if isnan(start) || isempty(start)
        start = 1;
    end
    if isnan(spacing) || isempty(spacing)
        spacing = 1;
    end 
end

% threshold = str2num(cell2mat(inputdlg('Is this a multi-B value spectrum?')));
% 
% if not(isnumeric(threshold)) || isempty(threshold)
%     threshold = 0;
% end

index = start:spacing:length(dpts)';

% index = find(dpts > threshold)';
% index = nbs;
filtered_dpts = dpts(index);
% norm_sig_b0 = norm_sig(index);

log_signal = log(filtered_dpts)';
P = polyfit(index, log_signal, 1);
angle = acosd(exp(P(1)));
msg = sprintf('Flip angle is %.2f degrees', angle);
updateStatusBox(handles, msg);

% angle2 = asind(exp(P(2)));

xaxis = 1:length(dpts);

fitted_curve = cosd(angle).^xaxis/2*sind(angle);

scaled_curve = fitted_curve / max(fitted_curve) * max(dpts);

hold on;
plot(xaxis,scaled_curve,'-gx','MarkerSize',8)
hold off;

end