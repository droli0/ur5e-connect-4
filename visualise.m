
% Define colors (RGB) for each type of cell
emptyColor = [1, 1, 1];    % White
redColor = [1, 0, 0];      % Red
blueColor = [0, 0, 1];     % Blue

% Board Dimensions
rows = size(board, 1);
cols = size(board, 2);

% Create or reuse figure for final board display
figure(1);
clf;
hold on;
axis equal;
xlim([0 cols]);
ylim([0 rows]);
set(gca, 'XColor', 'none', 'YColor', 'none'); % Hide axes
title('Detected board');
box on;

% Draw board background (white grid)
for r = 1:rows
    for c = 1:cols
        % Define circle center
        x = c - 0.5;
        y = rows - r + 0.5; % Flip Y-axis to match row ordering
        
        % Choose color
        if board(r, c) == 1
            color = redColor;
        elseif board(r, c) == 2
            color = blueColor;
        else
            color = emptyColor;
        end
        
        % Draw circle
        rectangle('Position', [x - 0.4, y - 0.4, 0.8, 0.8], 'Curvature', [1, 1], ...
                  'FaceColor', color, 'EdgeColor', 'black', 'LineWidth', 1.2);
    end
end
axis([0 cols 0 rows]);
hold off;