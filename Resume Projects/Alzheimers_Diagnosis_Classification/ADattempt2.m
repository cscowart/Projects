%% load data set
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
% test set
load('ADtestingDataSetsFull');
males = strcmp(testingSetFullnone.GENDER,'Male');
testingSetFullnone.GENDER(males) = {1};
testingSetFullnone.GENDER(~males) = {0};
testingSetFullnone.GENDER = cell2mat(testingSetFullnone.GENDER);
testingSetFullMaxMinNorm.GENDER = testingSetFullnone.GENDER;
testingSetFullZScoreNorm.GENDER = testingSetFullnone.GENDER;
% no normalization
featuresTest = testingSetFullZScoreNorm(:,3:end-1);
featuresTest.MMSE_bl_healthy_diff = [];
clear males
%% Binarize response variable
ADtruth = strcmp(truth,'AD');
cMCItruth = strcmp(truth,'cMCI');
MCItruth = strcmp(truth,'MCI');
HCtruth = strcmp(truth,'HC');
truthArray = [ADtruth cMCItruth MCItruth HCtruth];
%% Univariate ranking of features for each 
diagCorr = zeros(4,size(features,2));
diagAUC = zeros(size(features,2),4);
% diagCorrSort = zeros(4,size(features,2));
% diagCorrFeatIndex = zeros(4,size(features,2));
for i = 1:4 % order: AD cMCI MCI HC
    caseTruth = truthArray(:,i);
    fullSet = [caseTruth features{:,:}];
    C = corrcoef(fullSet);
    C = abs(C(1,2:end));
%     [Csort, Ci] = sort(C,'descend');
    diagCorr(i,:) = C;
%     diagCorrSort(i,:) = Csort;
%     diagCorrFeatIndex = Ci;
    % AUC
    for j = 1:size(features,2)
        scores = features{:,j};
        [~,~,~,AUC] = perfcurve(caseTruth,scores,1);
        AUCfeat(j,:) = AUC;
    end
    diagAUC(:,i) = AUCfeat;
end
clear caseTruth fullSet c
%% Eliminate highly correlated features, based on output correlations
% generate independent feature sets for each diagnosis
featC = corrcoef(features{:,:});
[var1,var2] = find(abs(featC) > .9);
for z = 1:4
    corr = diagAUC(:,z);
%     corr = diagCorr(z,:);
    elimVar = [];
    for i = 1:length(var1);
        if var1(i) ~= var2(i);
            if ~ismember(var1(i),elimVar) && ~ismember(var2(i),elimVar);
                vars = [var1(i),var2(i)];
                [a, ind] = min([corr(var1(i)),corr(var2(i))]);
                elimVar(i) = vars(ind);
            end
        end
    end
    elimVars{z}=elimVar(elimVar>0);
    diagAUC(elimVars{z},z) = 0;
%     diagCorr(z,elimVars{z}) = 0;
end
[diagCsort, diagCi] = sort(diagAUC,1,'descend');
% [diagCsort, diagCi] = sort(diagCorr,2,'descend');

ADfeatures = features;
cMCIfeatures = features;
MCIfeatures = features;
HCfeatures = features;

% ADfeatures(:,diagCi(1,10:end)) = [];
% cMCIfeatures(:,diagCi(2,10:end)) = [];
% MCIfeatures(:,diagCi(3,10:end)) = [];
% HCfeatures(:,diagCi(4,10:end)) = [];
ADfeatures(:,diagCi(10:end,1)) = [];
cMCIfeatures(:,diagCi(10:end,2)) = [];
MCIfeatures(:,diagCi(10:end,3)) = [];
HCfeatures(:,diagCi(10:end,4)) = [];

ADvariables = ADfeatures.Properties.VariableNames;
cMCIvariables = cMCIfeatures.Properties.VariableNames;
MCIvariables = MCIfeatures.Properties.VariableNames;
HCvariables = HCfeatures.Properties.VariableNames;
%% exhaustive search for top model combos and model type
% functions
tic
paroptions = statset('UseParallel',true);
% AD
varsUsedAD = cell(1,511);
LdiscrAD = zeros(10,511);
% LsvmAD = zeros(10,511);
LnbAD = zeros(10,511);
LdtAD = zeros(10,511);

for z = 1:10
c = 1;
for i=1:length(ADvariables);
    combos = nchoosek(ADvariables,i);
    for j = 1:size(combos,1);
        trainingFeatures = ADfeatures(:,combos(j,:));
        mdlDiscr = fitcdiscr(trainingFeatures, ADtruth,'CrossVal','on','KFold',5);
