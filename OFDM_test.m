function varargout = OFDM_test(varargin)
% OFDM_TEST MATLAB code for OFDM_test.fig
%      OFDM_TEST, by itself, creates a new OFDM_TEST or raises the existing
%      singleton*.
%
%      H = OFDM_TEST returns the handle to a new OFDM_TEST or the handle to
%      the existing singleton*.
%
%      OFDM_TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OFDM_TEST.M with the given input arguments.
%
%      OFDM_TEST('Property','Value',...) creates a new OFDM_TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OFDM_test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OFDM_test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OFDM_test

% Last Modified by GUIDE v2.5 07-Nov-2018 22:34:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OFDM_test_OpeningFcn, ...
                   'gui_OutputFcn',  @OFDM_test_OutputFcn, ...
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


% --- Executes just before OFDM_test is made visible.
function OFDM_test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OFDM_test (see VARARGIN)

% Choose default command line output for OFDM_test
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OFDM_test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OFDM_test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
set(handles.Path,'String',1);
set(handles.SNR,'String',20);




% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)

str = get(handles.Modulation_type, 'String');
val = get(handles.Modulation_type,'Value');

switch str{val}
case 'QPSK' 
   modu_type = 0;
case '16QAM' 
   modu_type = 1;
end
SNR = str2double(get(handles.SNR,'String'));  

if (isnan(SNR))
     SNR = 20;
     set(handles.SNR,'String',20);
end
pathes = str2double(get(handles.Path,'String'));  

if (isnan(pathes))
     pathes = 1;
     set(handles.Path,'String',1);
end
OP = get(handles.OP_switch, 'Value');

OFDM(modu_type, SNR, pathes, 1, 0, 0, OP);




function SNR_Callback(hObject, eventdata, handles)

guidata(hObject, handles);


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

guidata(hObject, handles);


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

guidata(hObject,handles)



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


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in BER_curve.
function BER_curve_Callback(hObject, eventdata, handles)

str = get(handles.Modulation_type, 'String');
val = get(handles.Modulation_type,'Value');
comp = get(handles.Compare_switch,'Value');
L = str2double(get(handles.Path,'String'));  

switch str{val}
case 'QPSK' 
   modu_type = 0;
case '16QAM' 
   modu_type = 1;
end
OFDM_BER_SNR(modu_type, L, comp);


% --- Executes on button press in BER_path.
function BER_path_Callback(hObject, eventdata, handles)

str = get(handles.Modulation_type, 'String');
val = get(handles.Modulation_type,'Value');
comp = get(handles.Compare_switch,'Value');
SNR = str2double(get(handles.SNR,'String')); 

switch str{val}
case 'QPSK' 
   modu_type = 0;
case '16QAM' 
   modu_type = 1;
end
OFDM_BER_L(modu_type, SNR, comp);
% hObject    handle to BER_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
