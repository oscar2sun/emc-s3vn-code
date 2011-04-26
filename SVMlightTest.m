function results = SVMlightTest(i,g,c)

load TSVMdata;

numSplit = 40;
gammaList = [0.005 0.01 0.02];
CList = [0.05 0.1 0.2];

N = size(DATA,1);
split = floor(N/numSplit);

L = i*split+1:(i+1)*split;
UL = [1:(i*split) (i+1)*split+1:numSplit*split];

XL = DATA(L,2:end);
TL = DATA(L,1);
XUL = DATA(UL,2:end);
TUL = DATA(UL,1);
Z = zeros(size(TUL));
NUL = size(TUL,1);

% set labels to be +1/-1
if (min(TL) == 0)
    TL = 2*TL -1;
    TUL = 2*TUL - 1;
end

args = ['-v 0 -t 2 -g ' num2str(gammaList(g)) ' -c ' num2str(CList(c))];


model = svmlearn([XL; XUL], [TL; Z], args);
model.dval = model.loss + 0.5*model.model_length^2;
[~, predictions] = svmclassify(XUL,TUL,model);
YUL = 2*(predictions >= 0) - 1;
results(1) = sum(YUL~=TUL) / NUL;
%results(2) = model.dval;

end