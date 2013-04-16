function varargout = visualizer(varargin)
%VISUALIZER M-file for visualizer.fig
%      VISUALIZER, by itself, creates a new VISUALIZER or raises the existing
%      singleton*.
%
%      H = VISUALIZER returns the handle to a new VISUALIZER or the handle to
%      the existing singleton*.
%
%      VISUALIZER('Property','Value',...) creates a new VISUALIZER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to visualizer_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      VISUALIZER('CALLBACK') and VISUALIZER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in VISUALIZER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualizer

% Last Modified by GUIDE v2.5 16-Apr-2013 16:49:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualizer_OpeningFcn, ...
                   'gui_OutputFcn',  @visualizer_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before visualizer is made visible.
function visualizer_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

mainGuiInput = find(strcmp(varargin, 'hyppo'));
if (isempty(mainGuiInput))...
        || (length(varargin) <= mainGuiInput) ...
        || (not(ishandle(varargin{mainGuiInput+1})))
    if isappdata(handles.figure1, 'data')
        rmappdata(handles.figure1, 'data');
    end
    
    numphased = 0;
else  
    %remember the handle, and adjust our position
    handles.hyppo = varargin{mainGuiInput+1};

    %obtain handles using GUIDATA with the caller's handle
    mainHandles = guidata(handles.hyppo);

    %get (array of) files loaded in
    dataArr = getappdata(mainHandles.figure1, 'data');
    
    %assign last loaded file to data variable for use in rest of function
    data = dataArr(end);
    
    if data.filename ~= -1
        str = sprintf('Current File: %s', data.filename);
        updateStatusBox(handles, str);
    end

    if data.getAveragedData ~= -1
        set(handles.radio_viewavg, 'Enable', 'on');
    end

    numphased = 0;
    for i = 1:data.parms.rows
        phaseangle = data.getPhaseAngle(i);
        if phaseangle > -1
            numphased = numphased + 1;
        end
    end
    if numphased > 1 
        set(handles.radio_viewavg, 'Enable', 'on')
    end
    
    setappdata(handles.figure1, 'dataArr', dataArr)
    setappdata(handles.figure1, 'data', data)
    setappdata(handles.figure1, 'currentDpts', data.getFFT())
    setappdata(handles.figure1, 'curFileIndex', length(dataArr));
end

setappdata(handles.figure1, 'isavg', 0);
set(handles.text_sumimag, 'String', '');
set(handles.text_fimag, 'String', '');
set(handles.text_phaseangle, 'String', 0);
setappdata(handles.figure1, 'curSpecIndex', 1);
setappdata(handles.figure1, 'numphased', numphased);
%remember what axis value is
setappdata(handles.axes1, 'prevAxis', get(handles.radio_ppm, 'Value'));

updateSliders(handles);

updateVisPlot(handles)

% Choose default command line output for visualizer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes visualizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = visualizer_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Editable text boxes
% hObject    handle to edit_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_offset as text
%        str2double(get(hObject,'String')) returns contents of edit_offset as a double
% --------------------------------------------------------------------
function edit_offset_Callback(hObject, eventdata, handles)

function edit_angle_Callback(hObject, eventdata, handles)

function edit_step_Callback(hObject, eventdata, handles)

function edit_normalize_Callback(hObject, eventdata, handles)


%% Dropdown boxes
% hObject    handle to drop_sig_noi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns drop_sig_noi contents as cell array
%        contents{get(hObject,'Value')} returns selected item from drop_sig_noi
% --------------------------------------------------------------------
function drop_sig_noi_Callback(hObject, eventdata, handles)

%Display checkbox to get noise from seperate gui
%Deprecated, can be done by loading another file into visualizer
% choice = get(hObject, 'Value');
% 
% switch choice
%  case 1
%      set(handles.check_noisefile, 'val', 0);
%      set(handles.check_noisefile, 'Visible', 'off');
%  case 2
%      set(handles.check_noisefile, 'Visible', 'on');
% end

%% Push Buttons
% --------------------------------------------------------------------
function push_save_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the state of the data object and save it to a file
%also assign it into the workspace
if isappdata(handles.figure1, 'data')
    data = getappdata(handles.figure1, 'data');
    
%     if isappdata(handles.figure1, 'dataArr')
%         dataArr = getappdata(handles.figure1, 'dataArr');
%         curFileIndex = getappdata(handles.figure1, 'curFileIndex');
%         dataArr(curFileIndex) = data;
        
%         for i = 1:length(dataArr)
%             dataArr(i).index = 1;
%             varName = sprintf('hypObj%d', i);
%             assignin('base', varName, dataArr(i));
%         end
    
%         try
%             uisave('dataArr');
%         catch err
%             disp(err.message);
%         end
%     else
        assignin('base', 'specdata', data);
        
        try
            uisave('data');
        catch err
            disp(err.message)
        end
%     end
else
    msgbox('No loaded data');
end

