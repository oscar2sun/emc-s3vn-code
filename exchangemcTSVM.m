function error = exchangemcTSVM(XL, TL, XUL, TUL, args)

if nargin < 5
    args = '-t 0 -g 1 -c 1 -v 0';
end

% defaults
showGraph = false;
kernelIsLinear = false;
kernel = 'rbf';

R = args;
while(not(isempty(R)))
    [T,R]=strtok(R);
    switch T
        case '-t'
            
            [T,R]=strtok(R);
            if (str2num(T) == 0);                
                kernelIsLinear = 1;
                kernel = 'linear';
            end
        case '-graph'
            showGraph = true;
    end
end

parm1 = 8; % args to svkernel - parm1 is sigma when kernel is rbf
parm2 = 0;
C = 10; % misclassification penalty for labelled points
Cs = 10; % penalty for unlabelled points (large number = hard margins)
numReplicas = 6; % number of simultaneous markov chains
tempLow = 0.01;    % upper and lower bounds on the temperature
tempHigh = 50;
numLoops = 60;
numSteps = 40;

% calculate temp for each replica
tempConfig = ones(numReplicas,1);
for i = 2:numReplicas
    tempConfig(i) = tempLow + (2^(i-numReplicas))*(tempHigh-tempLow);
end
tempConfig(1) = tempLow;


% set labels to be +1/-1
if (min(TL) == 0)
    TL = 2*TL -1;
    TUL = 2*TUL - 1;
end

NL = size(XL,1);
NUL = size(XUL,1);
N = NL+NUL;


% shift all values to the interval [0,1]
DATA = [XL ;XUL];
DATA = (DATA - repmat(min(DATA),N,1))...
        ./ (repmat(max(DATA),N,1)-repmat(min(DATA),N,1));
XL = DATA(1:NL,:);
XUL = DATA((NL+1):end,:);

DATA = [XL ;XUL];
DATA = (DATA - min(min(DATA)))...
        ./ (max(max(DATA))-min(min(DATA)));
XL = DATA(1:NL,:);
XUL = DATA((NL+1):end,:);


% create one time kernel matrix
X = [XL;XUL];
K = zeros(N,N);
for i=1:N
    fprintf('Calculating kernel matrix %d/%d\n', i, N);
    for j=i:N
        K(i,j) = svkernel(kernel,X(i,:),X(j,:),parm1,parm2);
        K(j,i) = K(i,j);
    end
end
    
% train svm on labelled data
if kernelIsLinear
    model = svmperflearn(XL, TL, args, K);
else
    model = svmlearn(XL, TL, '-t 0 -g 0.1 -c 10 -v 0');
    model.dval = model.loss + 0.5*model.model_length^2;
end
fprintf('labelled dval = %d\n', model.dval);

% use svm to label the remaining points
if kernelIsLinear
    predictions = svmperfclassify(XUL,TUL,model,K);
else
    [error, predictions] = svmclassify(XUL,TUL,model);
end
YUL = predictions >= 0;
YUL = 2*YUL - 1;

% train svm on starting configuration
if kernelIsLinear
    model = svmperflearn([XL; XUL], [TL; YUL], args, K);
else
    model = svmlearn([XL; XUL],[TL; YUL], args);
    model.dval = model.loss + 0.5*model.model_length^2;
end
fprintf('initial dval = %d\n', model.dval);

error(1,1) = sum(YUL~=TUL) / NUL;
error(1,2) = model.dval;

YULbest = YUL;
supportIdx = find(model.a~=0);
objValBest = CalculateEvidence(model.dval,K,C,model.a,supportIdx);
%objValBest = model.dval;
YULconfig = repmat(YUL, 1, numReplicas);
YULconfig2 = repmat(YUL, 1, numReplicas);
objValConfig = repmat(objValBest, 1, numReplicas);
objValConfig2 = repmat(objValBest, 1, numReplicas);
offset = 0;

