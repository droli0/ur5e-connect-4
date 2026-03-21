
function board = getGameboard()
    global SHOW_CV_DEMO CV_DEMO_DELAY

    transform; % get image from webcam, transform image based on aruco markers

    board = matrix(tformimg); % extract puck matrix from the transformed image

    % final output always shown
    visualise; % visualise the matrix as a figure

    if SHOW_CV_DEMO
        pause(CV_DEMO_DELAY);
    end
end