%         mdlSVM = fitcsvm(trainingFeatures, ADtruth,'CrossVal','on','KFold',5);
        mdlNB = fitcnb(trainingFeatures, ADtruth,'CrossVal','on','KFold',5);
        mdlDT = fitctree(trainingFeatures, ADtruth,'MaxNumSplits',20,'CrossVal','on','KFold',5);
%         LdiscrAD(z,c) = mdlDiscr.kfoldLoss;
%         LsvmAD(z,c) = mdlSVM.kfoldLoss;
%         LnbAD(z,c) = mdlNB.kfoldLoss;
%         LdtAD(z,c) = mdlDT.kfoldLoss;
        [~,prdtDiscr] = mdlDiscr.kfoldPredict;
        [~,prdtNB] = mdlNB.kfoldPredict;
        [~,prdtDT] = mdlDT.kfoldPredict;
        [~,~,~,LdiscrAD(z,c)] = perfcurve(ADtruth,prdtDiscr(:,2),1);
%         LsvmAD(z,c) = perfcurve(ADtruth,prdtDiscr,1);
        [~,~,~,LnbAD(z,c)] = perfcurve(ADtruth,prdtNB(:,2),1);
        [~,~,~,LdtAD(z,c)] = perfcurve(ADtruth,prdtDT(:,2),1);
        varsUsedAD{c} = combos(j,:);
        c=c+1;
    end
end
end
LdiscrAD = mean(LdiscrAD);
% LsvmAD = mean(LsvmAD);
LnbAD = mean(LnbAD);
LdtAD = mean(LdtAD);

% cMCI
varsUsedcMCI = cell(1,511);
LdiscrcMCI = zeros(10,511);
% LsvmcMCI = zeros(10,511);
LnbcMCI = zeros(10,511);
LdtcMCI = zeros(10,511);

for z = 1:10
c = 1;
for i=1:length(cMCIvariables);
    combos = nchoosek(cMCIvariables,i);
    for j = 1:size(combos,1);
        trainingFeatures = cMCIfeatures(:,combos(j,:));
        mdlDiscr = fitcdiscr(trainingFeatures, cMCItruth,'CrossVal','on','KFold',5);
%         mdlSVM = fitcsvm(trainingFeatures, cMCItruth,'CrossVal','on','KFold',5);
        mdlNB = fitcnb(trainingFeatures, cMCItruth,'CrossVal','on','KFold',5);
        mdlDT = fitctree(trainingFeatures, cMCItruth,'MaxNumSplits',20,'CrossVal','on','KFold',5);
%         LdiscrcMCI(z,c) = mdlDiscr.kfoldLoss;
%         LsvmcMCI(z,c) = mdlSVM.kfoldLoss;
%         LnbcMCI(z,c) = mdlNB.kfoldLoss;
%         LdtcMCI(z,c) = mdlDT.kfoldLoss;
        [~,prdtDiscr] = mdlDiscr.kfoldPredict;
        [~,prdtNB] = mdlNB.kfoldPredict;
        [~,prdtDT] = mdlDT.kfoldPredict;
        [~,~,~,LdiscrcMCI(z,c)] = perfcurve(cMCItruth,prdtDiscr(:,2),1);
        [~,~,~,LnbcMCI(z,c)] = perfcurve(cMCItruth,prdtNB(:,2),1);
        [~,~,~,LdtcMCI(z,c)] = perfcurve(cMCItruth,prdtDT(:,2),1);
        varsUsedcMCI{c} = combos(j,:);
        c=c+1;
    end
end
end
LdiscrcMCI = mean(LdiscrcMCI);
% LsvmcMCI = mean(LsvmcMCI);
LnbcMCI = mean(LnbcMCI);
LdtcMCI = mean(LdtcMCI);

% MCI
varsUsedMCI = cell(1,511);
LdiscrMCI = zeros(10,511);
% LsvmMCI = zeros(10,511);
LnbMCI = zeros(10,511);
LdtMCI = zeros(10,511);

for z = 1:10
c = 1;
for i=1:length(MCIvariables);
    combos = nchoosek(MCIvariables,i);
    for j = 1:size(combos,1);
        trainingFeatures = MCIfeatures(:,combos(j,:));
        mdlDiscr = fitcdiscr(trainingFeatures, MCItruth,'CrossVal','on','KFold',5);
