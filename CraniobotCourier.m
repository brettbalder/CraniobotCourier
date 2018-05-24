 %% GUI Initializers
function varargout = CraniobotCourier(varargin)
% IDK what this function does, but don't delete it

% CRANIOBOTCOURIER MATLAB code for CraniobotCourier.fig
% Last Modified by GUIDE v2.5 16-Apr-2018 12:27:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CraniobotCourier_OpeningFcn, ...
                   'gui_OutputFcn',  @CraniobotCourier_OutputFcn, ...
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
end

function CraniobotCourier_OpeningFcn(hObject, eventdata, handles, varargin)
% Objective: Initializes the GUI and many of its persistent variables, all of
% which are stored in the 'handles' structue
    
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - tof be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CraniobotCourier (see VARARGIN)

% Place all panels/objects in the appropriate tabs
tabgp = uitabgroup(hObject);
controlTab = uitab(tabgp,'Title','Control',...
               'Tag','controlTab');
set(handles.connectionPanel,'Parent',controlTab);
set(handles.machinePositionPanel,'Parent',controlTab);
set(handles.fileManagerPanel,'Parent',controlTab);
set(handles.MotionButtonsGrp,'Parent',controlTab);
set(handles.commonCommandsGrp,'Parent',controlTab);
set(handles.commandLine,'Parent',controlTab);
set(handles.commandLineTextBox,'Parent',controlTab);
set(handles.consoleWindow,'Parent',controlTab);
set(handles.consoleTextBox,'Parent',controlTab);
set(handles.clearWindow,'Parent',controlTab);

% Choose default command line output for CraniobotCourier
handles.output = hObject;

% initialize path of G-code file that is to be sent to Craniobot
handles.filePath = " ";

% initialize 2D array to store all probed points of skull in form 
% [x1,y1,z1; x2...
handles.skullPoints = [];

% initialize "linesToSend" value for Linemode protocol (see g2core wiki)
sb = findobj(gcf,'Tag','sendFileButton');
set(sb,'userdata',4);

% initialize machine state variable
handles.stat = " ";

% initialize CNC position variables
handles.posx = 0;
handles.posy = 0;
handles.posz = 0;
handles.posa = 0;
handles.posb = 0;
handles.posc = 0;

%initialize GCode parameters
handles.units = 1; % (0|1 - inch|mm). Default: 1. 

% initialize state and position textboxs
% Note: 32 is the ASCII character for a space
if handles.units == 1
    units = 'Machine Position (mm):';
else
    units = 'Machine Position (inch):';
end
xStr = strcat('X:',32,num2str(handles.posx));
yStr = strcat('Y:',32,num2str(handles.posy));
zStr = strcat('Z:',32,num2str(handles.posz));
aStr = strcat('A:',32,num2str(handles.posa));
bStr = strcat('B:',32,num2str(handles.posb));
cStr = strcat('C:',32,num2str(handles.posc));
positionString = {units,xStr,yStr,zStr,aStr,bStr,cStr};
stateString = {'Machine State:',handles.stat};
set(handles.machinePositionTextBox,'String',positionString);
set(handles.machineStateTextBox,'String',stateString);


% Update handles structure
guidata(hObject, handles);
end

function varargout = CraniobotCourier_OutputFcn(hObject, eventdata, handles)
% IDK what this function does, but don't delete it

% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end
%% Port Connection
function portMenu_Callback(hObject, eventdata, handles)
% Objective: Allows user to specify which serial object to connect to

% hObject    handle to portMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% portlist   array of all serial object connected to computer
% port       The serial port to communicate with

portList = get(hObject,'String');
% convert to string. If only one line is present in portList, portList(1) will
% just return the first letter of the device, not the first line
portList = string(portList);  
handles.port = portList(get(hObject,'Value'));
guidata(gcf,handles);
end

function portMenu_CreateFcn(hObject, eventdata, handles)
% Objective: Used in the creation of the port menu list 
% hObject    handle to portMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String',seriallist);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function connectButton_Callback(hObject, eventdata, handles)
% Objective: Open/close a serial connection to the Craniobot and enable buttons

% hObject    handle to connectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% device     handle to serial object (the Craniobot)
device = serial(handles.port,'baudRate',115200,...
                        'Databits', 8,...
                        'StopBits',1,...
                        'Parity','none',...
                        'FlowControl','none',...
                        'ReadAsyncMode','continuous',...
                        'Terminator','LF',...
                        'BytesAvailableFcnMode','terminator',...
                        'BytesAvailableFcn',@BytesAvailable);
% if button is switched "on"
if get(hObject,'Value')
    % Change button text and open the serial port
    set(hObject,'String','Close');
    fopen(device);
    % If the serial port fails to open
    if get(device,'Status') ~= 'open'
        instrreset;
        uiwait( errordlg('Missing input parameter...',...
                    'Input Error', 'modal') );
    end
    % store the device handle
    handles.device = device;
    guidata(hObject,handles);
    
    % enable control buttons when connected
    set(findall(handles.MotionButtonsGrp,...
        '-property', 'enable'), 'enable', 'on');
    % enable common commands when connected
    set(findall(handles.commonCommandsGrp,...
        '-property', 'enable'), 'enable', 'on');
    % enable command line
    set(handles.commandLine,'enable','on');
    
% Else, if button is switched "off"
else
    % Delete serial instrument from memory; change button string
    instrreset; 
    set(gcbo,'String','Open');
    
    % disnable control buttons when connected
    set(findall(handles.MotionButtonsGrp,...
        '-property', 'enable'), 'enable', 'off');
    % enable common commands when connected
    set(findall(handles.commonCommandsGrp,...
        '-property', 'enable'), 'enable', 'off');
    % enable command line
    set(handles.commandLine,'enable','off');
end
%save changes in data structure
guidata(hObject,handles);
end

function refreshButton_Callback(hObject, eventdata, handles)
% Objective: refreshes the list of serial objects connected to the computer

% hObject    handle to refreshButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.portMenu,'String',seriallist);
end
%% Console/Command Line
function consoleWindow_CreateFcn(hObject, eventdata, handles)
% Objective: Creates the console window

