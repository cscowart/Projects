%data science final project
clear all
clc
close all

%% Training
%%
% To load other data sets, just find and replace the proper set
load ADtrainingDataSetsFull.mat;
copyoftrainingset = trainingSetFullMaxMinNorm;
trainingsetlabels = trainingSetFullMaxMinNorm.Properties.VariableNames;


%%
% make the data set numeric
trainingSetFullMaxMinNorm.GENDER=categorical(trainingSetFullMaxMinNorm.GENDER);
trainingSetFullMaxMinNorm.Diagnosis=categorical(trainingSetFullMaxMinNorm.Diagnosis);
trainingSetFullMaxMinNorm.SUB_ID=categorical(trainingSetFullMaxMinNorm.SUB_ID);
trainingSetFullMaxMinNorm.GENDER =  grp2idx(trainingSetFullMaxMinNorm.GENDER);
trainingSetFullMaxMinNorm.Diagnosis=grp2idx(trainingSetFullMaxMinNorm.Diagnosis);
trainingSetFullMaxMinNorm.SUB_ID=grp2idx(trainingSetFullMaxMinNorm.SUB_ID);

xx=table2array(trainingSetFullMaxMinNorm);

X = xx(2:end, 3:end);
y = table2cell(copyoftrainingset(2:end,2));
colLabel = trainingsetlabels(3:end);

% Convert it into 2-class label
msk1 = strcmp(y,y{1});
y2 = y;
y2( msk1) = y(1);
y2(~msk1) = {['not ' y{1}]};

msk2 = strcmp(y,y{2});
y3 = y;
y3( msk2) = y(2);
y3(~msk2) = {['not ' y{2}]};

msk3 = strcmp(y,y{5});
y4 = y;
y4( msk3) = y(5);
y4(~msk3) = {['not ' y{5}]};

msk4 = strcmp(y,y{6});
y5 = y;
y5( msk4) = y(6);
y5(~msk4) = {['not ' y{6}]};


% cMCI vs not cMCI
% Calculate 2-class AUC using by integration of ROC 
auc_cMCI =colAUC(X,y2,'ROC');
out_cMCI = [colLabel; num2cell(auc_cMCI)];

[sorted_cMCI, index_cMCI] = sort(auc_cMCI);

% AD vs not AD
auc_AD =colAUC(X,y3,'ROC');
out_AD = [colLabel; num2cell(auc_AD)];

[sorted_AD, index_AD] = sort(auc_AD);

% HC vs not HC
auc_HC =colAUC(X,y5,'ROC');
out_HC = [colLabel; num2cell(auc_HC)];

[sorted_HC, index_HC] = sort(auc_HC);
 
% MCI vs not MCI
auc_MCI =colAUC(X,y5,'ROC');
out_MCI = [colLabel; num2cell(auc_MCI)];

[sorted_MCI, index_MCI] = sort(auc_MCI);

% Plot ROC curves for all the features 
figure
colAUC(X,y2,'abs',false);
legend(colLabel, 'Location', 'SouthEast');
title('ROC curves for cMCI and not cMCI')
xlabel('True Positive Rate');
ylabel('False Positive Rate');

figure
colAUC(X,y3,'abs',false);
legend(colLabel, 'Location', 'SouthEast');
title('ROC curves for AD and not AD')
xlabel('True Positive Rate');
ylabel('False Positive Rate');

figure
colAUC(X,y4,'abs',false)
legend(colLabel, 'Location', 'SouthEast');
title('ROC curves for HC and not HC')
xlabel('True Positive Rate');
ylabel('False Positive Rate');

figure
colAUC(X,y5,'abs',false);
legend(colLabel, 'Location', 'SouthEast');
title('ROC curves for MCI and not MCI')
xlabel('True Positive Rate');
ylabel('False Positive Rate');

% Feature selection found the top features were
% 'MMSE_bl','GENDER','right_hippocampal_fissure','lh_caudalmiddlefrontal_volume_vol_fraction','rh_fusiform_volume_vol_fraction'
% with a correlation between them of less than 0.4

