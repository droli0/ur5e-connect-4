
% initialise/load variables
init;

% get current gameboard state
getGameboard;

% dispenser calculation
puckDisp = floor(turnCount/3);
disp(puckDisp);
puckDisp = puckDisp + 1;
% disp("Current dispenser: " + puckDisp + ".");

% move robot to grab puck and wait for input command
initPos;

% get user column choice, move to column, drop puck, return to standby pos
robotMove;

% get gameboard at the end as well to check for win/loss states
getGameboard;