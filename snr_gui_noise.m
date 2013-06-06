function varargout = snr_gui_noise(varargin)
% SNR_GUI_NOISE MATLAB code for snr_gui_noise.fig
%      SNR_GUI_NOISE, by itself, creates a new SNR_GUI_NOISE or raises the existing
%      singleton*.
%
%      H = SNR_GUI_NOISE returns the handle to a new SNR_GUI_NOISE or the handle to
%      the existing singleton*.
%
%      SNR_GUI_NOISE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SNR_GUI_NOISE.M with the given input arguments.
%
%      SNR_GUI_NOISE('Property','Value',...) creates a new SNR_GUI_NOISE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before snr_gui_noise_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to snr_gui_noise_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help snr_gui_noise

% Last Modified by GUIDE v2.5 16-Jul-2012 14:17:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @snr_gui_noise_OpeningFcn, ...
                   'gui_OutputFcn',  @snr_gui_noise_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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

% --- Executes just before snr_gui_noise is made visible.
function snr_gui_noise_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to snr_gui_noise (see VARARGIN)

dontOpen = false;
mainGuiInput = find(strcmp(varargin, 'visualizer'));
if (isempty(mainGuiInput))...
        || (length(varargin) <= mainGuiInput) ...
        || (not(ishandle(varargin{mainGuiInput+1})))
    dontOpen = true;
else
    %remember the handle, and adjust our position
    handles.visualizer = varargin{mainGuiInput+1};

    %obtain handles using GUIDATA with the caller's handle
    mainHandles = guidata(handles.visualizer);
end

%read in spect data using Iain's reader
data = hypData(getData());
setappdata(handles.figure1, 'data', data);

noisedata = struct('noise', -1.0, 'filename', data.filename, ...
                   'noi_range', [-1 -1], 'noi_range_bin', [-1 -1]);

setappdata(handles.figure1, 'noisedata', noisedata);

updatePlot(handles);
axis tight;
% Set the motion detector.
% set(handles.figure1,'windowbuttonmotionfcn',{@fh_wbmfcn, handles});

try
        %rect contains dimensions of selected region
        %[xmin ymin width height]
        rect = getrect(handles.axes1);

        %perform selection if rect has been given a value
        if (not(isempty(rect)))
            data = getappdata(handles.figure1, 'data');

            xmin = fix(rect(1));
            xmax = xmin + fix(rect(3));
            
            xmin = max(xmin, 1); xmin = min(xmin, data.parms.samples*data.parms.padfactor);
            xmax = max(xmax, 1); xmax = min(xmax, data.parms.samples*data.parms.padfactor);
            
            fmin = getClosestFreq(data, xmin);
            fmax = getClosestFreq(data, xmax);
            
            
            noisedata.noi_range = [fmin fmax];
            noisedata.noi_range_bin = [xmin xmax];
            dpts = getFFT(data);
            noisedata.noise = std(dpts(xmin:xmax));
            setappdata(handles.figure1, 'noisedata', noisedata);
        end
catch err
    disp(err.message);
end

% Choose default command line output for snr_gui_noise
handles.output = noisedata;

% Update handles structure
guidata(hObject, handles);

% if dontOpen
%     disp('Something went wrong!')
% else
%     uiwait(handles.figure1);
% end

% UIWAIT makes snr_gui_noise wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% %I copied this function from the web, hence the unique syntax
% function [] = fh_wbmfcn(handles)
% 
% try
%     rect = getrect(handles.axes1);
%     if (not(isempty(rect)))
%         data = getappdata(handles.figure1, 'data');
% 
%         xmin = fix(rect(1));
%         xmax = xmin + fix(rect(3));
% 
%         data.setNoiRange([xmin xmax]);
%         dpts = abs(data.getFFT);
%         data.setNoise(NOISE(dpts(xmin:xmax)));
% 
%         setappdata(handles.figure1, 'data', data);
% 
%         updatePlot(handles);
%     end
% catch err
%     disp(err);
% end   

% 
% function [] = fh_none(varargin)
%  
% function noise = NOISE(dpts)
% %return the standard deviation of the data points in the selected range
% if length(dpts) <= 1
%     noise = -1;
% else
%     noise = std(dpts);
% end


% --- Outputs from this function are returned to the command line.
function varargout = snr_gui_noise_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%delete(hObject);

% --- Executes on button press in finished.
function finished_Callback(hObject, eventdata, handles)
% hObject    handle to finished (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% main = handles.visualizer;
% 
% if (ishandle(main))
%     noisedata = getappdata(handles.figure1, 'data');
%     mainHandles = guidata(main);
%     maindata = getappdata(mainHandles.figure1, 'data');
%     maindata.noisefile.noise = noisedata.spectra(1).noise;
%     maindata.noisefile.noi_range_bin = noisedata.spectra(1).noi_range;
%     maindata.noisefile.filename = noisedata.filename;
%     setappdata(mainHandles.figure1, 'data', maindata);
% end
% 
% uiresume(main);
delete(handles.figure1)

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
