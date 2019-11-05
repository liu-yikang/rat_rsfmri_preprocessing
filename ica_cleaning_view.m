function varargout = ica_cleaning_view(varargin)
% ICA_CLEANING_VIEW MATLAB code for ica_cleaning_view.fig
%      ICA_CLEANING_VIEW, by itself, creates a new ICA_CLEANING_VIEW or raises the existing
%      singleton*.
%
%      H = ICA_CLEANING_VIEW returns the handle to a new ICA_CLEANING_VIEW or the handle to
%      the existing singleton*.
%
%      ICA_CLEANING_VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ICA_CLEANING_VIEW.M with the given input arguments.
%
%      ICA_CLEANING_VIEW('Property','Value',...) creates a new ICA_CLEANING_VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ica_cleaning_view_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ica_cleaning_view_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ica_cleaning_view

% Last Modified by GUIDE v2.5 28-Jun-2019 13:47:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ica_cleaning_view_OpeningFcn, ...
                   'gui_OutputFcn',  @ica_cleaning_view_OutputFcn, ...
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


% --- Executes just before ica_cleaning_view is made visible.
function ica_cleaning_view_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ica_cleaning_view (see VARARGIN)

% Choose default command line output for ica_cleaning_view
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global result_path ic_index scan_index scan_list label_table;
ic_index = 1;
scan_index = 1;
result_path = strrep(mfilename('fullpath'), 'ica_cleaning_view', '');
handles.text2.String = result_path;
scan_list = dir(fullfile(result_path, '*EPI*'));
if ~isempty(scan_list)
    scans = {};
    for i_list = 1:length(scan_list)
        scans(end+1, 1) = {scan_list(i_list).name};
    end
    handles.listbox1.String = scans;
    try
        [~,~,label_table] = xlsread(fullfile(result_path, 'labels', [scan_list(scan_index).name,'.xlsx']));
        label_table = label_table(1:51,1:4);
    catch
        label_table = cell(51,4);
        label_table(1,2:4) = {'RSN','NOISE','OTHER'};
    end
    update_result(handles);
end

% UIWAIT makes ica_cleaning_view wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ica_cleaning_view_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function update_result(handles)
global result_path ic_index scan_index scan_list label_table;
im = imread(fullfile(result_path, scan_list(scan_index).name, 'report' ,['ic', num2str(ic_index), '_map.tif']));
imshow(im, 'Parent', handles.axes1);
im = imread(fullfile(result_path, scan_list(scan_index).name, 'report' ,['ic', num2str(ic_index), '_tc.tif']));
imshow(im, 'Parent', handles.axes2);
try
    idx = find(cell2mat(label_table(ic_index+1, 2:4))==1);
    if idx == 1
        handles.radiobutton1.Value = 1;
        handles.radiobutton2.Value = 0;
        handles.radiobutton3.Value = 0;
    elseif idx == 2
        handles.radiobutton1.Value = 0;
        handles.radiobutton2.Value = 1;
        handles.radiobutton3.Value = 0;
    elseif idx == 3
        handles.radiobutton1.Value = 0;
        handles.radiobutton2.Value = 0;
        handles.radiobutton3.Value = 1;
    else
        handles.radiobutton1.Value = 0;
        handles.radiobutton2.Value = 0;
        handles.radiobutton3.Value = 0;
    end
catch
    handles.radiobutton1.Value = 0;
    handles.radiobutton2.Value = 0;
    handles.radiobutton3.Value = 0;
end
handles.text4.String = ['#IC: ',num2str(ic_index)];            


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global result_path ic_index scan_index scan_list;
ic_index = 1;
scan_index = 1;
result_path = uigetdir();
handles.text2.String = result_path;
scan_list = dir(fullfile(result_path, 'rat*'));
if ~isempty(scan_list)
    scans = {};
    for i_list = 1:length(scan_list)
        scans(end+1, 1) = {scan_list(i_list).name};
    end
    handles.listbox1.String = scans;
    update_result(handles);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ic_index label_table;
if handles.radiobutton1.Value == 1
    label_table{ic_index+1, 2} = 1;
    label_table{ic_index+1, 3} = 0;
    label_table{ic_index+1, 4} = 0;
elseif handles.radiobutton2.Value == 1
    label_table{ic_index+1, 2} = 0;
    label_table{ic_index+1, 3} = 1;
    label_table{ic_index+1, 4} = 0;
elseif handles.radiobutton3.Value == 1
    label_table{ic_index+1, 2} = 0;
    label_table{ic_index+1, 3} = 0;
    label_table{ic_index+1, 4} = 1;
end
if ic_index == 1
    msgbox('It''s the first IC!');
else
    ic_index = ic_index - 1;
    update_result(handles);
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ic_index label_table;
if handles.radiobutton1.Value == 1
    label_table{ic_index+1, 2} = 1;
    label_table{ic_index+1, 3} = 0;
    label_table{ic_index+1, 4} = 0;
elseif handles.radiobutton2.Value == 1
    label_table{ic_index+1, 2} = 0;
    label_table{ic_index+1, 3} = 1;
    label_table{ic_index+1, 4} = 0;
elseif handles.radiobutton3.Value == 1
    label_table{ic_index+1, 2} = 0;
    label_table{ic_index+1, 3} = 0;
    label_table{ic_index+1, 4} = 1;
end
if ic_index == 50
    msgbox('It''s the last IC!');
else
    ic_index = ic_index + 1;
    update_result(handles);
end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
global scan_index ic_index label_table scan_list result_path;
ic_index = 1;
scan_index = get(hObject, 'Value');
try
    [~,~,label_table] = xlsread(fullfile(result_path, 'labels', [scan_list(scan_index).name,'.xlsx']));
    label_table = label_table(1:51,1:4);
catch
    label_table = {};
    for i = 1:50
        label_table{i+1,1} = i;
    end
    label_table{1,2} = 'RSN';
    label_table{1,3} = 'NOISE';
    label_table{1,4} = 'OTHER';
end
update_result(handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global result_path ic_index scan_index scan_list label_table;
xlswrite(fullfile(result_path, 'labels', ...
    [scan_list(scan_index).name,'.xlsx']), label_table);
handles.text4.String = ['#IC: ',num2str(ic_index)];

% --- Executes during object creation, after setting all properties.
function uibuttongroup1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uibuttongroup1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
handles.radiobutton2.Value = 0;
handles.radiobutton3.Value = 0;


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
handles.radiobutton1.Value = 0;
handles.radiobutton3.Value = 0;


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
handles.radiobutton1.Value = 0;
handles.radiobutton2.Value = 0;
