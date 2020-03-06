%% A tree of forests
%% load data
% section data
randN = randperm(240);
testN = randN(1:72);
trainN = randN(72:end);
% train set
load('ADtrainingDataSetsFull');
males = strcmp(trainingSetFullnone.GENDER,'Male');
trainingSetFullnone.GENDER(males) = {1};
trainingSetFullnone.GENDER(~males) = {0};
trainingSetFullnone.GENDER = cell2mat(trainingSetFullnone.GENDER);
trainingSetFullMaxMinNorm.GENDER = trainingSetFullnone.GENDER;
trainingSetFullZScoreNorm.GENDER = trainingSetFullnone.GENDER;
% features = trainingSetFullnone(:,3:end-1);
features = trainingSetFullZScoreNorm(:,3:end-1);
features.MMSE_bl_healthy_diff = [];
truth = trainingSetFullnone.Diagnosis;
variables = features.Properties.VariableNames;
featuresTraining = features(trainN,:);
featuresTesting = features(testN,:);
truthTraining = truth(trainN);
truthTesting = truth(testN);
% test set
load('ADtestingDataSetsFull');
males = strcmp(testingSetFullnone.GENDER,'Male');
testingSetFullnone.GENDER(males) = {1};
testingSetFullnone.GENDER(~males) = {0};
testingSetFullnone.GENDER = cell2mat(testingSetFullnone.GENDER);
testingSetFullMaxMinNorm.GENDER = testingSetFullnone.GENDER;
testingSetFullZScoreNorm.GENDER = testingSetFullnone.GENDER;
featuresTest = testingSetFullZScoreNorm(:,3:end-1);
featuresTest.MMSE_bl_healthy_diff = [];
clear males
% other
paroptions = statset('UseParallel',true);
%% truth sets
ADtruth = strcmp(truthTraining,'AD');
cMCItruth = strcmp(truthTraining,'cMCI');
MCItruth = strcmp(truthTraining,'MCI');
HCtruth = strcmp(truthTraining,'HC');
split1_truth = logical(HCtruth + MCItruth); % split: HC/MCI (1) and cMCI/AD (0)
split2_truth = logical(HCtruth + ADtruth); % split: HC/AD (1) and cMCI/MCI (0)
split3_truth = logical(HCtruth + cMCItruth); % split: HC/cMCI (1) and MCI/AD (0)
HC_MCI_truth = strcmp(truthTraining(strcmp(truthTraining,'HC')|strcmp(truthTraining,'MCI')),'HC');
cMCI_AD_truth = strcmp(truthTraining(strcmp(truthTraining,'cMCI')|strcmp(truthTraining,'AD')),'cMCI');
HC_AD_truth = strcmp(truthTraining(strcmp(truthTraining,'HC')|strcmp(truthTraining,'AD')),'HC');
MCI_cMCI_truth = strcmp(truthTraining(strcmp(truthTraining,'MCI')|strcmp(truthTraining,'cMCI')),'MCI');
HC_cMCI_truth = strcmp(truthTraining(strcmp(truthTraining,'HC')|strcmp(truthTraining,'cMCI')),'HC');
MCI_AD_truth = strcmp(truthTraining(strcmp(truthTraining,'MCI')|strcmp(truthTraining,'AD')),'MCI');
%% assemble feature groupings
split1_features = featuresTraining;
split2_features = featuresTraining;
split3_features = featuresTraining;
HC_MCI_features = featuresTraining(strcmp(truthTraining,'HC')|strcmp(truthTraining,'MCI'),:);
cMCI_AD_features = featuresTraining(strcmp(truthTraining,'cMCI')|strcmp(truthTraining,'AD'),:);
HC_AD_features = featuresTraining(strcmp(truthTraining,'HC')|strcmp(truthTraining,'AD'),:);
MCI_cMCI_features = featuresTraining(strcmp(truthTraining,'MCI')|strcmp(truthTraining,'cMCI'),:);
HC_cMCI_features = featuresTraining(strcmp(truthTraining,'HC')|strcmp(truthTraining,'cMCI'),:);
MCI_AD_features = featuresTraining(strcmp(truthTraining,'MCI')|strcmp(truthTraining,'AD'),:);
%% train models
lenFull = 240;
lenHalf = 120;
% split 1
Mdl_split1 = TreeBagger(1000,split1_features,split1_truth,'OOBPrediction', 'on','Options',paroptions);
prd_split1 = Mdl_split1.oobPredict;
acc_split1 = sum(strcmp(num2str(split1_truth),prd_split1))/lenFull;
% split 2
Mdl_split2 = TreeBagger(1000,split2_features,split2_truth,'OOBPrediction', 'on','Options',paroptions);
prd_split2 = Mdl_split2.oobPredict;
acc_split2 = sum(strcmp(num2str(split2_truth),prd_split2))/lenFull;
% split 3
Mdl_split3 = TreeBagger(1000,split3_features,split3_truth,'OOBPrediction', 'on','Options',paroptions);
prd_split3 = Mdl_split3.oobPredict;
acc_split3 = sum(strcmp(num2str(split3_truth),prd_split3))/lenFull;

