clear

port = '/dev/ttyUSB0';  % Replace with your serial port (e.g., 'COM3' for Windows, '/dev/ttyUSB0' for Linux)
baudRate = 9600; % Set the baud rate (match it with the device's baud rate)

serialObj = serialport(port, baudRate);
serialObj.Timeout = 10;  % Set timeout in seconds
disp('Serial connection established. Reading data...');

global place pickPositionTop


%%
place = [-755 170 585 2.568 2.57 1.8];
for i = 2:7
    place(i,:) = place(i-1,:);
    place(i,1) = place(i,1)+76;
end

pickPositionTop = [50 -575 20 1.57 -2.7 0];

dropIdx = 4;

%%
while true
    if serialObj.NumBytesAvailable > 0
        incomingData = readline(serialObj);
        incomingData = strtrim(incomingData);
        if strcmp(incomingData, 'PICK')
            dropIdx = 4;
            moveRobot(dropIdx,1);
            % Send 'd' to the serial port
            writeline(serialObj, 'd');
            disp('Command: PICK, Sent: d');
            
        elseif strcmp(incomingData, 'LEFT')
            dropIdx = dropIdx - 1;
            if(dropIdx < 1)
                dropIdx = 1;
            end
            moveRobot(dropIdx,0);
            disp('Command: LEFT, No response sent');
            
        elseif strcmp(incomingData, 'RIGHT')
            dropIdx = dropIdx + 1;
            if(dropIdx > 7)
                dropIdx = 7;
            end
            moveRobot(dropIdx,0);
            disp('Command: RIGHT, No response sent');
            
        elseif strcmp(incomingData, 'PLACE')
            moveRobot(dropIdx,-1);
            disp('Command: PLACE, No response sent');
            
        else
            disp(['Unrecognized command: ', incomingData]);
        end
    end

    pause(0.05);
end
clear serialObj;
