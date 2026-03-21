%% Run a turn and record how long it takes.

clear all;

% set running variables
turnCount = 0;
totalTime = 0;

% initial board capture
transform;
prevBoard = matrix(tformimg);

%% Main Loop

while True
    waitForOpponentMove(prevBoard);
    
    winCheck = checkWinCondition(prevBoard);
    
    if winCheck == 1
        disp('Red wins!');
        term = 1;
        break;
    elseif winCheck == 2
        disp('Blue wins!');
        term = 0;
        break;
    end

    %% main robot move
    tic;
    executeTurn;
    turnCount = turnCount + 1;
    totalTime = totalTime + toc;
    disp(['Turn ', num2str(turnCount), ' complete. Total time: ', num2str(totalTime), ' seconds']);
    
    % Capture new board state after your turn
    transform;
    prevBoard = matrix(tformimg);  % update the reference board

    %% win check
    winCheck = checkWinCondition(prevBoard);
    
    if winCheck == 1
        disp('Red wins!');
        term = 1;
        break;
    elseif winCheck == 2
        disp('Blue wins!');
        term = 0;
        break;
    end
end

endGame; % end game code

disp(['Team Survived '  + string(turnCount) + ' turns, and took ' + string(totalTime) + ' seconds!']);

clear all;

% command for getting robot joint angle: robot.actualJointPositions