for i = 1:numLoops
    
    fprintf('\nOuter Loop = %d\n', i);
    
    for j = 1:numReplicas
        [YULconfig(:,j), objValConfig(j), YULconfig2(:,j), objValConfig2(j)] = ...
            MCstep(XL, TL, XUL, YULconfig(:,j), K, C, kernelIsLinear, ...
            tempConfig(j), numSteps, args);
        if (objValConfig2(j) < objValBest)
            objValBest = objValConfig2(j);
            YULbest = YULconfig2(:,j);
        end
    end
    
    % compare pairs (1,2)(3,4) then compare (2,3)(4,5) on next pass
    pos1 = offset + 1;
    while pos1+1 <= numReplicas
        pos2 = pos1+1;
        delta = (1/tempConfig(pos2) - 1/tempConfig(pos1))...
            *(objValConfig(pos1) - objValConfig2(pos2));
        
        if (delta <= 0 || rand(1) < exp(-delta))
            fprintf('\nswapping (%d,%d)\n', pos1, pos2);
            temp = YULconfig(:,pos1);
            YULconfig(:,pos1) = YULconfig2(:,pos2);
            YULconfig(:,pos2) = temp;
            temp = objValConfig(pos1);
            objValConfig(pos1) = objValConfig2(pos2);
            objValConfig(pos2) = temp;
        end
        pos1 = pos1+2;
    end
    offset = 1-offset;
    
end

error(2,1) = sum(YULbest~=TUL) / NUL;

if kernelIsLinear
    model = svmperflearn([XL; XUL], [TL; YULbest], args, K);
else
    model = svmlearn([XL; XUL],[TL; YULbest], args);
    model.dval = model.loss + 0.5*model.model_length^2;
end
error(2,2) = model.dval;

if showGraph
    res = 0.1;
    xpts = (-1.5:res:2.5)';
    ypts = (1.5:-res:-1.5)';
    height = zeros(length(ypts),length(xpts));
    for j = 1:length(xpts)
        [~,height(:,j)] = svmclassify([repmat(xpts(j),length(ypts),1) ypts], ...
            zeros(length(ypts),1), model);
    end
    area = 4*ones(size(XUL,1),1);
    scatter(XUL(:,1), XUL(:,2), area, (0.5*(YULbest+1)));
    hold on;
    contour(-1.5:res:2.5, 1.5:-res:-1.5, height, (-2:2));
    hold off;
    % pause;
end

Z = zeros(size(TUL));
model = svmlearn([XL; XUL], [TL; Z], args);
model.dval = model.loss + 0.5*model.model_length^2;
[~, predictions] = svmclassify(XUL,TUL,model);
YUL = 2*(predictions >= 0) - 1;
error(3,1) = sum(YUL~=TUL) / NUL;
error(3,2) = model.dval;


if kernelIsLinear
    model = svmperflearn([XL; XUL], [TL; TUL], args, K);
    predictions = svmperfclassify(XUL, TUL, model, K);
else
    model = svmlearn([XL; XUL],[TL; TUL], args);
    model.dval = model.loss + 0.5*model.model_length^2;
    [~, predictions] = svmclassify(XUL,TUL,model);
end
YUL = 2*(predictions >= 0) - 1;
error(4,1) = sum(YUL~=TUL) / NUL;
error(4,2) = model.dval;




% [nsv alpha bias w2] = svc([XL; XUL],[TL; YULbest], kernel, C, K);
% YUL = svcoutput([XL; XUL],[TL; YULbest], XUL, 'linear', alpha, bias);
% DistanceL  = svcoutput([XL; XUL],[TL; YUL], XL,  kernel, alpha, bias, 1);
% DistanceUL = svcoutput([XL; XUL],[TL; YUL], XUL, kernel, alpha, bias, 1);
% error(3,2) = S3VMobjective(w2, C, Cs, DistanceL, DistanceUL);
%
% error(1,2) = sum(YUL ~= TUL) / size(TUL,1);
% error(2,2) = 0.5*sum(YUL(find(YUL==1)) == TUL(find(YUL==1)))/sum(TUL==1)...
%            + 0.5*sum(YUL(find(YUL~=1)) == TUL(find(YUL~=1)))/sum(TUL~=1);
%
% [nsv alpha bias w2] = svc([XL; XUL],[TL; TUL], kernel, C, K);
%
% YUL = svcoutput([XL; XUL],[TL; TUL], XUL, 'linear', alpha, bias);
% DistanceL  = svcoutput([XL; XUL],[TL; YUL], XL,  kernel, alpha, bias, 1);
% DistanceUL = svcoutput([XL; XUL],[TL; YUL], XUL, kernel, alpha, bias, 1);
% error(3,3) = S3VMobjective(w2, C, Cs, DistanceL, DistanceUL);
%
% error(1,3) = sum(YUL ~= TUL) / size(TUL,1);
% error(2,3) = 0.5*sum(YUL(find(YUL==1)) == TUL(find(YUL==1)))/sum(TUL==1)...
%            + 0.5*sum(YUL(find(YUL~=1)) == TUL(find(YUL~=1)))/sum(TUL~=1);