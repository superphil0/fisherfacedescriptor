%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this script performs pre-processing (cropping) of LFW images
% the images can be downloaded from http://vis-www.cs.umass.edu/lfw/lfw.tgz
clear;
%imgDir = '../data/images/adience/faces';
imgDir = '../data/images/adience/aligned';
procImgDir = ['..' filesep 'data' filesep 'adience' filesep 'images_preproc'];

% load image list
%load('../data/shared/info/databaseadience.mat', 'database');
load('../data/shared/info/databaseadiencealigned.mat', 'database');

imgList = database.images;
numImg = numel(imgList);

%% crop images
% for idxImg = 1:numImg
parfor idxImg = 1:numImg
    
    % image path
    imPath = sprintf('%s/%s', imgDir, imgList{idxImg});
    
    % load an image
    img = imread(imPath);
    img = imresize(img,[250,250]);
    img = rgb2gray(im2single(img));
    
    % crop a Viola-Jones face detection
    faceImg{idxImg} = img(68:181, 68:181);
    disp(['Cropping ' int2str(idxImg) '/' int2str(numImg)]);
end

%% save all images
ensure_dir(procImgDir);
save(sprintf('%s/all_img.mat', procImgDir), 'faceImg');
