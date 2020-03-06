function varargout = SliceDetectName(varargin)
% SLICEDETECTNAME MATLAB code for SliceDetectName.fig
%      SLICEDETECTNAME, by itself, creates a new SLICEDETECTNAME or raises the existing
%      singleton*.
%
%      H = SLICEDETECTNAME returns the handle to a new SLICEDETECTNAME or the handle to
%      the existing singleton*.
%
%      SLICEDETECTNAME('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLICEDETECTNAME.M with the given input arguments.
%
%      SLICEDETECTNAME('Property','Value',...) creates a new SLICEDETECTNAME or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SliceDetectName_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SliceDetectName_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SliceDetectName

% Last Modified by GUIDE v2.5 07-Mar-2017 00:50:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SliceDetectName_OpeningFcn, ...
                   'gui_OutputFcn',  @SliceDetectName_OutputFcn, ...
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


% --- Executes just before SliceDetectName is made visible.
function SliceDetectName_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SliceDetectName (see VARARGIN)

% Choose default command line output for SliceDetectName
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SliceDetectName wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SliceDetectName_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliceSlider_Callback(hObject, eventdata, handles)
% hObject    handle to sliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sliceSlider = findobj('Tag','sliceSlider');
slice = round(sliceSlider.Value);
handles.current_data = handles.I(:,:,slice);
image_CreateFcn(hObject, eventdata, handles);
sliceText = findobj('Tag','sliceN');
sliceText.String = ['Slice N: ' num2str(slice)];
guidata(hObject,handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function sliceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in fileSelect.
function fileSelect_Callback(hObject, eventdata, handles)
% hObject    handle to fileSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileSelect


% --- Executes during object creation, after setting all properties.
function fileSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sliceEntry_Callback(hObject, eventdata, handles)
% hObject    handle to sliceEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sliceEntry as text
%        str2double(get(hObject,'String')) returns contents of sliceEntry as a double


% --- Executes during object creation, after setting all properties.
function sliceEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliceEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sliceButton.
function sliceButton_Callback(hObject, eventdata, handles)
% hObject    handle to sliceButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sliceEntry = findobj('Tag','sliceEntry');
entry = sliceEntry.String;
entry = str2num(entry);
if isempty(entry)
    errordlg('Enter Integer Value');
elseif round(entry) ~= entry
    errordlg('Enter Integer Value')
end
handles.current_data = handles.I(:,:,entry); % when exporting to workspace, make sure to write current_data not I
image_CreateFcn(hObject, eventdata, handles);
sliceText = findobj('Tag','sliceN');
sliceText.String = ['Slice N: ' num2str(entry)];
sliceSlider = findobj('Tag','sliceSlider');
sliceSlider.Visible = 'off';
%sliceEntry.String = '';

handles = rmfield(handles,'I');

guidata(hObject,handles)   



function phantomEntry_Callback(hObject, eventdata, handles)
% hObject    handle to phantomEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of phantomEntry as text
%        str2double(get(hObject,'String')) returns contents of phantomEntry as a double


% --- Executes during object creation, after setting all properties.
function phantomEntry_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phantomEntry (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in detectButton.
function detectButton_Callback(hObject, eventdata, handles)
% hObject    handle to detectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
warning('off');
% sheetless determintation and handling
sheetlessRButton = findobj('Tag','sheetlessRButton');
if sheetlessRButton.Value == 1
    I = handles.current_data;
    dosetext = findobj('Tag','doseGenerate');
    dose = handles.info.Exposure;
    % change for dif doses, needs to be generalizable 
    if dose > 35 && dose < 55
        dose = '045';
        handles.dose = dose;
    elseif dose > 80 && dose < 105
        dose = '090';
        handles.dose = dose;
    elseif dose > 125 && dose < 145
        dose = '138';
        handles.dose = dose;
    end
%     if length(dose) < 3
%         dose = ['0' dose];
%         dosetext.String = dose;
%         handles.dose = [dose];
%     else
%         dosetext.String = dose;
%         handles.dose = dose;
%     end

    %handles.dose = handles.info.Exposure;

    vendPhant = findobj('Tag','phantomEntry');
    vendPhantEntry = vendPhant.String;
    if isempty(vendPhantEntry)
        errordlg('Enter Vendor and Phantom')
    else
        FileName = [vendPhantEntry, '_nSheet_',dose,'mAs'];
        fNameText = findobj('Tag','filename');
        fNameText.String = [FileName];
        handles.FileName = FileName;
    end

    % switch info
    breastCase = findobj('Tag','caseSelection');
    val = breastCase.Value;
    handles.breastCase = breastCase.String{val};
    bCase = handles.breastCase;

    info = handles.info;
    vendphant = strsplit(vendPhantEntry,'_');
    handles.vendor = vendphant{1};
    handles.phantom = vendphant{2};
    switch breastCase.String{val}
        case {'UM002'}
            handles.UM002.(FileName) = struct('I',I,'info',info,'dose',dose,'vendor',vendphant{1},'phantom',vendphant{2});
        case {'UM015'}
            handles.UM015.(FileName) = struct('I',I,'info',info,'dose',dose,'vendor',vendphant{1},'phantom',vendphant{2});
        case {'UM037'}
            handles.UM037.(FileName) = struct('I',I,'info',info,'dose',dose,'vendor',vendphant{1},'phantom',vendphant{2});
        case {'-Select Breast Case-'}
            errordlg('Select Breast Case')
    end

    %list box and total number
    fileList = findobj('Tag','fileList');
    fileNum = findobj('Tag','numfiles');
    filesDone = fieldnames(handles.(bCase));
    fileList.String = filesDone;
    fileNum.String = ['Total Number: ',num2str(length(filesDone))];
else

    % inputs
    xi = handles.xInput;
    yi = handles.yInput;
    I = handles.current_data;
    % initializations
    xf = zeros(4,1);
    yf = zeros(4,1);
    % orient = {'U','D','L','R'};
    % side = {'F','B'};
    % circle for correlation
    [x, y]=meshgrid(-10:10,-10:10);
    ind = find(sqrt((x).^2+(y).^2) <= 4);
    circ = zeros(size(x));
    circ(ind) = 1;
    corrPos = zeros(4,2);
    % morphology initialization
    se = strel('disk',4);
    % create ROIs
    for i = 1:4;
        if (xi(i) - 30) < 0
            roi = I((yi(i)-30):(yi(i)+30),1:(xi(i)+30-(xi(i) - 30)));
        else   
            roi = I((yi(i)-30):(yi(i)+30),(xi(i)-30):(xi(i)+30));
        end
    % detection    
        c = normxcorr2(circ,roi);
        [row, col] = find(c==max(c(:)));
        offset = (size(c,1) - size(roi,1))/2; % remove padding added by xcorr
        rowOffset = row - offset;
        colOffset = col - offset;
        corrPos(i,1) = colOffset; % x,y
        corrPos(i,2) = rowOffset;
    % morphology info
        if (rowOffset - 5)<=0
            rowMin = 1;
            rowMax = rowMin + 10;
        elseif (rowOffset + 5)>size(roi,1)
            rowMax = size(roi,1);
            rowMin = rowMax - 10;
        else
            rowMin = rowOffset - 5;
            rowMax = rowOffset + 5;
        end
        if (colOffset - 5)<=0
            colMin = 1;
            colMax = colMin + 10;
        elseif (colOffset + 5)>size(roi,2)
            colMax = size(roi,2);
            colMin = colMax - 10;
        else
            colMin = colOffset - 5;
            colMax = colOffset + 5;
        end
        section = roi(rowMin:rowMax,colMin:colMax);
        thresh = mean(section(:));
        bw = roi >= thresh;
        bw_clean = bwmorph(bw,'clean');
        bw_close = imclose(bw_clean,se);
        bw_filt = bwareafilt(bw_close,2);
        [bw_filt_label,num] = bwlabel(bw_filt);
        bw_positionFiltStats = regionprops('table',bw_filt_label,'centroid');
        clear corrDist
        for z = 1 : num
            corrDiff = bw_positionFiltStats.Centroid - repmat([corrPos(i,1), corrPos(i,2)],num,1);
            corrDist(z) = sqrt(corrDiff(z,1)^2 + corrDiff(z,2)^2);
        end
        [~,objN] = min(corrDist);
        index = find(bw_filt_label ~= objN);
        bw_filt_label(index) = 0;
        bw_final = bw_filt_label;
        roiLabels = bwlabel(bw_final);
        stats(i,:) = regionprops('table',roiLabels,roi,'WeightedCentroid','MajorAxisLength','MinorAxisLength','Orientation');
        if (xi(i) - 30) < 0
             xf(i,1) = 1 + stats.WeightedCentroid(i,1);
        else
            xf(i,1) = (xi(i,1) - 30) + stats.WeightedCentroid(i,1);
        end
        yf(i,1) = (yi(i,1) - 30) + stats.WeightedCentroid(i,2);
    end
    % position determinitation
    rectI = find(stats.MajorAxisLength == max(stats.MajorAxisLength));
    rectStats = [xf(rectI,:),yf(rectI,:),abs(stats.Orientation(rectI))];
    meanPos = [mean(xf),mean(yf)];
    % orientation and side determination
    if rectStats(1) < meanPos(1) && rectStats(2) < meanPos(2) && rectStats(3) > 45;
        orientation = 'U';
        side = 'F';
        pFidPosI = find(xf > meanPos(1) & yf > meanPos(2));
        pFidPos = [xf(pFidPosI),yf(pFidPosI)];

        sFidPosI = find(xf < meanPos(1) & yf > meanPos(2));
        sFidPos = [xf(sFidPosI),yf(sFidPosI)];

        tFidPosI = find(xf > meanPos(1) & yf < meanPos(2));
        tFidPos = [xf(tFidPosI),yf(tFidPosI)];
    elseif rectStats(1) < meanPos(1) && rectStats(2) < meanPos(2) && rectStats(3) < 45;
        orientation = 'L';
        side = 'B';
        pFidPosI = find(xf > meanPos(1) & yf > meanPos(2));
        pFidPos = [xf(pFidPosI),yf(pFidPosI)];

        sFidPosI = find(xf > meanPos(1) & yf < meanPos(2));
        sFidPos = [xf(sFidPosI),yf(sFidPosI)];

        tFidPosI = find(xf < meanPos(1) & yf > meanPos(2));
        tFidPos = [xf(tFidPosI),yf(tFidPosI)];
    elseif rectStats(1) > meanPos(1) && rectStats(2) < meanPos(2) && rectStats(3) > 45;
        orientation = 'U';
        side = 'B';

        pFidPosI = find(xf < meanPos(1) & yf > meanPos(2));
        pFidPos = [xf(pFidPosI),yf(pFidPosI)];

        sFidPosI = find(xf > meanPos(1) & yf > meanPos(2));
        sFidPos = [xf(sFidPosI),yf(sFidPosI)];

        tFidPosI = find(xf < meanPos(1) & yf < meanPos(2));
        tFidPos = [xf(tFidPosI),yf(tFidPosI)];
    elseif rectStats(1) > meanPos(1) && rectStats(2) < meanPos(2) && rectStats(3) < 45;
        orientation = 'R';
        side = 'F';
        pFidPosI = find(xf < meanPos(1) & yf > meanPos(2));
        pFidPos = [xf(pFidPosI),yf(pFidPosI)];

        sFidPosI = find(xf < meanPos(1) & yf < meanPos(2));
        sFidPos = [xf(sFidPosI),yf(sFidPosI)];

        tFidPosI = find(xf > meanPos(1) & yf > meanPos(2));
        tFidPos = [xf(tFidPosI),yf(tFidPosI)];
    elseif rectStats(1) > meanPos(1) && rectStats(2) > meanPos(2) && rectStats(3) > 45;
        orientation = 'D';
        side = 'F';
        pFidPosI = find(xf < meanPos(1) & yf < meanPos(2));
        pFidPos = [xf(pFidPosI),yf(pFidPosI)];

        sFidPosI = find(xf > meanPos(1) & yf < meanPos(2));
        sFidPos = [xf(sFidPosI),yf(sFidPosI)];

        tFidPosI = find(xf < meanPos(1) & yf > meanPos(2));
        tFidPos = [xf(tFidPosI),yf(tFidPosI)];
    elseif rectStats(1) > meanPos(1) && rectStats(2) > meanPos(2) && rectStats(3) < 45;
        orientation = 'R';
        side = 'B';
        pFidPosI = find(xf < meanPos(1) & yf < meanPos(2));
        pFidPos = [xf(pFidPosI),yf(pFidPosI)];

        sFidPosI = find(xf < meanPos(1) & yf > meanPos(2));
        sFidPos = [xf(sFidPosI),yf(sFidPosI)];

        tFidPosI = find(xf > meanPos(1) & yf < meanPos(2));
        tFidPos = [xf(tFidPosI),yf(tFidPosI)];
    elseif rectStats(1) < meanPos(1) && rectStats(2) > meanPos(2) && rectStats(3) > 45;
        orientation = 'D';
        side = 'B';
        pFidPosI = find(xf > meanPos(1) & yf < meanPos(2));
        pFidPos = [xf(pFidPosI),yf(pFidPosI)];

        sFidPosI = find(xf < meanPos(1) & yf < meanPos(2));
        sFidPos = [xf(sFidPosI),yf(sFidPosI)];

        tFidPosI = find(xf > meanPos(1) & yf > meanPos(2));
        tFidPos = [xf(tFidPosI),yf(tFidPosI)];
    elseif rectStats(1) < meanPos(1) && rectStats(2) > meanPos(2) && rectStats(3) < 45;
        orientation = 'L';
        side = 'F';
        pFidPosI = find(xf > meanPos(1) & yf < meanPos(2));
        pFidPos = [xf(pFidPosI),yf(pFidPosI)];

        sFidPosI = find(xf > meanPos(1) & yf > meanPos(2));
        sFidPos = [xf(sFidPosI),yf(sFidPosI)];

        tFidPosI = find(xf < meanPos(1) & yf < meanPos(2));
        tFidPos = [xf(tFidPosI),yf(tFidPosI)];
    end
    hold on
    scatter(xf,yf,'x');
    hold off

    nwtext = findobj('Tag','NWfidPos');
    nwtext.String = num2str(round(pFidPos));
    handles.pFidPos = pFidPos;

    netext = findobj('Tag','NEfidPos');
    netext.String = num2str(round(sFidPos));
    handles.sFidPos = sFidPos;

    swtext = findobj('Tag','SWfidPos');
    swtext.String = num2str(round(tFidPos));
    handles.tFidPos = tFidPos;

    orientext = findobj('Tag','orientGenerate');
    orientext.String = [orientation,'_',side];
    handles.orientation = {orientation,side};

    dosetext = findobj('Tag','doseGenerate');
    %change for new doses
    dose = handles.info.Exposure;
    if dose > 35 && dose < 55
        dose = '045';
        handles.dose = dose;
    elseif dose > 80 && dose < 105
        dose = '090';
        handles.dose = dose;
    elseif dose > 125 && dose < 145
        dose = '138';
        handles.dose = dose;
    end
%     if length(dose) < 3
%         dose = ['0' dose];
%         dosetext.String = dose;
%         handles.dose = [dose];
%     else
%         dosetext.String = dose;
%         handles.dose = dose;
%     end

    %handles.dose = handles.info.Exposure;

    vendPhant = findobj('Tag','phantomEntry');
    vendPhantEntry = vendPhant.String;
    if isempty(vendPhantEntry)
        errordlg('Enter Vendor and Phantom')
    else
        FileName = [vendPhantEntry, '_',orientation,'_',side,'_',dose,'mAs'];
        fNameText = findobj('Tag','filename');
        fNameText.String = [FileName];
        handles.FileName = FileName;
    end

    % switch info
    breastCase = findobj('Tag','caseSelection');
    val = breastCase.Value;
    handles.breastCase = breastCase.String{val};
    bCase = handles.breastCase;

    % values to save
    %fName = handles.filename.String;
    %I = handles.current_data;
    info = handles.info;
    %pFidPos = handles.pFidPos;
    %sFidPos = handles.sFidPos;
    %tFidPos = handles.tFidPos;
    %dose = handles.dose;
    %orient = handles.orientation(1);
    %side = handles.orientation(2);
    vendphant = strsplit(vendPhantEntry,'_');
    handles.vendor = vendphant{1};
    handles.phantom = vendphant{2};
    correctCheck = questdlg('Was the detection correct?');
    switch correctCheck
        case 'Yes'
            switch breastCase.String{val}
                case {'UM002'}
                    handles.UM002.(FileName) = struct('I',I,'info',info,'pFidPos',pFidPos,'sFidPos',sFidPos,'tFidPos',tFidPos,'dose',dose,'orient',orientation,'side',side,'vendor',vendphant{1},'phantom',vendphant{2});
                case {'UM015'}
                    handles.UM015.(FileName) = struct('I',I,'info',info,'pFidPos',pFidPos,'sFidPos',sFidPos,'tFidPos',tFidPos,'dose',dose,'orient',orientation,'side',side,'vendor',vendphant{1},'phantom',vendphant{2});
                case {'UM037'}
                    handles.UM037.(FileName) = struct('I',I,'info',info,'pFidPos',pFidPos,'sFidPos',sFidPos,'tFidPos',tFidPos,'dose',dose,'orient',orientation,'side',side,'vendor',vendphant{1},'phantom',vendphant{2});
                case {'-Select Breast Case-'}
                    errordlg('Select Breast Case')
            end
        case 'No'
            return
        case 'Cancel'
            return
    end
end

%list box and total number
fileList = findobj('Tag','fileList');
fileNum = findobj('Tag','numfiles');
filesDone = fieldnames(handles.(bCase));
fileList.String = filesDone;
fileNum.String = ['Total Number: ',num2str(length(filesDone))];

guidata(hObject,handles)


% --- Executes on button press in writeButton.
function writeButton_Callback(hObject, eventdata, handles)
% hObject    handle to writeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

savePath = 'C:\Users\chase\Documents\MATLAB\researchCode\Images\';
bCase = handles.breastCase;
vend = handles.vendor;
phant = handles.phantom;
% contains the function cellsearch.m
% MO calculations
passSizeCombos = {'5P_350','5P_490','5P_630','5P_770','6P_350','6P_490','6P_630','6P_770','7P_350','7P_490','7P_630','7P_770','8P_350','8P_490','8P_630','8P_770',};
doses = {'045','090','138'};

fNames = fieldnames(handles.(bCase));
% get case names for sheet in and out seperately
nSheetCases = cellsearch(fNames,'nSheet');
ySheetCases = cellsearch(fNames,'nSheet','remove');
% sheet in, looped through pass/size and dose
for i = 1:length(doses)
    doseLoop = doses{i}; % sets dose for current loop
    doseCases = cellsearch(ySheetCases,doseLoop); % searches through the ySheet filenames for the files containing the dose for current loop    
    for z = 1:length(passSizeCombos)
        passSize = passSizeCombos{z}; 
        meanSigStack = cell(1,4);
        meanBkgdStack = cell(1,4);
        cornerSig = cell(1,4);
        for j = 1:length(doseCases)
            doseCase = doseCases{j};
            roifNames = fieldnames(handles.(bCase).(doseCase));
            passSizeROIs = cellsearch(roifNames,passSize);
            disp(doseCase)
            meanSigStack{1}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{1}).meanSig;
            meanSigStack{2}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{2}).meanSig;
            meanSigStack{3}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{3}).meanSig;
            meanSigStack{4}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{4}).meanSig;
           
            meanBkgdStack{1}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{1}).meanBkgd;
            meanBkgdStack{2}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{2}).meanBkgd;
            meanBkgdStack{3}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{3}).meanBkgd;
            meanBkgdStack{4}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{4}).meanBkgd;
            
            cornerSig{1}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{1}).cornerSig;
            cornerSig{2}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{2}).cornerSig;
            cornerSig{3}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{3}).cornerSig;
            cornerSig{4}(:,:,j) = handles.(bCase).(doseCase).(passSizeROIs{4}).cornerSig; 
        end
        meanSigBigStack = cat(3,meanSigStack{1},meanSigStack{2},meanSigStack{3},meanSigStack{4});
        meanSig = mean(meanSigBigStack,3);
        meanSigName = ['MeanSig_',vend,'_',phant,'_',doseLoop,'_',passSize];
        handles.(bCase).MeanSig.(meanSigName) = meanSig;
        
        meanBkgdBigStack = cat(3,meanBkgdStack{1},meanBkgdStack{2},meanBkgdStack{3},meanBkgdStack{4});
        meanBkgd = mean(meanBkgdBigStack,3);
        meanBkgdName = ['MeanBkgd_',vend,'_',phant,'_',doseLoop,'_',passSize];
        handles.(bCase).MeanBkgd.(meanBkgdName) = meanBkgd;
        
        covSigStack = cat(3,meanSigBigStack,cornerSig{1},cornerSig{2},cornerSig{3},cornerSig{4});
        covSigStackName = ['covSigStack_',vend,'_',phant,'_',doseLoop,'_',passSize];
        handles.(bCase).covSigStack.(covSigStackName) = covSigStack;
    end
