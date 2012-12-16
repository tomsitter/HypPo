function [ ft ] = fft_centre( fid )
%FFT_CENTRE Summary of this function goes here
%   Detailed explanation goes here
    ft = fftshift(fft(fid, [], 2), 2);

end