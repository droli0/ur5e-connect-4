host = '192.168.0.100'; % THIS IP ADDRESS MUST BE USED FOR THE REAL ROBOT
rtdeport = 30003;
vacuumport = 63352;

% clear stale handles when rerunning
if exist('robot', 'var') == 1
    try
        robot.close();
    catch
    end
end
if exist('vacuumGrip', 'var') == 1
    clear vacuumGrip;
end

robot = rtde(host, rtdeport);
vacuumGrip = vacuum(host, vacuumport);
vacuumGrip.setTimeout(100000000000);
vacuumGrip.setTimeout(100008999999);