function push_open_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% attempt to load in the data from the SPAR/SDAT files into a hyppo object
% save the object as ap data and display in the status box
try
    dataObj = getData();
    if isfield(dataObj, 'dataArr')
        dataObj = dataObj.dataArr;
    end
        
    for i = 1:length(dataObj)
        curData = hypData(dataObj(i));
        if isappdata(handles.figure1, 'dataArr')
            prevdata = getappdata(handles.figure1, 'dataArr');
            setappdata(handles.figure1, 'dataArr', [prevdata curData]);
        else
            setappdata(handles.figure1, 'dataArr', curData);
        end    
        
        str = sprintf('Loaded File: \n%s', curData.filename);
        updateStatusBox(handles, str);
    end
    
    setappdata(handles.figure1, 'dataArr', dataObj);
    setappdata(handles.figure1, 'data', curData);
    setappdata(handles.figure1, 'currentDpts', curData.getFFT());
    setappdata(handles.figure1, 'curFileIndex', length(dataObj));
    if ~isappdata(handles.figure1, 'curSpecIndex')
        setappdata(handles.figure1, 'curSpecIndex', 1)
    end
    
    if curData.getAveragedData ~= -1
        set(handles.radio_viewavg, 'Enable', 'on');
    end

    numphased = 0;
    for i = 1:curData.parms.rows
        phaseangle = curData.getPhaseAngle(i);
        if phaseangle > -1
            numphased = numphased + 1;
        end
    end
    if numphased > 1 
        set(handles.radio_viewavg, 'Enable', 'on')
    end
    
    setappdata(handles.figure1, 'numphased', numphased);
    
    updateSliders(handles);
    updateVisPlot(handles);
    
catch err
    disp(err.message)
end

function push_snr_Callback(hObject, eventdata, handles)
% hObject    handle to push_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1, 'data')
    calcSNR(handles);
else
    msgbox('No data read in yet.');
end

function calcSNR(handles)
%initialize SNR (there is one calculation per selected peak)
data = getappdata(handles.figure1, 'data');
t_noisefile = data.noisefile;

isavg = getappdata(handles.figure1, 'isavg');

if isavg
    %make sure signal and noise have been selected by user
    if isempty(data.getSignalAvg)
        msgbox('Missing selection of signal peaks', ...
            'Missing Data', ...
            'warn');
        %set dropdown box to 'signal'
        set(handles.drop_sig_noi, 'val', 1);
    elseif data.getNoiseAvg == -1 && t_noisefile.noise == -1
        msgbox('Missing selection of noise region', ...
            'Missing Data', ...
            'warn');
        %set dropdown box to 'noise'
        set(handles.drop_sig_noi, 'val', 2);
    else
        if t_noisefile.noise ~= -1
            data.setSNRAvg(data.getSignalAvg, t_noisefile.noise);
        else
            data.setSNRAvg(data.getSignalAvg, data.getNoiseAvg);
        end

        snr = data.getSNRAvg;
    end
else
    %make sure signal and noise have been selected by user
    if isempty(data.getSignal)
        msgbox('Missing selection of signal peaks', ...
            'Missing Data', ...
            'warn');
        %set dropdown box to 'signal'
        set(handles.drop_sig_noi, 'val', 1);
    elseif data.getNoise == -1 && t_noisefile.noise == -1
        msgbox('Missing selection of noise region', ...
            'Missing Data', ...
            'warn');
        %set dropdown box to 'noise'
        set(handles.drop_sig_noi, 'val', 2);
    else
        if t_noisefile.noise ~= -1
            data.setSNR(data.getSignal, t_noisefile.noise);
        else
            data.setSNR(data.getSignal, data.getNoise);
        end

        snr = data.getSNR;
    end
end

setappdata(handles.figure1, 'data', data);

if exist('snr', 'var')
    for i=1:length(snr) %each element of signal is a peak
       %update status box
       updateStatusBox(handles, sprintf('SNR %d: %.3f', i, snr(i)));
    end
end

function push_clear_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1, 'data')
    data = getappdata(handles.figure1, 'data');
    if getappdata(handles.figure1, 'isavg')
        setappdata(handles.figure1, 'data', data.clearCalcsAvg());
    else
        setappdata(handles.figure1, 'data', data.clearCalcs());
    end
    updateVisPlot(handles);
    updateStatusBox(handles, 'Selection Cleared');
end

function push_id_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1, 'data')
    data = getappdata(handles.figure1, 'data');
    if getappdata(handles.figure1, 'isavg')
        sigRange = data.getSigRangeAvg;
        sigRangeB = data.getSigRangeAvgBin;
        noiRange = data.getNoiRangeAvg;
        noiRangeB = data.getNoiRangeAvgBin;      
        sig = data.getSignalAvg;
        noi = data.getNoiseAvg;
    else
        sigRange = data.getSigRange;
        sigRangeB = data.getSigRangeBin;
        noiRange = data.getNoiRange;
        noiRangeB = data.getNoiRangeBin;
        sig = data.getSignal;
        noi = data.getNoise;
    end
    
    if numel(noiRange)>0
        str = sprintf(['Noise: %.3f\n' ...
                       '  Range: %.2f->%.2f\n' ...
                       '  Range(bin): %d->%d'], ...
                   noi, noiRange(1), noiRange(2), noiRangeB(1), noiRangeB(2));
        updateStatusBox(handles, str)
    else
        str = 'Missing selection of noise region';
        updateStatusBox(handles, str);
        return;
    end
    
    for i = 1:length(sig)
        str = sprintf(['SNR: %.3f\n' ...
                       '  Signal: %.3f\n' ...
                       '  Range: %.2f->%.2f\n' ...
                       '  Range(bin): %d->%d'], ...
              sig(i)/noi, sig(i), sigRange(2*i-1), sigRange(2*i), ...
              sigRangeB(2*i-1), sigRangeB(2*i));
        updateStatusBox(handles, str)
    end
