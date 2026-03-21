%% Run a turn and record runtime performance.

clc;
close all;

%% Launch-time setup
AUTO_PLAY = askBinaryChoice('Enable autonomous minimax play? (1 = auto, 0 = manual): ', 1);
ROBOT_STARTS = askBinaryChoice('Should the robot start first? (1 = robot, 0 = opponent): ', 0);
SHOW_CV_DEMO = askBinaryChoice('Show CV transformation stages? (1 = yes, 0 = board only): ', 1);
CV_DEMO_DELAY = askDelaySeconds('CV stage delay in seconds (default 0.5): ', 0.5);

%% Global execution state used by helper scripts
global AUTO_PLAY ROBOT_STARTS SHOW_CV_DEMO CV_DEMO_DELAY OPPONENT_POLL_DELAY CAMERA_DEVICE;
global robot vacuum visionCamera turnCount totalTime term board prevBoard MOVE_STEP_DELAY;
global topPos bottomPos initPos grabPos colTPos colPos;

% Configured in root scripts for readability and performance.
CAMERA_DEVICE = '/dev/video1';
OPPONENT_POLL_DELAY = 1;
MOVE_STEP_DELAY = 0.1;

turnCount = 0;
totalTime = 0;
term = 0;

if AUTO_PLAY
    disp('Mode: robot uses minimax to pick moves.');
else
    disp('Mode: operator manually enters robot move column each turn.');
end
if ROBOT_STARTS
    disp('Starter mode: robot moves first.');
else
    disp('Starter mode: opponent moves first.');
end
if SHOW_CV_DEMO
    fprintf('Showing CV stages with delay = %.2f s\n', CV_DEMO_DELAY);
else
    disp('Showing final board graphic only.');
end

%% Main setup (robot, gripper, board variables)
init;

% Initial board capture
prevBoard = getGameboard();
board = prevBoard;

%% Main Loop
isFirstTurn = true;
while true
    if ~(isFirstTurn && ROBOT_STARTS)
        waitForOpponentMove(prevBoard);
    end

    [term, isTerminal] = checkTerminalState(prevBoard);
    if isTerminal
        break;
    end

    % Main robot move
    tic;
    executeTurn;
    turnCount = turnCount + 1;
    isFirstTurn = false;
    totalTime = totalTime + toc;
    fprintf('Turn %d complete. Total time: %.3f seconds\n', turnCount, totalTime);

    % Capture new board state after your turn.
    prevBoard = getGameboard();
    board = prevBoard;

    [term, isTerminal] = checkTerminalState(prevBoard);
    if isTerminal
        break;
    end
end

endGame;
fprintf('Team survived %d turns and took %.3f seconds.\n', turnCount, totalTime);

% No cleanup here; endGame.m handles robot and hardware release.

function choice = askBinaryChoice(promptText, defaultValue)
    while true
        raw = input([promptText], 's');
        raw = strtrim(raw);
        if isempty(raw)
            choice = defaultValue;
            return;
        end

        parsed = str2double(raw);
        if parsed == 0
            choice = 0;
            return;
        elseif parsed == 1
            choice = 1;
            return;
        end
        disp('Please enter 1 (yes) or 0 (no).');
    end
end

function delaySeconds = askDelaySeconds(promptText, defaultValue)
    while true
        raw = input(promptText, 's');
        raw = strtrim(raw);
        if isempty(raw)
            delaySeconds = defaultValue;
            return;
        end

        parsed = str2double(raw);
        if ~isnan(parsed) && parsed >= 0
            delaySeconds = parsed;
            return;
        end
        disp('Please enter a non-negative numeric value.');
    end
end

function [term, isTerminal] = checkTerminalState(boardState)
    term = 0;
    isTerminal = false;

    winCheck = checkWinCondition(boardState);
    if winCheck == 1
        disp('Red wins!');
        term = 1;
        isTerminal = true;
        return;
    end
    if winCheck == 2
        disp('Blue wins!');
        term = 0;
        isTerminal = true;
        return;
    end
    if ~any(boardState(:) == 0)
        term = -1;
        isTerminal = true;
    end
end