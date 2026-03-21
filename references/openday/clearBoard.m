function clearBoard


    host = '192.168.0.100'; % THIS IP ADDRESS MUST BE USED FOR THE REAL ROBOT
    rtdeport = 30003;
    vacuumport = 63352;
    rtde1 = rtde(host,rtdeport);
    vacuum1 = vacuum(host,vacuumport);
    vacuum1.setTimeout(100000000000);
    vacuum1.setTimeout(100009000000);

    % Example of a joint CONFIGURATION
    home = [15 -60 25 -145 -100 0];

    a = [7.28 -60.15 73 -103 -90 6.7];
    b = [9.32 -58.99 71.21 -102.21 -90 -5];
    c = [8 -63 70 -97 -88 8];
    rtde1.movel(deg2rad(home),'joint');

    rtde1.movel(deg2rad(a),'joint');
    vacuum1.grip();
    rtde1.movel(deg2rad(b),'joint');
    vacuum1.release();
    rtde1.movel(deg2rad(c),'joint');


    %%
    % Closing the TCP Connection
    rtde1.close(); 
end