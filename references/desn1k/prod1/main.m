%% Run a turn and record how long it takes.

clear all;

turnCount = 0;
totalTime = 0;

%% Main Loop

answer = questdlg('What Next?','What Next?', 'Next Turn!', 'We Won!', 'We Lost.', 'Next Turn!');

while strcmp(answer, 'Next Turn!')
    tic;
    executeTurn;
    turnCount = turnCount + 1;
    totalTime = totalTime + toc;
    disp(totalTime);
    answer = questdlg('What Next?','What Next?', 'Next Turn!', 'We Won!', 'We Lost.', 'Next Turn!');
end

%% Win/Loss Condition

if answer == "We Won!"
    term = 1; % "terminal state"
elseif answer == "We Lost."
    term = 0;
end

endGame; % end game code

disp(['Team Survived '  + string(turnCount) + ' turns, and took ' + string(totalTime) + ' seconds!']);

clear all;

% command for getting robot joint angle: robot.actualJointPositions