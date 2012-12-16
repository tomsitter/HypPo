function [signal, lval, rval] = FWHM_returnMax(dpts) %calculate full width half max
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

    %sum up all the values in the the full width half max
    signal = max(dpts(lval:rval));
 end