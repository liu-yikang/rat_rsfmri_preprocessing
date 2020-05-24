function varargout = alignment_checking_tool(varargin)

% GUI for coregistering the first frame of a rat rsfMRI scan to a built-in template. 
% Output files: 
%    coregistered image: 'mr*'
%    transformation matrix: '*_checked_tform.mat'

% Author: Yikang Liu
% Last modified data: 11/05/2019

% ALIGNMENT_CHECKING_TOOL MATLAB code for alignment_checking_tool.fig
%      ALIGNMENT_CHECKING_TOOL, by itself, creates a new ALIGNMENT_CHECKING_TOOL or raises the existing
%      singleton*.
%
%      H = ALIGNMENT_CHECKING_TOOL returns the handle to a new ALIGNMENT_CHECKING_TOOL or the handle to
%      the existing singleton*.
%
%      ALIGNMENT_CHECKING_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALIGNMENT_CHECKING_TOOL.M with the given input arguments.
%
%      ALIGNMENT_CHECKING_TOOL('Property','Value',...) creates a new ALIGNMENT_CHECKING_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before alignment_checking_tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to alignment_checking_tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help alignment_checking_tool

% Last Modified by GUIDE v2.5 15-Jan-2018 14:28:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @alignment_checking_tool_OpeningFcn, ...
                   'gui_OutputFcn',  @alignment_checking_tool_OutputFcn, ...
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


% --- Executes just before alignment_checking_tool is made visible.
function alignment_checking_tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to alignment_checking_tool (see VARARGIN)

% Choose default command line output for alignment_checking_tool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes alignment_checking_tool wait for user response (see UIRESUME)
% uiwait(handles.main);

% show blank images
imshow(zeros(100),'Parent',handles.coronal);
imshow(zeros(100),'Parent',handles.sagittal);
imshow(zeros(100),'Parent',handles.transverse);

handles.main.KeyPressFcn = {@move_slice,handles};

clear all;


% --- Outputs from this function are returned to the command line.
function varargout = alignment_checking_tool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in subject.
function subject_Callback(hObject, eventdata, handles)
% hObject    handle to subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns subject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from subject


% --- Executes during object creation, after setting all properties.
function subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_scan.
function listbox_scan_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_scan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_scan


% --- Executes during object creation, after setting all properties.
function listbox_scan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_xtran_Callback(hObject, eventdata, handles)
% hObject    handle to slider_xtran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_xtran_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_xtran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_ytran_Callback(hObject, eventdata, handles)
% hObject    handle to slider_ytran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_ytran_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_ytran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_ztran_Callback(hObject, eventdata, handles)
% hObject    handle to slider_ztran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_ztran_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_ztran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_xrot_Callback(hObject, eventdata, handles)
% hObject    handle to slider_xrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_xrot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_xrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_yrot_Callback(hObject, eventdata, handles)
% hObject    handle to slider_yrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_yrot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_yrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_zrot_Callback(hObject, eventdata, handles)
% hObject    handle to slider_zrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_zrot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_zrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tform filename ref0 ref;

xlim = ref.XWorldLimits(2);
ylim = ref.YWorldLimits(2);
zlim = ref.ZWorldLimits(2);
dx = ref0.PixelExtentInWorldX;
dy = ref0.PixelExtentInWorldY;
dz = ref0.PixelExtentInWorldZ;

ref_out = imref3d(round([xlim/dx,ylim/dy,zlim/dz]),ref.XWorldLimits,ref.YWorldLimits,ref.ZWorldLimits);
if isempty(tform)
    update_transformation_edit(handles);
end
[pathstr,name] = fileparts(filename);
name_new = strrep(name,'r_mean_','');
%name_new = strrep(name_new,'nii','img');
try
    try
        nii = load_nii(fullfile(strrep(pathstr,'aligned','functional'),...
            [name_new,'.nii'])); % load original image
    catch
        nii = load_nii(fullfile(strrep(pathstr,'aligned','functional'),...
            [name_new,'.img'])); % load original image        
    end
    img = nii.img;
catch
    if contains(name_new, 'sdt')
        img = loadSdt(fullfile(pathstr,name_new));
    elseif contains(name_new, 'nii')
        try
            nii = load_nii(fullfile(pathstr,name_new));
        catch
            nii = load_nii(fullfile(pathstr, [name_new, '.gz']));
        end
        img = nii.img;
    end
    if handles.checkbox_rat.Value 
        img(:,size(img,2):64,:,:) = 0;
    end
    img = img(:,end:-1:1,:,:);
    img = img(end:-1:1,:,:,:);
end
img_out = zeros(ref_out.ImageSize);
for i = 1:size(img,4)
    img_out(:,:,:,i) = permute(imwarp(permute(img(:,:,:,i),[2 1 3]),ref0,tform,'cubic','OutputView',ref_out),[2 1 3]);
end
nii = make_nii(img_out,[dx,dy,dz],[1,1,1]);
name_new = strsplit(name_new,'.'); % remove file extension
mkdir(strrep(pathstr,'functional','aligned'));
save_nii(nii,fullfile(strrep(pathstr,'functional','aligned'),['mr',name_new{1},'.nii']));
save(fullfile(strrep(pathstr,'functional','aligned'),[name_new{1},'_checked_tform.mat']),'tform');
msgbox('Done');

function edit_xtran_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xtran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xtran as text
%        str2double(get(hObject,'String')) returns contents of edit_xtran as a double


% --- Executes during object creation, after setting all properties.
function edit_xtran_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xtran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ytran_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ytran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ytran as text
%        str2double(get(hObject,'String')) returns contents of edit_ytran as a double


% --- Executes during object creation, after setting all properties.
function edit_ytran_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ytran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ztran_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ztran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ztran as text
%        str2double(get(hObject,'String')) returns contents of edit_ztran as a double


% --- Executes during object creation, after setting all properties.
function edit_ztran_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ztran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_xrot_Callback(hObject, eventdata, handles)
% hObject    handle to edit_xrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_xrot as text
%        str2double(get(hObject,'String')) returns contents of edit_xrot as a double


% --- Executes during object creation, after setting all properties.
function edit_xrot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_xrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_yrot_Callback(hObject, eventdata, handles)
% hObject    handle to edit_yrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_yrot as text
%        str2double(get(hObject,'String')) returns contents of edit_yrot as a double


