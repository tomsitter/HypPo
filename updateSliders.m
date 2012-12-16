function updateSliders(handles)

if isappdata(handles.figure1, 'data')
    %set up file slider
    if isappdata(handles.figure1, 'dataArr')
        dataArr = getappdata(handles.figure1, 'dataArr');
        curFileIndex = getappdata(handles.figure1, 'curFileIndex');
        
        numFiles = length(dataArr);
        if numFiles > 1
            set(handles.file_slider, 'Visible', 'on');
            set(handles.text_fileslider, 'Visible', 'on');
            set(handles.file_slider, 'min', 1);
            set(handles.file_slider, 'val', curFileIndex);
            set(handles.file_slider, 'max', numFiles);
            set(handles.file_slider, 'sliderstep', [1/(numFiles-1), 1/(numFiles-1)]);
        else
            set(handles.file_slider, 'Visible', 'off');
            set(handles.text_fileslider, 'Visible', 'off');
        end
    end

    %set up spectrum slider
    curData = getappdata(handles.figure1, 'data');
    if curData.parms.rows > 1
        %initialize slider values
        set(handles.spectrum_slider, 'min', 1);
        curSpecIndex = getappdata(handles.figure1, 'curSpecIndex');
        if curData.parms.rows >= curSpecIndex
            set(handles.spectrum_slider, 'val', curSpecIndex);
        else
            set(handles.spectrum_slider, 'val', 1);
        end
        set(handles.spectrum_slider, 'max', curData.parms.rows);
        set(handles.spectrum_slider, 'sliderstep', [1/(curData.parms.rows-1), ...
                                                    1/(curData.parms.rows-1)] );
        set(handles.spectrum_slider, 'Visible', 'on');
        set(handles.text_specslider, 'Visible', 'on');
    else %otherwise if only one specturm, hide it
        set(handles.spectrum_slider, 'Visible', 'off');
        set(handles.text_specslider, 'Visible', 'off');
    end
end