function d = gaussLorentzFilt(handles, dpts)

data = getappdata(handles.figure1, 'data');
padfactor = data.parms.padfactor;

TL = str2double(get(handles.text_lorentz, 'String'));
TG = str2double(get(handles.text_gauss, 'String'));

t = timeAxis(getappdata(handles.figure1, 'data'));

d=dpts(1:length(t)).*(exp(abs(t./TL))).*(exp(-(t.^2/TG.^2)));

d = padarray(d, [0 (padfactor-1)*length(d)], 0, 'post');
