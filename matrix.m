
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

% Soft scores (0–1) matching the same cutoff directions — for gradient plots only.
Rd = double(R);
Gd = double(G);
Bd = double(B);
redStrength = max(0, Rd - 95) ./ (255 - 95) .* max(0, 20 - Gd) ./ 20 .* max(0, 40 - Bd) ./ 40;
blueStrength = max(0, 30 - Rd) ./ 30 .* max(0, 20 - Gd) ./ 20 .* max(0, Bd - 60) ./ (255 - 60);
redStrength = min(1, redStrength);
blueStrength = min(1, blueStrength);
RBdiff = mat2gray(Rd - Bd); % 0–1: darker bluer, brighter redder

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
    title('Red threshold mask (binary)');
    subplot(1,2,2);
    imshow(blue_mask);
    title('Blue threshold mask (binary)');
    hold off;
    drawnow;
    pause(CV_DEMO_DELAY);

    % Figure 13: continuous "how red / how blue" from the same rules + R-B axis.
    figure(13);
    clf;
    subplot(2, 2, 1);
    imshow(img);
    title('Warped input (RGB)');
    subplot(2, 2, 2);
    imshow(RBdiff);
    title('R minus B (bright = redder, dark = bluer)');
    subplot(2, 2, 3);
    imshow(redStrength);
    title('Soft red score (margins vs red thresholds)');
    subplot(2, 2, 4);
    imshow(blueStrength);
    title('Soft blue score (margins vs blue thresholds)');
    drawnow;
    pause(CV_DEMO_DELAY);
end

if showCvStages
    disp(board);
end
