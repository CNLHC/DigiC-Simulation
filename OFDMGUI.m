function varargout = OFDMGUI(varargin)
%OFDMGUI MATLAB code file for OFDMGUI.fig
%      OFDMGUI, by itself, creates a new OFDMGUI or raises the existing
%      singleton*.
%
%      H = OFDMGUI returns the handle to a new OFDMGUI or the handle to
%      the existing singleton*.
%
%      OFDMGUI('Property','Value',...) creates a new OFDMGUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to OFDMGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      OFDMGUI('CALLBACK') and OFDMGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in OFDMGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OFDMGUI

% Last Modified by GUIDE v2.5 20-Nov-2018 19:32:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OFDMGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @OFDMGUI_OutputFcn, ...
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


% --- Executes just before OFDMGUI is made visible.
function OFDMGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for OFDMGUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes OFDMGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OFDMGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tSNR= get(findall(0,'tag','SNR'),'String')
tPath=get( findall(0,'tag','Path'),'String')
if(isempty(tSNR)||isempty(tPath))
    msgbox("Please input required parameter");
    return
else
    %function BER=OFDM(modulation, SNR, L, plot_config, SNR_test, CN, OP)
    OFDMEntry(1,tSNR,tPath,1);
end



% --- Executes on button press in BER_curve.
function BER_curve_Callback(hObject, eventdata, handles)
% hObject    handle to BER_curve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tSNR= get(findall(0,'tag','SNR'),'String')
tPath=get( findall(0,'tag','Path'),'String')
if(isempty(tSNR)||isempty(tPath))
    msgbox("Please input required parameter");
    return
else
    %function BER=OFDM(modulation, SNR, L, plot_config, SNR_test, CN, OP)
    OFDMEntry(1,tSNR,tPath,1);
end




% --- Executes on button press in BER_path.
function BER_path_Callback(hObject, eventdata, handles)
% hObject    handle to BER_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tSNR= get(findall(0,'tag','SNR'),'String')
tPath=get( findall(0,'tag','Path'),'String')
if(isempty(tSNR)||isempty(tPath))
    msgbox("Please input required parameter");
    return
else
    %function BER=OFDM(modulation, SNR, L, plot_config, SNR_test, CN, OP)
    OFDMEntry(1,tSNR,tPath,1);
end




function SNR_Callback(hObject, eventdata, handles)
% hObject    handle to SNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SNR as text
%        str2double(get(hObject,'String')) returns contents of SNR as a double
tUserInput=get(hObject,'String');
tUserInput=lower(tUserInput);
tUserInput=strrep(tUserInput,'db','')
if (isnan(str2double(tUserInput)))
    set(hObject,'String','');
else
    set(hObject,'String',tUserInput);
end

    


% --- Executes during object creation, after setting all properties.
function SNR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function Path_Callback(hObject, eventdata, handles)
% hObject    handle to Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Path as text
%        str2double(get(hObject,'String')) returns contents of Path as a double
if (isnan(str2double(get(hObject,'String'))))
    set(hObject,'String','');
end

% --- Executes during object creation, after setting all properties.
function Path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Modulation_type.
function Modulation_type_Callback(hObject, eventdata, handles)
% hObject    handle to Modulation_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Modulation_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Modulation_type


% --- Executes during object creation, after setting all properties.
function Modulation_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Modulation_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OP_switch.
function OP_switch_Callback(hObject, eventdata, handles)
% hObject    handle to OP_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OP_switch


% --- Executes on button press in Compare_switch.
function Compare_switch_Callback(hObject, eventdata, handles)
% hObject    handle to Compare_switch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Compare_switch
