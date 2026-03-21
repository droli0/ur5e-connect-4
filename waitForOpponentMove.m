function waitForOpponentMove(prevBoard)
    % Waits until a board change is detected with debounce logic
    global OPPONENT_POLL_DELAY

    disp('Waiting for opponent move...');

    debounceThreshold = 3;
    debounceCount = 0;
    lastDetectedBoard = prevBoard;

    while true
        transform;
        newBoard = matrix(tformimg);

        % Check for board change
        if ~isequal(newBoard, prevBoard)
            if isequal(newBoard, lastDetectedBoard)
                debounceCount = debounceCount + 1;
                disp(['Change detected (', num2str(debounceCount), '/3)...']);
            else
                debounceCount = 1;
                lastDetectedBoard = newBoard;
                disp('Potential change detected. Restarting debounce.');
            end
        else
            debounceCount = 0;
        end

        % If board has changed consistently for 3 checks
        if debounceCount >= debounceThreshold
            disp('Board change confirmed!');
            break;
        end

        pause(OPPONENT_POLL_DELAY); % wait before next check
    end
end
