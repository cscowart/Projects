%% Alzheimers Disease Scripts
load('ADtrainingSet');
varNames = train.Properties.VariableNames;

%% gender binary
% males = strcmp(train.GENDER,'Male');
% train.GENDER(males) = 1;
% train.GENDER(~males) = 0;

%% seperate data
AD = strcmp(train.Diagnosis,'AD');
ADcases = train(AD,:);

cMCI = strcmp(train.Diagnosis,'cMCI');
cMCIcases = train(cMCI,:);

HC = strcmp(train.Diagnosis,'HC');
HCcases = train(HC,:);

MCI = strcmp(train.Diagnosis,'MCI');
MCIcases = train(MCI,:);

%corrArray = train(:,2:end);
diagnosisDiscr(AD) = 4;
diagnosisDiscr(cMCI) = 3;
diagnosisDiscr(MCI) = 2;
diagnosisDiscr(HC) = 1;
% train.Diagnosis = diagnosisDiscr';

%% healthy pop values
data = table2array(HCcases(:,4:end));
for i = 1:length(data);
    feature = data(:,i);
%     variableN = i + 3;
    maxV = prctile(feature,85);
    minV = prctile(feature,15);
    cleanData = feature(feature>minV & feature<maxV);
    averages(i) = mean(feature);
    stds(i) = std(feature);
end
    

%% Add new Features
% volumes in terms or total brain volume
volumefields = [cellsearch(varNames,'vol') cellsearch(varNames,'Vol')];
newVolFeats = [];
for i = 1:length(volumefields)
    variableN = volumefields{i};
    volumeTotal = train.EstimatedTotalIntraCranialVol;
    newFeatureNames{i} = [variableN,'_vol_fraction']; 
    newFeat = train.(variableN) ./ volumeTotal;
    newVolFeats = [newVolFeats, newFeat];
end
volFeatures = array2table(newVolFeats,'VariableNames',newFeatureNames);

% Difference from healthy pop
newFeatArray = [];
for i = 1:length(averages)
    trainN = i+3;
    healthyV = averages(i);
    variableName = varNames{trainN};
    variableNewName{i} = [variableName,'_healthy_diff'];
    newFeat = train{:,trainN} - healthyV; 
    newFeatArray = [newFeatArray,newFeat];
end
newFeatTableHCdiff = array2table(newFeatArray,'VariableNames',variableNewName);

% rh lh differences
p1 = 'rh';
p2 = 'lh';
fields = cellsearch(varNames,[p1,'_']);
newFeatArrayrl = [];
for i = 1:length(fields)
    featureN1 = fields{i};
    splits = strsplit(featureN1,'_');
    featureN2 = p2;
    newFeatureN = [];
    for j = 2:length(splits)
        featureN2 = [featureN2,'_',splits{j}];
        newFeatureN = [newFeatureN,splits{j},'_'];
    end
    newFeatureN = [newFeatureN,'hemi_diff'];
    newFeatVarNamesrl{i} = newFeatureN;
    feature1 = train.(featureN1);
    feature2 = train.(featureN2);
    newFeature = feature1 - feature2;
    newFeatArrayrl = [newFeatArrayrl, newFeature];
end
newFeatTablerldiff = array2table(newFeatArrayrl,'VariableNames',newFeatVarNamesrl);

% Right Left Differences
p1 = 'Right';
p2 = 'Left';
fields = cellsearch(varNames,p1);
newFeatArrayrl = [];
for i = 1:length(fields)
    featureN1 = fields{i};
    splits = strsplit(featureN1,p1);
    featureN2 = p2;
    newFeatureN = [];
    for j = 2:length(splits)
        featureN2 = [featureN2,splits{j}];
        newFeatureN = [newFeatureN,splits{j},'_hemi_diff'];
    end
    newFeatVarNamesRL{i} = newFeatureN;
    feature1 = train.(featureN1);
    feature2 = train.(featureN2);
    newFeature = feature1 - feature2;
    newFeatArrayrl = [newFeatArrayrl, newFeature];
end
newFeatTableRLdiff = array2table(newFeatArrayrl,'VariableNames',newFeatVarNamesRL);

% right and left difference
p1 = 'right';
p2 = 'left';
fields = cellsearch(varNames,[p1,'_']);
newFeatArrayrl = [];
for i = 1:length(fields)
    featureN1 = fields{i};
    splits = strsplit(featureN1,'_');
    featureN2 = p2;
    newFeatureN = [];
    for j = 2:length(splits)
        featureN2 = [featureN2,'_',splits{j}];
        newFeatureN = [newFeatureN,splits{j},'_'];
    end
    newFeatureN = [newFeatureN,'hemi_diff'];
    newFeatVarNamesrightleft{i} = newFeatureN;
    feature1 = train.(featureN1);
    feature2 = train.(featureN2);
    newFeature = feature1 - feature2;
    newFeatArrayrl = [newFeatArrayrl, newFeature];
end
newFeatTablerightleftdiff = array2table(newFeatArrayrl,'VariableNames',newFeatVarNamesrightleft);

%add tables together
hemiDiffsTable = [newFeatTablerldiff,newFeatTableRLdiff,newFeatTablerightleftdiff];


%% prep the data sets and normalize

%no normalization
trainingSetFullnone = [train,newFeatTableHCdiff,hemiDiffsTable,volFeatures];

% max and min normalization
trainingSetFullMaxMinNorm = trainingSetFullnone;
for i = 4:size(trainingSetFullnone,2)
   maxes(i) = max(trainingSetFullnone{:,i});
   mins(i) = min(trainingSetFullnone{:,i});
   trainingSetFullMaxMinNorm{:,i} = (trainingSetFullnone{:,i} - mins(i))/(maxes(i)- mins(i));
