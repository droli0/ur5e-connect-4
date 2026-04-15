
emptyColor = [1, 1, 1];
redColor = [1, 0, 0];
blueColor = [0, 0, 1];

rows = size(board, 1);
cols = size(board, 2);

figure(1);
clf;
hold on;
axis equal;
xlim([0 cols]);
ylim([0 rows]);
set(gca, 'XColor', 'none', 'YColor', 'none');
title('Board');
box on;

for r = 1:rows
    for c = 1:cols
        x = c - 0.5;
        y = rows - r + 0.5;

        if board(r, c) == 1
            color = redColor;
        elseif board(r, c) == 2
            color = blueColor;
        else
            color = emptyColor;
        end

        rectangle('Position', [x - 0.4, y - 0.4, 0.8, 0.8], 'Curvature', [1, 1], ...
                  'FaceColor', color, 'EdgeColor', 'black', 'LineWidth', 1.2);
    end
end
axis([0 cols 0 rows]);
hold off;
