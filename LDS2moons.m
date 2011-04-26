function results = LDS2moons(i,g,c)
% g=100, C=10 are optimal

gammaList = [100];
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

% set labels to be +1/-1
if (min(TL) == 0)
    TL = 2*TL -1;
    TUL = 2*TUL - 1;
end

opt.C = CList(c);
rho = gammaList(g);
YUL = lds(XL',XUL',TL,rho,opt);

results = mean( YUL.*TUL < 0 );

end