% hObject    handle to consoleWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function commandLine_CreateFcn(hObject, eventdata, handles)
% Objective: Creates the command line

% hObject    handle to commandLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function clearWindow_Callback(hObject, eventdata, handles)
% Objective: Clears all text from the console window

% Variables:
% hObject    handle to clearWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% consoleWindow     Handle to ui object
consoleWindow = handles.consoleWindow;
set(consoleWindow,'String',' ',...
    'Value',1);
end

function commandLine_Callback(hObject, eventdata, handles)
% hObject    handle to commandLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get handles/set make command line blank
device = handles.device;
text = string(get(gcbo,'String'));
set(gcbo,'String','');

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = upper(text);
%data{end+1} = "";
set(consoleWindow,'String',data,...
                  'Value',length(data));

% send command             
fprintf(device,upper(text));
end
%% Jogging 
function linearStepSize_CreateFcn(hObject, eventdata, handles)
% Objective: Creates the button group that holds the units radio buttons

% hObject    handle to linearStepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function linearStepSize_Callback(hObject, eventdata, handles)
% Objective: This callback doesn't do anything since all that is needed is the string
% stored in the textbox, which is used in the jogging buttons. But don't delete
% this!
    
% hObject    handle to linearStepSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of linearStepSize as text
%        str2double(get(hObject,'String')) returns contents of linearStepSize as a double
str=get(hObject,'String');
if isempty(str2num(str))
    set(hObject,'string',1);
end
end

function linearStepGrp_SelectionChangedFcn(hObject, eventdata, handles)
% Objective: creates the button group that holds the units and step size
% buttons. Its just used for ease of moving the button group in the future.
    
% hObject    handle to the selected object in linearStepGrp 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.MillimeterButton,'Value')
    fprintf(handles.device,'G21');
    handles.units = 1;
else
    fprintf(handles.device,'G20');
    handles.units = 0;
end
guidata(hObject,handles);
end

function XPlus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp

% hObject    handle to XMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' X',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function XMinus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp

% hObject    handle to XMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' X-',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function YPlus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to YPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' Y',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function YMinus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to YMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' Y-',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function ZPlus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to ZPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' Z',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function ZMinus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to ZMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' Z-',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function APlus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to APlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' A',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function AMinus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to AMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' A-',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function BPlus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to BPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' B',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function BMinus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to BMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' B-',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function CPlus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to CPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' C',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function CMinus_Callback(hObject, eventdata, handles)
% Objective: Sends a gcode command to move the Craniobot incrimentally in the 
% given axis and direction using the step size from the linearStepGrp
    
% hObject    handle to CMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% send movement command
stepSize = get(handles.linearStepSize,'String');
command = string(strcat('G0',' C-',stepSize));
fprintf(handles.device,'G91'); % set to incrimental move
fprintf(handles.device,command); % move to new position

% display sent command in command window
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = command;
set(consoleWindow,'String',data,...
                  'Value',length(data));
end

function MillimeterButton_Callback(hObject, eventdata, handles)
% This callback doesn't do anything since all that is needed is the state of the
% button. But don't delete it!
end

function InchesButton_Callback(hObject, eventdata, handles)
% This callback doesn't do anything since all that is needed is the state of the
% button. But don't delete it!
end
%% Axis Control Commands
function setOriginButton_Callback(hObject, eventdata, handles)
% Objective: Sets current position to 0 for all axes

% hObject    handle to setOriginButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% device     handle to serial device (Craniobot)
% consoleWindow     Handle to ui object

fprintf(handles.device,'G28.3 X0 Y0 Z0 A0 B0 C0');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "G28.3 X0 Y0 Z0 A0 B0 C0 (Set Origin)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));
end

function moveToOriginButton_Callback(hObject, eventdata, handles)
% Objective: Moves all axes to their home position

% hObject    handle to moveToOriginButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% device     handle to serial device (Craniobot)
% consoleWindow     Handle to ui object

fprintf(handles.device,' G90 G0 X0 Y0 Z0 A0 B0 C0');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "G0 X0 Y0 Z0 A0 B0 C0 (Move to Origin)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));
end

function clearButton_Callback(hObject, eventdata, handles)
% Objective: used to clear alarms

% hObject    handle to clearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% device     handle to serial device (Craniobot)
% consoleWindow     Handle to ui object

% Send reset command to controller
% Note: 24 is the ASCII character for ctrl-x
fprintf(handles.device,'{"clear":n}');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "$Clear (Clear Alarms)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));
end

function resetXButton_Callback(hObject, eventdata, handles)
% Objective: Set the current X axis position to 0
% hObject    handle to resetXButton (see GCBO)

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% device     handle to serial device (Craniobot)
% consoleWindow     Handle to ui object


% Set controller position
fprintf(handles.device,'G28.3 X0');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "G28.3 X0 (Reset X Axis)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));

end

function resetYButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetYButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set controller position
fprintf(handles.device,'G28.3 Y0');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "G28.3 Y0 (Reset Y Axis)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));
end

function resetZButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetZButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set controller position
fprintf(handles.device,'G28.3 Z0');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "G28.3 Z0 (Reset Z Axis)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));
end

function resetAButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetAButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set controller position
fprintf(handles.device,'G28.3 A0');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "G28.3 A0 (Reset X Axis)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));
end

function resetBButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetBButton (see GCBO)

% Set controller position
fprintf(handles.device,'G28.3 B0');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "G28.3 B0 (Reset B Axis)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

function resetCButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetCButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set controller position
fprintf(handles.device,'G28.3 C0');
consoleWindow = handles.consoleWindow;
data = cellstr(get(consoleWindow,'String'));
data{end+1} = "G28.3 C0 (Reset C Axis)"; %concatenate newData with the old data
set(consoleWindow,'String',data,...
           'Value',length(data));
end

function homeAllAxes_Callback(hObject, eventdata, handles)
% Objective: Homes all axes and sets values to 0

% hObject    handle to homeAllAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf(handles.device,'G28.2 X0 Y0 Z0'); %home all axes on machine

