%% This script will be used to send movements to the HURON Upper Body torso
% This script allows the user to do the following:
% make a movement of the torso using a GUI
% see if that movement is valid
% send the movement information to the esp32 controlling the robot



%% Variable definitions

%minimum and maximum actuator lengths to check if a given transformation is
%possible for the actuators to reach
actuatorMinLength = 0.2385;
actuatorMaxLength = 0.3285;

% Minimum and maximum rotation amounts for roll, pitch, yaw
minRoll = -30;
maxRoll = 30;
minPitch = -30;
maxPitch = 30;
minYaw = -30;
maxYaw = 30;

% Formatting the gui stuff
% Where to start drawing the bottom of the scroll bars
rotStuffBottom = 70;

% Where to start drawing the bottom of the serial stuff
serialStuffBottom = 250;

% Locations of the top of the actuators relative to where the spine meets
% the top plate
act1Top = [-0.02 -0.12 0]; % location of the first actuator top relative to top plate
act2Top = [0.02 -0.12 0];
act3Top = [0.1 -0.02 0];
act4Top = [-0.1 -0.02 0];

% Locations of the bottom of the actuators relative to where the spine meets
% the bottom plate
act1bottom = [-0.11 -0.1 0]; % location of the first actuator top relative to bottom plate
act2bottom = [0.11 -0.1 0];
act3bottom = [0.12 -0.07 0];
act4bottom = [-0.12 -0.07 0];

% Transformation matricies for the previous translations
Actuator1TMatrixTop = [eye(3) transpose(act1Top); 0 0 0 1];
Actuator2TMatrixTop = [eye(3) transpose(act2Top); 0 0 0 1];
Actuator3TMatrixTop = [eye(3) transpose(act3Top); 0 0 0 1];
Actuator4TMatrixTop = [eye(3) transpose(act4Top); 0 0 0 1];

% Transformation matricies for the previous translations
Actuator1TMatrixBottom = [eye(3) transpose(act1bottom); 0 0 0 1];
Actuator2TMatrixBottom = [eye(3) transpose(act2bottom); 0 0 0 1];
Actuator3TMatrixBottom = [eye(3) transpose(act3bottom); 0 0 0 1];
Actuator4TMatrixBottom = [eye(3) transpose(act4bottom); 0 0 0 1];


%% Serial communication setup
device = 0; % A placeholder for the serial device that will be opened by the user
serialPortWasUpdated = 0;

%% Initial Setup

% making all the transformation matricies for the first time and drawing
% everything on the figure. 

% The initial transformation of the spine where it is just straight
% vertical
transformationMatrix = [1 0 0 0; 0 1 0 0; 0 0 1 0.26; 0 0 0 1];

%The transformation from the bottom of the spine (origin) to the top of each
%actuators
act1TF = transformationMatrix*Actuator1TMatrixTop;
act2TF = transformationMatrix*Actuator2TMatrixTop;
act3TF = transformationMatrix*Actuator3TMatrixTop;
act4TF = transformationMatrix*Actuator4TMatrixTop;

% Measuring the actuators for sending to the serial device
act1 = act1TF(1:3,end)-Actuator1TMatrixBottom(1:3,end);
act2 = act2TF(1:3,end)-Actuator2TMatrixBottom(1:3,end);
act3 = act3TF(1:3,end)-Actuator3TMatrixBottom(1:3,end);
act4 = act4TF(1:3,end)-Actuator4TMatrixBottom(1:3,end);

act1Len = sqrt(act1(1)^2 + act1(2)^2 + act1(3)^2);
act2Len = sqrt(act2(1)^2 + act2(2)^2 + act2(3)^2);
act3Len = sqrt(act3(1)^2 + act3(2)^2 + act3(3)^2);
act4Len = sqrt(act4(1)^2 + act4(2)^2 + act4(3)^2);

%Make the figure and clear it, just in case the old figure wasn't closed
f = uifigure('Name','Inverse Kinematics Generation');
f.Position = [200 160 800 500];
%clf(f)

g = uipanel(f,'Units','normalized','Position',[0 0 0.7,1],'Title', 'Simulated Torso Position'); % graphing panel
p = uipanel(f,'Units','normalized','Position',[0.7 0 0.3,1]); % control panel

ax = uiaxes(g,'NextPlot','add', 'Units','normalized','Position',[0 0 1 1]); %This makes sure the graphing happens in the 'g' uipanel obj
ax.XLim = [-0.3 0.3];
ax.YLim = [-0.3 0.3];
ax.ZLim = [-0.1 0.4];% Setting axis limits
ax.View = [30,30];

%getting the coordinates of all the actuators and the spine
act1Coords = [transpose(Actuator1TMatrixBottom(1:3,end));
    transpose(act1TF(1:3,end))];
