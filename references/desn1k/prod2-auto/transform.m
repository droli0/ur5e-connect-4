
camera = webcam('/dev/video1');
img = snapshot(camera);

[ids, locs] = readArucoMarker(img,'DICT_4X4_50');

centers = [];
 for i = 1:4
     centers(i,:) = mean(locs(:,:,i));
 end
 
 [ids_sorted, sort_idx] = sort(ids);

centers_sorted = centers(sort_idx,:);

basis = [15 25; 85 25; 15 85; 85 85];

tform = fitgeotrans(centers_sorted, basis, "projective");
tformimg = imwarp(img, tform,OutputView=imref2d([100 100 3]));

% imshow(tformimg) % used for checking threshold values