global robot vacuum
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
if exist('vacuum', 'var') == 1
    clear vacuum;
end

robot = rtde(host, rtdeport);
vacuum = vacuum(host, vacuumport);
vacuum.setTimeout(100000000000);
vacuum.setTimeout(100008999999);
    