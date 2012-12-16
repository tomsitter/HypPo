function updateSNR(handles)

hold on;
data = getappdata(handles.figure1, 'data');

if getappdata(handles.figure1, 'isavg')
    srange = data.getSigRangeAvg;
    nrange = data.getNoiRangeAvg;
else
    srange = data.getSigRange;
    nrange = data.getNoiRange;
end

if isempty(srange) && isempty(nrange)
    return;
end

if get(handles.slider_realmag, 'Value') == 1
    dpts = abs(getappdata(handles.figure1, 'currentDpts'));
else
    dpts = real(getappdata(handles.figure1, 'currentDpts'));
end

%plot all selected peak regions as green circles
if not(isempty(srange))
    for p = 1:2:length(srange)
        [brange(1), ~] = getClosestBin(data, srange(p));
        [brange(2), ~] = getClosestBin(data, srange(p+1));
        step = (srange(p+1)-srange(p)) / (brange(2) - brange(1));
        if isnan(step)
            step = 1;
        end
        plot(srange(p):step:srange(p+1), dpts(brange(1):brange(2)), 'blacko', 'MarkerSize', 3);
    end
end

%plot noise region as red circles
if not(isempty(nrange))
    brange(1) = getClosestBin(data, nrange(1));
    brange(2) = getClosestBin(data, nrange(2));
    step = (nrange(2)-nrange(1)) / (brange(2) - brange(1));
    plot(nrange(1):step:nrange(2), dpts(round(brange(1)):round(brange(2))), 'ro', 'MarkerSize', 3);
end