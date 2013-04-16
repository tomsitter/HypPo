function plotSpectralStack2D(handles)
%plots all spectra
%data is the set of all spectra
%part is a string for what you want to see ('real', 'imag', 'mag', 'all')
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
       plot(1:numspec, dpts, 'bo');
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

xlabel('Acquisition')
ylabel('Peak Signal')

xlim([0 numspec]);

set(handles.push_flipangle, 'Enable', 'on');