%         mdlSVM = fitcsvm(trainingFeatures, MCItruth,'CrossVal','on','KFold',5);
        mdlNB = fitcnb(trainingFeatures, MCItruth,'CrossVal','on','KFold',5);
        mdlDT = fitctree(trainingFeatures, MCItruth,'MaxNumSplits',20,'CrossVal','on','KFold',5);
%         LdiscrMCI(z,c) = mdlDiscr.kfoldLoss;
%         LsvmMCI(z,c) = mdlSVM.kfoldLoss;
%         LnbMCI(z,c) = mdlNB.kfoldLoss;
%         LdtMCI(z,c) = mdlDT.kfoldLoss;
        [~,prdtDiscr] = mdlDiscr.kfoldPredict;
        [~,prdtNB] = mdlNB.kfoldPredict;
        [~,prdtDT] = mdlDT.kfoldPredict;
        [~,~,~,LdiscrMCI(z,c)] = perfcurve(MCItruth,prdtDiscr(:,2),1);
        [~,~,~,LnbMCI(z,c)] = perfcurve(MCItruth,prdtNB(:,2),1);
        [~,~,~,LdtMCI(z,c)] = perfcurve(MCItruth,prdtDT(:,2),1);
        varsUsedMCI{c} = combos(j,:);
        c=c+1;
    end
end
end
LdiscrMCI = mean(LdiscrMCI);
% LsvmMCI = mean(LsvmMCI);
LnbMCI = mean(LnbMCI);
LdtMCI = mean(LdtMCI);

% HC
varsUsedHC = cell(1,511);
LdiscrHC = zeros(10,511);
% LsvmHC = zeros(10,511);
LnbHC = zeros(10,511);
LdtHC = zeros(10,511);

for z = 1:10
c = 1;
for i=1:length(HCvariables);
    combos = nchoosek(HCvariables,i);
    for j = 1:size(combos,1);
        trainingFeatures = HCfeatures(:,combos(j,:));
        mdlDiscr = fitcdiscr(trainingFeatures, HCtruth,'CrossVal','on','KFold',5);
%         mdlSVM = fitcsvm(trainingFeatures, HCtruth,'CrossVal','on','KFold',5);
        mdlNB = fitcnb(trainingFeatures, HCtruth,'CrossVal','on','KFold',5);
        mdlDT = fitctree(trainingFeatures, HCtruth,'MaxNumSplits',20,'CrossVal','on','KFold',5);
%         LdiscrHC(z,c) = mdlDiscr.kfoldLoss;
%         LsvmHC(z,c) = mdlSVM.kfoldLoss;
%         LnbHC(z,c) = mdlNB.kfoldLoss;
%         LdtHC(z,c) = mdlDT.kfoldLoss;
        [~,prdtDiscr] = mdlDiscr.kfoldPredict;
        [~,prdtNB] = mdlNB.kfoldPredict;
        [~,prdtDT] = mdlDT.kfoldPredict;
        [~,~,~,LdiscrHC(z,c)] = perfcurve(HCtruth,prdtDiscr(:,2),1);
        [~,~,~,LnbHC(z,c)] = perfcurve(HCtruth,prdtNB(:,2),1);
        [~,~,~,LdtHC(z,c)] = perfcurve(HCtruth,prdtDT(:,2),1);
        varsUsedHC{c} = combos(j,:);
        c=c+1;
    end
end
end
LdiscrHC = mean(LdiscrHC);
% LsvmHC = mean(LsvmHC);
LnbHC = mean(LnbHC);
LdtHC = mean(LdtHC);
% top models

