
% Pickup script: must not share a name with the pose vector initPos (init.m),
% or MATLAB will resolve initPos to the array and never run this file.

% move to bottom transition position
robot.movej(bottomPos,'joint');
pause(MOVE_STEP_DELAY)

% move to pre-grab position
robot.movej(initPos,'joint');
pause(MOVE_STEP_DELAY)

% open gripper (vacuum off)
try
    vacuumGrip.release();
catch ME
    warning('runPickupSequence:vacuumRelease', 'vacuumGrip.release failed: %s', ME.message);
end
pause(MOVE_STEP_DELAY);

% move to grab position
robot.movej(grabPos,'joint');
pause(MOVE_STEP_DELAY)

% close gripper (vacuum on)
try
    vacuumGrip.grip();
catch ME
    warning('runPickupSequence:vacuumGrip', 'vacuumGrip.grip failed: %s', ME.message);
end
pause(MOVE_STEP_DELAY);

% move back to pre-grab position
robot.movej(initPos,'joint');
pause(MOVE_STEP_DELAY)

% move back to bottom transition position
robot.movej(bottomPos,'joint');
pause(MOVE_STEP_DELAY)