end

% z-score normalization ([-1 1] mean at 0, std 1)
trainingSetFullZScoreNorm = trainingSetFullnone;
data = trainingSetFullnone{:,4:end};
[dataZScores,mus,sigmas] = zscore(data);
trainingSetFullZScoreNorm{:,4:end} = dataZScores;
%% 4 different data sets for each diagnosis. Dummy variable for each diagnosis
% no feature engineering
ADtrain = train;
ADtrain.Diagnosis = AD;

cMCItrain = train;
cMCItrain.Diagnosis = cMCI;

HCtrain = train;
HCtrain.Diagnosis = HC;

MCItrain = train;
MCItrain.Diagnosis = MCI;

%% testing set prep
load('ADtestingSet');
varNamesTest = test.Properties.VariableNames;

%% Add new Features TEST
% volumes in terms or total brain volume
volumefields = [cellsearch(varNamesTest,'vol') cellsearch(varNamesTest,'Vol')];
newVolFeats = [];
for i = 1:length(volumefields)
    variableN = volumefields{i};
    volumeTotal = test.EstimatedTotalIntraCranialVol;
    newFeatureNames{i} = [variableN,'_vol_fraction']; 
    newFeat = test.(variableN) ./ volumeTotal;
    newVolFeats = [newVolFeats, newFeat];
end
volFeaturesTest = array2table(newVolFeats,'VariableNames',newFeatureNames);

% Difference from healthy pop
newFeatArray = [];
for i = 1:length(averages)
    testN = i+2;
    healthyV = averages(i);
    variableName = varNamesTest{testN};
    variableNewName{i} = [variableName,'_healthy_diff'];
    newFeat = test{:,testN} - healthyV; 
    newFeatArray = [newFeatArray,newFeat];
end
newFeatTableHCdiffTest = array2table(newFeatArray,'VariableNames',variableNewName);

% rh lh differences
p1 = 'rh';
p2 = 'lh';
fields = cellsearch(varNamesTest,[p1,'_']);
newFeatArrayrl = [];
for i = 1:length(fields)
    featureN1 = fields{i};
    splits = strsplit(featureN1,'_');
    featureN2 = p2;
    newFeatureN = [];
    for j = 2:length(splits)
        featureN2 = [featureN2,'_',splits{j}];
        newFeatureN = [newFeatureN,splits{j},'_'];
    end
    newFeatureN = [newFeatureN,'hemi_diff'];
    newFeatVarNamesrl{i} = newFeatureN;
    feature1 = test.(featureN1);
    feature2 = test.(featureN2);
    newFeature = feature1 - feature2;
    newFeatArrayrl = [newFeatArrayrl, newFeature];
end
newFeatTablerldiff = array2table(newFeatArrayrl,'VariableNames',newFeatVarNamesrl);

% Right Left Differences
p1 = 'Right';
p2 = 'Left';
fields = cellsearch(varNamesTest,p1);
newFeatArrayrl = [];
for i = 1:length(fields)
    featureN1 = fields{i};
    splits = strsplit(featureN1,p1);
    featureN2 = p2;
    newFeatureN = [];
    for j = 2:length(splits)
        featureN2 = [featureN2,splits{j}];
        newFeatureN = [newFeatureN,splits{j},'_hemi_diff'];
    end
    newFeatVarNamesRL{i} = newFeatureN;
    feature1 = test.(featureN1);
    feature2 = test.(featureN2);
    newFeature = feature1 - feature2;
    newFeatArrayrl = [newFeatArrayrl, newFeature];
end
newFeatTableRLdiff = array2table(newFeatArrayrl,'VariableNames',newFeatVarNamesRL);

% right and left difference
p1 = 'right';
p2 = 'left';
fields = cellsearch(varNamesTest,[p1,'_']);
newFeatArrayrl = [];
for i = 1:length(fields)
    featureN1 = fields{i};
    splits = strsplit(featureN1,'_');
    featureN2 = p2;
    newFeatureN = [];
    for j = 2:length(splits)
        featureN2 = [featureN2,'_',splits{j}];
        newFeatureN = [newFeatureN,splits{j},'_'];
    end
    newFeatureN = [newFeatureN,'hemi_diff'];
    newFeatVarNamesrightleft{i} = newFeatureN;
    feature1 = test.(featureN1);
    feature2 = test.(featureN2);
    newFeature = feature1 - feature2;
    newFeatArrayrl = [newFeatArrayrl, newFeature];
end
newFeatTablerightleftdiffTest = array2table(newFeatArrayrl,'VariableNames',newFeatVarNamesrightleft);

%add tables together
hemiDiffsTable = [newFeatTablerldiff,newFeatTableRLdiff,newFeatTablerightleftdiffTest];


%% prep the data sets and normalize

%no normalization
testingSetFullnone = [test,newFeatTableHCdiffTest,hemiDiffsTable,volFeaturesTest];

% max and min normalization
testingSetFullMaxMinNorm = testingSetFullnone;
for i = 3:size(testingSetFullnone,2)
%    maxes(i) = max(testingSetFullnone{:,i});
%    mins(i) = min(testingSetFullnone{:,i});
   testingSetFullMaxMinNorm{:,i} = (testingSetFullnone{:,i} - mins(i+1))/(maxes(i+1)- mins(i+1));
end

% z-score normalization ([-1 1] mean at 0, std 1)
testingSetFullZScoreNorm = testingSetFullnone;
for i = 3:size(testingSetFullnone,2)
   testingSetFullZScoreNorm{:,i} = (testingSetFullnone{:,i} - mus(i-2))/(sigmas(i-2));
end