end

function push_auto_ClickedCallback(~, eventdata, handles)
% hObject    handle to push_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1, 'data');
    if get(handles.check_domain, 'Value')
        automateSNR(handles);
    end
end

function push_selectdata_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_selectdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1, 'data')
    set(hObject, 'Enable', 'off')
    try
        %rect contains dimensions of selected region
        %[xmin ymin width height]
        rect = getrect(handles.axes1);

        %perform selection if rect has been given a value
        if (not(isempty(rect)))
            data = getappdata(handles.figure1, 'data');

            xmin = fix(rect(1));
            xmax = xmin + fix(rect(3));
            
            [bmin, fmin] = getClosestBin(data, xmin);
            [bmax, fmax] = getClosestBin(data, xmax);
            
            handleDataSelection(handles, [bmin bmax], [fmin fmax]);
            
            hold on;
            updateVisPlot(handles);
        end
    catch err
        throw(err);
    end
    set(hObject, 'Enable', 'on')
end

function push_offset_ClickedCallback(hObject, ~, handles)
% hObject    handle to push_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1, 'data')
    set(hObject, 'Enable', 'off')
    try
        updateStatusBox(handles, 'Draw boxes around the two peaks of interest');
        %answer should be the same regardless of whether the dpts are
        %mag/real values, but this may be needed in the future.
        if get(handles.slider_realmag, 'Value') == 1
            spec_part = 'magnitude';
            dpts = abs(getappdata(handles.figure1, 'currentDpts'));
        else
            spec_part = 'real';
            dpts = real(getappdata(handles.figure1, 'currentDpts'));
        end
        
        data = getappdata(handles.figure1, 'data');


        offset = str2double(get(handles.edit_offset, 'String'));
        if isnan(offset)
            offset=0;
        end

        f = data.parms.synthesizer_frequency + offset;
        
        xaxis = (frequencyAxis(data) / f) * 10^6;

        %perform selection if rect has been given a value
        lm = zeros(1, 2);
        for i = 1:2
            %rect contains dimensions of selected region
            %[xmin ymin width height]
            rect = getrect(handles.axes1);

            if (not(isempty(rect)))
                x1 = rect(1);
                x2 = x1 + rect(3);

                %b1 = ppmTobin(handles, x1);
                %b2 = ppmTobin(handles, x2);
                b1 = find(xaxis > x1, 1);
                b2 = find(xaxis > x2, 1);
                
                [~, ind] = max(dpts(b1:b2));           
                %lm(i) = binToppm(handles, b1+ind);
                lm(i) = xaxis(b1+ind-1);
                
                str = sprintf('Peak %d selected', i);
                updateStatusBox(handles, str);
            end
        end
         offset = num2str(abs(lm(2) - lm(1)));
         str = sprintf('Peaks in the %s part are offset by %s ppm', spec_part, offset);
         updateStatusBox(handles, str);
    catch err
        throw(err)
    end
    set(hObject, 'Enable', 'on')
end

function push_parms_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_parms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1, 'data')
    data = getappdata(handles.figure1, 'data');
    assignin('base', 'data_parms', data.parms);
    updateStatusBox(handles, evalc('parms = data.parms'));
end

function push_flipangle_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_flipangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

angle = flipangle( handles );

data = getappdata(handles.figure1, 'data');
setappdata(handles.figure1, 'data', data.setFlipAngle( angle ));


function push_normalize_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateVisPlot(handles)

function push_autophase_Callback(hObject, eventdata, handles)
% hObject    handle to push_autophase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(handles.figure1, 'data');

for i = 1:data.parms.rows
    %PHASE CORRECTION
    fid = data.getFID(i);
    fft = data.getFFT(i);
    
    %data is put through a low pass filter to improve chance of correct
    %phasing
    filterfid = filterData(fid);
    [~, ind] = max(abs(filterfid));
    dpt = filterfid(ind);
    
    %calculate phase angle from max val of FID
    phaseangle = round( atand( imag(dpt)/real(dpt)));

    %phase angle must be >0
    if phaseangle < 0
        phaseangle = phaseangle + 360;
    end
    
    %correct phase
    %phasedatafid = fid*exp(-1j*(phaseangle*pi/180));
    phasedatafft = fft*exp(-1j*(phaseangle*pi/180));
    
    %CHECKS
    
    %correct quadrant?
    %if not, flip by 180 degrees into correct axis
    if abs(max(real(phasedatafft))) < abs(min(real(phasedatafft)))
        phaseangle = mod(phaseangle + 180, 360);
    end
    
    %Two more checks not yet implemented
    
    %small angle?
    
    %sum(imag) ~= 0
    
    %Update the sum of the imaginary part in frequency space
    %sumimag = sum(imag(phasedatafft));
    %set(handles.text_sumimag, 'String', sumimag);

    %Update the value of the max of the imaginary part in time space
    %[~, ind] = max(abs(phasedatafid));
    %set(handles.text_fimag, 'String', imag(phasedatafid(ind)));
    
    data.setPhaseAngle(phaseangle, i);