act2Coords = [transpose(Actuator2TMatrixBottom(1:3,end));
    transpose(act2TF(1:3,end))];
act3Coords = [transpose(Actuator3TMatrixBottom(1:3,end));
    transpose(act3TF(1:3,end))];
act4Coords = [transpose(Actuator4TMatrixBottom(1:3,end));
    transpose(act4TF(1:3,end))];
spineCoords = [0 0 0; transpose(transformationMatrix(1:3,end))];
% The coordinates for the top of all 4 actuators
bottomActuatorCoords = [Actuator1TMatrixBottom(1:3,end) Actuator2TMatrixBottom(1:3,end) Actuator3TMatrixBottom(1:3,end) transpose(spineCoords(1,1:3)) Actuator4TMatrixBottom(1:3,end) Actuator1TMatrixBottom(1:3,end)];
% The coordinates for the bottom of all 4 actuators
topActuatorCoords = [act1TF(1:3,end) act2TF(1:3,end) act3TF(1:3,end) transpose(spineCoords(2,1:3)) act4TF(1:3,end) act1TF(1:3,end)];

%drawing all 4 actuators using the coordinates found above
draw1 = plot3(ax, act1Coords(:,1),act1Coords(:,2),act1Coords(:,3),'k','LineWidth',3);
draw2 = plot3(ax, act2Coords(:,1),act2Coords(:,2),act2Coords(:,3),'k','LineWidth',3);
draw3 = plot3(ax, act3Coords(:,1),act3Coords(:,2),act3Coords(:,3),'k','LineWidth',3);
draw4 = plot3(ax, act4Coords(:,1),act4Coords(:,2),act4Coords(:,3),'k','LineWidth',3);

% Drawing the top plate in blue
draw5 = plot3(ax, topActuatorCoords(1,:), topActuatorCoords(2,:), topActuatorCoords(3,:),'b','LineWidth',3);
% Drawing the bottom plate in blue
draw6 = plot3(ax, bottomActuatorCoords(1,:), bottomActuatorCoords(2,:), bottomActuatorCoords(3,:),'b','LineWidth',3);
% Drawing the spine
draw7 = plot3(ax, spineCoords(:,1),spineCoords(:,2),spineCoords(:,3),'Color','#0072BD','LineWidth',10);

%% Setting up the GUI
% roll (rotation about x-axis) slider & Text
rollSlider = uicontrol(p,'Style','slider','Units','pixels', 'Position',[1 rotStuffBottom+80 238 20], 'SliderStep',[0.01 0.1]);
rollText = uicontrol(p,'Style','text','Units','pixels', 'Position',[2 rotStuffBottom+102 200 15],'String','Roll value in degrees: ','HorizontalAlignment','left');
rollValue = uicontrol(p,'Style','text','Units','pixels', 'Position',[105 rotStuffBottom+102 40 15],'String','0','HorizontalAlignment','left');
rollSlider.Value = 0;
rollSlider.Min = minRoll;
rollSlider.Max = maxRoll;
% pitch (rotation about y-axis) slider
pitchSlider = uicontrol(p,'Style','slider','Units','pixels', 'Position',[1 rotStuffBottom+40 238 20], 'SliderStep',[0.01 0.1]);
pitchText = uicontrol(p,'Style','text','Units','pixels', 'Position',[2 rotStuffBottom+62 200 15],'String','Pitch value in degrees: ','HorizontalAlignment','left');
pitchValue = uicontrol(p,'Style','text','Units','pixels', 'Position',[110 rotStuffBottom+62 40 15],'String','0','HorizontalAlignment','left');
pitchSlider.Value = 0;
pitchSlider.Min = minPitch;
pitchSlider.Max = maxPitch;
% yaw (rotation about z-axis) slider
yawSlider = uicontrol(p,'Style','slider','Units','pixels', 'Position',[1 rotStuffBottom 238 20], 'SliderStep',[0.01 0.1]);
yawText = uicontrol(p,'Style','text','Units','pixels', 'Position',[2 rotStuffBottom+22 200 15],'String','Yaw value in degrees: ','HorizontalAlignment','left');
yawValue = uicontrol(p,'Style','text','Units','pixels', 'Position',[111 rotStuffBottom+22 40 15],'String','0','HorizontalAlignment','left');
yawSlider.Value = 0;
yawSlider.Min = minYaw;
yawSlider.Max = maxYaw;


%Return to 0 position button
zeroTorsoButton = uibutton(p, 'Position',[40 20 140 30],'ButtonPushedFcn', ...
    @(btn,event) zeroButtonPushed(btn,rollSlider, pitchSlider, yawSlider), ...
    'Text','Reset Torso Position');

