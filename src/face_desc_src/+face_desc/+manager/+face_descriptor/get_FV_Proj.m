%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this example script shows how to compute a dimensionality-reduced FV face representation of a single image

function features = get_FV_Proj(faceImg)
 %%
run('./startup.m');

    % load SIFT PCA projection
    linTrans = load('../data/lfw_vj/SIFT_1pix_PCA64_GMM512/codebooks/9/PCA_64.mat');

    % load GMM
    load('../data/lfw_vj/SIFT_1pix_PCA64_GMM512/codebooks/9/gmm_512.mat', 'codebook');
    %
    % FV encoder
    faceDescriptor = face_desc.lib.face_descriptor.poolFV();
    faceDescriptor.set_feat_proj(linTrans);
    faceDescriptor.set_codebook(codebook);

    % load a discriminative FV projection
    load('../data/lfw_vj/SIFT_1pix_PCA64_GMM512/models/dimred_class_unreg_128/9/g0.25_gb10.mat', 'model');
    
    W = model.state.W;
%     nums = gcp('nocreate');
%     nums = nums.NumWorkers;
%     numWorkers = max(1, nums);
%     % load a face image
     numImages = size(faceImg,2);
%     bucketSize = numImages / numWorkers;
%     buckets = cell(1,numWorkers);
%     for i = 1:numWorkers
%         if i<numWorkers
%             buckets{i} = faceImg((1:bucketSize)+(i-1)*bucketSize);
%         else
%             buckets{i} = faceImg((1+(i-1)*bucketSize):end);
%         end
%     end

        for i=1:numImages

            % compute the descriptor
            faceDesc = faceDescriptor.compute(faceImg{i}, 'doPooling', true);

            % project onto low-dim subspace
           features{i} = W * faceDesc;
       %     features{j}(i) = W * faceDesc;
            disp(['Finished ' int2str(i) '/' num2str(numImages)]);
        end
   
   
 
