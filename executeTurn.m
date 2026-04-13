
global AUTO_PLAY prevBoard colPos colTPos topPos bottomPos board robot vacuum MOVE_STEP_DELAY

column = NaN;

while true
    if AUTO_PLAY
        [column, ~] = minimax(board, 7, true);
        if isnan(column) || column < 1
            error('No valid move was available from minimax.');
        end
        disp(['Minimax chose column: ', num2str(column)]);
        break;
    else
        userInput = input('Enter a column for the robot to drop into (1-7): ', 's');
        userInput = strtrim(userInput);
        parsed = str2double(userInput);
        if ~isempty(parsed) && isfinite(parsed) && parsed >= 1 && parsed <= 7 && parsed == round(parsed)
            column = round(parsed);
        else
            column = NaN;
        end
    end

    if isColumnAvailable(column, prevBoard)
        if ~AUTO_PLAY
            fprintf('Manual move selected: %d\n', column);
        end
        break;
    end

    if AUTO_PLAY
        disp("Minimax chose an invalid column. Trying again...");
    else
        disp("That column is invalid or full. Choose a different column.");
    end
end

% move robot to grab puck from the shared init/grab pickup pose
initPos;

% assign current drop column and transition positions
dropCol = colPos(column, :);
dropTCol = colTPos(column, :);

% move to top transition position
robot.movej(topPos, 'joint');
pause(MOVE_STEP_DELAY);

% move to column transition position
robot.movej(dropTCol, 'joint');
pause(MOVE_STEP_DELAY);

% move to drop position
robot.movej(dropCol, 'joint');
pause(MOVE_STEP_DELAY);

% open gripper (vacuum)
vacuum.release();
pause(MOVE_STEP_DELAY);

% move back to column transition position
robot.movej(dropTCol, 'joint');
pause(MOVE_STEP_DELAY);

% move back to top transition position
robot.movej(topPos, 'joint');
pause(MOVE_STEP_DELAY);

function valid = isColumnAvailable(column, boardState)
    valid = false;
    if isempty(column) || ~isscalar(column) || column < 1 || column > 7
        return;
    end
    valid = boardState(1, column) == 0;
end