[acc_split1, acc_split2, acc_split3]
%% Second layer
% HC MCI
Mdl_HC_MCI = TreeBagger(1000,HC_MCI_features,HC_MCI_truth,'OOBPrediction', 'on','Options',paroptions);
prd_HC_MCI = Mdl_HC_MCI.oobPredict;
acc_HC_MCI = sum(strcmp(num2str(HC_MCI_truth),prd_HC_MCI))/lenHalf;
% cMCI AD
Mdl_cMCI_AD = TreeBagger(1000,cMCI_AD_features,cMCI_AD_truth,'OOBPrediction', 'on','Options',paroptions);
prd_cMCI_AD = Mdl_cMCI_AD.oobPredict;
acc_cMCI_AD = sum(strcmp(num2str(cMCI_AD_truth),prd_cMCI_AD))/lenHalf;
% HC AD
Mdl_HC_AD = TreeBagger(1000,HC_AD_features,HC_AD_truth,'OOBPrediction', 'on','Options',paroptions);
prd_HC_AD = Mdl_HC_AD.oobPredict;
acc_HC_AD = sum(strcmp(num2str(HC_AD_truth),prd_HC_AD))/lenHalf;
% MCI cMCI
Mdl_MCI_cMCI = TreeBagger(1000,MCI_cMCI_features,MCI_cMCI_truth,'OOBPrediction', 'on','Options',paroptions);
prd_MCI_cMCI = Mdl_MCI_cMCI.oobPredict;
acc_MCI_cMCI = sum(strcmp(num2str(MCI_cMCI_truth),prd_MCI_cMCI))/lenHalf;
% HC cMCI
Mdl_HC_cMCI = TreeBagger(1000,HC_cMCI_features,HC_cMCI_truth,'OOBPrediction', 'on','Options',paroptions);
prd_HC_cMCI = Mdl_HC_cMCI.oobPredict;
acc_HC_cMCI = sum(strcmp(num2str(HC_cMCI_truth),prd_HC_cMCI))/lenHalf;
% MCI AD
Mdl_MCI_AD = TreeBagger(1000,MCI_AD_features,MCI_AD_truth,'OOBPrediction', 'on','Options',paroptions);
prd_MCI_AD = Mdl_MCI_AD.oobPredict;
acc_MCI_AD = sum(strcmp(num2str(MCI_AD_truth),prd_MCI_AD))/lenHalf;

ACC =  [acc_split1, acc_HC_MCI, acc_cMCI_AD;
        acc_split2, acc_HC_AD, acc_MCI_cMCI;
        acc_split3, acc_HC_MCI, acc_MCI_AD]
%% testing predicitons
prd_split1_test = Mdl_split3.predict(table2array(featuresTesting));
% prd_split2_test = predict(Mdl_split2,featuresTesting);
% prd_split3_test = predict(Mdl_split3,featuresTesting);
prd_test1 = cell(size(truthTesting));
for i = 1:length(prd_split1_test)
    prd1 = prd_split1_test{i};
    feat1 = featuresTesting(i,:);
    if strcmp(prd1,'1')
        prd2 = Mdl_HC_cMCI.predict(table2array(feat1));
        if strcmp(prd2,'1')
            prdFinal = 'HC';
            prd_test1{i} = prdFinal;
        else % prd2 == 0
            prdFinal = 'cMCI';
            prd_test1{i} = prdFinal;
        end
    else % prd1 == 0
        prd2 = Mdl_MCI_AD.predict(table2array(feat1));
        if strcmp(prd2,'1')
            prdFinal = 'MCI';
            prd_test1{i} = prdFinal;
        else % prd2 == 0
            prdFinal = 'AD';
            prd_test1{i} = prdFinal;
        end
    end
end
    
acc1 = sum(strcmp(truthTesting,prd_test1))/length(truthTesting)
%% confusion mat
truthInt = ones(240,1);
strcmp(truthTesting,'HC');
truthInt(ans) = 1;
strcmp(truthTesting,'MCI');
truthInt(ans) = 2;
strcmp(truthTesting,'cMCI');
truthInt(ans) = 3;
strcmp(truthTesting,'AD');
truthInt(ans) = 4;
intPrd = zeros(size(prd_test1));
i = strcmp(prd_test1,'AD');
intPrd(i) = 4;
i = strcmp(prd_test1,'cMCI');
intPrd(i) = 3;
i = strcmp(prd_test1,'MCI');
intPrd(i) = 2;
i = strcmp(prd_test1,'HC');
intPrd(i) = 1;
intPrdFinal = mode(intPrd,2);
confusionmat(truthInt,intPrdFinal)










