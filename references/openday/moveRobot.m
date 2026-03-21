function moveRobot(n, pick)


    host = '192.168.0.100'; % THIS IP ADDRESS MUST BE USED FOR THE REAL ROBOT
    rtdeport = 30003;
    vacuumport = 63352;
    rtde1 = rtde(host,rtdeport);
    vacuum1 = vacuum(host,vacuumport);
    vacuum1.setTimeout(100000000000);
    vacuum1.setTimeout(100009000000);

    global pickPositionTop place
            
    pickPositionLow = pickPositionTop; pickPositionLow(3) = 3;

    % Example of a POSE
    home = [-6.15, -75, 45, -70, -155, -15];
    home2 = [-2.4 -82 95 -112 -200 -15];

    %%

    if (pick==1)
        rtde1.movej(deg2rad(home),'joint');
        rtde1.movel(pickPositionTop,'pose');
        rtde1.movel(pickPositionLow,'pose');
        vacuum1.grip();
        rtde1.movel(pickPositionTop,'pose');
        rtde1.movel(deg2rad(home),'joint');
        rtde1.movel((place(n,:)),'pose');
    elseif (pick==-1)
        vacuum1.release();
        place_new = place(n,:);
        place_new(2) = place(n,2) - 50;
        rtde1.movel((place_new),'pose');
    else
        rtde1.movel((place(n,:)),'pose');
    end

    %%
    % Closing the TCP Connection
    rtde1.close(); 
    
end