end
%% Program Generation
function probeMenu_Callback(hObject, eventdata, handles)
% Objective: create window to input probing parameters and generate gcode script 
% hObject    handle to probeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% create new window
fig = figure('Name','Probing Parameters',...
    'Units','pixels',...
    'Position',[200,200,400,150],...
    'Tag','ProbeWindow',...
    'MenuBar','none',...
    'ToolBar','none');
figHandles = guidata(fig);

% create window elements
figHandles.chamberDiameterLabel = uicontrol(fig,'Style','text',...
    'Units','pixels',...
    'String','Chamber Diameter (mm)',...
    'Position',[5,120,150,20]);
figHandles.chamberDiameterTextBox = uicontrol(fig,'Style','edit',...
    'Units','pixels',...
    'Tag','chamberDiameterTextBox',...
    'Position',[200,120,50,20]);

figHandles.chamberLocationLabel = uicontrol(fig,'Style','text',...
    'Units','pixels',...
    'String','Chamber Location (X,Y,Z) (mm)',...
    'Position',[5,90,150,20]);
figHandles.chamberXTextBox = uicontrol(fig,'Style','edit',...
    'Units','pixels',...
    'Tag','chamberXTextBox',...
    'Position',[200,90,30,20]);
figHandles.chamberYTextBox = uicontrol(fig,'Style','edit',...
    'Units','pixels',...
    'Position',[240,90,30,20]);
figHandles.chamberZTextBox = uicontrol(fig,'Style','edit',...
    'Units','pixels',...
    'Position',[280,90,30,20]);

figHandles.probeSpeedLabel = uicontrol(fig,'Style','text',...
    'Units','pixels',...
    'String','Probe Speed (mm/min)',...
    'Position',[5,60,150,20]);
figHandles.probeSpeedTextBox = uicontrol(fig,'Style','edit',...
    'Units','pixels',...
    'Position',[200,60,100,20]);

figHandles.probeSkullButton = uicontrol(fig,'Style','pushbutton',...
    'Units','pixels',...
    'Position',[100,5,200,40],...
    'String','Generate Chamber Probing Program',...
    'Callback',@probeSkullButton_Callback);

guidata(fig,figHandles);
end

function millMenu_Callback(hObject, eventdata, handles)
% Objective: create window to input milling parameters and generate gcode script 

% hObject    handle to millMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% create new window
fig = figure('Name','Milling Parameters',...
    'Units','pixels',...
    'Position',[200,200,400,150],...
    'Tag','millWindow',...
    'MenuBar','none',...
    'ToolBar','none');
figHandles = guidata(fig);

% create window elements
figHandles.depthLabel = uicontrol(fig,'Style','text',...
    'Units','pixels',...
    'String','Skull Thickness (mm)',...
    'Position',[5,120,150,20]);
figHandles.depthTextBox = uicontrol(fig,'Style','edit',...
    'Units','pixels',...
    'Tag','chamberDiameterTextBox',...
    'Position',[200,120,50,20]);

figHandles.feedrateLabel = uicontrol(fig,'Style','text',...
    'Units','pixels',...
    'String','Feedrate (mm/min)',...
    'Position',[5,90,150,20]);
figHandles.feedrateTextBox = uicontrol(fig,'Style','edit',...
    'Units','pixels',...
    'Position',[200,90,100,20]);

figHandles.millSkullButton = uicontrol(fig,'Style','pushbutton',...
    'Units','pixels',...
    'Position',[100,5,200,40],...
    'String','Generate Chamber Probing Program',...
    'Callback',@millSkullButton_Callback);

guidata(fig,figHandles);
end

function probeSkullButton_Callback(hObject, eventdata, handles)
% Objective: Take user input values for desired chamber location (in stereotaxic
% coordinates), probe the skull, and record the xyz coordinates of each point to
% produce a tool path 

% hObject    handle to probeSkullButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% @val       axis value stored in text box by user

figHandles = guidata(findobj(0,'Tag','ProbeWindow')); % get handles % get input values
xVal   = str2num(get(figHandles.chamberXTextBox,'String'));
yVal   = str2num(get(figHandles.chamberYTextBox,'String'));
zVal   = str2num(get(figHandles.chamberZTextBox,'String'));
diaVal = str2num(get(figHandles.chamberDiameterTextBox,'String'));
speed  = str2num(get(figHandles.probeSpeedTextBox,'String'));