end
            
    

% save path and file
FILENAME = [savePath,bCase,'\',vend,'\',bCase];
filesDone = fieldnames(handles.(bCase));
% if length(unique(filesDone)) > 27;
%     errordlg('delete repeated cases')
% else
    % variable being saved
    saveVar = handles.(bCase);
    % save
    save(FILENAME,'-struct','saveVar')
    % clear files and listbox
    handles = rmfield(handles,bCase);
    fileNum = findobj('Tag','numfiles');
    fileNum.String = 'Total Number: 0';
    fileList = findobj('Tag','fileList');
    fileList.String = {'None'};


guidata(hObject,handles)



% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Read in image and getinfo on it
[FileName, PathName] = uigetfile('*.*');
handles.filenameOld = FileName;
breast = [PathName FileName];
handles.I = dicomread(breast);
handles.info = dicominfo(breast);
if ~isfield(handles.info,'Exposure')
    handles.info.Exposure = round(handles.info.Unknown_0018_9507.Item_1.ExposureInmAs);
end
[rows cols z] = size(handles.I);

% Display the image
handles.current_data = handles.I(:,:,1);
image_CreateFcn(hObject, eventdata, handles);

% Filname
filenameText = findobj('Tag','filename');
filenameText.String = ['Filename: ' FileName];

% Slider
sliceSlider = findobj('Tag','sliceSlider');
image = gca;
sPos = sliceSlider.Position;
iPos = image.Position;
sliceSlider.Position = [iPos(1) (iPos(2)-sPos(4)) iPos(3) sPos(4)];
sliceText = findobj('Tag','sliceN');
if z == 1
    sliceSlider.Visible = 'off';
    sliceSlider.Max = z;
    sliceSlider.Min = 0;
    sliceSlider.Value = 1;
    sliceText.String = ['Slice N:'];
else
    sliceSlider.Visible = 'on';  
    sliceSlider.Max = z;
    sliceSlider.Min = 1;
    sliceSlider.Value = 1;
    sliceSlider.SliderStep = [(1/(z-1)) (10/(z-1))];
    sliceText.String = ['Slice N: 1'];
end

% Reset entries
nwtext = findobj('Tag','NWfidPos');
nwtext.String = '';

netext = findobj('Tag','NEfidPos');
netext.String = '';

swtext = findobj('Tag','SWfidPos');
swtext.String = '';

orientext = findobj('Tag','orientGenerate');
orientext.String = '';

dosetext = findobj('Tag','doseGenerate');
dosetext.String = '';

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function image_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isfield(handles,'current_data')
   im = imshow(handles.current_data,[]);
   set(im,'ButtonDownFcn',@buttonDownFidDetection)
end
% Hint: place code in OpeningFcn to populate image


% --- Executes on mouse press over axes background.
function image_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function buttonDownFidDetection(hObject,eventdata,handles)
%gather inputs
[xi, yi] = ginput(4);
hold on
scatter(xi,yi,60)
hold off
loadObj = findobj('Tag','loadButton');
loadData = guidata(loadObj);
handles = loadData;
handles.xInput = xi;
handles.yInput = yi;
guidata(hObject,handles)    
    
    


% --- Executes on button press in rotateButton.
function rotateButton_Callback(hObject, eventdata, handles)
% hObject    handle to rotateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rotButt = findobj('Tag','rotateButton');
handles.current_data = imrotate(handles.current_data,180);
image_CreateFcn(hObject, eventdata, handles);
guidata(hObject,handles)  


% --- Executes on selection change in caseSelection.
function caseSelection_Callback(hObject, eventdata, handles)
% hObject    handle to caseSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns caseSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from caseSelection


% --- Executes during object creation, after setting all properties.
function caseSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to caseSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fileList.
function fileList_Callback(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileList


% --- Executes during object creation, after setting all properties.
function fileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clearCase.
function clearCase_Callback(hObject, eventdata, handles)
% hObject    handle to clearCase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fileList = findobj('Tag','fileList');
val = fileList.Value;
file = fileList.String{val};
bCase = handles.breastCase;
handles.(bCase) = rmfield(handles.(bCase),file);

fileNum = findobj('Tag','numfiles');
filesDone = fieldnames(handles.(bCase));
fileList.String = filesDone;
fileNum.String = ['Total Number: ',num2str(length(filesDone))];
guidata(hObject,handles)


% --- Executes on button press in sheetlessRButton.
function sheetlessRButton_Callback(hObject, eventdata, handles)
% hObject    handle to sheetlessRButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sheetlessRButton


% --- Executes on button press in segmentButt.
function segmentButt_Callback(hObject, eventdata, handles)
% hObject    handle to segmentButt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sheetlessRButton = findobj('Tag','sheetlessRButton');
if sheetlessRButton.Value == 1
I = handles.current_data;
bCase = handles.breastCase;
fName = handles.FileName;
dose = handles.dose;
vend = handles.vendor;
phant = handles.phantom;
smallDim = 10;

xi = handles.xInput;
yi = handles.yInput;
orderX = sort(xi);
orderY = sort(yi);
xStart = orderX(2);
xEnd = orderX(3);
yStart = orderY(2);
yEnd = orderY(3);

roiStartX = xStart;
roiStartY = yStart;
c=1;
while roiStartY < yEnd
    if roiStartX < xEnd
        covBkgdStack(:,:,c) = I(roiStartY-smallDim:roiStartY+smallDim,roiStartX-smallDim:roiStartX+smallDim);
        roiStartX = roiStartX + 22;
    else
        roiStartX = xStart;
        roiStartY = roiStartY + 22;
        covBkgdStack(:,:,c) = I(roiStartY-smallDim:roiStartY+smallDim,roiStartX-smallDim:roiStartX+smallDim);
    end
    c = c+1;
end
covBkgdStackName = ['covBkgdStack_',vend,'_',phant,'_',dose];
handles.(bCase).covBkgdStack.(covBkgdStackName) = covBkgdStack;
disp('Segmented');
else
%needs angleBasedPositionShange.m
load('segmentationVariables.mat');
pFidPos = (handles.pFidPos);
sFidPos = (handles.sFidPos);
tFidPos = (handles.tFidPos);
orientation = handles.orientation{1};
sides = handles.orientation{2};
% get fiducial measurements
switch sides
    case 'F'
        switch orientation % Pri/Sec/Ter
            case 'U' %SE/SW/NE
                SEfiducialPos = pFidPos;
                SWfiducialPos = sFidPos;
                NEfiducialPos = tFidPos;
                xfiducialDistanceX = SEfiducialPos(1,1) - SWfiducialPos(1,1);
                xfiducialDistanceY = SEfiducialPos(1,2) - SWfiducialPos(1,2);
                xFD = ( sqrt( ( xfiducialDistanceX ^2 ) + ( xfiducialDistanceY ^2 ) ) );
                FA = atand( xfiducialDistanceY / xfiducialDistanceX );
                 yfiducialDistanceX = NEfiducialPos(1,1) - SEfiducialPos(1,1);
                 yfiducialDistanceY = SEfiducialPos(1,2) - NEfiducialPos(1,2);
                 yFD = ( sqrt( ( yfiducialDistanceX ^2 ) + ( yfiducialDistanceY ^2 ) ) );
            case 'D' %NW/NE/SW
                NWfiducialPos = pFidPos;
                NEfiducialPos = sFidPos;
                SWfiducialPos = tFidPos;
                xfiducialDistanceX = NEfiducialPos(1,1) - NWfiducialPos(1,1);
                xfiducialDistanceY = NWfiducialPos(1,2) - NEfiducialPos(1,2);
                xFD = ( sqrt( ( xfiducialDistanceX ^2 ) + ( xfiducialDistanceY ^2 ) ) );
                FA = atand( xfiducialDistanceY / xfiducialDistanceX );
                yfiducialDistanceX = NWfiducialPos(1,1) - SWfiducialPos(1,1);
                yfiducialDistanceY = SWfiducialPos(1,2) - NWfiducialPos(1,2);
                yFD = ( sqrt( ( yfiducialDistanceX ^2 ) + ( yfiducialDistanceY ^2 ) ) );
            case 'L' %NE/SE/NW
                NEfiducialPos = pFidPos;
                SEfiducialPos = sFidPos;
                NWfiducialPos = tFidPos;
                xfiducialDistanceX = NEfiducialPos(1,1) - SEfiducialPos(1,1);
                xfiducialDistanceY = SEfiducialPos(1,2) - NEfiducialPos(1,2);
                xFD = ( sqrt( ( xfiducialDistanceX ^2 ) + ( xfiducialDistanceY ^2 ) ) );
                FA = atand( xfiducialDistanceX / xfiducialDistanceY );
                yfiducialDistanceX = NEfiducialPos(1,1) - NWfiducialPos(1,1);
                yfiducialDistanceY = NEfiducialPos(1,2) - NWfiducialPos(1,2);
                yFD = ( sqrt( ( yfiducialDistanceX ^2 ) + ( yfiducialDistanceY ^2 ) ) );
            case 'R' %SW/NW/SE
                SWfiducialPos = pFidPos;
                NWfiducialPos = sFidPos;
                SEfiducialPos = tFidPos;
                xfiducialDistanceX = SWfiducialPos(1,1) - NWfiducialPos(1,1);
                xfiducialDistanceY = SWfiducialPos(1,2) - NWfiducialPos(1,2);
                xFD = ( sqrt( ( xfiducialDistanceX ^2 ) + ( xfiducialDistanceY ^2 ) ) );
                FA = atand( xfiducialDistanceX / xfiducialDistanceY );
                yfiducialDistanceX = SWfiducialPos(1,1) - SEfiducialPos(1,1);
                yfiducialDistanceY = SWfiducialPos(1,2) - SEfiducialPos(1,2);
                yFD = ( sqrt( ( yfiducialDistanceX ^2 ) + ( yfiducialDistanceY ^2 ) ) );
        end
    case 'B'
        switch orientation
            case 'U' %SW/SE/NW
                SWfiducialPos = pFidPos;
                SEfiducialPos = sFidPos;
                NWfiducialPos = tFidPos;
                xfiducialDistanceX = SEfiducialPos(1,1) - SWfiducialPos(1,1);
                xfiducialDistanceY = SWfiducialPos(1,2) - SEfiducialPos(1,2);
                xFD = ( sqrt( ( xfiducialDistanceX ^2 ) + ( xfiducialDistanceY ^2 ) ) );
                FA = atand( xfiducialDistanceY / xfiducialDistanceX );
                yfiducialDistanceX = SWfiducialPos(1,1) - NWfiducialPos(1,1);
                yfiducialDistanceY = SWfiducialPos(1,2) - NWfiducialPos(1,2);
                yFD = ( sqrt( ( yfiducialDistanceX ^2 ) + ( yfiducialDistanceY ^2 ) ) );
            case 'D' %NE/NW/SE
                NEfiducialPos = pFidPos;
                NWfiducialPos = sFidPos;
                SEfiducialPos = tFidPos;
                xfiducialDistanceX = NEfiducialPos(1,1) - NWfiducialPos(1,1);
                xfiducialDistanceY = NEfiducialPos(1,2) - NWfiducialPos(1,2);
                xFD = ( sqrt( ( xfiducialDistanceX ^2 ) + ( xfiducialDistanceY ^2 ) ) );
                FA = atand( xfiducialDistanceY / xfiducialDistanceX );
                yfiducialDistanceX = NEfiducialPos(1,1) - SEfiducialPos(1,1);
                yfiducialDistanceY = SEfiducialPos(1,2) - NEfiducialPos(1,2);
                yFD = ( sqrt( ( yfiducialDistanceX ^2 ) + ( yfiducialDistanceY ^2 ) ) );
            case 'L' %SE/NE/SW
                SEfiducialPos = pFidPos;
                NEfiducialPos = sFidPos;
                SWfiducialPos = tFidPos;
                xfiducialDistanceX = SEfiducialPos(1,1) - NEfiducialPos(1,1);
                xfiducialDistanceY = SEfiducialPos(1,2) - NEfiducialPos(1,2);
                xFD = ( sqrt( ( xfiducialDistanceX ^2 ) + ( xfiducialDistanceY ^2 ) ) );
                FA = atand( xfiducialDistanceX / xfiducialDistanceY );
                yfiducialDistanceX = SWfiducialPos(1,1) - SEfiducialPos(1,1);
                yfiducialDistanceY = SEfiducialPos(1,2) - SWfiducialPos(1,2);
                yFD = ( sqrt( ( yfiducialDistanceX ^2 ) + ( yfiducialDistanceY ^2 ) ) );
            case 'R' %NW/SW/NE
                NWfiducialPos = pFidPos;
                SWfiducialPos = sFidPos;
                NEfiducialPos = tFidPos;
                xfiducialDistanceX = NWfiducialPos(1,1) - SWfiducialPos(1,1);
                xfiducialDistanceY = SWfiducialPos(1,2) - NWfiducialPos(1,2);
                xFD = ( sqrt( ( xfiducialDistanceX ^2 ) + ( xfiducialDistanceY ^2 ) ) );
                FA = atand( xfiducialDistanceX / xfiducialDistanceY );
                yfiducialDistanceX = NEfiducialPos(1,1) - NWfiducialPos(1,1);
                yfiducialDistanceY = NWfiducialPos(1,2) - NEfiducialPos(1,2);
                yFD = ( sqrt( ( yfiducialDistanceX ^2 ) + ( yfiducialDistanceY ^2 ) ) );
        end
end
handles.xFD = xFD;
handles.yFD = yFD;
handles.FA = FA;

blockSize = blocksize * xFD;
range = floor(blockSize/2);
cornerDotDist = round(cornerDotDist(2) * xFD);

centerPositions = cell(8);
for i = 1:8
    for j = 1:8       
        centerPositions{i,j}(1) = xFD * centerRatios{i,j}(1);
        centerPositions{i,j}(2) = yFD * centerRatios{i,j}(2);
        [centerPositions{i,j}(1),centerPositions{i,j}(2)] = angleBasedPositionChange(centerPositions{i,j}(1),centerPositions{i,j}(2),FA, orientation, sides);
        switch sides
            case 'F'    
                switch orientation
                    case 'D'
                        centerPositions{i,j} = round(centerPositions{i,j} + pFidPos);
                    case 'R'
                        centerPositions{i,j}(1) = round( centerPositions{i,j}(1) + pFidPos(1)); % difference is in this part
                        centerPositions{i,j}(2) = round(- centerPositions{i,j}(2) + pFidPos(2));
                    case 'U'
                        centerPositions{i,j} = round(-centerPositions{i,j} + pFidPos);
                    case 'L'
                        centerPositions{i,j}(1) = round(- centerPositions{i,j}(1) + pFidPos(1)); % difference is in this part
                        centerPositions{i,j}(2) =  round(centerPositions{i,j}(2) + pFidPos(2));
                end
            case 'B'    
                switch orientation
                    case 'D'
                        centerPositions{i,j}(1) = round(- centerPositions{i,j}(1) + pFidPos(1)); % difference is in this part
                        centerPositions{i,j}(2) =  round(centerPositions{i,j}(2) + pFidPos(2));
                    case 'R'
                        centerPositions{i,j}(1) =  centerPositions{i,j}(1) + pFidPos(1); % difference is in this part
                        centerPositions{i,j}(2) =  centerPositions{i,j}(2) + pFidPos(2);
                    case 'U'
                        centerPositions{i,j}(1) = round(  centerPositions{i,j}(1) + pFidPos(1)); % difference is in this part
                        centerPositions{i,j}(2) = round(- centerPositions{i,j}(2) + pFidPos(2));
                    case 'L'
                        centerPositions{i,j}(1) = round(- centerPositions{i,j}(1) + pFidPos(1)); % difference is in this part
                        centerPositions{i,j}(2) = round(- centerPositions{i,j}(2) + pFidPos(2));
                end
        end
    end
end

% orient correctly
switch sides
    case 'F'
        switch orientation
            case 'D'
                centerPositions = centerPositions;
            case 'R'
                centerPositions = flipud(centerPositions);
            case 'U'
                centerPositions = rot90(centerPositions,2);
            case 'L'
                centerPositions = fliplr(centerPositions);
        end
    case 'B'
        switch orientation
            case 'D'
                centerPositions = fliplr(centerPositions);
            case 'R'
                centerPositions = centerPositions;
            case 'U'
                centerPositions = flipud(centerPositions);
            case 'L'
                centerPositions = rot90(centerPositions,2);
        end
end
       
hold on
for i = 1:64
scatter(centerPositions{i}(1),centerPositions{i}(2));
end
hold off

I = handles.current_data;
bCase = handles.breastCase;
fName = handles.FileName;
O = [orientation sides];
dose = handles.dose;
vend = handles.vendor;
phant = handles.phantom;
smallDim = 10;
for i = 1:8
    for j = 1:8
        roiRow = centerPositions{i,j}(2);
        roiCol = centerPositions{i,j}(1);
        correctCorner = correctLoc.(O).CorrectCorners{i,j};
        diskPass = num2str(correctLoc.(O).PassSize{i,j}(1));
        diskSize = num2str(correctLoc.(O).PassSize{i,j}(2));
        numRow = num2str(i);
        numCol = num2str(j);
        roiName = [vend,'_',phant,'_',dose,'_',O,'_',numRow,'x',numCol,'_',diskPass,'P_',diskSize,'_',correctCorner];
        
        wholeROI = I(roiRow-range:roiRow+range,roiCol-range:roiCol+range);
        handles.(bCase).(fName).(roiName).whole = wholeROI;
        
        centerSig = I(roiRow-smallDim:roiRow+smallDim,roiCol-smallDim:roiCol+smallDim);
        handles.(bCase).(fName).(roiName).meanSig = centerSig;
        
        bkgdRoiCol = roiCol + (2*smallDim);
        meanBkgd = I(roiRow-smallDim:roiRow+smallDim,bkgdRoiCol-smallDim:bkgdRoiCol+smallDim);
        handles.(bCase).(fName).(roiName).meanBkgd = meanBkgd;
        
        switch correctCorner
            case 'NW'
                cornerRow = roiRow - cornerDotDist;
                cornerCol = roiCol - cornerDotDist;
            case 'NE'
                cornerRow = roiRow - cornerDotDist;
                cornerCol = roiCol + cornerDotDist;
            case 'SW'
                cornerRow = roiRow + cornerDotDist;
                cornerCol = roiCol - cornerDotDist;
            case 'SE'
                cornerRow = roiRow + cornerDotDist;
                cornerCol = roiCol + cornerDotDist;
        end
        cornerSig = I(cornerRow-smallDim:cornerRow+smallDim,cornerCol-smallDim:cornerCol+smallDim);
        handles.(bCase).(fName).(roiName).cornerSig = cornerSig;

        NW = I(roiRow - cornerDotDist-smallDim:roiRow - cornerDotDist+smallDim,roiCol - cornerDotDist-smallDim:roiCol - cornerDotDist+smallDim);
        NE = I(roiRow - cornerDotDist-smallDim:roiRow - cornerDotDist+smallDim,roiCol + cornerDotDist-smallDim:roiCol + cornerDotDist+smallDim);
        SW = I(roiRow + cornerDotDist-smallDim:roiRow + cornerDotDist+smallDim,roiCol - cornerDotDist-smallDim:roiCol - cornerDotDist+smallDim);
        SE = I(roiRow + cornerDotDist-smallDim:roiRow + cornerDotDist+smallDim,roiCol + cornerDotDist-smallDim:roiCol + cornerDotDist+smallDim);
        handles.(bCase).(fName).(roiName).NW = NW;
        handles.(bCase).(fName).(roiName).NE = NE;
        handles.(bCase).(fName).(roiName).SW = SW;
        handles.(bCase).(fName).(roiName).SE = SE;
    end
end
% display tests. change stack variable to ROI of interest
% 
% fn = fieldnames(handles.(bCase).(fName));
% fn = fn(11:end);
% for i = 1:length(fn)
% stack(:,:,1,i) = handles.(bCase).(fName).(fn{i}).whole;
% end
% montage(stack,'Size', [8 8],'DisplayRange',[])
end

guidata(hObject,handles)