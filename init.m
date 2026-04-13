%% connect to robot and vacuum gripper
global robot vacuum CAMERA_DEVICE visionCamera turnCount

connectRobot;

if turnCount == 0
    try
        vacuum.release(); % ensure puck source is clear before starting
    catch
        % vacuum object may not yet accept commands.
    end
end

%% variables

visionCamera = webcam(CAMERA_DEVICE);

% standby pos and upper transition position
topPos = [0.5751   -1.8075    1.2287    0.5320    2.1553   -1.5809];

% bottom transition position
bottomPos = [1.2090   -1.9117    1.5060   -1.2038   -1.5948    1.1352];

% single dispenser init/grab positions (single vacuum pickup location)
% - initPos: pre-grab hover pose above puck
% - grabPos: descent pose to engage suction
initPos = [1.4059   -0.9105    1.4491   -1.3492   -1.7932   -1.7805];
grabPos = [1.3928   -0.8445    1.4640   -1.1969   -1.7937   -1.7805];

% column transition positions (right above the drop pos.)
colTPos = [-0.2480   -1.2363    0.5213    5.2496   -1.5257   -0.1944;
    -0.1051   -1.2174    0.4946    5.2533   -1.5515   -0.0536;
    0.0388   -1.1497    0.3897    5.2902   -1.5780    0.0879;
    0.1527   -1.2195    0.5547    5.0838   -1.5436    0.2199;
    0.2577   -1.1963    0.5557    4.9898   -1.5061    0.2822;
    0.3838   -1.0057    0.2443    5.1059   -1.5519    0.4001;
    0.4941   -0.8378    0.0158    5.0560   -1.4892    0.4342];

% column drop positions
colPos = [-0.2479   -1.3254    0.7662    5.0938   -1.5253   -0.1941;
    -0.1050   -1.3074    0.7395    5.0984   -1.5511   -0.0532;
    0.0388   -1.2569    0.6712    5.1160   -1.5775    0.0882;
    0.1741   -1.0270    0.2639    5.3798   -1.5853    0.2262;
    0.2454   -0.6346   -0.5410    5.6288   -1.4796    0.2778;
    0.3644   -0.8487    0.0047    5.3047   -1.5196    0.4016;
    0.4652   -0.8179    0.0156    5.1244   -1.4918    0.4341];