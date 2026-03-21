
global robot vacuum bottomPos initPos grabPos MOVE_STEP_DELAY

% single pickup sequence: approach from hover pose, engage suction, then withdraw.

% move to bottom transition position
robot.movej(bottomPos,'joint');
pause(MOVE_STEP_DELAY)

% move to pre-grab position
robot.movej(initPos,'joint');
pause(MOVE_STEP_DELAY)

% open gripper
if exist('vacuum', 'var')
    vacuum.release();
end
pause(MOVE_STEP_DELAY);

% move to grab position
robot.movej(grabPos,'joint');
pause(MOVE_STEP_DELAY)

% close gripper
if exist('vacuum', 'var')
    vacuum.grip();
end
pause(MOVE_STEP_DELAY);

% move back to pre-grab position
robot.movej(initPos,'joint');
pause(MOVE_STEP_DELAY)

% move back to bottom transition position
robot.movej(bottomPos,'joint');
pause(MOVE_STEP_DELAY)