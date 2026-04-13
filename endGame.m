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

try
    vacuumGrip.release();
catch
end

try
    robot.movej(topPos, 'joint');
catch
end
try
    robot.close();
catch
end

try
    clear robot vacuumGrip visionCamera;
catch
end