% if an input is missing, throw an error message
if isempty(xVal) || isempty(yVal) || isempty(zVal) || isempty(diaVal)
    uiwait( errordlg('Missing input parameter...',...
                     'Input Error', 'modal') );
else
    % create probe-path file
    probeCircle(diaVal,xVal,yVal,zVal,speed);
end
end

function millSkullButton_Callback(hObject, eventdata, handles)
% Objective: Take the recorded skull points and generate a milling filling
% accordingly

% hObject    handle to probeSkullButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get input values
figHandles = guidata(findobj(0,'Tag','millWindow')); % get handles % get input values
handles = guidata(findobj(0,'Tag','GUI'));
xVals   = handles.skullPoints(:,1);
yVals   = handles.skullPoints(:,2);
zVals   = handles.skullPoints(:,3);
depth   = str2num(get(figHandles.depthTextBox,'String'));
feedrate= str2num(get(figHandles.feedrateTextBox,'String'));
gCodeGeneration(xVals,yVals,zVals,depth,feedrate);

end
%% File Manager
function chooseFileButton_Callback(hObject, eventdata, handles)
% Objective: Allow user to choose a G-code (txt) file to be send to the Craniobot

% Key Variables:
% handles    structure with handles and user data (see GUIDATA)

% open dialog box, get file name and path to file on user computer
% Note: must be .txt file
[tempName,tempPath] = uigetfile('.txt');

% if file exists: change text box to file name, enable send/pause/cancel buttons
if tempName ~= 0
    handles.filePath = strcat(tempPath,tempName);
    set(handles.fileTextBox,'String',tempName);
    set(handles.sendFileButton,'enable','on');
    set(handles.pauseButton,'enable','on');
    set(handles.cancelButton,'enable','on');
    % save changes to handles
    guidata(hObject,handles);
end


end

function sendFileButton_Callback(hObject, eventdata, handles)
% Objective: Send a G-code file to the Crabiobot using Linemode
% protocol (see g2core wiki).

% Key Variables:
% hObject    handle to sendFileButton (see GCBO)
% handles    structure with handles and user data (see GUIDATA)

% disable Send File button
set(hObject,'enable','off');
% disable control buttons when connected
set(findall(handles.MotionButtonsGrp,...
    '-property', 'enable'), 'enable', 'off');
% disable common commands when connected
set(findall(handles.commonCommandsGrp,...
    '-property', 'enable'), 'enable', 'off');
% disable command line
set(handles.commandLine,'enable','off');
    
% open g-code file
prgmFile = fopen(handles.filePath);

% delete any old probed points if we are probing again
if contains(handles.filePath,'probe')
    handles = guidata(findobj(0,'Tag','GUI')); % get handles 
    handles.skullPoints = [];
    guidata(findobj(0,'Tag','GUI'),handles);   
end

% Begin file stream using Linemode Protocol
% Continue protocol unless the file ends or the cancel button is pressed.
% The number of lines to be send to the Craniobot is stored in the Send Button's
% 'userdata' variable.
set(gcbo,'userdata',4);

while ~feof(prgmFile) && ~get(handles.cancelButton,'Value')
    % if there is room in the serial buffer AND the pause button is not 
    % pressed AND the file is not done, send commands
    while (get(gcbo,'userdata') > 0) && ~get(handles.pauseButton,'Value') && ~feof(prgmFile)
        % send line
        command = fgetl(prgmFile);
        fprintf(handles.device,command);
        % decrement number of lines to be sent to arduino
        set(gcbo,'userdata',get(gcbo,'userdata')-1);
        % print command to console window as well
        data = cellstr(get(handles.consoleWindow,'String'));
        data{end+1} = command; %concatenate newData with the old data
        set(handles.consoleWindow,'String',data,...
                'Value',length(data));
        drawnow(); %% this allows other callbacks to execute (pause/cancel)
    end
    drawnow(); %% this allows other callbacks to execute (pause/cancel)
end

fclose(prgmFile);
set(gcbo,'enable','on'); % reset Send File button
set(handles.cancelButton,'Value',0);
% enable control buttons when connected
set(findall(handles.MotionButtonsGrp,...
    '-property', 'enable'), 'enable', 'on');
