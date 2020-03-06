load('ADtrainingDataSetsFull');
males = strcmp(trainingSetFullnone.GENDER,'Male');
trainingSetFullnone.GENDER(males) = {1};
trainingSetFullnone.GENDER(~males) = {0};
trainingSetFullnone.GENDER = cell2mat(trainingSetFullnone.GENDER);
trainingSetFullMaxMinNorm.GENDER = trainingSetFullnone.GENDER;
trainingSetFullZScoreNorm.GENDER = trainingSetFullnone.GENDER;
%% no normalization
features = trainingSetFullnone(:,3:end-1);
% features = trainingSetFullZScoreNorm(:,3:end-1);
features.MMSE_bl_healthy_diff = [];
truth = trainingSetFullnone.Diagnosis;
variables = features.Properties.VariableNames;

% single feature scores
% for i = 1:size(features,2)
%     Mdl = fitcdiscr(features(:,i),truth,'CrossVal','on');
%     Losses(i) = Mdl.kfoldLoss;
% end
% RF feature ranking
paroptions = statset('UseParallel',true);
mdlRF = TreeBagger(1000,features,truth,'OOBPredictorImportance','on','Options',paroptions);%'PredictorSelection','interaction-curvature'
featImportanceRF = mdlRF.OOBPermutedPredictorDeltaError;
% [featImportanceRFRank featImportanceRFRanki] = sort(featImportanceRF);

% elim corr >.9
C = corrcoef(features{:,:});
[var1,var2] = find(abs(C) > .9);
elimVar = [];
for i = 1:length(var1);
    if var1(i) ~= var2(i);
        if ~ismember(var1(i),elimVar) && ~ismember(var2(i),elimVar);
           vars = [var1(i),var2(i)];
           [a, ind] = min([featImportanceRF(var1(i)),featImportanceRF(var2(i))]); % edit
           elimVar(i) = vars(ind);
        end
    end
end
elimVar=elimVar(elimVar>0);
featImportanceRF(elimVar) = 0; % edit

% take top feats
[LossesSorted, LossesSortedI] = sort(featImportanceRF,'descend'); % edit
topFeaturesI = LossesSortedI(1:9); 
features2 = features(:,topFeaturesI);
variables2 = variables(topFeaturesI);

varsUsed = cell(1,511);
Losses2 = ones(10,511);

for z = 1:10
c = 1;
for i=1:length(variables2);
    combos = nchoosek(variables2,i);
    for j = 1:size(combos,1);
        mdl=fitcdiscr(features2(:,combos(j,:)), truth,'CrossVal','on');
        Losses2(z,c) = mdl.kfoldLoss;
        varsUsed{c} = combos(j,:);
        c=c+1;
        [c z]
    end
end
end

Losses2Mean = mean(Losses2);
[Losses2Sorted Losses2SortedI] = sort(Losses2Mean);
topModelsI = Losses2SortedI(1:30); 
topModelsVars = varsUsed(topModelsI);
%% Predictions
load('ADtestingDataSetsFull');
males = strcmp(testingSetFullnone.GENDER,'Male');
testingSetFullnone.GENDER(males) = {1};
testingSetFullnone.GENDER(~males) = {0};
testingSetFullnone.GENDER = cell2mat(testingSetFullnone.GENDER);
testingSetFullMaxMinNorm.GENDER = testingSetFullnone.GENDER;
testingSetFullZScoreNorm.GENDER = testingSetFullnone.GENDER;
% no normalization
featuresTest = testingSetFullnone(:,2:end-1);
featuresTest.MMSE_bl_healthy_diff = [];
featuresTest2 = featuresTest(:,topFeaturesI);
%% generate meta features
for z = 1:10
scoreFeats = [];
scoreTestFeats = [];
predictionFeats = [];
predictionTestFeats = [];
for i = 1:30
    MdlDisc = fitcdiscr(features2(:,topModelsVars{i}),truth,'CrossVal','on');
    MDL2 = fitcdiscr(features2(:,topModelsVars{i}),truth);
    L(z,i) = MdlDisc.kfoldLoss;
    [predictions,scores] = MdlDisc.kfoldPredict;
    [testPredictions scoresTest] = predict(MDL2,featuresTest(:,topModelsVars{i}));%(:,topModelsVars{i})
    scoreTestFeats = [scoreTestFeats scoresTest];
    scoreFeats = [scoreFeats scores];
    predictionFeats = [predictionFeats predictions];
    predictionTestFeats = [predictionTestFeats testPredictions];