end

setappdata(handles.figure1, 'data', data);
set(handles.text_phaseangle, 'String', data.getPhaseAngle());
set(handles.radio_viewavg, 'Enable', 'on');
%set appropriate phase data
setappdata(handles.figure1, 'phaseangle', data.getPhaseAngle());
setappdata(handles.figure1, 'phasedata', data.getFFT());
setappdata(handles.figure1, 'phasedatafid', data.getFID());

% cleanphasedata(handles.figure1);

updateVisPlot(handles);

function push_incrangle_Callback(hObject, eventdata, handles)
% hObject    handle to push_incrangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get previous angle and increment by the amount specified by user
angle = str2double(get(handles.edit_angle, 'String'));
curAngle = str2double(get(handles.text_phaseangle, 'String'));
%prevangle = getappdata(handles.figure1, 'phaseangle');
phaseangle = mod(curAngle+angle, 360);

%update the phase angle and display it
setappdata(handles.figure1, 'phaseangle', phaseangle);
set(handles.text_phaseangle, 'String', phaseangle);

%phase correct the data and display the change
phaseCorrect(handles);

function push_decrangle_Callback(hObject, eventdata, handles)
% hObject    handle to push_decrangle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get previous angle and increment by the amount specified by user
angle = str2double(get(handles.edit_angle, 'String'));
curAngle = str2double(get(handles.text_phaseangle, 'String'));
%prevangle = getappdata(handles.figure1, 'phaseangle');
phaseangle = mod(curAngle-angle, 360);

%update the phase angle and display it
setappdata(handles.figure1, 'phaseangle', phaseangle);
set(handles.text_phaseangle, 'String', phaseangle);

%phase correct the data and display the change
phaseCorrect(handles);

function push_finish_phase_Callback(hObject, eventdata, handles)
% hObject    handle to push_finish_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isappdata(handles.figure1, 'phaseangle')
    
    data = getappdata(handles.figure1, 'data');
    if data.getPhaseAngle > -1
        prevnum = getappdata(handles.figure1, 'numphased');
        setappdata(handles.figure1, 'numphased', (prevnum+1));
        if prevnum > 0
            set(handles.radio_viewavg, 'Enable', 'on');
        end
    end

    text_phaseangle = str2double(get(handles.text_phaseangle, 'String'));
    %phaseangle = getappdata(handles.figure1, 'phaseangle');
    phaseangle = data.getPhaseAngle();

    if text_phaseangle ~= phaseangle && ~isnan(text_phaseangle)
        data = data.clearCalcs();
    end
    
    data = data.setPhaseAngle( ...
                    mod(getappdata(handles.figure1, 'phaseangle'), 360 ));
    setappdata(handles.figure1, 'data', data);
    
    set(handles.check_average, 'Value', 0);
    set(handles.panel_phase, 'Visible', 'off');
    
    %remove all phase data, prepare for next phase correction
    cleanphasedata(handles.figure1);
    
    updateVisPlot(handles);
    
    set(handles.push_discard, 'Enable', 'off');
    set(handles.spectrum_slider, 'Enable', 'on');
end

function push_discard_Callback(hObject, eventdata, handles)
% hObject    handle to push_discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
        
%remove all phase data and reset current spectrum
cleanphasedata(handles.figure1);

set(handles.text_phaseangle, 'String', 0);
set(handles.text_sumimag, 'String', []);
set(handles.text_fimag, 'String', []);

%plot the selected spectrum
updateVisPlot(handles)

set(handles.spectrum_slider, 'Enable', 'on');
set(hObject, 'Enable', 'off');

function figure = cleanphasedata(figure)
    fields = fieldnames(getappdata(figure));
    matches = regexp(fields, '^phase\w*');
    for i = 1:length(matches)
        if not(isempty(matches{i}))
            rmappdata(figure, fields{i});
        end
    end

function phaseCorrect(handles)

%get appropriate phase data
phaseangle = getappdata(handles.figure1, 'phaseangle');
phasedata = getappdata(handles.figure1, 'phasedata');
phasedatafid = getappdata(handles.figure1, 'phasedatafid');

%PHASE CORRECTION

%calculate phase correction
phase0=exp(-1j*(phaseangle*pi/180));

%correct phase
phasedata=phasedata*phase0;
phasedatafid = phasedatafid*phase0;

%Update the sum of the imaginary part in frequency space
sumimag = sum(imag(phasedata));
set(handles.text_sumimag, 'String', sumimag);

%Update the value of the max of the imaginary part in time space
[~, ind] = max(abs(phasedatafid));
set(handles.text_fimag, 'String', imag(phasedatafid(ind)));

%update plot
updateVisPlot(handles)

set(handles.push_discard, 'Enable', 'on');
set(handles.spectrum_slider, 'Enable', 'off');

