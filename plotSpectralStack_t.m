function []=plotSpectralStack_t(data, part)
%plots all spectra
%data is the set of all spectra
%part is a string for what you want to see ('real', 'imag', 'mag', 'all')
figure
hold on

samples = data.parms.samples;
numspec = data.parms.rows;
%spec_band = hypData.parms.sample_frequency;
spec_band = 1 / data.parms.dim1_step;

offset=input('Input the frequency offset in Hz:');
if isempty(offset)
    yaxis = 1:samples
else
    f = data.parms.synthesizer_frequency + offset;
    f_centre = ((-samples/2:samples/2-1)*spec_band/samples) + f;
    yaxis=((f_centre-f)./f)*10^6;
end

xaxis = ones(1, samples);

switch part
    case 'real'
        for n=1:numspec
            d=data.spectra(n).datapoints;
            plot3(yaxis,xaxis*n,real(d),'b-');
        end
    case 'imag'
        for n=1:numspec
            d=data(:,n);
            plot3(yaxis,xaxis*n,imag(d),'b-');
        end
    case 'mag'
        for n=1:numspec
            d=data(n,:);
            c = rand(3, 1) * 0.8 + 0.1;
            plot3(yaxis,xaxis*n,abs(d), 'Color', [c(1) c(2) c(3)]);
        end
    case 'all'
        for n=1:numspec
            d=data(n,:);
            plot3(yaxis,xaxis*n,real(d),'b-');
            plot3(yaxis,xaxis*n,imag(d),'r-');
            plot3(yaxis,xaxis*n,abs(d),'g-');
        end
end

xlim([min(yaxis) max(yaxis)]);

axis ij
view(-60,20)

hold off