% --- Executes during object creation, after setting all properties.
function edit_yrot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_yrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_zrot_Callback(hObject, eventdata, handles)
% hObject    handle to edit_zrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_zrot as text
%        str2double(get(hObject,'String')) returns contents of edit_zrot as a double


% --- Executes during object creation, after setting all properties.
function edit_zrot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_zrot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_subject.
function listbox_subject_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_subject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_subject


% --- Executes during object creation, after setting all properties.
function listbox_subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

        
% --- Executes on button press in pushbutton_loadmatrix.
function pushbutton_loadmatrix_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadmatrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function coronal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coronal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate coronal


% --- Executes on button press in checkbox_landmark.
function checkbox_landmark_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_landmark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_landmark
global h_landmark_coronal h_landmark_sagittal h_landmark_transverse;
global landmark ref;
global slice_num_coronal slice_num_sagittal slice_num_transverse;

if isempty(slice_num_coronal)
    slice_num_coronal = 10;
end
if isempty(slice_num_transverse)
    slice_num_transverse = 10;
end
if isempty(slice_num_sagittal)
    slice_num_sagittal = 10;
end

if isempty(landmark)
    if handles.checkbox_rat.Value
%         WM_CSF_mask=load_nii(which('WM_CSF_mask_64x64.nii'));
%         WM_CSF_mask = WM_CSF_mask.img;
%         brain_mask=load_nii(which('brain_mask_64x64.nii'));
%         brain_mask = brain_mask.img;
%         perim = bwperim(brain_mask, 8);
%         landmark_mask = perim|WM_CSF_mask>0;
        landmark_mask = load_nii('landmark.nii.gz');
        landmark_mask = landmark_mask.img;
        ref_mask = imref3d(size(landmark_mask),[0 32],[0 32],[0 20]);
        t = eye(4);
%         t(4,2) = -0.5;
        landmark = imwarp(double(landmark_mask),ref_mask,affine3d(t),'nearest','OutputView',ref);
    elseif handles.checkbox_mouse.Value
%         nii_csf = load_nii(which('mouse_csf_mask.hdr'));
%         nii_wm = load_nii(which('mouse_wm_mask.hdr'));
%         landmark_mask = nii_csf.img>0 | nii_wm.img>0;
%         landmark = landmark_mask(end:-1:1,:,:);
        nii_wm = load_nii(which('standard_WM_mask_91_91_96.nii'));
        landmark_mask = nii_wm.img>0;
        landmark = landmark_mask(end:-1:1,:,:);
    end
end

if handles.checkbox_landmark.Value
    [x,y] = find(landmark(:,end:-1:1,slice_num_coronal)>0);
%     if isempty(h_landmark_coronal)
        h_landmark_coronal = scatter(handles.coronal,x,y,5,'filled','k');
%     else
%         h_landmark_coronal.XData = x;
%         h_landmark_coronal.YData = y;
%     end
    [x,y] = find(squeeze(landmark(slice_num_sagittal,:,end:-1:1))>0);
%     if isempty(h_landmark_sagittal)
        h_landmark_sagittal = scatter(handles.sagittal,x,y,5,'filled','k');
%     else
%         h_landmark_sagittal.XData = x;
%         h_landmark_sagittal.YData = y;
%     end
    [x,y] = find(squeeze(landmark(:,slice_num_transverse,end:-1:1))>0);
%     if isempty(h_landmark_transverse)
        h_landmark_transverse = scatter(handles.transverse,x,y,5,'filled','k');
%     else
%         h_landmark_transverse.XData = x;
%         h_landmark_transverse.YData = y;
%     end   
else
    if ~isempty(h_landmark_coronal) && isvalid(h_landmark_coronal)
        h_landmark_coronal.XData = [];
        h_landmark_coronal.YData = [];
        h_landmark_sagittal.XData = [];
        h_landmark_sagittal.YData = [];
        h_landmark_transverse.XData = [];
        h_landmark_transverse.YData = [];
    end
end


% --- Executes on slider movement.
function slider_tranx_Callback(hObject, eventdata, handles)
% hObject    handle to slider_tranx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

update_transformation_slider(handles);


