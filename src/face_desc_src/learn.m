
%%
startup

%%
database ={};
 database.images = {};
 database.face_id = [];
 database.gender = [];
 database.x = [];
 database.y = [];
 database.dx = [];
 database.dy = [];
imgIds = {};
index = 1;
for j=0:4
    fold = tdfread(['../data/images/adience/fold_frontal_' int2str(j) '_data.txt']);
    % img file in format: USERID/coarse_tilt_aligned_face.FACEID.IMAGEPATH
    %imgList = database.images;
    fold.path = {};
    for i=1:size(fold.original_image)
        %A= [fold.user_id(i,:) '/coarse_tilt_aligned_face.' num2str(fold.face_id(i,:)) '.' fold.original_image(i,:)];
        A= [fold.user_id(i,:) '/landmark_aligned_face.' num2str(fold.face_id(i,:)) '.' fold.original_image(i,:)];
        A= A(~isspace(A));
        fold.path{i,1} = A; 
        fold.ids(i,1) = index;
        tmp = +(fold.gender =='f');   
        tmp = tmp*2 -1;
        index = index+1;
    end
  %  sizee = 500;
%     fold.path = fold.path(1:sizee);
%     fold.face_id = fold.face_id(1:sizee);
%     tmp = tmp(1:sizee);
    %fold.ids = fold.ids(1:sizee);
    database.images = [database.images; fold.path];
    database.face_id = [database.face_id; fold.face_id];
    database.gender = [database.gender; tmp];
    database.x = [database.x; fold.x];
    database.y = [database.y; fold.y];
    database.dx = [database.dx; fold.dx];
    database.dy = [database.dy; fold.dy];
    
    imgIds{j+1} = fold.ids;
end


save('../data/shared/train_data/unrest_adience/img_idsaligned.mat', 'imgIds');
save('../data/shared/info/databaseadiencealigned.mat', 'database');
%%
%begin computation
clear;
startup;
% read the files
face_desc.prep_img.crop_adience
%%
allImg = load('../data/adience/images_preproc/all_img.mat');
faces = allImg.faceImg;
split = size(faces,2) / 10;
for i = 1:10
    features = face_desc.manager.face_descriptor.get_FV_Proj(faces((1:split)+(i-1)*split));
    save(['featuresall' num2str(i) '.mat'], 'features');
end
%% build trainingset
load('../data/shared/info/databaseadiencealigned.mat', 'database');
% already in right splits
load('../data/shared/train_data/unrest_adience/img_idsaligned.mat', 'imgIds');
load('featuresfrontaligned.mat', 'features');

% modification is done so to keep compatibility to framework
X =zeros(size(features{1},1),size(features,2));
for i = 1:size(features,2)
    X(:,i) = features{i}';
end
% parameters
lambdainit = 10;
maxIter = 1000;


%first make n sets train with n-1 test with nth
% do it k-fold so all permutations
% C = 1/lambda
    startup;

for j= -5:1:5
    lambda = lambdainit ^j;
    erg = 0;
    set = 1:5;
    for i = set
        indices = setdiff(set,i);
        ids = cell2mat(imgIds(indices)');
        labels = database.gender(ids);
        trainingset = X(:,ids);
        % train data on training set
        testset = X(:,imgIds{i});
        [w b info] = vl_svmtrain(trainingset, labels, lambda, 'MaxNumIterations', maxIter);
        result = w'*testset+b;
        result(result>0) = 1;
        result(result<0) = -1;
        r = database.gender(imgIds{i}) == result';
        erg = erg + (sum(r)/size(imgIds{i},1));
    end
    
    disp([num2str(erg/5) ' with ' num2str(lambda)]);
end

%% endresult
lambda = 0.01;
ids = cell2mat(imgIds(1:4)');
trainingset = X(:,ids);
labels = database.gender(ids);
[w b info] = vl_svmtrain(trainingset, labels, lambda, 'MaxNumIterations', maxIter);
result = w'*testset+b;
result(result>0) = 1;
result(result<0) = -1;
r = database.gender(imgIds{5}) == result';
sum(r)/ size(imgIds{5},1)
% test data

% save results

% pick best C value