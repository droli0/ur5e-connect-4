% Uses prevBoard, OPPONENT_POLL_DELAY, SHOW_CV_DEMO, CV_DEMO_DELAY from workspace.

disp('Waiting for opponent move...');

debounceThreshold = 3;
debounceCount = 0;
lastDetectedBoard = prevBoard;

% No CV figures/pauses while polling — only after debounce confirms.
CV_QUIET = true;

while true
    transform;
    matrix;
    newBoard = board;

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

    if debounceCount >= debounceThreshold
        disp('Board change confirmed!');
        break;
    end

    pause(OPPONENT_POLL_DELAY);
end

clear CV_QUIET

% Fresh capture with full CV pipeline + board figure (matches post-robot getGameboard).
getGameboard;
prevBoard = board;
