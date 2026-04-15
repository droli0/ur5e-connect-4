
% CV_QUIET: skip saving a raw snapshot for the debug montage (debounce polling).
showCvStages = SHOW_CV_DEMO;
if exist('CV_QUIET', 'var') && CV_QUIET
    showCvStages = false;
end

arucoWarnKey = 'ur5e_connect4_arucoWarningShown';
if ~isappdata(0, arucoWarnKey)
    setappdata(0, arucoWarnKey, false);
end

img = snapshot(visionCamera);
if showCvStages
    cvRawImg = img;
end

detected = false;
try
    [ids, locs] = readArucoMarker(img, 'DICT_4X4_50');
    if numel(ids) >= 4
        centers = zeros(numel(ids), 2);
        for i = 1:numel(ids)
            centers(i, :) = mean(locs(:, :, i), 1);
        end
        [~, sort_idx] = sort(ids);
        centers_sorted = centers(sort_idx, :);
        basis = [15 25; 85 25; 15 85; 85 85];
        tform = fitgeotrans(centers_sorted, basis, "projective");
        tformimg = imwarp(img, tform, OutputView=imref2d([100 100 3]));
        detected = true;
    end
catch
end

if ~detected
    if ~getappdata(0, arucoWarnKey)
        warning('Aruco markers not detected. Falling back to resized raw frame for board read.');
        setappdata(0, arucoWarnKey, true);
    end
    tformimg = imresize(img, [100 100]);
end
