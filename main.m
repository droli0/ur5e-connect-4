%% Run a turn and record runtime performance.

clc;
close all;

%% Launch-time setup
AUTO_PLAY = askBinaryChoice('Enable autonomous minimax play? (1 = auto, 0 = manual): ', 1);
ROBOT_STARTS = askBinaryChoice('Should the robot start first? (1 = robot, 0 = opponent): ', 0);
SHOW_CV_DEMO = askBinaryChoice('Show CV transformation stages? (1 = yes, 0 = board only): ', 1);

ROBOT_PIECE = askRobotPiece( ...
    ['Which color is the robot on the board? Vision uses 1=red, 2=blue. ', ...
     'Enter 1 or 2 [default 1]: '], 1);
OPPONENT_PIECE = 3 - ROBOT_PIECE;

% Shared state lives in the base workspace; child scripts see the same variables.

CAMERA_DEVICE = '/dev/video0';
OPPONENT_POLL_DELAY = 1;
MOVE_STEP_DELAY = 0.1;
MINIMAX_DEPTH = 6; % search plies (lower = faster; uses alpha-beta in minimax.m)
% Optional pause after each CV montage refresh (s). 0 = no wait; use e.g. 0.5 for a slower demo.
CV_DEMO_DELAY = 0;

turnCount = 0;
totalTime = 0;
term = 0;

if AUTO_PLAY
    disp('Mode: robot uses minimax to pick moves.');
else
    disp('Mode: operator manually enters robot drop column each turn.');
end
if ROBOT_STARTS
    disp('Starter mode: robot moves first.');
else
    disp('Starter mode: opponent moves first.');
end
if ROBOT_PIECE == 1
    disp('Robot plays red (1); opponent plays blue (2).');
else
    disp('Robot plays blue (2); opponent plays red (1).');
end
if SHOW_CV_DEMO
    disp('Showing CV montage on figure 2 (see CV_DEMO_DELAY in main.m for optional pause).');
else
    disp('Showing final board graphic only.');
end

%% Main setup (robot, gripper, board variables)
init;

% Initial board capture
getGameboard;
prevBoard = board;

%% Main Loop
isFirstTurn = true;
while true
    if ~(isFirstTurn && ROBOT_STARTS)
        waitForOpponentMove;
    end

    [term, isTerminal] = checkTerminalState(prevBoard, ROBOT_PIECE);
    if isTerminal
        break;
    end

    tic;
    executeTurn;
    turnCount = turnCount + 1;
    isFirstTurn = false;
    totalTime = totalTime + toc;
    fprintf('Turn %d complete. Total time: %.3f seconds\n', turnCount, totalTime);

    getGameboard;
    prevBoard = board;

    [term, isTerminal] = checkTerminalState(prevBoard, ROBOT_PIECE);
    if isTerminal
        break;
    end
end

endGame;
fprintf('Team survived %d turns and took %.3f seconds.\n', turnCount, totalTime);

function choice = askBinaryChoice(promptText, defaultValue)
    while true
        raw = input([promptText], 's');
        raw = strtrim(raw);
        if isempty(raw)
            choice = defaultValue;
            return;
        end

        parsed = str2double(raw);
        if isnan(parsed) || ~isfinite(parsed)
            disp('Invalid input. Enter 0 (no), 1 (yes), or press Enter for the default.');
            continue;
        end
        if parsed ~= 0 && parsed ~= 1
            disp('Please enter exactly 0 or 1 (or press Enter for the default).');
            continue;
        end
        choice = parsed;
        return;
    end
end

function piece = askRobotPiece(promptText, defaultValue)
    while true
        raw = input(promptText, 's');
        raw = strtrim(raw);
        if isempty(raw)
            piece = defaultValue;
            return;
        end

        parsed = str2double(raw);
        if isnan(parsed) || ~isfinite(parsed)
            disp('Invalid input. Enter 1 (robot is red on the board) or 2 (robot is blue).');
            continue;
        end
        if parsed ~= 1 && parsed ~= 2
            disp('Please enter 1 or 2 only (or press Enter for the default).');
            continue;
        end
        piece = parsed;
        return;
    end
end

function [term, isTerminal] = checkTerminalState(boardState, robotPiece)
    term = 0;
    isTerminal = false;
    opponentPiece = 3 - robotPiece;

    winCheck = checkWinCondition(boardState);
    if winCheck == robotPiece
        if robotPiece == 1
            disp('Robot wins! (red four in a row)');
        else
            disp('Robot wins! (blue four in a row)');
        end
        term = 1;
        isTerminal = true;
        return;
    end
    if winCheck == opponentPiece
        if opponentPiece == 1
            disp('Opponent wins! (red four in a row)');
        else
            disp('Opponent wins! (blue four in a row)');
        end
        term = 0;
        isTerminal = true;
        return;
    end
    if ~any(boardState(:) == 0)
        disp('Board full — tie game.');
        term = -1;
        isTerminal = true;
    end
end
