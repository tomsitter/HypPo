classdef hypData < handle
    %HYPPODATA is an object representing that data in spar/sdat files
    %It contains the fields:
    %   filename        - the name of the file this data is from
    %   parms           - parameters extracted from the SPAR file
    %   avgData         - averaged data from phase correction
    %   flipangle       - unimplemented, will hold flip angle used in exp.
    %   spectra         - array of acquisitions from the scanner
    %       .signal     - signal, calculated using FWHM
    %       .sig_range  - x range of points selected for signal calculation
    %       .noise      - calculated noise (std)
    %       .noi_range  - x range of points selected for noise calc.
    %       .datapoints - acquisiton data points for current spectrum
    %       .snr        - can hold have of SNR, but not used
    %       .polar      - calculated polarization 
    %   index           - the index of the current spectrum of interest
    %   noisefile       - data associated with a file read for noise
    %       .filename   - name of noise file
    %       .noise      - calculated noise (std)
    %       .noi_range  - x range of points selected for noise calculation
    %   --------------------   To implement -------------------------     %
    %   phantomfile     - data associated with thermal phantom
    %       .polar
    %   allow import of hypData.mat files (they are saved as structures)
    
    properties
        spectra = struct('signal', [], ...  %array of fwhm calculations
                         'sig_range', [], ...       %array of x ranges used in fwhm calculations
                         'sig_range_bin', [], ...    %bin range
                         'noise', -1.0, ...         %calculated noise
                         'noi_range', [], ...       %x range of noise
                         'noi_range_bin', [], ...   %x range of noise (bin)
                         'fftdata', [], ...  %spectral data points (freq domain)
                         'fiddata', [], ...  %spectra data points (time domain)
                         'snr', [], ...             %array of (signal / noise) calculations for each element in signal
                         'polarization', ...        %calculated polarization
                            struct('pol_thermal', -1.0, ...
                                   'percentpol', -1.0), ...
                         'phaseangle', -1.0, ...      %0 order phase correction
                         'phaseangle1', -1.0);        %1st order phase correction
        avgspectrum = struct('signal', [], ...
                             'sig_range', [], ...
                             'sig_range_bin', [], ...
                             'noise', -1.0, ...
                             'noi_range', [], ...
                             'noi_range_bin', [], ...
                             'fiddata', [], ...
                             'fftdata', [], ...
                             'snr', []);
        thermalPhantom = struct('volume', -1.0, ...
                                'pressure', -1.0, ...
                                'frac_vol', -1.0, ...
                                'iso_abund', -1.0);
        hyperPhantom = struct('volume', -1.0, ...
                        'pressure', -1.0, ...
                        'frac_vol', -1.0, ...
                        'iso_abund', -1.0);
        ver = -1;
        parms = struct;
        filename = -1;
        flipangle = -1.0;
        noisefile = struct('filename',  -1, ...   %name of noise file
                           'noise', -1.0, ...      %noise calculated in file
                           'noi_range', [], ...
                           'noi_range_bin', []);       %x-range of noise selection
        index = 1;
    end

    methods
        %% Constructor
        % --- Defines data structure using passed in data matrix, data
        % structure, or will create a 'dummy structure' if no arguments are
        % passed in.
        % datavar can either be a matrix of acquisitions, a structure
        % returned from getData(), or an array hypData object.
        function obj = hypData(datavar)
            if nargin < 1 
                %nothing passed in, socreate a new object with no data
                disp('Creating dummy structure');
                obj.parms.rows = -1;
                obj.parms.samples = -1;
                obj.index = 1;
            else
                %determine if we can import the data into our object
                if isobject(datavar)
                    obj = datavar;
                    obj.index = 1;
                elseif isstruct(datavar)
                    %data read from SDAT/SPAR file using getData will
                    %contain a field 'raw'
                    if isfield(datavar, 'raw')
                        %get number of spectra
                        num_spec = datavar.parms.rows;  
                        obj.filename = datavar.filename;
                        obj.parms = datavar.parms; %experiment parameters
                        obj.ver = datavar.ver; %file version
                        obj.parms.padfactor = 4;
                        spec_data = padarray(datavar.spec_data, ...
                                   [0 (obj.parms.padfactor-1)*length(datavar.spec_data)], 0, 'post');

                        fft_spec_data = fft_centre(spec_data);

                        %get correct data into each spectra
                        for i = 1:num_spec
                            obj.spectra(i).fftdata = fft_spec_data(i, :);
                            obj.spectra(i).fiddata = spec_data(i, :);
                            obj.spectra(i).noise = -1.0;
                            obj.spectra(i).polar = -1.0;
                            obj.spectra(i).phaseangle = -1.0;
                        end
                    else
                        %assume that this is a previous hypObj
                        %initialize spectrum values that need to be
                        for i = 1:datavar.data.parms.rows
                            obj.spectra(i).noise = -1.0;
                            obj.spectra(i).polar = -1.0;
                            obj.spectra(i).phaseangle = -1.0;
                        end

                        %read in all fields and try to assign them to a
                        %new hypData object
                        fn = fieldnames(datavar);
                        for i = 1:numel(fn),
                            try
                                obj.(fn{i}) = datavar.(fn{i});
                            catch err
                                err.message;
                            end
                        end
                        %in case it was overwritten, reset index to 1
                        obj.index = 1;
                    end
                elseif ismatrix(datavar)
                    [rows cols] = size(datavar);

                    %assume less samples than data points
                    num_spec = min([rows cols]);

                    %if less columns than rows, want to transpose the matrix
                    if cols < rows
                        datavar = datavar';
                    end

                    obj.parms.rows = rows;
                    obj.parms.samples = cols;

                    %get correct data into each spectra
                    for i = 1:num_spec
                        obj.spectra(i).fftdata = datavar.spec_data(i, :);
                    end 
                end %ismatrix
            end %nargin < 1
        end %constructor
        
        %% --- Convenvience function, returns filename --- %%
        function identify(obj)
            disp(obj.filename);
        end
        
         %% Get functions %%
         %e.g.
         %get value in current dataset
         %fid = hypData.getFID()
         %
         %specify from which dataset to get the new value
         %noise = hypData.getNoise(index)
         function dps = getDatapoints(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             dps = abs(obj.spectra(i).fftdata);
         end
         
         function fid = getFID(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             fid = obj.spectra(i).fiddata;
         end
        
         function fft = getFFT(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
                fft = obj.spectra(i).fftdata;
         end
         
         function pa = getPhaseAngle(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             pa = obj.spectra(i).phaseangle;
         end
         
         function signal = getSignal(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             signal = obj.spectra(i).signal;
         end
         
         function noise = getNoise(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             noise = obj.spectra(i).noise;
         end
         
         function SNR = getSNR(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             SNR = obj.spectra(i).snr;
             if isempty(SNR)
                 try
                    SNR = obj.spectra(i).signal ./ obj.spectra(i).noise;
                 catch err
                     disp(err.message);
                 end
             end
         end
         
         function sr = getSigRange(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             sr = obj.spectra(i).sig_range;
         end
         
        function sr = getSigRangeBin(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             sr = obj.spectra(i).sig_range_bin;
         end
         
         function nr = getNoiRange(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             nr = obj.spectra(i).noi_range;
         end
         
        function nr = getNoiRangeBin(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             nr = obj.spectra(i).noi_range_bin;
         end
         
         function p = getPolar(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             p = obj.spectra(i).polar;
         end
         
         function dpts = getAllFFT(obj)
             dpts = ones(obj.parms.rows, obj.parms.samples*obj.parms.padfactor);
             size(dpts)
             for i = 1:length(obj.spectra)
                 dpts(i, :) = obj.getFFT(i);
             end
         end
         
         function spectrum = getSpectrum(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             spectrum = obj.spectra(i);
         end

         function pt = getPolThermal(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             pt = obj.spectra(i).polarization.pol_thermal;
         end
         
         function pp = getPercentPol(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             pp = obj.spectra(i).polarization.percentpol;
         end

         function tp = getThermalPhantom(obj)
            tp = obj.thermalPhantom;
         end
         
         function hp = getHyperPhantom(obj)
            hp = obj.hyperPhantom;
         end
         
         function avgdata = getAveragedData(obj)
             avgdata = obj.avgspectrum.fiddata;
         end
         
         function avgsig = getSignalAvg(obj)
             avgsig = obj.avgspectrum.signal;
         end
         
         function avgnoi = getNoiseAvg(obj)
             avgnoi = obj.avgspectrum.noise;
         end
         
         function avgsr = getSigRangeAvg(obj)
             avgsr = obj.avgspectrum.sig_range;
         end
         
         function avgnr = getNoiRangeAvg(obj)
             avgnr = obj.avgspectrum.noi_range;
         end
         
         function avgsr = getSigRangeAvgBin(obj)
             avgsr = obj.avgspectrum.sig_range_bin;
         end
         
         function avgnr = getNoiRangeAvgBin(obj)
             avgnr = obj.avgspectrum.noi_range_bin;
         end
         
         function SNR = getSNRAvg(obj)
             SNR = obj.avgspectrum.snr;
         end
         
         function fa = getFlipAngle(obj)
             fa = obj.flipangle;
         end
         
         %% Set functions %%
         %data specific to each acquisition
         %e.g.
         %set value in current dataset
         %hypData = hypData.setSignal(newSignal)
         %
         %specify which dataset gets the new value
         %hypData = hypData.setNoise(newNoise, index)
         function obj = setSignal(obj, signal, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             obj.spectra(i).signal = signal;
         end
         
        function obj = setNoise(obj, noise, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
            obj.spectra(i).noise = noise;
        end
         
        function obj = setSigRange(obj, sig_range, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
            obj.spectra(i).sig_range = sig_range;
        end
        
        function obj = setSigRangeBin(obj, sig_range, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
            obj.spectra(i).sig_range_bin = sig_range;
        end
        
        function obj = setNoiRange(obj, noi_range, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
            obj.spectra(i).noi_range = noi_range;
        end
        
        function obj = setNoiRangeBin(obj, noi_range, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
            obj.spectra(i).noi_range_bin = noi_range;
        end
        
        function obj = setSNR(obj, signal, noise, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             obj.spectra(i).snr = signal ./ noise;
        end
        
        function obj = setDatapoints(obj, dp, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
            obj.spectra(i).datapoints = dp;
        end
        
        function obj = setPolar(obj, p, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
            obj.spectra(i).polar = p;
        end
        
        function obj = setSpectrum(obj, spec, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
            obj.spectra(i) = spec;
        end
         
         function obj = setPhaseAngle(obj, angle, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             obj.spectra(i).phaseangle = angle;
         end
         
          function obj = setPolThermal(obj, pt, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             obj.spectra(i).polarization.pol_thermal = pt;
          end
         
         function obj = setPercentPol(obj, pp, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             obj.spectra(i).polarization.percentpol = pp;
         end
         
         %data relevant to entire file
         %Averaged Data properties
         function obj = setAveragedData(obj, avg)
             obj.avgspectrum.fiddata = avg;
         end
         
         function obj = setSignalAvg(obj, avgsig)
             obj.avgspectrum.signal = avgsig;
         end
         
         function obj = setNoiseAvg(obj, avgnoi)
             obj.avgspectrum.noise = avgnoi;
         end
         
         function obj = setSigRangeAvg(obj, avgsr)
             obj.avgspectrum.sig_range = avgsr;
         end
         
         function obj = setNoiRangeAvg(obj, avgnr)
             obj.avgspectrum.noi_range = avgnr;
         end
         
         function obj = setSigRangeAvgBin(obj, avgsr)
             obj.avgspectrum.sig_range_bin = avgsr;
         end
         
         function obj = setNoiRangeAvgBin(obj, avgnr)
             obj.avgspectrum.noi_range_bin = avgnr;
         end
         
         function obj = setSNRAvg(obj, signal, noise)
             obj.avgspectrum.snr = signal ./ noise;
         end
         
         function obj = setThermalPhantom(obj, p)
            obj.thermalPhantom = p;
         end
         
         function obj = setHyperPhantom(obj, p)
            obj.hyperPhantom = p;
         end
         
         %Experiment properties
         function obj = setFlipAngle(obj, fa, varargin)
             obj.flipangle = fa;
         end
         
         %Data analysis functions
         function obj = clearCalcs(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             obj.spectra(i).noise = -1.0;
             obj.spectra(i).noi_range = [];
             obj.spectra(i).signal = [];
             obj.spectra(i).sig_range = [];
             obj.spectra(i).snr = [];
         end
         
         function obj = clearCalcsAvg(obj)
             obj.avgspectrum.noise = -1.0;
             obj.avgspectrum.noi_range = [];
             obj.avgspectrum.signal = [];
             obj.avgspectrum.sig_range = [];
             obj.avgspectrum.snr = [];
         end
         
         function pc = correctPhase(obj, varargin)
             if isempty(varargin)
                 i = obj.index;
             else
                 i = varargin{1};
             end
             
             if obj.getPhaseAngle < 0
                pc = 1.0;
             else
                pc = exp(-1i * (obj.getPhaseAngle(i) * pi / 180.0));
             end
         end
    end
end

