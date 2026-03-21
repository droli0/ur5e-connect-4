winPos1 = [];
winPos2 = [];
losePos = [];

if term == 1 % win code
    % open gripper like "clapping"
    writeline(arduino, "2");
    pause(0.1);

    % play win music
    writeline(arduino, "3");
    pause(0.1);

    % move arm in dance motion
    for i = 1:5
        robot.movej(winPos1,'joint');
        pause(0.1)

        robot.moveJ(winPos2,'joint');
        pause(0.1)
    end

    % reset position
    robot.movej(topPos,'joint');
    pause(0.1)
elseif term == 2
    % play lose music
    writeline(arduino, "4");
    pause(0.1);

    % move arm to lose (sad) position
    robot.movej(losePos,'joint');
        pause(0.1)
end