% AD
[LdiscrADsort, LdiscrADi] = sort(LdiscrAD,'descend');
% [LsvmADsort, LsvmADi] = sort(LsvmAD);
[LnbADsort, LnbADi] = sort(LnbAD,'descend');
[LdtADsort, LdtADi] = sort(LdtAD,'descend');
topModelsL_AD = [LdiscrADsort(1:5);LnbADsort(1:5);LdtADsort(1:5)];
topModelsI_AD = [LdiscrADi(1:5);LnbADi(1:5);LdtADi(1:5)];
% ADmodels = {varsUsedAD{152};varsUsedAD{426};varsUsedAD{57};varsUsedAD{62}};
% ADclassifierType = {'svm','discr','svm'};
% cMCI
[LdiscrcMCIsort, LdiscrcMCIi] = sort(LdiscrcMCI,'descend');
% [LsvmcMCIsort, LsvmcMCIi] = sort(LsvmcMCI);
[LnbcMCIsort, LnbcMCIi] = sort(LnbcMCI,'descend');
[LdtcMCIsort, LdtcMCIi] = sort(LdtcMCI,'descend');
topModelsL_cMCI = [LdiscrcMCIsort(1:5);LnbcMCIsort(1:5);LdtcMCIsort(1:5)];
topModelsI_cMCI = [LdiscrcMCIi(1:5);LnbcMCIi(1:5);LdtcMCIi(1:5)];
% cMCImodels = {varsUsedcMCI{463};varsUsedcMCI{250};varsUsedcMCI{126};varsUsedcMCI{11}};
% cMCIclassifierType = {'discr','discr','nb','dt'};
% MCI
[LdiscrMCIsort, LdiscrMCIi] = sort(LdiscrMCI,'descend');
% [LsvmMCIsort, LsvmMCIi] = sort(LsvmMCI);
[LnbMCIsort, LnbMCIi] = sort(LnbMCI,'descend');
[LdtMCIsort, LdtMCIi] = sort(LdtMCI,'descend');
topModelsL_MCI = [LdiscrMCIsort(1:5);LnbMCIsort(1:5);LdtMCIsort(1:5)];
topModelsI_MCI = [LdiscrMCIi(1:5);LnbMCIi(1:5);LdtMCIi(1:5)];
% MCImodels = {varsUsedMCI{150};varsUsedMCI{1};varsUsedMCI{24};varsUsedMCI{17}};
% MCIclassifierType = {'dt','discr','nb'};
% HC
[LdiscrHCsort, LdiscrHCi] = sort(LdiscrHC,'descend');
% [LsvmHCsort, LsvmHCi] = sort(LsvmHC);
[LnbHCsort, LnbHCi] = sort(LnbHC,'descend');
[LdtHCsort, LdtHCi] = sort(LdtHC,'descend');
topModelsL_HC = [LdiscrHCsort(1:5);LnbHCsort(1:5);LdtHCsort(1:5)];
topModelsI_HC = [LdiscrHCi(1:5);LnbHCi(1:5);LdtHCi(1:5)];
% HCmodels = {varsUsedHC{149};varsUsedHC{292};varsUsedHC{39};varsUsedHC{1}};
% HCclassifierType = {'svm','discr','discr'};
%% get predictions for meta features
diags = {'AD','cMCI','MCI','HC'};
% classifiers = {'discr','svm','nb','dt'};
ADmodels = {varsUsedAD{94};varsUsedAD{24};varsUsedAD{150}};
cMCImodels = {varsUsedcMCI{464};varsUsedcMCI{501};varsUsedcMCI{373}};
MCImodels = {varsUsedMCI{392};varsUsedMCI{393};varsUsedMCI{156}};
HCmodels = {varsUsedHC{171};varsUsedHC{62};varsUsedHC{12}};

ADclassifierType = {'discr','discr','discr'};
cMCIclassifierType = {'discr','discr','discr'};
MCIclassifierType = {'nb','nb','nb'};
HCclassifierType = {'discr','discr','discr'};

c=1;
testStack = [];
trainStack= [];
for i = 1:4
    diagnosis = diags{i};
    switch diagnosis
        case 'AD'
            models = ADmodels;
            classifiers = ADclassifierType;
            truthB = ADtruth;
            feats = ADfeatures;
            metaFeatsTrain = [];
            metaFeatsTest = [];
        case 'cMCI'
            models = cMCImodels;
            classifiers = cMCIclassifierType;
            truthB = cMCItruth;
            feats = cMCIfeatures;
            metaFeatsTrain = [];
            metaFeatsTest = [];
        case 'MCI'
            models = MCImodels;
            classifiers = MCIclassifierType;
            truthB = MCItruth;
            feats = MCIfeatures;
            metaFeatsTrain = [];
            metaFeatsTest = [];
        case 'HC'
            models = HCmodels;
            classifiers = HCclassifierType;
            truthB = HCtruth;
            feats = HCfeatures;
            metaFeatsTrain = [];
            metaFeatsTest = [];
    end
    for j = 1:3
        modelFeatures = models{j};
        classifier = classifiers{j};
        switch classifier
            case 'discr'
                mdl = fitcdiscr(feats(:,modelFeatures),truthB,'CrossVal','on','KFold',5);
                predTrain = mdl.kfoldPredict;
                mdl2 = fitcdiscr(feats(:,modelFeatures),truthB);
                predTest = mdl2.predict(featuresTest(:,modelFeatures));
                metaFeatsTrain = [metaFeatsTrain, predTrain];
                metaFeatsTest = [metaFeatsTest, predTest];
            case 'svm'
                mdl = fitcsvm(feats(:,modelFeatures),truthB,'CrossVal','on','KFold',5);
                predTrain = mdl.kfoldPredict;
                mdl2 = fitcdiscr(feats(:,modelFeatures),truthB);
                predTest = mdl2.predict(featuresTest(:,modelFeatures));
                metaFeatsTrain = [metaFeatsTrain, predTrain];
                metaFeatsTest = [metaFeatsTest, predTest];
            case 'nb'
                mdl = fitcnb(feats(:,modelFeatures),truthB,'CrossVal','on','KFold',5);
                predTrain = mdl.kfoldPredict;
                mdl2 = fitcdiscr(feats(:,modelFeatures),truthB);
                predTest = mdl2.predict(featuresTest(:,modelFeatures));
                metaFeatsTrain = [metaFeatsTrain, predTrain];
                metaFeatsTest = [metaFeatsTest, predTest];
            case 'dt'
                mdl = fitctree(feats(:,modelFeatures),truthB,'CrossVal','on','KFold',5,'MaxNumSplits',20);
                predTrain = mdl.kfoldPredict;
                mdl2 = fitcdiscr(feats(:,modelFeatures),truthB);
                predTest = mdl2.predict(featuresTest(:,modelFeatures));
                metaFeatsTrain = [metaFeatsTrain, predTrain];
                metaFeatsTest = [metaFeatsTest, predTest];
        end
    end
    trainStack = [trainStack, metaFeatsTrain];
    testStack = [testStack, metaFeatsTest];
