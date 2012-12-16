%%
%these functions handle the SNR calculations depending on user input
function handleDataSelection(handles, brange, frange)
try
    bmin = brange(1);
    bmax = brange(2);
    fmin = frange(1);
    fmax = frange(2);
    data = getappdata(handles.figure1, 'data');
    
    if get(handles.slider_realmag, 'Value') == 1
        dpts = abs(getappdata(handles.figure1, 'currentDpts'));
    else
        dpts = real(getappdata(handles.figure1, 'currentDpts'));
    end
    
    isavg = getappdata(handles.figure1, 'isavg');

    dpts = dpts(bmin:bmax);
    
    %get the currently selection from drop down box
    %1 => signal, 2 => noise
    signoi_selection = get(handles.drop_sig_noi, 'Value');
    switch signoi_selection
        case 1
            %calculated the full width at half max
            [newsignal, lval, rval] = FWHM(dpts);
            lfval = getClosestFreq(data, bmin+lval);
            rfval = getClosestFreq(data, bmin+rval);
            %set the range of signal selection
            if isavg
                if isempty(data.getSigRangeAvg)
                    data.setSigRangeAvg([lfval rfval]);
                    data.setSigRangeAvgBin([bmin+lval bmin+rval])
                else
                    sig = data.getSigRangeAvg;
                    data.setSigRangeAvg([sig lfval rfval]);
                    data.setSigRangeAvgBin([sig bmin+lval bmin+rval])
                end

                %update the signal data
                if isempty(data.getSignalAvg) 
                    data.setSignalAvg(newsignal);
                else
                    data.setSignalAvg([data.getSignal newsignal]);
                end             
            else
                if isempty(data.getSigRange)
                    data.setSigRange([lfval rfval]);
                    data.setSigRangeBin([bmin+lval bmin+rval]);
                else
                    sig = data.getSigRange;
                    sigb = data.getSigRangeBin;
                    data.setSigRange([sig lfval rfval]);
                    data.setSigRangeBin([sigb bmin+lval bmin+rval]);
                end

                %update the signal data
                if isempty(data.getSignal) 
                    data.setSignal(newsignal);
                else
                    data.setSignal([data.getSignal newsignal]);
                end
            end
            %display calulation in status box
            updateStatusBox(handles, sprintf('FWHM: %.3f \n Range(Hz): %.2f->%.2f \n Range(bin): %d->%d', ...
                newsignal(end), lfval, rfval, bmin+lval, bmin+rval))
        case 2
%             sigrange = data.getSigRange;
%             sigrangeb = data.getSigRangeBin;
%             if numel(sigrange) >= 2
%                 %ensure that only the range of dpts used in the last signal
%                 %calculation is used for the noise calculation
%                 sig_span = sigrange(end) - sigrange(end-1);
%                 fmax = fmin + sig_span;
%                 
%                 sig_span_bin = sigrangeb(end) - sigrangeb(end-1);
%                 bmax = bmin + sig_span_bin;
%             end
                
            if isavg
                %save selected range
                data.setNoiRangeAvg([fmin fmax]);
                data.setNoiRangeAvgBin([bmin bmax]);

                %calculate and save noise, overwrites previously save noise
                %(only one can exist at a time)
                data.setNoiseAvg(calcNoise(dpts));   
            else
                %save selected range
                data.setNoiRange([fmin fmax]);
                data.setNoiRangeBin([bmin bmax]);

                %calculate and save noise, overwrites previously save noise
                %(only one can exist at a time)
                data.setNoise(calcNoise(dpts));
            end
            %update status box
            msg = sprintf('Noise: %.3f \n Range: %.2f->%.2f \n Range(bin): %d->%d', ...
                            data.getNoise, fmin, fmax, bmin, bmax);
            updateStatusBox(handles, msg)
    end
    setappdata(handles.figure1, 'data', data);
catch err
    disp(err.message)
end