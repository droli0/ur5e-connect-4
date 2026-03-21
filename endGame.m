if term == 1
    gameStatus = "Victory";
elseif term == 0
    gameStatus = "Defeat";
elseif term == -1
    gameStatus = "Tie";
else
    gameStatus = "Ended";
end
fprintf('Game ended (%s).\n', gameStatus);

if exist('vacuum', 'var') == 1
    try
        vacuum.release();
    catch
        % vacuum may not be connected or already released
    end
end

if exist('robot', 'var') == 1
    try
        robot.movej(topPos, 'joint');
    catch
        % no-op
    end
    try
        robot.close();
    catch
        % no-op
    end
end

try
    clear robot vacuum visionCamera;
catch
end