end
    %% evaluate stack model
trainStack = [mean(trainStack(:,10:12),2),mean(trainStack(:,7:9),2),mean(trainStack(:,4:6),2),mean(trainStack(:,1:3),2)];
% trainStack = trainStack(:,[1 2 4 5 7 8 10 11]);
% testStack = testStack(:,[1 2 4 5 6 7 9 11 12 13 14 16]);

% train and evaluate losses
LLdiscr = zeros(1,100);
LLsvm = zeros(1,100);
LLnb = zeros(1,100);
LLdt = zeros(1,100);
LLtb = zeros(1,100);
PrdtDiscr = cell(240,100); 
for z = 1:100
z
MDLdiscr = fitcdiscr(trainStack,truth,'CrossVal','on');
LLdiscr(z) = MDLdiscr.kfoldLoss;
PrdtDiscr(:,z) = MDLdiscr.kfoldPredict;
MDLsvm = fitcecoc(trainStack,truth,'CrossVal','on');
LLsvm(z) = MDLsvm.kfoldLoss;
% MDLnb = fitcnb(trainStack,truth,'CrossVal','on');
% LLnb(z) = MDLnb.kfoldLoss;
MDLdt = fitctree(trainStack, truth,'MaxNumSplits',20,'CrossVal','on');
LLdt(z) = MDLdt.kfoldLoss;
end

kfoldPredictions = zeros(size(PrdtDiscr));
i = strcmp(PrdtDiscr,'AD'); 
kfoldPredictions(i) = 4;
i = strcmp(PrdtDiscr,'cMCI');
kfoldPredictions(i) = 3;
i = strcmp(PrdtDiscr,'MCI');
kfoldPredictions(i) = 2;
i = strcmp(PrdtDiscr,'HC');
kfoldPredictions(i) = 1;
kfoldFinal = mode(kfoldPredictions,2);
discrResults = [truthInt,kfoldFinal,trainStack];
% treebagger approach
for z = 1:100
z
MDLtb = TreeBagger(1000,trainStack,truth,'OOBPrediction', 'on','Options',paroptions);
tbPred = MDLtb.oobPredict;
PrdtTB(:,z) = MDLtb.oobPredict;
LLtb(z) = 1-(sum(strcmp(truth,tbPred))/length(truth));
end
kfoldPredictions = zeros(size(PrdtTB));
i = strcmp(PrdtTB,'AD');
kfoldPredictions(i) = 4;
i = strcmp(PrdtTB,'cMCI');
kfoldPredictions(i) = 3;
i = strcmp(PrdtTB,'MCI');
kfoldPredictions(i) = 2;
i = strcmp(PrdtTB,'HC');
kfoldPredictions(i) = 1;
kfoldFinal = mode(kfoldPredictions,2);
bagResults = [truthInt,kfoldFinal,trainStack];
% mdlDiscr = fitcdiscr(trainStack,truth);
% submis = mdlDiscr.predict(testStack);
LL = [mean(LLdiscr),mean(LLsvm),mean(LLdt)];%,mean(LLtb)];