%Input for serial port stuff
serialPortdropdown = uidropdown(p,'Items',{'None'},'Position', [68 serialStuffBottom+60 110 22],'Placeholder','Com Port (COM1)');
serialPortText = uilabel(p,'Position',[3 serialStuffBottom+60 110 22],'Text','Serial Port:');
serialBaudratedropdown = uidropdown(p,'Items',{'1200','2400','4800','9600','19200','38400','57600','115200'}, ...
    'ItemsData',[1200 2400 4800 9600 19200 38400 57600 115200],'Value',115200, ...
    'Position',[68 serialStuffBottom+30 110 22],'value',9600);
serialBaudrateText = uilabel(p,'Position',[3 serialStuffBottom+30 110 22],'Text','Baudrate:');

% Buttons for Serial Stuff
findAvailablePortsButton = uibutton(p, 'Position',[40 serialStuffBottom 70 22],'ButtonPushedFcn', ...
    @(btn,event) findAvailablePortsButtonPushed(serialPortdropdown), ...
    'Text','Find Ports');
openSerialPortButton = uibutton(p, 'Position',[130 serialStuffBottom 70 22],'ButtonPushedFcn', ...
    @(btn,event) openSerialButtonPushed(device, serialPortdropdown.Value, serialBaudratedropdown.Value), ...
    'Text','Open Port');
sendTorsoPositionButton = uibutton(p, 'Position',[40 serialStuffBottom-30 160 22],'ButtonPushedFcn', ...
    @(btn,event) sendTorsoPositionButtonPushed(serialPort, act1Len, act2Len, act3Len, act4Len), ...
    'Text','Send Torso Position', 'Enable','off');

lastRollValue = 0;
lastPitchValue = 0;
lastYawValue = 0;

