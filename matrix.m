
showCvStages = SHOW_CV_DEMO;
if exist('CV_QUIET', 'var') && CV_QUIET
    showCvStages = false;
end

img = tformimg;

% RGB thresholds — same numbers drive hard masks and soft heatmaps below.
Rmin_red = 88;
Gmax_red = 25;
Bmax_red = 48;
Rmax_blue = 30;
Gmax_blue = 20;
Bmin_blue = 60;

R = img(:, :, 1);
G = img(:, :, 2);
B = img(:, :, 3);

red_mask = (R > Rmin_red) & (G < Gmax_red) & (B < Bmax_red);
blue_mask = (R < Rmax_blue) & (G < Gmax_blue) & (B > Bmin_blue);

Rd = double(R);
Gd = double(G);
Bd = double(B);
redStrength = min(1, max(0, Rd - Rmin_red) ./ (255 - Rmin_red) .* max(0, Gmax_red - Gd) ./ Gmax_red .* max(0, Bmax_red - Bd) ./ Bmax_red);
blueStrength = min(1, max(0, Rmax_blue - Rd) ./ Rmax_blue .* max(0, Gmax_blue - Gd) ./ Gmax_blue .* max(0, Bd - Bmin_blue) ./ (255 - Bmin_blue));
RBdiff = mat2gray(Rd - Bd);

board_rows = 5;
board_cols = 7;
board = zeros(board_rows, board_cols);

[img_rows, img_cols, ~] = size(img);
cell_height = round(img_rows / board_rows);
cell_width = round(img_cols / board_cols);

for row = 1:board_rows
    for col = 1:board_cols
        r_start = (row - 1) * cell_height + 1;
        r_end = min(row * cell_height, img_rows);
        c_start = (col - 1) * cell_width + 1;
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
    figure(2);
    clf;
    set(gcf, 'Name', 'CV', 'NumberTitle', 'off');

    subplot(2, 4, 1);
    if exist('cvRawImg', 'var') && ~isempty(cvRawImg)
        imshow(cvRawImg);
    else
        imshow(img);
    end
    title('Raw');

    subplot(2, 4, 2);
    imshow(img);
    title('Warped');

    subplot(2, 4, 3);
    imshow(red_mask);
    title('Red Mask');

    subplot(2, 4, 4);
    imshow(blue_mask);
    title('Blue Mask');

    subplot(2, 4, 5);
    imshow(RBdiff);
    title('R vs B');

    subplot(2, 4, 6);
    imshow(redStrength);
    title('Red Score');

    subplot(2, 4, 7);
    imshow(blueStrength);
    title('Blue Score');

    drawnow;
    if exist('CV_DEMO_DELAY', 'var') && CV_DEMO_DELAY > 0
        pause(CV_DEMO_DELAY);
    end
end

if showCvStages
    disp(board);
end
