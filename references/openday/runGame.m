%% SETUP - DONT CHANGE 
clc; 
host = '192.168.0.100'; % THIS IP ADDRESS MUST BE USED FOR THE REAL ROBOT
rtdeport = 30003;
vacuumport = 63352;
clear rtde;
clear vacuum;

i = 1

while i > 0 & i < 8
    i = input("Where would you like to move? ")
    rtde = rtde(host,rtdeport);
    vacuum = vacuum(host,vacuumport);

    vacuum.setTimeout(100000000000);
    vacuum.setTimeout(100008999999);

    % MOVE TO HOME
    rtde.movej(deg2rad(homeA),'joint');
    
    % MOVE TO PICK UP
    rtde.movej(pickPosition,'pose');
    pause(1)
    rtde.movej(pickPosition2,'pose');
    vacuum.grip();
    pause(1)
    rtde.movej(pickPosition,'pose');
    
    % MOVE TO HOME
    rtde.movej(deg2rad(homeA),'joint');
    
    % MOVE TO DROP ZONE
    
    
    rtde.movej(deg2rad(dropZones(i,:)),'joint');
    %rtde.movej(dropZones(i,:),'pose');
    
    vacuum.release();
    rtde.movej(deg2rad(homeB),'joint');
      
    %%
    % Closing the TCP Connection
    rtde.close(); 
    clear rtde;
    clear vacuum;

end
