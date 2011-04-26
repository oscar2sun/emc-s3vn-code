function results = TSVMtest(i,g,c)

fprintf('i=%d, g=%d, c=%d\n', i, g, c);
load TSVMdata;
    
numSplit = 10;
gammaList = [0.01 0.1 1 10];
CList = [1 10 100];

N = size(DATA,1);
split = floor(N/numSplit);

% iMax = numSplit;
% gMax = length(gammaList);
% cMax = length(CList);
% 
% i = mod(procNum,iMax); % i = 0:numSplit-1
% g = mod(floor(procNum/iMax),gMax)+1; % g = 1:length(gammaList)
% c = mod(floor(floor(procNum/iMax)/gMax),cMax)+1; % c = 1:length(CList)

% for i = 0:numSplit-1
    
    L = i*split+1:(i+1)*split;
    UL = [1:(i*split) (i+1)*split+1:numSplit*split];
    
    XL = DATA(L,2:end);
    TL = DATA(L,1);
    XUL = DATA(UL,2:end);
    TUL = DATA(UL,1);
     
    % args = '-v 0 -y 0 -t 2 -g .1 -c 1';
    
    args = ['-v 0 -t 2 -g ' num2str(gammaList(g)) ' -c ' num2str(CList(c))];
    
    results = exchangemcTSVM(XL, TL, XUL, TUL, args);
    %results(:,:,start,i+1,g,c) = error;
    
% end

filename = ['resultsTSVM' num2str(i) 'i'...
                          num2str(g) 'g'...
                          num2str(c) 'c'...
                          '.mat'];
save(filename, 'results');
exit;   

end
        %     opt.C = 100; % large C performs best
        %     opt.delta = -50;
        %     opt.verb = 2;
        %     rho = 4;     % (cf figure 5)
        %     YUL = lds(XL',XUL',TL,rho,opt);
        %
        %     te(i+1) = mean( YUL.*TUL < 0 );
        
        %     cmdline = '-A 1 -W 0.01';
        %     XS = sparse([XL; XUL]);
        %     XLS = sparse(XL);
        %     %w = ones(size(XLS,2)+1,1);
        %
        %     [w,o] = svmlin(cmdline, XLS, TL);
        %
        %     XULS = sparse(XUL);
        %     [w,o] = svmlin(cmdline, XS, [], w);
        %
        %     XUL = [XUL ones(size(XUL,1),1)];
        %
        %     pred = XUL * w;
        %     pred = 2*(pred > 0) - 1;
        %     error(i+1) = sum(pred ~= TUL)/length(TUL);
        
        
        %
        %     model1 = svmlearn(XL, TL, '-t 2 -g 0.01 -c 1 -v 0');
        %     [err1, predictions] = svmclassify(XUL,TUL,model1);
        %
        %     model = svmlearn([XL; XUL], [TL; Z], '-t 0 -v 2 -c 10');
        %     [err, predictions] = svmclassify(XUL,TUL,model);
        %
        %     % create one time kernel matrix
        %     N = size(XL,1);
        %     X = XL;
        %     K = zeros(N,N);
        %     for k=1:N
        %         for j=1:N
        %             K(k,j) = svkernel('linear',X(k,:),X(j,:));
        %         end
        %     end
        %
        %     args = '-t 0 -c 1';
        %     % train svm on labelled data
        %     model2 = svmperflearn(XL, TL, args, K);
        %
        %     % use svm to label the remaining points
        %     err2 = svmperfclassify(XUL,TUL,model2,K);
        %
        %     YUL = err2 >= 0;
        %     YUL = 2*YUL - 1;
        %
        %     err3 = sum(YUL~=TUL) / size(TUL,1);
        %     % model = svmperflearn([XL; XUL],[TL; YUL], args, K);
        