% enable common commands when connected
set(findall(handles.commonCommandsGrp,...
    '-property', 'enable'), 'enable', 'on');
% enable command line
set(handles.commandLine,'enable','on');
end

function pauseButton_Callback(hObject, eventdata, handles)
% Objective: Change the button's text based on its state

% hObject    handle to pauseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(gcbo,'Value')
    set(gcbo,'String','Resume');
    fprintf(handles.device,'!');
else
    set(gcbo,'String','Pause');
    fprintf(handles.device,'~');
end
end

function cancelButton_Callback(hObject, eventdata, handles)
% Objective: Cancel the rest of the file being sent to the Craniobot

% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fprintf(handles.device,'%');
end
%% Auxillary
function BytesAvailable(device,~)
% Objective: Computer will automatically read input from serial device
% asynchronously. This function assumes all incoming data is formatted as json

% Variables:
% GUI           Handle to GUI object
% handles       struct containing all handles within the GUI
% json          JSON structure

GUI = findobj(0,'Tag','GUI'); % find GUI since hObject isn't passed into this function
handles = guidata(GUI); % get handles   
consoleWindow = handles.consoleWindow;
newData = fscanf(device); % get input serial data

% If input msg is in json format (first char is {'{'), then analyze the json
if newData(1) == '{'
    json = jsondecode(newData);
    interpretJson(json);
else 
    data = cellstr(get(handles.consoleWindow,'String'));
    data{end+1} = newData;
    % print to console
    set(handles.consoleWindow,'String',data,...
                 'Value',length(data));
end
end

function interpretJson(json)
% Objective: This function takes in a json structure, loops through each
% element, and will call functions depending on the elements of the json msg.

% Variables:
% GUI        handle to figure window
% handles    structure with handles and user data of GUI (see GUIDATA)
% json       struct containing name-value pairs or nested structs
% field      data containers within a struct (similar to array element)

GUI = findobj(0,'Tag','GUI'); % find GUI since hObject isn't passed into this function
handles = guidata(GUI); % get handles
% get console text
data = cellstr(get(handles.consoleWindow,'String'));

% get field names of json text
fields = fieldnames(json);

% Look at each field of the json struct and respond accordingly to the
% information
for i = 1:numel(fields)
    % Ignore empty fields
    if ~isempty(json.(fields{i}))
        switch fields{i}
            case 'r' % Reports
                % if g2core sends a json report, increment the Send Button's 
                % 'userdata' variable (aka, the Linemode protocol's linesToSend
                % variable (used in sendFileButton_Callback))
                SendButton = findobj(gcf,'Tag','sendFileButton');
                if get(SendButton,'userdata') < 4
                    set(SendButton,'userdata',get(SendButton,'userdata')+1);
                end
                % if the report has children objects, interpret them
                if ~isempty(json.r)
                    interpretJson(json.r); 
                end
            case 'sr' % Status Reports
                % If g2core sends a status report, update the GUI's system report
                % window
                statusReportJson(json.sr);
            case 'prb' % Probe Reports
                % If g2core sends a probe report, update the skullPoints array
                updateSkullPoints(json.prb);
            case 'f' % Footers 
                % Display status (f is a 1x3 array; element 2 is the status number
                text = statusCodes(json.f(2));
                if text ~= "STAT_OK" % suppress 'ok' messages
                    data = cellstr(get(handles.consoleWindow,'String'));
                    data{end+1} = text; %concatenate json-string with the old data
                    set(handles.consoleWindow,'String',data,...
                                 'Value',length(data));
                end
            case 'er' % Error Messages
                % Print error message on console
                text = json.er.msg;
                data = cellstr(get(handles.consoleWindow,'String'));
                data{end+1} = strcat("MSG: ",text); %concatenate json-string with the old data
                set(handles.consoleWindow,'String',data,...
                             'Value',length(data));
            otherwise % Any other information is probably relevant to the user, so 
                      % we print every name-value pair in message
                % iterate through every name-value pair in message
                name = fields{i};
                value = json.(fields{i});
                % if nested json, use recursion to go through the different
                % nests
                if isstruct(value)
                    data{end+1} = sprintf("%-s:",name);
                    % print to console
                    set(handles.consoleWindow,'String',data,...
                         'Value',length(data));
                     
                    interpretJson(value);
                else
                    % convert to string (if not already string) and add to
                    % console text (note, 32 is ascii for 'space'
                    value = string(value);
                    data{end+1} = sprintf("%-s: %+20s",name,value);
                    % print to console
                    set(handles.consoleWindow,'String',data,...
                         'Value',length(data));
                end
        end
    end
end
end

function statusReportJson(SR)
% Objective: take a struct containing a json status report (SR), extract
% the name-value pairs, and update the GUI with relevant information. 

% Variables:
% SR         Status Report struct containing name-value pairs
% handles    structure with handles and user data (see GUIDATA)
% SRFields   list of fields in the status report

handles = guidata(findobj(0,'Tag','GUI')); % get handles 

% get field names of json text
SRfields = fieldnames(SR);

% update the GUI variables that are called in the Status Report
for i = 1:numel(SRfields)
    switch SRfields{i}
        case "posx"
            handles.posx = SR.(SRfields{i});
        case "posy"
            handles.posy = SR.(SRfields{i});
        case "posz"
            handles.posz = SR.(SRfields{i});
        case "posa"
            handles.posa = SR.(SRfields{i});
        case "posb"
            handles.posb = SR.(SRfields{i});
        case "posc"
            handles.posc = SR.(SRfields{i});
        case "stat"
            switch SR.(SRfields{i})
                case 0
                    handles.stat = "INITIALIZING";
                case 1
                    handles.stat = "READY";
                case 2
                    handles.stat = "ALARM";
                case 3
                    % Should be program stop, but it means the same thing and
                    % looks better
                    handles.stat = "READY";
                case 4
                    handles.stat = "PROGRAM_END";
                case 5
                    handles.stat = "RUN";
                case 6
                    handles.stat = "HOLD";
                case 7
                    handles.stat = "PROBE";
                case 8
                    handles.stat = "CYCLE";
                case 9
                    handles.stat = "HOMING";
                case 10
                    handles.stat = "JOG";
                case 11
                    handles.stat = "INTERLOCK";
                case 12
                    handles.stat = "SHUTDOWN";
                case 13
                    handles.stat = "PANIC";
            end            
        case "units"
            switch SR.(SRfields{i})
                case 0
                    handles.units = 0;
                case 1
                    handles.units = 1;
            end
    end
end

if handles.units == 1
    units = 'Machine Position (mm):';
else
    units = 'Machine Position (inch):';
end

xStr = strcat('X:',32,num2str(handles.posx));
yStr = strcat('Y:',32,num2str(handles.posy));
zStr = strcat('Z:',32,num2str(handles.posz));
aStr = strcat('A:',32,num2str(handles.posa));
bStr = strcat('B:',32,num2str(handles.posb));
cStr = strcat('C:',32,num2str(handles.posc));
positionString = {units,xStr,yStr,zStr,aStr,bStr,cStr};
stateString = {'Machine State:',handles.stat};
set(handles.machinePositionTextBox,'String',positionString);
set(handles.machineStateTextBox,'String',stateString);
    
% Update handles structure
guidata(findobj(0,'Tag','GUI'), handles);
end

function updateSkullPoints(PR)
% Objective: take a struct containing a json probe report (PR), extract the
% name-value pair for the probed z-value, and update the skullPoints array

% Variables:
% PR         struct containing name-value pairs
% handles    structure with handles and user data (see GUIDATA)
% PRFields   list of fields in the probe report

handles = guidata(findobj(0,'Tag','GUI')); % get handles 

% get field names of json text
PRfields = fieldnames(PR); 

% update skullPoints array
for i = 1:numel(PRfields)
    switch PRfields{i}
        case "z"
            x = handles.posx;
            y = handles.posy;
            z = PR.(PRfields{i});
            handles.skullPoints(end+1,:) = [x, y, z];
    end
end

% update handles structure
guidata(findobj(0,'Tag','GUI'),handles);
end
