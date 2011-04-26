function results = TSVM2moons(i,g,c)
% g=1, C=10 are optimal

gammaList = [1];
CList = [10];

args = ['-v 0 -t 2 -g ' num2str(gammaList(g)) ' -c ' num2str(CList(c))];

%numPts = typecast(100*(2^i), 'int16');
[x,y] = GD_GenerateData(2,200,2,[0.5,0.5],0.01);
x = x';
y = 2*y-3;
DATA = [y x];

XL = [0 0; 1 0];
TL = [1; -1];
XUL = DATA(:,2:end);
TUL = DATA(:,1);

results = exchangemcTSVM(XL, TL, XUL, TUL, args);

opt.C = 100;
rho = 10;
YUL = lds(XL',XUL',TL,rho,opt);
results(5,1) = mean( YUL.*TUL < 0 );

filename = ['resultsTSVM2moons200' num2str(i) 'i'...
                          num2str(g) 'g'...
                          num2str(c) 'c'...
                          '.mat'];
save(filename, 'results');
exit;

end