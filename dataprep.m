clear;

[X, T, XT, TT] = loadBinaryUSPS(2, 5);
DATA = [TT XT];

%load sonar.all-data;
%DATA = sonar(:,[end,1:end-1]);

% load newsData.mat;
% DATA = X;

% load isolet1234.data;
% load isolet5.data;
% isolet = [isolet1234; isolet5];
% sel = [2,3,4,5,7,16,20,22,26];
% DATA = [];
% for i = 1:length(isolet)
%     if (sum(isolet(i,end)==sel))
%         DATA = [DATA; isolet(i,:)];
%     end
% end
% clear i;
% DATA = DATA([1:54,145:162],:);
% DATA(:,end) = DATA(:,end)<=5;
% DATA = DATA(:,[end, 1:(end-1)]);

% load SPECTF.train;
% DATA = SPECTF;
% load SPECTF.test;
% DATA = [DATA; SPECTF];

% load text1.mat
% X = full(X);
% DATA = [y X];

% load g50c.mat;
% DATA = [y X];

% load coil20;
% DATA = [y X];
% DATA = DATA((y==3)|(y==6),:);
% DATA(:,1) = (DATA(:,1) - 3)/3;

% load SSL_set=4_data.mat;
% DATA = [y X];

% load SSL_set=9_data.mat;
% DATA = [y X];

% load SSL_set=3_data.mat;
% DATA = [y X];

% load SSL_set=1_data.mat;
% DATA = [y X];
% 
% numSplit = 10;

DATA = DATA(randperm(end),:);
% DATA = DATA(1:400,:);
% N = size(DATA,1);
% split = floor(N/numSplit);

save('TSVMdata.mat');