% --- Executes during object creation, after setting all properties.
function slider_tranx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_tranx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_trany_Callback(hObject, eventdata, handles)
% hObject    handle to slider_trany (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
update_transformation_slider(handles);


% --- Executes during object creation, after setting all properties.
function slider_trany_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_trany (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_roty_Callback(hObject, eventdata, handles)
% hObject    handle to slider_roty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
update_transformation_slider(handles);


% --- Executes during object creation, after setting all properties.
function slider_roty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_roty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_rotz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_rotz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
update_transformation_slider(handles);


% --- Executes during object creation, after setting all properties.
function slider_rotz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_rotz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_tranz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_tranz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
update_transformation_slider(handles);


% --- Executes during object creation, after setting all properties.
function slider_tranz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_tranz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_rotx_Callback(hObject, eventdata, handles)
% hObject    handle to slider_rotx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
update_transformation_slider(handles);


% --- Executes during object creation, after setting all properties.
function slider_rotx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_rotx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_rotz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rotz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rotz as text
%        str2double(get(hObject,'String')) returns contents of edit_rotz as a double
update_transformation_edit(handles);

% --- Executes during object creation, after setting all properties.
function edit_rotz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rotz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_tranx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tranx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tranx as text
%        str2double(get(hObject,'String')) returns contents of edit_tranx as a double
update_transformation_edit(handles);

% --- Executes during object creation, after setting all properties.
function edit_tranx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tranx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_trany_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trany (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trany as text
%        str2double(get(hObject,'String')) returns contents of edit_trany as a double
update_transformation_edit(handles);


% --- Executes during object creation, after setting all properties.
function edit_trany_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trany (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_tranz_Callback(hObject, ~, handles)
% hObject    handle to edit_tranz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tranz as text
%        str2double(get(hObject,'String')) returns contents of edit_tranz as a double
update_transformation_edit(handles);


% --- Executes during object creation, after setting all properties.
function edit_tranz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tranz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rotx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rotx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rotx as text
%        str2double(get(hObject,'String')) returns contents of edit_rotx as a double
update_transformation_edit(handles);


% --- Executes during object creation, after setting all properties.
function edit_rotx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rotx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_roty_Callback(hObject, eventdata, handles)
% hObject    handle to edit_roty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_roty as text
%        str2double(get(hObject,'String')) returns contents of edit_roty as a double
update_transformation_edit(handles);


% --- Executes during object creation, after setting all properties.
function edit_roty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_roty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function update_transformation_slider(handles)
global tform tform0;  % tform0: automatic transformation
global ref img0 ref0; % ref: display reference; ref0: 
global hF_coronal hF_sagittal hF_transverse;
global filename
global imgF;
global slice_num_coronal slice_num_transverse slice_num_sagittal;

% load original image and transformation matrix
if isempty(tform0) || isempty(ref0) || isempty(img0)
    [pathstr,name] = fileparts(filename);
    if strcmp(name(1),'r')
        % autoaligned images found
        scanname = strrep(name,'r_mean_','');
        scanname = strrep(scanname,'.nii','');
        mat = load(fullfile(pathstr,[scanname,'_mat']),'-ascii');
        if sum(isnan(mat(:))) > 0
            mat = eye(4);
        end
        tform0 = affine3d(mat');
        nii = load_nii(fullfile(strrep(pathstr,'aligned','functional'),[scanname,'.img']));
        img0 = double(nii.img);
        
%         % calculate displacement relative to mean
%         img_mean = mean(img0,4);
%         diff = zeros(size(img0,4),1);
%         thresh = multithresh(img_mean(:));
%         mask = imerode(img_mean>thresh,strel('diamond',2));
%         mask = bwareaopen(mask,round(0.02*size(mask,1)*size(mask,2)*size(mask,3)),6);
%         mask = imdilate(mask,strel('diamond',2));
%         mask = imfill(mask,'holes');
%         for i_frame = 1:size(img0,4)
%             frame = img0(:,:,:,i_frame);
%             diff(i_frame) = mean(abs(frame(mask)-img_mean(mask)));
%         end
%         index_slct = diff<prctile(diff,20);
%         img0 = mean(img0(:,:,:,index_slct),4);
        
        img0 = img0(end:-1:1,:,:,1);
        img0_dx = nii.hdr.dime.pixdim(2);
        img0_dy = nii.hdr.dime.pixdim(3);
        img0_dz = nii.hdr.dime.pixdim(4);
        ref0 = imref3d(size(img0),[0,size(img0,1)*img0_dx],...
            [0,size(img0,2)*img0_dy],...
            [0,size(img0,3)*img0_dz]);

    else
        % only orignial image
        if handles.checkbox_rat.Value
            tform0 = affine3d(eye(4));
        elseif handles.checkbox_mouse.Value
            mat = load(which('mouse_ana2atlas.txt'),'ascii');
            tform0 = affine3d(mat');
        end
        
        if contains(filename,'nii')
            nii = load_nii(filename);
            img = double(nii.img);
            % img = img(:,end:-1:1,:,:);
            img0_dx = nii.hdr.dime.pixdim(2);
            img0_dy = nii.hdr.dime.pixdim(3);
            img0_dz = nii.hdr.dime.pixdim(4);
        elseif strcmp(filename(end-2:end),'sdt') || strcmp(filename(end-2:end),'spr')
            [img,img0_dx,img0_dy,img0_dz] = loadSdt(filename);
            if handles.checkbox_rat.Value 
                img(:,size(img,2):64,:,:) = 0;
            end
            img = img(:,end:-1:1,:,:);
        end
        
        
%         % calculate displacement relative to mean
%         if size(img,4) > 5
%             img_mean = mean(img,4);
%             diff = zeros(size(img,4),1);
%             thresh = multithresh(img_mean(:));
%             mask = imerode(img_mean>thresh,strel('diamond',2));
%             mask = bwareaopen(mask,round(0.02*size(mask,1)*size(mask,2)*size(mask,3)),6);
%             mask = imdilate(mask,strel('diamond',2));
%             mask = imfill(mask,'holes');
%             for i_frame = 1:size(img,4)
%                 frame = img(:,:,:,i_frame);
%                 diff(i_frame) = mean(abs(frame(mask)-img_mean(mask)));
%             end
%             index_slct = diff<prctile(diff,20);
%             img = mean(img(:,:,:,index_slct),4);
%         end
        
        % img0 = img(end:-1:1,:,:,1);
        img0 = img(:,:,:,1);
        ref0 = imref3d(size(img0),[0,size(img0,1)*img0_dx],...
            [0,size(img0,2)*img0_dy],...
            [0,size(img0,3)*img0_dz]);
        
    end
end


tranx = handles.slider_tranx.Value;
trany = handles.slider_trany.Value;
tranz = handles.slider_tranz.Value;
rotx = handles.slider_rotx.Value*pi/180;
roty = handles.slider_roty.Value*pi/180;
rotz = handles.slider_rotz.Value*pi/180;

handles.edit_tranx.String = num2str(tranx);
handles.edit_trany.String = num2str(trany);
handles.edit_tranz.String = num2str(tranz);
handles.edit_rotx.String = num2str(rotx);
handles.edit_roty.String = num2str(roty);
handles.edit_rotz.String = num2str(rotz);

Rz = [cos(rotz) sin(rotz) 0 0; -sin(rotz) cos(rotz) 0 0; 0 0 1 0; 0 0 0 1];
Rx = [1 0 0 0; 0 cos(rotx) sin(rotx) 0; 0 -sin(rotx) cos(rotx) 0; 0 0 0 1];
Ry = [cos(roty) 0 -sin(roty) 0; 0 1 0 0; sin(roty) 0 cos(roty) 0; 0 0 0 1];
T = [1 0 0 tranx; 0 1 0 trany; 0 0 1 tranz;0 0 0 1];

M = T*[1 0 0 ref0.XWorldLimits(2)/2; 0 1 0 ref0.YWorldLimits(2)/2; 0 0 1 ref0.ZWorldLimits(2)/2; 0 0 0 1]...
    *Rx*Ry*Rz*[1 0 0 -ref0.XWorldLimits(2)/2; 0 1 0 -ref0.YWorldLimits(2)/2; 0 0 1 -ref0.ZWorldLimits(2)/2; 0 0 0 1];

tform = affine3d(tform0.T*M');

img0(isnan(img0)) = 0;

img0_trans = imwarp(permute(img0,[2 1 3 4]),ref0,tform,'OutputView',ref);
imgF = permute(img0_trans,[2 1 3 4]);
hF_coronal.CData = rot90(imgF(:,:,slice_num_coronal));
hF_sagittal.CData = rot90(squeeze(imgF(slice_num_sagittal,:,:)));
hF_transverse.CData = rot90(squeeze(imgF(:,slice_num_transverse,:)));

function update_transformation_edit(handles)
global tform tform0;  % tform0: automatic transformation
global ref img0 ref0; % ref: display reference; ref0: 
global hF_coronal hF_sagittal hF_transverse;
global filename
global imgF;
global slice_num_coronal slice_num_transverse slice_num_sagittal;

% load original image and transformation matrix3
if isempty(tform0) || isempty(ref0) || isempty(img0)
    [pathstr,name] = fileparts(filename);
    if strcmp(name(1),'r')
        % autoaligned images found
        scanname = strrep(name,'r_mean_','');
        scanname = strrep(scanname,'.nii','');
        mat = load(fullfile(pathstr,[scanname,'_mat']),'-ascii');
        if sum(isnan(mat(:))) > 0
            mat = eye(4);
        end      
        tform0 = affine3d(mat');
        nii = load_nii(fullfile(strrep(pathstr,'aligned','functional'),[scanname,'.img']));
        img0 = double(nii.img);
        
        
        % calculate displacement relative to mean
        img_mean = mean(img0,4);
        diff = zeros(size(img0,4),1);
        thresh = multithresh(img_mean(:));
        mask = imerode(img_mean>thresh,strel('diamond',2));
        mask = bwareaopen(mask,round(0.02*size(mask,1)*size(mask,2)*size(mask,3)),6);
        mask = imdilate(mask,strel('diamond',2));
        mask = imfill(mask,'holes');
        for i_frame = 1:size(img0,4)
            frame = img0(:,:,:,i_frame);
            diff(i_frame) = mean(abs(frame(mask)-img_mean(mask)));
        end
        index_slct = diff<prctile(diff,20);
        img0 = mean(img0(:,:,:,index_slct),4);
        
        
        img0 = img0(end:-1:1,:,:,1);
        img0_dx = nii.hdr.dime.pixdim(2);
        img0_dy = nii.hdr.dime.pixdim(3);
        img0_dz = nii.hdr.dime.pixdim(4);
        ref0 = imref3d(size(img0),[0,size(img0,1)*img0_dx],...
            [0,size(img0,2)*img0_dy],...
            [0,size(img0,3)*img0_dz]);
    else
        % only orignial image
        if handles.checkbox_mouse.Value
            mat = load(which('mouse_ana2atlas.txt'),'ascii');
            tform0 = affine3d(mat');
        else
            tform0 = affine3d(eye(4));
        end
        if ~isempty(strfind(filename,'nii'))
            nii = load_nii(filename);
            img = double(nii.img);
            img0_dx = nii.hdr.dime.pixdim(2);
            img0_dy = nii.hdr.dime.pixdim(3);
            img0_dz = nii.hdr.dime.pixdim(4);
        elseif strcmp(filename(end-2:end),'sdt') || strcmp(filename(end-2:end),'spr')
            [img,img0_dx,img0_dy,img0_dz] = loadSdt(filename);
            img = img(:,end:-1:1,:,1);
        end
        
        % calculate displacement relative to mean
        if size(img,4) > 5
            img_mean = mean(img,4);
            diff = zeros(size(img,4),1);
            thresh = multithresh(img_mean(:));
            mask = imerode(img_mean>thresh,strel('diamond',2));
            mask = bwareaopen(mask,round(0.02*size(mask,1)*size(mask,2)*size(mask,3)),6);
            mask = imdilate(mask,strel('diamond',2));
            mask = imfill(mask,'holes');
            for i_frame = 1:size(img,4)
                frame = img(:,:,:,i_frame);
                diff(i_frame) = mean(abs(frame(mask)-img_mean(mask)));
            end
            index_slct = diff<prctile(diff,20);
            img = mean(img(:,:,:,index_slct),4);
        end
        
        img0 = img(end:-1:1,:,:,1);
        ref0 = imref3d(size(img0),[0,size(img0,1)*img0_dx],...
            [0,size(img0,2)*img0_dy],...
            [0,size(img0,3)*img0_dz]);
    end
end

if str2double(handles.edit_tranx.String) <= handles.slider_tranx.Max ...
        && str2double(handles.edit_tranx.String) >= handles.slider_tranx.Min
    tranx = str2double(handles.edit_tranx.String);
else
    handles.edit_tranx.String = num2str(handles.slider_tranx.Value);
    tranx = handles.slider_tranx.Value;
end

if str2double(handles.edit_trany.String) <= handles.slider_trany.Max ...
        && str2double(handles.edit_trany.String) >= handles.slider_trany.Min
    trany = str2double(handles.edit_trany.String);
else
    handles.edit_trany.String = num2str(handles.slider_trany.Value);
    trany = handles.slider_trany.Value;
end

if str2double(handles.edit_tranz.String) <= handles.slider_tranz.Max ...
        && str2double(handles.edit_tranz.String) >= handles.slider_tranz.Min
    tranz = str2double(handles.edit_tranz.String);
else
    handles.edit_tranz.String = num2str(handles.slider_tranz.Value);
    tranz = handles.slider_tranz.Value;
end

if str2double(handles.edit_rotx.String) <= handles.slider_rotx.Max ...
        && str2double(handles.edit_rotx.String) >= handles.slider_rotx.Min
    rotx = str2double(handles.edit_rotx.String)*pi/180;
else
    handles.edit_rotx.String = num2str(handles.slider_rotx.Value);
    rotx = handles.slider_rotx.Value;
end

if str2double(handles.edit_roty.String) <= handles.slider_roty.Max ...
        && str2double(handles.edit_roty.String) >= handles.slider_roty.Min
    roty = str2double(handles.edit_roty.String)*pi/180;
else
    handles.edit_roty.String = num2str(handles.slider_roty.Value);
    roty = handles.slider_roty.Valoadlue;
end

if str2double(handles.edit_rotz.String) <= handles.slider_rotz.Max ...
        && str2double(handles.edit_rotz.String) >= handles.slider_rotz.Min
    rotz = str2double(handles.edit_rotz.String)*pi/180;
else
    handles.edit_rotz.String = num2str(handles.slider_rotz.Value);
    rotz = handles.slider_rotz.Value;
end

handles.slider_tranx.Value = tranx;
handles.slider_trany.Value = trany;
handles.slider_tranz.Value = tranz;
handles.slider_rotx.Value = rotx;
handles.slider_roty.Value = roty;
handles.slider_rotz.Value = rotz;

Rz = [cos(rotz) sin(rotz) 0 0; -sin(rotz) cos(rotz) 0 0; 0 0 1 0; 0 0 0 1];
Rx = [1 0 0 0; 0 cos(rotx) sin(rotx) 0; 0 -sin(rotx) cos(rotx) 0; 0 0 0 1];
Ry = [cos(roty) 0 -sin(roty) 0; 0 1 0 0; sin(roty) 0 cos(roty) 0; 0 0 0 1];
T = [1 0 0 tranx; 0 1 0 trany; 0 0 1 tranz;0 0 0 1];

M = T*Rx*Ry*Rz;

tform = affine3d(tform0.T*M');

img0_trans = imwarp(permute(img0,[2 1 3 4]),ref0,tform,'OutputView',ref);
imgF = permute(img0_trans,[2 1 3 4]);
hF_coronal.CData = rot90(imgF(:,:,slice_num_coronal));
hF_sagittal.CData = rot90(squeeze(imgF(slice_num_sagittal,:,:)));
hF_transverse.CData = rot90(squeeze(imgF(:,slice_num_transverse,:)));



function move_slice(varargin)
global slice_num_coronal slice_num_sagittal slice_num_transverse;
global hF_coronal hB_coronal hF_sagittal hB_sagittal hF_transverse hB_transverse;
global landmark h_landmark_coronal h_landmark_sagittal h_landmark_transverse;
global imgF imgB climB climF alpha;

if isempty(slice_num_coronal)
    slice_num_coronal = 10;
end
if isempty(slice_num_transverse)
    slice_num_transverse = 10;
end
if isempty(slice_num_sagittal)
    slice_num_sagittal = 10;
end
key = varargin{2}.Key;
handles = varargin{3};
mouse = handles.main.CurrentPoint;
if mouse(1)/handles.main.Position(3) > 0.01 && mouse(1)/handles.main.Position(3) < 0.5
    if mouse(2)/handles.main.Position(4) > 0.5
        axes_selected = 'coronal';
    else
        axes_selected = 'transverse';
    end
elseif mouse(1)/handles.main.Position(3) > 0.5  ...
        && mouse(2)/handles.main.Position(4) > 0.5
    axes_selected = 'sagittal';
end
    
    
if isempty(axes_selected)
    axes_selected = 'coronal';
end
switch key
    case 'downarrow'
        switch axes_selected
            case 'coronal'
                if slice_num_coronal > 1
                    slice_num_coronal = slice_num_coronal - 1;
                end
            case 'sagittal'
                if slice_num_sagittal > 1
                    slice_num_sagittal = slice_num_sagittal - 1;
                end
            case 'transverse'
                if slice_num_transverse > 1
                    slice_num_transverse = slice_num_transverse - 1;
                end
        end
    case 'uparrow'
        switch axes_selected
            case 'coronal'
                if slice_num_coronal < size(imgF,3)
                    slice_num_coronal = slice_num_coronal + 1;
                end
            case 'sagittal'
                if slice_num_sagittal < size(imgF,1)
                    slice_num_sagittal = slice_num_sagittal + 1;
                end                
            case 'transverse'
                if slice_num_transverse < size(imgF,2)
                    slice_num_transverse = slice_num_transverse + 1;
                end                
        end
end


if handles.checkbox_landmark.Value
    [x,y] = find(landmark(:,end:-1:1,slice_num_coronal)>0);
    if isempty(h_landmark_coronal)
        h_landmark_coronal = scatter(handles.coronal,x,y,5,'filled');
    else
        h_landmark_coronal.XData = x;
        h_landmark_coronal.YData = y;
    end
    [x,y] = find(squeeze(landmark(slice_num_sagittal,:,end:-1:1))>0);
    if isempty(h_landmark_sagittal)
        h_landmark_sagittal = scatter(handles.sagittal,x,y,5,'filled');
    else
        h_landmark_sagittal.XData = x;
        h_landmark_sagittal.YData = y;
    end
    [x,y] = find(squeeze(landmark(:,slice_num_transverse,end:-1:1))>0);
    if isempty(h_landmark_transverse)
        h_landmark_transverse = scatter(handles.transverse,x,y,5,'filled');
    else
        h_landmark_transverse.XData = x;
        h_landmark_transverse.YData = y;
    end
    
end

hB_coronal.CData = repmat(mat2gray(double(rot90(imgB(:,:,slice_num_coronal))),double(climB)*max(imgB(:))),[1,1,3]);
hF_coronal.CData = rot90(imgF(:,:,slice_num_coronal));
hB_sagittal.CData = repmat(mat2gray(double(rot90(squeeze(imgB(slice_num_sagittal,:,:)))),double(climB)*max(imgB(:))),[1,1,3]);
hF_sagittal.CData = rot90(squeeze(imgF(slice_num_sagittal,:,:)));
hB_transverse.CData = repmat(mat2gray(double(rot90(squeeze(imgB(:,slice_num_transverse,:)))),double(climB)*max(imgB(:))),[1,1,3]);
hF_transverse.CData = rot90(squeeze(imgF(:,slice_num_transverse,:)));
alphadata = alpha.*(rot90(imgF(:,:,slice_num_coronal)) >= climF(1) * max(imgF(:)));
set(hF_coronal,'AlphaData',alphadata);
alphadata = alpha.*(rot90(squeeze(imgF(slice_num_sagittal,:,:))) >= climF(1) * max(imgF(:)));
set(hF_sagittal,'AlphaData',alphadata);
alphadata = alpha.*(rot90(squeeze(imgF(:,slice_num_transverse,:))) >= climF(1) * max(imgF(:)));
set(hF_transverse,'AlphaData',alphadata);

% --- Executes on slider movement.
function slider_max_Callback(hObject, eventdata, handles)
% hObject    handle to slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global imgF imgB climF climB;
global hB_coronal hB_transverse hB_sagittal;
global hF_coronal hF_transverse hF_sagittal;
global alpha;
global slice_num_coronal slice_num_sagittal slice_num_transverse;

if isempty(alpha)
    alpha = handles.slider_opacity.Value;
end
if isempty(slice_num_coronal)
    slice_num_coronal = 10;
end
if isempty(slice_num_transverse)
    slice_num_transverse = 10;
end
if isempty(slice_num_sagittal)
    slice_num_sagittal = 10;
end
if handles.checkbox_background.Value
    climB = [handles.slider_min.Value, handles.slider_max.Value];
    hB_coronal.CData = repmat(mat2gray(double(rot90(squeeze(imgB(:,:,slice_num_coronal)))),double(climB * max(imgB(:)))),[1,1,3]);
    hB_sagittal.CData = repmat(mat2gray(double(rot90(squeeze(imgB(slice_num_sagittal,:,:)))),double(climB * max(imgB(:)))),[1,1,3]);
    hB_transverse.CData = repmat(mat2gray(double(rot90(squeeze(imgB(:,slice_num_transverse,:)))),double(climB * max(imgB(:)))),[1,1,3]);
end
if handles.checkbox_foreground.Value
    climF = [handles.slider_min.Value, handles.slider_max.Value];
    F = rot90(imgF(:,:,slice_num_coronal));
    F(F<=climF(1) * max(imgF(:))) = nan;
    alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
    set(hF_coronal,'AlphaData',alphadata);
    hF_coronal.CData = F;
    handles.coronal.CLim = climF * max(imgF(:));
    
    F = rot90(squeeze(imgF(slice_num_sagittal,:,:)));
    F(F<=climF(1) * max(imgF(:))) = nan;
    alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
    set(hF_sagittal,'AlphaData',alphadata);
    hF_sagittal.CData = F;
    handles.sagittal.CLim = climF * max(imgF(:));
    
    F = rot90(squeeze(imgF(:,slice_num_transverse,:)));
    F(F<=climF(1) * max(imgF(:))) = nan;
    alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
    set(hF_transverse,'AlphaData',alphadata);
    hF_transverse.CData = F;
    handles.transverse.CLim = climF * max(imgF(:));
end

% --- Executes during object creation, after setting all properties.
function slider_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_min_Callback(hObject, eventdata, handles)
% hObject    handle to slider_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global imgF imgB climF climB;
global hB_coronal hB_transverse hB_sagittal;
global hF_coronal hF_transverse hF_sagittal;
global alpha;
global slice_num_coronal slice_num_sagittal slice_num_transverse;

if isempty(alpha)
    alpha = handles.slider_opacity.Value;
end
if isempty(slice_num_coronal)
    slice_num_coronal = 10;
end
if isempty(slice_num_transverse)
    slice_num_transverse = 10;
end
if isempty(slice_num_sagittal)
    slice_num_sagittal = 10;
end

if handles.checkbox_background.Value
    climB = [handles.slider_min.Value, handles.slider_max.Value];
    hB_coronal.CData = repmat(mat2gray(double(rot90(squeeze(imgB(:,:,slice_num_coronal)))),double(climB * max(imgB(:)))),[1,1,3]);
    hB_sagittal.CData = repmat(mat2gray(double(rot90(squeeze(imgB(slice_num_sagittal,:,:)))),double(climB * max(imgB(:)))),[1,1,3]);
    hB_transverse.CData = repmat(mat2gray(double(rot90(squeeze(imgB(:,slice_num_transverse,:)))),double(climB * max(imgB(:)))),[1,1,3]);
end
if handles.checkbox_foreground.Value
    climF = [handles.slider_min.Value, handles.slider_max.Value];
    F = rot90(imgF(:,:,slice_num_coronal));
    F(F<=climF(1) * max(imgF(:))) = nan;
    alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
    set(hF_coronal,'AlphaData',alphadata);
    hF_coronal.CData = F;
    handles.coronal.CLim = climF * max(imgF(:));
    
    F = rot90(squeeze(imgF(slice_num_sagittal,:,:)));
    F(F<=climF(1) * max(imgF(:))) = nan;
    alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
    set(hF_sagittal,'AlphaData',alphadata);
    hF_sagittal.CData = F;
    handles.sagittal.CLim = climF * max(imgF(:));
    
    F = rot90(squeeze(imgF(:,slice_num_transverse,:)));
    F(F<=climF(1) * max(imgF(:))) = nan;
    alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
    set(hF_transverse,'AlphaData',alphadata);
    hF_transverse.CData = F;
    handles.transverse.CLim = climF * max(imgF(:));
end


% --- Executes during object creation, after setting all properties.
function slider_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox_foreground.
function checkbox_foreground_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_foreground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_foreground
global climF;

if isempty(climF)
    climF = [0 1];
end
handles.checkbox_background.Value = 0;
handles.slider_min.Value = climF(1);
handles.slider_max.Value = climF(2);



% --- Executes on button press in checkbox_background.
function checkbox_background_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_background
global climB;

if isempty(climB)
    climB = [0 1];
end
handles.checkbox_foreground.Value = 0;
handles.slider_min.Value = climB(1);
handles.slider_max.Value = climB(2);


% --- Executes on slider movement.
function slider_opacity_Callback(hObject, eventdata, handles)
% hObject    handle to slider_opacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global alpha;
global imgF climF;
global slice_num_coronal slice_num_transverse slice_num_sagittal;
global hF_coronal hF_transverse hF_sagittal;

alpha = handles.slider_opacity.Value;

F = rot90(imgF(:,:,slice_num_coronal));
F(F<=climF(1) * max(imgF(:))) = nan;
alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
set(hF_coronal,'AlphaData',alphadata);

F = rot90(squeeze(imgF(:,slice_num_transverse,:)));
F(F<=climF(1) * max(imgF(:))) = nan;
alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
set(hF_transverse,'AlphaData',alphadata);

F = rot90(squeeze(imgF(slice_num_sagittal,:,:)));
F(F<=climF(1) * max(imgF(:))) = nan;
alphadata = alpha.*(F >= climF(1) * max(imgF(:)));
set(hF_sagittal,'AlphaData',alphadata);


% --- Executes during object creation, after setting all properties.
function slider_opacity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_opacity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in pushbutton_loadData.
function pushbutton_loadData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename tform tform0 alpha ref imgF imgB climF climB...
    hF_coronal hB_coronal hF_sagittal hB_sagittal hF_transverse hB_transverse...
    slice_num_coronal slice_num_sagittal slice_num_transverse pathname img0;
img0 = [];
tform = [];
if handles.checkbox_mouse.Value
    mat = load(which('mouse_ana2atlas.txt'),'ascii');
    tform0 = affine3d(mat');
else
    tform0 = [];
end

if isempty(pathname) || sum(pathname == 0)==1
    [filename,pathname] = uigetfile();
else
    cd(pathname);
    [filename,pathname] = uigetfile();%({fullfile(pathname,'*.nii*');fullfile(pathname,'*.spr*')});
end
filename = fullfile(pathname,filename);
handles.text_filename.String = filename;
if isempty(alpha)
    alpha = handles.slider_opacity.Value;
end
if isempty(slice_num_coronal)
    slice_num_coronal = 15;
end
if isempty(slice_num_sagittal)
    slice_num_sagittal = 15;
end
if isempty(slice_num_transverse)
    slice_num_transverse = 15;
end

% load subject image
%[img,dx,dy,dz] = loadSdt(filename);
if ~isempty(strfind(filename,'nii')) || ~isempty(strfind(filename,'img'))...
        || ~isempty(strfind(filename,'hdr'))
    nii = load_nii(filename);
    dx = nii.hdr.dime.pixdim(2);
    dy = nii.hdr.dime.pixdim(3);
    dz = nii.hdr.dime.pixdim(4);
    if dx==-1 || dy==-1 || dz==-1
        dx=0.5;
        dy=0.5;
        dz=1;
    end
    img = double(nii.img);
    % img = img(:,end:-1:1,:,1);
elseif strcmp(filename(end-2:end),'sdt')||strcmp(filename(end-2:end),'spr')
    [img,dx,dy,dz] = loadSdt(filename);
    if handles.checkbox_rat.Value  
        img(:,size(img,2):64,:,:) = 0;
    end
    img = img(:,end:-1:1,:,1);
end
% img = img(end:-1:1,:,:,1);
img = img(:,:,:,1);

if sum(img(:)) == 0 % automatic alignment failed
    filename = strrep(filename,'r_mean_','');
    filename = strrep(filename,'.nii.gz','.img');
    filename = strrep(filename,'aligned','functional');
    nii = load_nii(filename);
    dx = nii.hdr.dime.pixdim(2);
    dy = nii.hdr.dime.pixdim(3);
    dz = nii.hdr.dime.pixdim(4);
    if dx==-1 || dy==-1 || dz==-1
        dx=0.5;
        dy=0.5;
        dz=1;
    end
    img = double(nii.img);
    handles.text_filename.String = filename;
    
    % calculate displacement relative to mean
    img_mean = mean(img,4);
    diff = zeros(size(img,4),1);
    thresh = multithresh(img_mean(:));
    mask = imerode(img_mean>thresh,strel('diamond',2));
    mask = bwareaopen(mask,round(0.02*size(mask,1)*size(mask,2)*size(mask,3)),6);
    mask = imdilate(mask,strel('diamond',2));
    mask = imfill(mask,'holes');
    for i_frame = 1:size(img,4)
        frame = img(:,:,:,i_frame);
        diff(i_frame) = mean(abs(frame(mask)-img_mean(mask)));
    end
    index_slct = diff<prctile(diff,20);
    img = mean(img(:,:,:,index_slct),4);
        
else
    handles.slider_tranx.Value = 0;
    handles.slider_trany.Value = 0;
    handles.slider_tranz.Value = 0;
    handles.slider_rotx.Value = 0;
    handles.slider_roty.Value = 0;
    handles.slider_rotz.Value = 0;
    
    handles.edit_tranx.String = '0';
    handles.edit_trany.String = '0';
    handles.edit_tranz.String = '0';
    handles.edit_rotx.String = '0';
    handles.edit_roty.String = '0';
    handles.edit_rotz.String = '0';
end

ref = imref3d(size(img),[0 size(img,1)*dx],...
    [0 size(img,2)*dy],[0 size(img,3)*dz]);
% img = img(:,end:-1:1,:,1);

% load standard image
if handles.checkbox_rat.Value  
    nii = load_nii(which('standard_anatomy_t2.nii'));
    std = nii.img;
    dx = nii.hdr.dime.pixdim(2);
    dy = nii.hdr.dime.pixdim(3);
    dz = nii.hdr.dime.pixdim(4);
    std = std(end:-1:1,:,:);
elseif handles.checkbox_mouse.Value
    nii = load_nii(which('mouse_standard_anatomy_ds_91_91_96.nii'));
    std = nii.img;
    dx = nii.hdr.dime.pixdim(2);
    dy = nii.hdr.dime.pixdim(3);
    dz = nii.hdr.dime.pixdim(4);
    std = std(end:-1:1,:,:);
end

% 
% vol = spm_vol(which('standard_anatomy_t2.hdr'));
% dx = abs(vol.mat(1,1)/10);
% dy = abs(vol.mat(2,2)/10);
% dz = abs(vol.mat(3,3)/10);
% std = spm_read_vols(vol);

ref_std = imref3d(size(std),[0 size(std,1)*dx],...
    [0 size(std,2)*dy],[0 size(std,3)*dz]);

% unify ref
size_display = size(std);
size_display(3) = (size_display(3)-1)*round(dz/dx)+1;
ref_display = imref3d(size_display,[0 size(std,1)*dx],...
    [0 size(std,2)*dy],[0 size(std,3)*dz]);
if ~handles.checkbox_mouse.Value
    img = imwarp(img,ref,affine3d(eye(4)),'OutputView',ref_display);
else
    img = permute(imwarp(permute(img,[2 1 3]),ref,tform0,'OutputView',ref_display),[2 1 3]);
end
std = imwarp(std,ref_std,affine3d(eye(4)),'OutputView',ref_display);
ref = ref_display;

imgF = double(img);
imgB = double(std);
if isempty(climF)
    climF=[0 0.9];%[handles.slider_min.Value,handles.slider_max.Value]; 
end
if isempty(climB)
    climB=[0.05 0.6];%[handles.slider_min.Value,handles.slider_max.Value]; 
end

if isempty(hF_coronal)
[hF_coronal,hB_coronal] = myimoverlay(rot90(imgB(:,:,slice_num_coronal,1)),rot90(imgF(:,:,slice_num_coronal,1)),...
    climF*max(imgF(:)),climB*max(imgB(:)),'jet',alpha,handles.coronal);
else
    hF_coronal.CData = rot90(squeeze(imgF(:,:,slice_num_coronal)));
    hB_coronal.CData = repmat(mat2gray(double(rot90(imgB(:,:,slice_num_coronal))),double(climB)*max(imgB(:))),[1,1,3]);
end

if isempty(hF_sagittal)
[hF_sagittal,hB_sagittal] = myimoverlay(rot90(squeeze(imgB(slice_num_sagittal,:,:,1))),rot90(squeeze(imgF(slice_num_sagittal,:,:,1))),...
    climF*max(imgF(:)),climB*max(imgB(:)),'jet',alpha,handles.sagittal);
else
    hF_sagittal.CData = rot90(squeeze(imgF(slice_num_sagittal,:,:)));
    hB_sagittal.CData = repmat(mat2gray(double(rot90(squeeze(imgB(slice_num_sagittal,:,:)))),double(climB)*max(imgB(:))),[1,1,3]);
end

if isempty(hF_transverse)
[hF_transverse,hB_transverse] = myimoverlay(rot90(squeeze(imgB(:,slice_num_transverse,:,1))),rot90(squeeze(imgF(:,slice_num_transverse,:,1))),...
    climF*max(imgF(:)),climB*max(imgB(:)),'jet',alpha,handles.transverse);
else
    hF_transverse.CData = rot90(squeeze(imgF(:,slice_num_transverse,:)));
    hB_transverse.CData = repmat(mat2gray(double(rot90(squeeze(imgB(:,slice_num_transverse,:)))),double(climB)*max(imgB(:))),[1,1,3]);
end


% --- Executes on mouse press over axes background.
function coronal_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to coronal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global axes_selected;
axes_selected = 'coronal';


% --- Executes during object creation, after setting all properties.
function sagittal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate sagittal


% --- Executes on mouse press over axes background.
function sagittal_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global axes_selected;
axes_selected = 'sagittal';

% --- Executes on mouse press over axes background.
function transverse_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to transverse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global axes_selected;
axes_selected = 'transverse';


% --- Executes on button press in checkbox_rat.
function checkbox_rat_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rat
handles.checkbox_mouse.Value = 0;

% --- Executes on button press in checkbox_mouse.
function checkbox_mouse_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mouse
handles.checkbox_rat.Value = 0;

% --- Executes on button press in pushbutton_loadmat.
function pushbutton_loadmat_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadmat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global tform0 ref0 ref img0 imgF pathname filename...
    hF_coronal hF_sagittal hF_transverse slice_num_coronal slice_num_sagittal slice_num_transverse;

if isempty(img0)
    if ~isempty(strfind(filename,'nii'))
        nii = load_nii(filename);
        img = double(nii.img);
        img0_dx = nii.hdr.dime.pixdim(2);
        img0_dy = nii.hdr.dime.pixdim(3);
        img0_dz = nii.hdr.dime.pixdim(4);
    elseif strcmp(filename(end-2:end),'sdt') || strcmp(filename(end-2:end),'spr')
        [img,img0_dx,img0_dy,img0_dz] = loadSdt(filename);
        img = img(:,end:-1:1,:,1);
    end
     
%     % calculate displacement relative to mean
%     if size(img,4) > 5
%         img_mean = mean(img,4);
%         diff = zeros(size(img,4),1);
%         thresh = multithresh(img_mean(:));
%         mask = imerode(img_mean>thresh,strel('diamond',2));
%         mask = bwareaopen(mask,round(0.02*size(mask,1)*size(mask,2)*size(mask,3)),6);
%         mask = imdilate(mask,strel('diamond',2));
%         mask = imfill(mask,'holes');
%         for i_frame = 1:size(img,4)
%             frame = img(:,:,:,i_frame);
%             diff(i_frame) = mean(abs(frame(mask)-img_mean(mask)));
%         end
%         index_slct = diff<prctile(diff,20);
%         img = mean(img(:,:,:,index_slct),4);
%     end
    
    %img0 = img(end:-1:1,:,:,1);
    img0 = img(:,:,:,1);
    ref0 = imref3d(size(img0),[0,size(img0,1)*img0_dx],...
        [0,size(img0,2)*img0_dy],...
        [0,size(img0,3)*img0_dz]);
end

[file,path] = uigetfile(strrep(pathname,'functional','aligned'));
mat = load(fullfile(path,file));
tform0 = mat.tform;
handles.text_mat.String = fullfile(path,file);
tranx = handles.slider_tranx.Value;
trany = handles.slider_trany.Value;
tranz = handles.slider_tranz.Value;
rotx = handles.slider_rotx.Value*pi/180;
roty = handles.slider_roty.Value*pi/180;
rotz = handles.slider_rotz.Value*pi/180;

handles.edit_tranx.String = num2str(tranx);
handles.edit_trany.String = num2str(trany);
handles.edit_tranz.String = num2str(tranz);
handles.edit_rotx.String = num2str(rotx);
handles.edit_roty.String = num2str(roty);
handles.edit_rotz.String = num2str(rotz);

Rz = [cos(rotz) sin(rotz) 0 0; -sin(rotz) cos(rotz) 0 0; 0 0 1 0; 0 0 0 1];
Rx = [1 0 0 0; 0 cos(rotx) sin(rotx) 0; 0 -sin(rotx) cos(rotx) 0; 0 0 0 1];
Ry = [cos(roty) 0 -sin(roty) 0; 0 1 0 0; sin(roty) 0 cos(roty) 0; 0 0 0 1];
T = [1 0 0 tranx; 0 1 0 trany; 0 0 1 tranz;0 0 0 1];

M = T*[1 0 0 ref0.XWorldLimits(2)/2; 0 1 0 ref0.YWorldLimits(2)/2; 0 0 1 ref0.ZWorldLimits(2)/2; 0 0 0 1]...
    *Rx*Ry*Rz*[1 0 0 -ref0.XWorldLimits(2)/2; 0 1 0 -ref0.YWorldLimits(2)/2; 0 0 1 -ref0.ZWorldLimits(2)/2; 0 0 0 1];

tform = affine3d(tform0.T*M');

img0(isnan(img0)) = 0;

img0_trans = imwarp(permute(img0,[2 1 3 4]),ref0,tform,'OutputView',ref);
imgF = permute(img0_trans,[2 1 3 4]);
hF_coronal.CData = rot90(imgF(:,:,slice_num_coronal));
hF_sagittal.CData = rot90(squeeze(imgF(slice_num_sagittal,:,:)));
hF_transverse.CData = rot90(squeeze(imgF(:,slice_num_transverse,:)));


% --- Executes on button press in pushbutton_discard_scan.
function pushbutton_discard_scan_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_discard_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename;
[pathstr,name] = fileparts(filename);
name = strsplit(name,'.');
name = name{1};
bad_scan_dir = strrep(pathstr,'aligned','bad_scan');
bad_scan_dir = strrep(bad_scan_dir,'functional','bad_scan');
mkdir(bad_scan_dir);
movefile(fullfile(pathstr,['*',name(2:end),'*']),bad_scan_dir);
