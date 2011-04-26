function results = TSVMthrombin(i,g,c)

load thrombinSelect;
load thrombinSelectTest;

gammaList = [1 0.1 0.01];
CList = [0.1 1 10 100];

XL  = thrombinSelect(:,2:end);
TL  = thrombinSelect(:,1);
XUL = thrombinSelectTest(:,2:21);
TUL = thrombinSelectTest(:,1);

args = ['-v 0 Then-t 2 -g ' num2str(gammaList(g)) ' -c ' num2str(CList(c))];

% if (min(TL) == 0)
%     TL = 2*TL -1;
%     TUL = 2*TUL - 1;
% end
% 
% opt.C = 100;
% rho = 4;
% YUL = lds(XL',XUL',TL,rho,opt);
% results = mean( YUL.*TUL < 0 );

results = exchangemcTSVM(XL, TL, XUL, TUL, args);

filename = ['resultsTSVMthrombin' num2str(i) 'i'...
    num2str(g) 'g'...
    num2str(c) 'c'...
    '.mat'];
save(filename, 'results');
exit;

end
