
validColumn = false;

while ~validColumn % check if column is valid
    column = input("Which column would you like to drop a puck into? (1-7): ");
    
    if column >= 1 && column <= 7 % valid columns
        validColumn = true;  % Exit loop

        % assign current drop column and transition positions
        dropCol = colPos(column, :);
        dropTCol = colTPos(column, :);

        % move to top transition position
        robot.movej(topPos,'joint');
        pause(0.1);

        % move to column transition position
        robot.movej(dropTCol,'joint');
        pause(0.1);

        % move to drop position
        robot.movej(dropCol,'joint');
        pause(0.1);

        % open gripper
        writeline(arduino, "1");
        pause(0.1);

        % move back to column transition position
        robot.movej(dropTCol,'joint');
        pause(0.1);

        % move back to top transition position
        robot.movej(topPos,'joint');
        pause(0.1);
    else
        disp("Invalid column. Please enter a number between 1 and 7.");
    end
end