function [signal, lval, rval] = FWHM(dpts) 
%calculate full width at half of the maximum value of a peak
%currently only returns the max value of the peak and the width
    dpts = real(dpts);

    %find max of peak
    [maxval, maxval_index] = max(dpts);
    
    %find all data points with signal >= 1/2 the max
    rval = maxval_index+1;
    lval = maxval_index-1;
    
    while 1
        if ((rval+1) < length(dpts)) && (dpts(rval+1) >= (maxval/2))
            rval = rval+1;
        else
            break
        end
    end
    
    while 1
        if ((lval-1) >= 1) && (dpts(lval-1) >= (maxval/2))
            lval = lval-1;
        else
            break
        end
    end

    %return the maximum value
    %alternatively you can consider returning the mean
    signal = max(dpts(lval:rval));
 end