%% GUI
while true
    

    pause(0.06);


    % If we have a serial port and it's new
    if device ~=0 && serialPortWasUpdated == 1
        % update a text box saying there is a serial connection
        % enable the button to send data to the torso
        serialPortWasUpdated = 0;
        sendTorsoPositionButton.Enable = on;
        disp("We're connected");
    end    
    

    % If the angles have changed, update the torso model and the text boxes
    % saying the angle
    if rollSlider.Value ~= lastRollValue || pitchSlider.Value ~= lastPitchValue || yawSlider.Value ~= lastYawValue
        rollValue.String = num2str(rollSlider.Value,'%.2f');
        pitchValue.String = num2str(pitchSlider.Value,'%.2f');
        yawValue.String = num2str(yawSlider.Value,'%.2f');
        
        %% if one of the rotation values has changed, show the torso
        
        % Grabbing the rotation angles from the sliders
        xrotation = rollSlider.Value/2; % Divided by 2 because the rotation is applied twice, once at the bottom and once at the top of the spine
        yrotation = pitchSlider.Value/2;
        zrotation = yawSlider.Value/2;
        % Making them into a Quaternion
        quat = quaternion([xrotation,yrotation,zrotation],'eulerd','XYZ','frame');
        
        % Making the rotation matricies
        rotationMatrix = rotmat(quat,'frame');
        translationMatrix1 = [0 0 0]; % column vector representing the translation of the top plane
        translationMatrix2 = [0 0 0.26]; % column vector representing the translation of the top plane
        transformationMatrix1 = [rotationMatrix transpose(translationMatrix1); 0 0 0 1];
        transformationMatrix2 = [rotationMatrix transpose(translationMatrix2); 0 0 0 1];
        transformationMatrix = transformationMatrix1*transformationMatrix2;
        
        %The transformation from the bottom of the spine (origin) to the top of each
        %actuators
        act1TF = transformationMatrix*Actuator1TMatrixTop;
        act2TF = transformationMatrix*Actuator2TMatrixTop;
        act3TF = transformationMatrix*Actuator3TMatrixTop;
        act4TF = transformationMatrix*Actuator4TMatrixTop;
        
        %getting the coordinates of all the actuators and the spine
        act1Coords = [transpose(Actuator1TMatrixBottom(1:3,end));
            transpose(act1TF(1:3,end))];
        act2Coords = [transpose(Actuator2TMatrixBottom(1:3,end));
            transpose(act2TF(1:3,end))];
        act3Coords = [transpose(Actuator3TMatrixBottom(1:3,end));
            transpose(act3TF(1:3,end))];
        act4Coords = [transpose(Actuator4TMatrixBottom(1:3,end));
            transpose(act4TF(1:3,end))];
        spineCoords = [0 0 0; transpose(transformationMatrix(1:3,end))];
        % The coordinates for the top of all 4 actuators
        bottomActuatorCoords = [Actuator1TMatrixBottom(1:3,end) Actuator2TMatrixBottom(1:3,end) Actuator3TMatrixBottom(1:3,end) transpose(spineCoords(1,1:3)) Actuator4TMatrixBottom(1:3,end) Actuator1TMatrixBottom(1:3,end)];
        % The coordinates for the bottom of all 4 actuators
        topActuatorCoords = [act1TF(1:3,end) act2TF(1:3,end) act3TF(1:3,end) transpose(spineCoords(2,1:3)) act4TF(1:3,end) act1TF(1:3,end)];
        
        %drawing all 4 actuators using the coordinates found above
        set(draw1, 'XData', act1Coords(:,1), 'YData', act1Coords(:,2), 'ZData', act1Coords(:,3));
        set(draw2, 'XData', act2Coords(:,1), 'YData', act2Coords(:,2), 'ZData', act2Coords(:,3));
        set(draw3, 'XData', act3Coords(:,1), 'YData', act3Coords(:,2), 'ZData', act3Coords(:,3));
        set(draw4, 'XData', act4Coords(:,1), 'YData', act4Coords(:,2), 'ZData', act4Coords(:,3));
        
        set(draw7, 'XData', spineCoords(:,1), 'YData', spineCoords(:,2), 'ZData', spineCoords(:,3));
    
        set(draw5, 'XData', topActuatorCoords(1,:), 'YData', topActuatorCoords(2,:), 'ZData', topActuatorCoords(3,:));
        set(draw6, 'XData', bottomActuatorCoords(1,:), 'YData', bottomActuatorCoords(2,:), 'ZData', bottomActuatorCoords(3,:));


        % update the saved values for themost current ones
        lastRollValue = rollSlider.Value;
        lastPitchValue = pitchSlider.Value;
        lastYawValue = yawSlider.Value;

        % Measuring the actuators to see if this position is valid
        act1 = act1TF(1:3,end)-Actuator1TMatrixBottom(1:3,end);
        act2 = act2TF(1:3,end)-Actuator2TMatrixBottom(1:3,end);
        act3 = act3TF(1:3,end)-Actuator3TMatrixBottom(1:3,end);
        act4 = act4TF(1:3,end)-Actuator4TMatrixBottom(1:3,end);
    
        act1Len = sqrt(act1(1)^2 + act1(2)^2 + act1(3)^2);
        act2Len = sqrt(act2(1)^2 + act2(2)^2 + act2(3)^2);
        act3Len = sqrt(act3(1)^2 + act3(2)^2 + act3(3)^2);
        act4Len = sqrt(act4(1)^2 + act4(2)^2 + act4(3)^2);
        

        % If any of the actuator lengths are invalid, change them to thick
        % red lines instead of the small black ones and change the title
        if act1Len<actuatorMinLength || act1Len>actuatorMaxLength
            set(draw1,'Color','red','LineWidth',7);
            %title('INVALID TRANSFORMATION', 'Color','red');
        end
        if act2Len<actuatorMinLength || act2Len>actuatorMaxLength
            set(draw2,'Color','red','LineWidth',7);
            %title('INVALID TRANSFORMATION', 'Color','red');
        end
        if act3Len<actuatorMinLength || act3Len>actuatorMaxLength
            set(draw3,'Color','red','LineWidth',7);
            %title('INVALID TRANSFORMATION', 'Color','red');
        end
        if act4Len<actuatorMinLength || act4Len>actuatorMaxLength
            set(draw4,'Color','red','LineWidth',7);
            %title('INVALID TRANSFORMATION', 'Color','red');
        end

        % If all the actuators are correct, change them all to the regular
        % formatting and change the title back to normal
        if act1Len>=actuatorMinLength && act2Len>=actuatorMinLength && ...
            act3Len>=actuatorMinLength && act4Len>=actuatorMinLength && ...
            act1Len<=actuatorMaxLength && act2Len<=actuatorMaxLength && ...
            act3Len<=actuatorMaxLength && act4Len<=actuatorMaxLength
            %If the actuator lengths are valid
            %title('Torso', 'Color','black');
            set(draw1,'Color','black','LineWidth',3);
            set(draw2,'Color','black','LineWidth',3);
            set(draw3,'Color','black','LineWidth',3);
            set(draw4,'Color','black','LineWidth',3);
        end


    end
    
end


function zeroButtonPushed(btn,rollSlider, pitchSlider, yawSlider)
    rollSlider.Value = 0;
    pitchSlider.Value = 0;
    yawSlider.Value = 0;
end
function openSerialButtonPushed(device, port, baud, updated)
    device = serialport(port, baud, 'Timeout',5);
    updated = 1;
end

function sendTorsoPositionButtonPushed(device, act1, act2, act3, act4)
    write(device, strcat(num2sr(act1), num2sr(act2), num2sr(act3), num2sr(act4)),"string");
end

function findAvailablePortsButtonPushed(serialPortdropdown)
    serialPortdropdown.Items = serialportlist("available");
end