function push_incrLorentz_Callback(hObject, eventdata, handles)
% hObject    handle to push_incrLorentz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curVal = str2double(get(handles.text_lorentz, 'String'));
step = str2double(get(handles.edit_step, 'String'));
set(handles.text_lorentz, 'String', curVal+step)
updateVisPlot(handles)
function push_decrLorentz_Callback(hObject, eventdata, handles)
% hObject    handle to push_decrLorentz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step = str2double(get(handles.edit_step, 'String'));
curVal = str2double(get(handles.text_lorentz, 'String'));

if (curVal-step) < 0
    set(handles.text_lorentz, 'String', 0)
else
    set(handles.text_lorentz, 'String', curVal-step)
end
updateVisPlot(handles)

function push_incrGauss_Callback(hObject, eventdata, handles)
% hObject    handle to push_incrGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step = str2double(get(handles.edit_step, 'String'));
curVal = str2double(get(handles.text_gauss, 'String'));
set(handles.text_gauss, 'String', curVal+step)
updateVisPlot(handles)
function push_decrGauss_Callback(hObject, eventdata, handles)
% hObject    handle to push_decrGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
step = str2double(get(handles.edit_step, 'String'));
curVal = str2double(get(handles.text_gauss, 'String'));

if (curVal - step) < 0
    set(handles.text_gauss, 'String', 0)
else
    set(handles.text_gauss, 'String', curVal-step)
end
updateVisPlot(handles)

%% Radio and Check boxes
% --------------------------------------------------------------------
function radio_viewavg_Callback(hObject, eventdata, handles)
% hObject    handle to radio_viewavg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_viewavg
if isappdata(handles.figure1, 'data')
    
    data = getappdata(handles.figure1, 'data');

    if (get(hObject, 'Value')) == 1
        setappdata(handles.figure1, 'isavg', 1);
        %initialize phasedata matrix if it's known that all spectra were
        %phased
        phasedata = [];
        for i = 1:data.parms.rows
            %phaseangle = data.getPhaseAngle(i);
            phasedata = [phasedata ; ...
                        (data.getFID(i) * data.correctPhase(i))];
        end

        [rows, ~] = size(phasedata);

        if rows > 1
            setappdata(handles.figure1, 'data', data.setAveragedData( mean(phasedata)));
        end
    else
        setappdata(handles.figure1, 'data', data.setAveragedData([]));
        setappdata(handles.figure1, 'isavg', 0);
    end
    updateVisPlot(handles);
end

function radio_resetaxis_Callback(hObject, eventdata, handles)
% hObject    handle to radio_resetaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_resetaxis

data = getappdata(handles.figure1, 'data');
dpts = getappdata(handles.figure1, 'currentDpts');

%determine if frequency domain
if get(handles.check_domain, 'Value') == 1
    %determine if ppm or Hz
    if get(handles.radio_ppm, 'Value') == 1
        %create chemical shift axis
        offset = str2double(get(handles.edit_offset, 'String'));
        if isnan(offset)
            offset=0;
        end
        
        xaxis = ppmAxis(data, offset); %(xaxis/f)*10^6;
        xlbl = sprintf('offset = %d ppm', offset);
        if isappdata(handles.axes1, 'xlim_ppm')
            rmappdata(handles.axes1, 'xlim_ppm');
        end
        if isappdata(handles.axes1, 'ylim_ppm')
            rmappdata(handles.axes1, 'ylim_ppm');
        end
    else
        xaxis = frequencyAxis(data);
        xlbl = 'frequency (Hz), f - fo';
        if isappdata(handles.axes1, 'xlim_hz')
            rmappdata(handles.axes1, 'xlim_hz');
        end
        if isappdata(handles.axes1, 'ylim_hz')
            rmappdata(handles.axes1, 'ylim_hz');
        end
    end
else
    xaxis = timeAxis(data);
    xlbl = 'Time';
end

xlim([xaxis(1) xaxis(end)])
if exist('xlbl', 'var')
    xlabel(xlbl)
end


ymin = min([min(real(dpts)) min(imag(dpts))]);
ymax = max([max(real(dpts)) max(abs(dpts)) max(imag(dpts))]);
ylim([ymin ymax])

function radio_ppm_Callback(hObject, eventdata, handles)
% hObject    handle to radio_ppm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_ppm
% 0 => hz, 1 => ppm
if get(hObject, 'Value')
    set(handles.push_clear, 'Enable', 'off')
    set(handles.push_id, 'Enable', 'off')
    set(handles.push_auto, 'Enable', 'off')
    set(handles.push_selectdata, 'Enable', 'off')
    set(handles.push_offset, 'Enable', 'on')
else
    set(handles.push_clear, 'Enable', 'on')
    set(handles.push_id, 'Enable', 'on')
    set(handles.push_auto, 'Enable', 'on')
    set(handles.push_selectdata, 'Enable', 'on')

    set(handles.push_offset, 'Enable', 'off')
end

updateVisPlot(handles)

function check_fitfid_Callback(hObject, eventdata, handles)
% hObject    handle to check_fitfid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_fitfid
dpts = abs(getappdata(handles.figure1, 'currentDpts'));
if not(isempty(dpts))
    eqt = fitFID(dpts);
    set(handles.text_curve, 'String', eqt);
end

