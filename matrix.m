
showCvStages = SHOW_CV_DEMO;
if exist('CV_QUIET', 'var') && CV_QUIET
    showCvStages = false;
end

img = tformimg;

% Extract RGB Channels
R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

% Adjust Red and Blue Color Thresholds
red_mask = (R > 95) & (G < 20) & (B < 40);  % Expanded red range
blue_mask = (R < 30) & (G < 20) & (B > 60); % Expanded blue range

% Define board size
board_rows = 5;
board_cols = 7;
board = zeros(board_rows, board_cols);

% Get image dimensions
[img_rows, img_cols, ~] = size(img);
cell_height = round(img_rows / board_rows);
cell_width = round(img_cols / board_cols);

% Process each cell in the 5x7 grid
for row = 1:board_rows
    for col = 1:board_cols
        r_start = (row-1) * cell_height + 1;
        r_end = min(row * cell_height, img_rows);
        c_start = (col-1) * cell_width + 1;
        c_end = min(col * cell_width, img_cols);

        red_count = sum(sum(red_mask(r_start:r_end, c_start:c_end)));
        blue_count = sum(sum(blue_mask(r_start:r_end, c_start:c_end)));

        if red_count > blue_count
            board(row, col) = 1;
        elseif blue_count > red_count
            board(row, col) = 2;
        else
            board(row, col) = 0;
        end
    end
end

if showCvStages
    figure(12);
    clf;
    hold off;
    subplot(1,2,1);
    imshow(red_mask);
    title('Red threshold mask');
    subplot(1,2,2);
    imshow(blue_mask);
    title('Blue threshold mask');
    hold off;
    drawnow;
    pause(CV_DEMO_DELAY);
end

if showCvStages
    disp(board);
end