%%
%svm model
w = table2cell(trainingSetFullMaxMinNorm(:,{'Diagnosis'}));
XX = trainingSetFullMaxMinNorm(:,{'MMSE_bl','GENDER','right_hippocampal_fissure','lh_caudalmiddlefrontal_volume_vol_fraction','rh_fusiform_volume_vol_fraction'});

msk12 = strcmp(w,w{1});
w2 = w;
w2( msk12) = w(1);
w2(~msk12) = {['not ' w{1}]};

msk22 = strcmp(w,w{2});
w3 = w;
w3( msk22) = w(2);
w3(~msk22) = {['not ' w{2}]};

msk32 = strcmp(w,w{5});
w4 = w;
w4( msk32) = w(5);
w4(~msk32) = {['not ' w{5}]};

msk42 = strcmp(w,w{6});
w5 = w;
w5( msk42) = w(6);
w5(~msk42) = {['not ' w{6}]};


SVMModel_cMCI = fitcsvm(XX,w2,'KernelFunction','linear','Standardize',true);
SVMModel_AD = fitcsvm(XX,w3,'KernelFunction','linear','Standardize',true);
SVMModel_HC = fitcsvm(XX,w4,'KernelFunction','linear','Standardize',true);
SVMModel_MCI = fitcsvm(XX,w5,'KernelFunction','linear','Standardize',true);

% Cross validation accuracy of svm - not working 
cvmodel_cMCI = crossval(SVMModel_cMCI);
cverror_cMCI = kfoldLoss(cvmodel_cMCI);
accuracy_cMCI = 1-cverror_cMCI;
cvmodel_AD = crossval(SVMModel_AD);
cverror_AD = kfoldLoss(cvmodel_AD);
accuracy_AD = 1-cverror_AD;
cvmodel_HC = crossval(SVMModel_HC);
cverror_HC = kfoldLoss(cvmodel_HC);
accuracy_HC = 1-cverror_HC;
cvmodel_MCI = crossval(SVMModel_MCI);
cverror_MCI = kfoldLoss(cvmodel_MCI);
accuracy_MCI = 1-cverror_MCI;

%%
% naive bayes
j = trainingSetFullMaxMinNorm(:,{'Diagnosis'});
k = trainingSetFullMaxMinNorm(:,{'MMSE_bl','GENDER','right_hippocampal_fissure','lh_caudalmiddlefrontal_volume_vol_fraction','rh_fusiform_volume_vol_fraction'});
Mdl = fitcnb(k,j);
cvmodel_naivebayes = crossval(Mdl,'kfold',10);
cverror_naivebayes = kfoldLoss(cvmodel_naivebayes);
accuracy_naivebayes = 1-cverror_naivebayes;

%% Testing
%%
load ADtestingDataSetsFull

testingSetFullMaxMinNorm.GENDER = categorical(testingSetFullMaxMinNorm.GENDER);
testingSetFullMaxMinNorm.SUB_ID = categorical(testingSetFullMaxMinNorm.SUB_ID);
testingSetFullMaxMinNorm.GENDER =  grp2idx(testingSetFullMaxMinNorm.GENDER);
testingSetFullMaxMinNorm.SUB_ID = grp2idx(testingSetFullMaxMinNorm.SUB_ID);

[label_full_test_cMCI,score_full_test_cMCI] = predict(SVMModel_cMCI,testingSetFullMaxMinNorm);
[label_full_test_AD,score_full_test_AD] = predict(SVMModel_AD,testingSetFullMaxMinNorm);
[label_full_test_HC,score_full_test_HC] = predict(SVMModel_HC,testingSetFullMaxMinNorm);
[label_full_test_MCI,score_full_test_MCI] = predict(SVMModel_MCI,testingSetFullMaxMinNorm);
[label_full_test_naivebayes,score_full_test_naivebayes] = predict(Mdl,testingSetFullMaxMinNorm);