end
end
Lmean = mean(L);
[LFsort LFi] = sort(Lmean);
FeatsFf = LFi(1:10)*4;
FeatsI = [(FeatsFf(1)-3):FeatsFf(1) ,   (FeatsFf(2)-3):FeatsFf(2),    (FeatsFf(3)-3):FeatsFf(3),    (FeatsFf(4)-3):FeatsFf(4),    (FeatsFf(5)-3):FeatsFf(5)];%,    ...
%     (FeatsFf(6)-3):FeatsFf(6),    (FeatsFf(7)-3):FeatsFf(7),    (FeatsFf(8)-3):FeatsFf(8),    (FeatsFf(9)-3):FeatsFf(9),    (FeatsFf(10)-3):FeatsFf(10)];
% FeatsIp = LFi(1:5);
% stackFeatures = predictionFeats(:,FeatsIp);
stackFeatures = scoreFeats(:,FeatsI);
stackFeaturesTest = scoreTestFeats(:,FeatsI);
%% Meta feature selection
% modelN  = 1:30;
% modelNCombos = nchoosek(modelN,2);
% for i = 1:length(modelNCombos)
%     m1N = modelNCombos(i,1);
%     m2N = modelNCombos(i,2);
%     % acc
%     acc1 = Lmean(m1N);
%     acc2 = Lmean(m2N);
%     accDif = abs(acc1-acc2);
%     % prediction similarity
%     pred1 = predictionFeats(:,m1N);
%     pred2 = predictionFeats(:,m2N);
%     same = strcmp(pred1,pred2);
%     percSame = sum(same)/length(same);
%     % combine scores
%     modelScore(i) = (1-accDif) + (2*(1-percSame));
% end
% 
% % get the best models
% [modelScoreSort modelScoreSortI] = sort(modelScore,'descend');
% bestModel = [];
% i=1;
% while length(bestModel) < 4
%     j = modelScoreSortI(i);
%     Mi = modelNCombos(j,:);
%     bestModel = [bestModel,Mi];
%     bestModel = unique(bestModel);
%     i=i+1;
% end
% 
% FeatsFf = bestModel*4;
% finalScoreFeatsI = [(FeatsFf(1)-3):FeatsFf(1) ,   (FeatsFf(2)-3):FeatsFf(2)];%,    (FeatsFf(3)-3):FeatsFf(3),    ...
%     %(FeatsFf(4)-3):FeatsFf(4)];%,    (FeatsFf(5)-3):FeatsFf(5),    (FeatsFf(6)-3):FeatsFf(6)];
% FinalFeats = scoreFeats(:,finalScoreFeatsI);
% FinalTestFeats = scoreTestFeats(:,finalScoreFeatsI);
%%
FinalFeats = [stackFeatures table2array(features2)];
FinalTestFeats = [stackFeaturesTest table2array(featuresTest2)];
% Mdl1 = fitcdiscr(FinalFeats,truth);
fun = @(xtrain,ytrain,xtest,ytest)...
      (sum(~strcmp(ytest,predict(fitcdiscr(xtrain,ytrain),xtest))));
