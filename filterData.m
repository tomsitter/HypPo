function filterdata = filterData(dpts)
    
    filterFactor = 12;

    [col dim] = size(dpts);
    index = (1:dim)*filterFactor;
    
    %Apply the filter
    filterdata = dpts .* exp(-index./dim);

