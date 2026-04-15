
% Single source of truth: board state before this robot move (must match vision labels 1=red, 2=blue).
gameBoard = prevBoard;

column = NaN;

while true
    if AUTO_PLAY
        [column, ~] = minimax(gameBoard, MINIMAX_DEPTH, true, ROBOT_PIECE, OPPONENT_PIECE);
        validCols = find(gameBoard(1, :) == 0);
        if isempty(validCols)
            error('executeTurn:NoMoves', 'No legal columns left; board should have been terminal.');
        end
        if isnan(column) || ~ismember(column, validCols)
            warning('Minimax returned invalid column %s; using first legal column.', mat2str(column));
            column = validCols(1);
        end
        disp(['Minimax chose column: ', num2str(column)]);
    else
        userInput = input('Enter a column for the robot to drop into (1-7): ', 's');
        userInput = strtrim(userInput);
        if isempty(userInput)
            disp('Empty input. Enter an integer from 1 through 7.');
            continue;
        end
        parsed = str2double(userInput);
        if isnan(parsed) || ~isfinite(parsed)
            disp('Invalid input (not a number). Enter an integer from 1 through 7, e.g. 4.');
            continue;
        end
        if parsed ~= round(parsed)
            disp('Enter a whole column number 1-7, not a fraction.');
            continue;
        end
        column = round(parsed);
        if column < 1 || column > 7
            disp('Column out of range. Use 1 through 7 only.');
            continue;
        end
    end

    if isColumnAvailable(column, gameBoard)
        if ~AUTO_PLAY
            fprintf('Manual move selected: %d\n', column);
        end
        break;
    end

    if AUTO_PLAY
        error('executeTurn:MinimaxFullColumn', 'Minimax chose a full column; logic error.');
    end
    disp('That column is full. Pick a different column (1-7).');
end

% move robot to grab puck from the shared init/grab pickup pose
runPickupSequence;

dropCol = colPos(column, :);
dropTCol = colTPos(column, :);
dropACol = colAPos(column, :);

robot.movej(topPos, 'joint');
pause(MOVE_STEP_DELAY);

robot.movej(dropTCol, 'joint');
pause(MOVE_STEP_DELAY);

robot.movej(dropCol, 'joint');
pause(MOVE_STEP_DELAY);

vacuumGrip.release();
pause(MOVE_STEP_DELAY);

% Retreat to column-specific "after" pose (not dropTCol) so the puck falls cleanly into the board.
robot.movej(dropACol, 'joint');
pause(MOVE_STEP_DELAY);

robot.movej(topPos, 'joint');
pause(MOVE_STEP_DELAY);

function valid = isColumnAvailable(column, boardState)
    valid = false;
    if isempty(column) || ~isscalar(column) || column < 1 || column > 7
        return;
    end
    valid = boardState(1, column) == 0;
end