function check_domain_Callback(hObject, ~, handles)
% hObject    handle to check_domain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_domain
    if get(hObject, 'Value')
        set(handles.radio_ppm, 'Enable', 'on');
        set(handles.push_selectdata, 'Enable', 'on');
    else
        set(handles.radio_ppm, 'Enable', 'off');
        set(handles.push_selectdata, 'Enable', 'off');
    end
    updateVisPlot(handles);

function check_average_Callback(hObject, eventdata, handles)
% hObject    handle to check_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_average

%if the average box is checked
if isappdata(handles.figure1, 'data')
    if get(hObject, 'Value')
        data = getappdata(handles.figure1, 'data');
        set(handles.panel_phase, 'Visible', 'on');

        %want to average data
        if isempty(getappdata(handles.figure1, 'phaseangle'))
            %get the data in both time and freq space
            phasedatafid = data.getFID;
            phasedatafft = data.getFFT;
            %phase angle is initialized to -1
            phaseangle = max(data.getPhaseAngle, 0);

            %initialize the phase data
            setappdata(handles.figure1, 'phasedata', phasedatafft);
            setappdata(handles.figure1, 'phasedatafid', phasedatafid);
            setappdata(handles.figure1, 'phaseangle', phaseangle);

            %initialize the text fields
            sumimag = sum(imag(phasedatafft));
            set(handles.text_sumimag, 'String', sumimag);

            [~, ind] = max(abs(phasedatafid));
            set(handles.text_fimag, 'String', imag(phasedatafid(ind)));
            
            set(handles.text_phaseangle, 'String', phaseangle);
        end
    else
        set(handles.panel_phase, 'Visible', 'off')
    end
end

% function check_noisefile_Callback(hObject, eventdata, handles)
% hObject    handle to check_noisefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% Hint: get(hObject,'Value') returns toggle state of check_noisefile
% try
%     if get(hObject, 'Value') == 1
%         snr_gui_noise('visualizer', handles.figure1);
%         data = getappdata(handles.figure1, 'data');
% 
%         msg = sprintf('Noise: %f', noise);
%         updateStatusBox(handles, sprintf('Noise: %.3f', data.noisefile.noise));
%     else
%         data = getappdata(handles.figure1, 'data');
%         if data.noisefile.noise > -1.0
%             data.noisefile.noise = -1.0;
%             data.noisefile.filename = -1.0;
%             data.noisefile.noi_range = [-1.0 -1.0];
%             data.noisefile.noi_range_bin = [-1.0 -1.0];
%         end
%         updateStatusBox(handles, sprintf('Noise file data cleared'));
%     end
% catch err
%     disp(err.message);
% end

%% Toggles
% --------------------------------------------------------------------
function tog_real_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tog_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateVisPlot(handles);

function tog_imag_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tog_imag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateVisPlot(handles);

function tog_mag_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tog_mag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateVisPlot(handles);

function tog_waterfall_OnCallback(hObject, eventdata, handles)
% hObject    handle to tog_waterfall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.panel_2d3d, 'Visible', 'on');
set(handles.panel_phase, 'Visible', 'off');
set(handles.radio_viewavg, 'Enable', 'off');
set(handles.check_average, 'Enable', 'off');
set(handles.radio_resetaxis, 'Enable', 'off');

updateVisPlot(handles);

function tog_waterfall_OffCallback(hObject, eventdata, handles)
% hObject    handle to tog_waterfall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.panel_2d3d, 'Visible', 'off');
set(handles.radio_viewavg, 'Enable', 'on');
set(handles.check_average, 'Enable', 'on');
set(handles.radio_resetaxis, 'Enable', 'on');

updateVisPlot(handles);

function tog_filter_OnCallback(hObject, eventdata, handles)
% hObject    handle to tog_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% data = getappdata(handles.figure1, 'data');

if strcmp(get(handles.tog_filter2, 'State'), 'on')
    set(handles.tog_filter2, 'State', 'off')
end
updateVisPlot(handles);

function tog_filter_OffCallback(hObject, eventdata, handles)
% hObject    handle to tog_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if isappdata(handles.figure1, 'filterdata')
%     rmappdata(handles.figure1, 'filterdata');
if isappdata(handles.figure1, 'data')
    data = getappdata(handles.figure1, 'data');
    if getappdata(handles.figure1, 'isavg')
        setappdata(handles.figure1, 'data', data.clearCalcsAvg());
    else
        setappdata(handles.figure1, 'data', data.clearCalcs());
    end

    updateVisPlot(handles);
end

function tog_filter2_OnCallback(hObject, eventdata, handles)
% hObject    handle to tog_filter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.tog_filter, 'State'), 'on')
    set(handles.tog_filter, 'State', 'off')
end
set(handles.panel_filter2, 'Visible', 'on');
updateVisPlot(handles);

function tog_filter2_OffCallback(hObject, eventdata, handles)
% hObject    handle to tog_filter2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.panel_filter2, 'Visible', 'off');
if isappdata(handles.figure1, 'data')
    data = getappdata(handles.figure1, 'data');
    if getappdata(handles.figure1, 'isavg')
        setappdata(handles.figure1, 'data', data.clearCalcsAvg());
    else
        setappdata(handles.figure1, 'data', data.clearCalcs());
    end
    updateVisPlot(handles);
