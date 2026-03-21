function waitForOpponentMove(prevBoard)
    % Waits until a board change is detected with debounce logic
    % Allows manual override via keyboard input
    
    disp('Waiting for opponent move... Press Enter to override.');

    debounceThreshold = 3;
    debounceCount = 0;
    lastDetectedBoard = prevBoard;

    overrideTriggered = false;

    while true
        % Manual override check
        if waitforbuttonpress
            key = get(gcf, 'CurrentCharacter');
            if key == char(13)  % Enter key
                disp('Manual override triggered.');
                overrideTriggered = true;
                break;
            end
        end

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

        pause(1); % wait before next check
    end
end
