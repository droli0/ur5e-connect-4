
% assign current dispenser position based on matrices and current dispenser
puckPos = initPos(puckDisp, :);
grabPos = grabPos(puckDisp, :);

% move to bottom transition position
robot.movej(bottomPos,'joint');
pause(0.1)

% move to pre-grab position
robot.movej(puckPos,'joint');
pause(0.1)

% open gripper
writeline(arduino, "1");
pause(0.1);

% move to grab position
robot.movej(grabPos,'joint');
pause(0.1)

% close gripper
writeline(arduino, "0");
pause(0.1);

% move back to pre-grab position
robot.movej(puckPos,'joint');
pause(0.1)

% move back to bottom transition position
robot.movej(bottomPos,'joint');
pause(0.1)