function val = convert_ppm_bin(handles, orig_val, convertTo)
%convert_ppm_bin takes a ppm or bin value and a string indicating what you
%which way you want to convert it
%val = convert_ppm_bin(handles, orig_val, convertTo)
%convertTo can be on of either 'ppm' or 'bin'
%to convert 100 ppm to bin:
%binval = convert_ppm_bin(handles, 100, 'bin')

ppm_axis = get_new_axis(handles, 'ppm');

if strcmp(convertTo, 'bin')
    val = find(ppm_axis > orig_val, 1) - 1;
elseif strcmp(convertTo, 'ppm')
    val = ppm_axis(orig_val-1);
end