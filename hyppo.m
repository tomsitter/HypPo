function varargout = hyppo(varargin)
% HYPPO MATLAB code for hyppo.fig
%      HYPPO, by itself, creates a new HYPPO or raises the existing
%      singleton*.
%
%      H = HYPPO returns the handle to a new HYPPO or the handle to
%      the existing singleton*.
%
%      HYPPO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HYPPO.M with the given input arguments.
%
%      HYPPO('Property','Value',...) creates a new HYPPO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hyppo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hyppo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hyppo

% Last Modified by GUIDE v2.5 03-Aug-2012 14:07:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hyppo_OpeningFcn, ...
                   'gui_OutputFcn',  @hyppo_OutputFcn, ...
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

% --- Executes just before hyppo is made visible.
function hyppo_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hyppo (see VARARGIN)
% 

% imgArr = imread('Hippo_archigraphs.jpeg');
% axes(handles.axes_pic);
% imshow(imgArr);


% Choose default command line output for hyppo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes hyppo wait for user response (see UIRESUME)
%uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = hyppo_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function statusbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function push_load_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_load (see GCBO)
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
        newdata = hypData(dataObj(i));
        if isappdata(handles.figure1, 'data')
            prevdata = getappdata(handles.figure1, 'data');
            setappdata(handles.figure1, 'data', [prevdata newdata]);
        else
            setappdata(handles.figure1, 'data', newdata);
        end    
        
        str = sprintf('Loaded File: \n%s', newdata.filename);
        updateStatusBox(handles, str);
    
    end
catch err
    disp(err.message)
end

% --------------------------------------------------------------------
function push_save_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get the state of the data object and save it to a file
%also assign it into the workspace
if isappdata(handles.figure1, 'data')
    
    dataArr = getappdata(handles.figure1, 'data');
    for i = 1:length(dataArr)
        dataArr(i).index = 1;
        varName = sprintf('hypObj%d', i);
        assignin('base', varName, dataArr(i));
    end
    
    try
        uisave('dataArr');
    catch err
        disp(err.message);
    end
    
else
    msgbox('No loaded data');
end


% --------------------------------------------------------------------
function push_visualize_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_visualize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%launch the visualizer gui
if isappdata(handles.figure1, 'data')
    visualizer('hyppo', handles.figure1);
end


% --------------------------------------------------------------------
function push_snr_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to push_snr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%launch the snr gui
if isappdata(handles.figure1, 'data')
    snr_gui('hyppo', handles.figure1);
end



function statusbox_Callback(hObject, eventdata, handles)
% hObject    handle to statusbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of statusbox as text
%        str2double(get(hObject,'String')) returns contents of statusbox as a double


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