end

function tog_normalize_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tog_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateVisPlot(handles);

%% Sliders
% --------------------------------------------------------------------
function file_slider_Callback(hObject, eventdata, handles)
% hObject    handle to file_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.file_slider, 'Enable', 'off');

try
    if isappdata(handles.figure1, 'dataArr')
        %get current file data
        curData = getappdata(handles.figure1, 'data');
        curSpecIndex = getappdata(handles.figure1, 'curSpecIndex');
        
        %%clean up current calculations        
        text_phaseangle = str2double(get(handles.text_phaseangle, 'String'));
        phaseangle = curData.getPhaseAngle(curSpecIndex);
        if text_phaseangle ~= phaseangle && text_phaseangle ~= 0
            choice = questdlg('Would you like to accept the current phase change?', ...
                'Save Phase Changes', ...
                'Yes', 'No', 'Yes');
            drawnow;
            waitfor(choice);
            if strcmp(choice, 'Yes')
                curData = curData.setPhaseAngle(text_phaseangle, curSpecIndex);
                curData = curData.clearCalcs(curSpecIndex);
            end
        end
        %remove all phase data, prepare for next phase correction
        cleanphasedata(handles.figure1);
        set(handles.text_phaseangle, 'String', 0);
        set(handles.text_sumimag, 'String', []);
        set(handles.text_fimag, 'String', []);
        
        %%Switch active variables and store all calculations
        %%get current file index
        curFileIndex = getappdata(handles.figure1, 'curFileIndex');

        %get all the file data
        dataArr = getappdata(handles.figure1, 'dataArr');
        %update the current files data
        dataArr(curFileIndex) = curData;
        
        %get the index for the new file to be loaded
        newFileIndex = fix(get(hObject, 'Value'));
        %updata the current file index
        setappdata(handles.figure1, 'curFileIndex', newFileIndex);
                
        %get the data for the new file
        newData = dataArr(newFileIndex);

        %try to keep index the same
        if length(newData.spectra) >= curSpecIndex
            newData.index = curSpecIndex;
        else
            newData.index = length(newData.spectra);
            setappdata(handles.figure1, 'curSpecIndex', length(newData.spectra));
        end
        
        %set the new file data to the working data variable
        setappdata(handles.figure1, 'data', newData);
        
        updateSliders(handles);
        
        %%update status box
        str = sprintf('Current File: %s', newData.filename);
        updateStatusBox(handles, str);

        %prepare the gui for a new spectrum
        set(handles.panel_phase, 'Visible', 'off');
        set(handles.check_average, 'Value', 0);

        %%plot the selected spectrum
        updateVisPlot(handles)
    end
catch err
    disp(err.message)
    set(handles.file_slider, 'Enable', 'on');
end

set(handles.file_slider, 'Enable', 'on');

function spectrum_slider_Callback(hObject, ~, handles)
% hObject    handle to spectrum_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%set(handles.spectrum_slider, 'Enable', 'off')
% try
    if isappdata(handles.figure1, 'data')
        data = getappdata(handles.figure1, 'data');

        %get current value of slider to determine which spectrum to plot
        data.index = fix(get(hObject, 'Value'));
        
        setappdata(handles.figure1, 'curSpecIndex', data.index);
        
        %update status box
        str = sprintf('Spectrum Index: %d', data.index);
        updateStatusBox(handles, str);

        %update the index in the object
        setappdata(handles.figure1, 'data', data);

        %prepare the gui for a new spectrum
        set(handles.panel_phase, 'Visible', 'off');
        set(handles.check_average, 'Value', 0);

        %remove all phase data, prepare for next phase correction
        cleanphasedata(handles.figure1);

        set(handles.text_phaseangle, 'String', 0);
        set(handles.text_sumimag, 'String', []);
        set(handles.text_fimag, 'String', []);

        %plot the selected spectrum
        updateVisPlot(handles)
    end

function slider_realmag_Callback(hObject, eventdata, handles)
% hObject    handle to slider_realmag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
try
    set(handles.push_selectdata, 'Enable', 'on');
    if isappdata(handles.figure1, 'data')
        val = get(hObject, 'Value');
        if val == 0
            set(handles.tog_real, 'State', 'on');
                data = getappdata(handles.figure1, 'data');
                prevnum = getappdata(handles.figure1, 'numphased');
                for i = 1:data.parms.rows
                    if data.getPhaseAngle(i) > -1
                           prevnum = prevnum + 1;
                    end
                end
                if prevnum > 1
                    set(handles.radio_viewavg, 'Enable', 'on');
                else
                    set(handles.radio_viewavg, 'Enable', 'off')
                end
                setappdata(handles.figure1, 'numphased', (prevnum+1));
        else
            set(handles.tog_mag, 'State', 'on');
            set(handles.radio_viewavg, 'Enable', 'on')
        end
        data = getappdata(handles.figure1, 'data');
        setappdata(handles.figure1, 'data', data.clearCalcs());
        updateVisPlot(handles);
    end
catch err
    disp(err)
end

function slider_2d3d_Callback(hObject, eventdata, handles)
% hObject    handle to slider_2d3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateVisPlot(handles);

