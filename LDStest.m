function results = LDStest(i,g,c)

load TSVMdata;

numSplit = 40;
gammaList = [0.1 1 10 100];
CList = [1 10 100];

N = size(DATA,1);
split = floor(N/numSplit);

L = i*split+1:(i+1)*split;
UL = [1:(i*split) (i+1)*split+1:numSplit*split];

XL = DATA(L,2:end);
TL = DATA(L,1);
XUL = DATA(UL,2:end);
TUL = DATA(UL,1);

% set labels to be +1/-1
if (min(TL) == 0)
    TL = 2*TL -1;
    TUL = 2*TUL - 1;
end

opt.C = CList(c);
rho = gammaList(g);     % (cf figure 5)
YUL = lds(XL',XUL',TL,rho,opt);

results = mean( YUL.*TUL < 0 );

end