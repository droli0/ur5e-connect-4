%% connect to robot and vacuum gripper
connectRobot;

if turnCount == 0
    try
        vacuumGrip.release(); % ensure puck source is clear before starting
    catch
        % vacuum object may not yet accept commands.
    end
end

%% variables

visionCamera = webcam(CAMERA_DEVICE);

% standby pos and upper transition position
topPos = [0.3696   -1.7851    1.5963   -2.9370   -1.8961    1.5590];

% bottom transition position
bottomPos = [0.9131   -1.6921    2.5632   -3.9920   -1.9055    1.5639];

% single dispenser init/grab positions (single vacuum pickup location)
% - initPos: pre-grab hover pose above puck
% - grabPos: descent pose to engage suction
initPos = [1.4221   -1.2505    1.8194   -2.1239   -1.5637    1.4343];
grabPos = [1.4217   -1.1051    1.9041   -2.3540   -1.5648    1.4354];

% column transition positions (right above the drop pos.)
colTPos = [-0.4201   -1.7431    1.6802   -3.0809   -1.1635    1.5218;
    -0.1869   -1.7250    1.6653   -3.0824   -1.3967    1.5214;
    0.0204   -1.6732    1.6207   -3.0882   -1.6041    1.5213;
    0.2412   -1.5782    1.5315   -3.0924   -1.8249    1.5215;
    0.4248   -1.4576    1.4041   -3.0844   -2.0086    1.5218;
    0.5714   -1.3194    1.2388   -3.0564   -2.1551    1.5220;
    0.6969   -1.1489    1.0071   -2.9944   -2.2801    1.5221];

% column drop positions
colPos = [-0.3891   -1.7343    1.7448   -2.7759   -1.1856    1.3688;
    -0.1721   -1.7140    1.7298   -2.8024   -1.3885    1.4494;
    0.0410   -1.6573    1.6805   -2.8145   -1.5888    1.5232;
    0.2059   -1.5867    1.6134   -2.8113   -1.7436    1.5803;
    0.3725   -1.4858    1.5073   -2.7898   -1.8995    1.6414;
    0.5182   -1.3631    1.3630   -2.7446   -2.0346    1.7004;
    0.6512   -1.2057    1.1545   -2.6621   -2.1564    1.7613];