%% Create and Delete Functions
% Executes during object creation, after setting all properties.
% --------------------------------------------------------------------
function statusbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_normalize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function file_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function drop_sig_noi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to drop_sig_noi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function slider_2d3d_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_2d3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edit_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function spectrum_slider_CreateFcn(hObject, ~, handles)
% hObject    handle to spectrum_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider_realmag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_realmag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function edit_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function check_average_DeleteFcn(hObject, eventdata, handles)


% --------------------------------------------------------------------
function push_polarization_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_polarization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isappdata(handles.figure1, 'data')
%     try
        msg = sprintf('Beginning polarization calculation, see workspace');
        updateStatusBox(handles, msg);         
        disp('Polarization Calculation: \n\n');
       
        data = getappdata(handles.figure1, 'data');
    
        nucleus = char(data.parms.nucleus);

        gamma = -1;
        %gamma is in rad s^-1 T^-1
        %values are obtained from
        switch(nucleus)
            case '129Xe'
                gamma = 73.997e6;
            case '3He'
                gamma = 203.789e6;
            case '1H'
                gamma = 267.513e6;
            case '13C'
                gamma = 67.262e6;
            case '31P'
                gamma = 108.291e6;
            case '19F'
                gamma = 251.662e6;
        end

        %fprintf('Input the data from the thermal phantom experiment: \n')

        [data, mol_tp] = idealmoles(data, 'thermal');
        thermal_snr = input('Enter SNR from thermal experiment: ');

        thermal_pol = ThermalP(gamma);
        data = data.setPolThermal(thermal_pol);
        %fprintf('Input the data from the polarization test experiment: \n')

        [data, mol_hyp]=idealmoles(data, 'hyper');
        hyper_snr = input('Enter SNR from hyperpolarized experiment: ');
        
        %calculate the Xe polarization:
        polarization = (hyper_snr/thermal_snr) * (mol_tp/mol_hyp) * thermal_pol * 100;

        data.setPercentPol(polarization);

        msg = sprintf('The percent polarization of %s is %f%%', nucleus, polarization);
        disp(msg)
        updateStatusBox(handles, msg);
        
        setappdata(handles.figure1, 'data', data);
%     catch err
%         throw(err);
%         msg = sprintf('Polarization calculation failed: %s', err.message);
%         disp(msg)
%         updateStatusBox(handles, msg)
%     end
end

%% Calculate moles of gas using ideal gas law
function [data, moles]=idealmoles(data, phantom_type)
%% Phantom should be either 'thermal' or 'hyper'

    R=0.08206; %L atm per K mol
    T = 298; %K
    
    if strcmpi(phantom_type, 'hyper')
        phantom = data.getHyperPhantom;
        %for displaying to user later in this function
        phantom_type = 'hyperpolarized';
    else
        phantom = data.getThermalPhantom;
    end
    
    P = phantom.pressure;
    V = phantom.volume;
    fV = phantom.frac_vol;
    b = phantom.iso_abund;
        
    if (P == -1)
        reply = 'N';
    else
        msg = sprintf(['\nCurrent %s phantom has: \n' ...
                        'Pressure: %f atm\n' ...
                        'Volume: %f L\n' ...
                        'Fractional Volume: %f\n' ...
                        'Isotopic Abundance: %f\n'], phantom_type, P, V, fV, b);
        disp(msg);

        reply = input('Are these the correct parameters? (Y/N): ', 's');
        if isempty(reply)
            reply = 'Y';
        end
    end

    if strcmpi(reply, 'N')
        msg = sprintf('Enter the correct parameters for the %s phantom: ', phantom_type);
        disp(msg);
        P = input('Enter pressure (atm): ');
        phantom.pressure = P;
        V = input('Enter volume (L): ');
        phantom.volume = V;
        %find the nucleus
        nucleus = data.parms.nucleus;
        %strip numbers to get element only
        element = regexprep(nucleus, '\d', '');
        strFracVol = sprintf('Enter fraction volume that is %s: ', element);
        fV = input(strFracVol);
        phantom.frac_vol = fV;
        strIsoAbund = sprintf('Enter isotopic abundance of %s (decimal): ', nucleus);
        b = input(strIsoAbund);
        phantom.iso_abund = b;
        
        if strcmpi(phantom_type, 'hyper')
            data = data.setHyperPhantom(phantom);
        else
            data = data.setThermalPhantom(phantom);
        end
    end
        
    moles = (b*P*(V*fV))/(R*T)
    
%% Calculate the polarization of the thermal phantom
function polarization_thermal=ThermalP(gamma)

    %gamma = 74.02e6;
    Bo = 3; %Tesla
    T = 298; %Kelvin
    I = 0.5;
    hbar = 1.054571e-34;
    u = gamma*I*hbar;                       %(A/m^2)
    kB = 1.380648e-23 ; %T %J/K
    
    polarization_thermal = (u*Bo)/(kB*T)
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function push_restart_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('This will restart the program. All unsaved data will be lost! Do you wish to continue?', ...
                  'Restart Program?', ...
                  'Yes', 'No', 'No');
switch choice
    case 'Yes'
        close(gcbf)
        visualizer
    case 'No'
        ;
end