inmodel = sequentialfs(fun,FinalFeats,truth);
FinalFeats2 = FinalFeats(:,inmodel);
FinalTestFeats2 = FinalTestFeats(:,inmodel);
for z =1:100
% MdlStack = fitcdiscr(scoreFeats(:,1:20), truth,'CrossVal','on');
MdlStack = fitcdiscr(FinalFeats2, truth,'CrossVal','on');
PrdtDiscr(:,z) = MdlStack.kfoldPredict;
LL(z) = MdlStack.kfoldLoss;
end
truthInt = ones(240,1);
strcmp(truth,'HC')
truthInt(ans) = 1;
strcmp(truth,'MCI');
truthInt(ans) = 2;
strcmp(truth,'cMCI');
truthInt(ans) = 3;
strcmp(truth,'AD');
truthInt(ans) = 4;
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
1-mean(LL)
confusionmat(truthInt,kfoldFinal)
%% Final corrections
% RF correction
HCMCIcases = logical(strcmp(trainingSetFullnone.Diagnosis,'HC') + strcmp(trainingSetFullnone.Diagnosis,'MCI'));
HCMCItruth = truth(HCMCIcases);
HCMCIfeatFull = features(HCMCIcases,:);
% HCMCIfeatMeta = FinalFeats(HCMCIcases,:);
mdlRFCorrectionFull = TreeBagger(1000,HCMCIfeatFull,HCMCItruth,'Options',paroptions);
% mdlRFCorrectionMeta = TreeBagger(1000,HCMCIfeatMeta,HCMCItruth,'Options',paroptions);

for z = 1%:10
    z
    MdlStack = fitcdiscr(FinalFeats2, truth,'CrossVal','on');
    Prd = MdlStack.kfoldPredict;
    PrdFull = Prd;
%     PrdMeta = Prd;
    AccNoCor(z) = 1 - MdlStack.kfoldLoss;
    for i = 1:length(Prd)
        p = Prd(i);
        if strcmp(p,'HC') || strcmp(p,'MCI')
            ObsFull = table2array(features(i,:));
            pFull = mdlRFCorrectionFull.predict(ObsFull);
%             ObsMeta = (FinalFeats(i,:));
%             pMeta = mdlRFCorrectionMeta.predict(ObsMeta);
            PrdFull(i) = pFull;
%             PrdMeta(i) = pMeta;
        end
    end
    AccCorFull(z) = sum(strcmp(truth,PrdFull))/length(truth);
%     AccCorMeta(z) = sum(strcmp(truth,PrdMeta))/length(truth);
end
AccFullDif = AccCorFull - AccNoCor;
% AccMetaDif = AccCorMeta - AccNoCor;
[mean(AccNoCor) mean(AccCorFull)]% mean(AccCorMeta)]
[0 AccFullDif]% AccMetaDif]
[AccNoCor(1) AccCorFull(1)]

prd_test1 = PrdFull;
intPrd = zeros(size(prd_test1));
i = strcmp(prd_test1,'AD');
intPrd(i) = 4;
i = strcmp(prd_test1,'cMCI');
intPrd(i) = 3;
i = strcmp(prd_test1,'MCI');
intPrd(i) = 2;
i = strcmp(prd_test1,'HC');
intPrd(i) = 1;
confusionmat(truthInt,intPrd)

%%
MDLStack = fitcdiscr(FinalFeats2,truth);
prediction = MDLStack.predict(FinalTestFeats2);
predictionFinal = prediction;
for i = 1:length(prediction)
    p = prediction(i);
    if strcmp(p,'HC') || strcmp(p,'MCI')
        obs = table2array(featuresTest(i,:));
        pNew = mdlRFCorrectionFull.predict(obs);
        predictionFinal(i) = pNew;
    end
end
submis = table(predictionFinal);
writetable(submis,'submission_dedicated_corrections.txt')

% must convert from cell to table and then use writetable to get a text
% file to copy into excel

% scoreTestFeats = [];
% for i = 1:10
%     MDL = fitcdiscr(features(:,topModelsVars{i}),truth);
%     [predictions,scores] = MDL.predict(featuresTest(:,topModelsVars{i}));
%     scoreTestFeats = [scoreTestFeats scores];
% end

% MDLStack = fitcdiscr(scoreTestFeats,truth)





