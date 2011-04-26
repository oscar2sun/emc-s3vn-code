i=0;
g=1;
c=1;

% for i = 0:9
%     for g = 1:3
%         for c = 1:3
%             filename = ['resultsTSVM' num2str(i) 'i'...
%                 num2str(g) 'g'...
%                 num2str(c) 'c'...
%                 '.mat'];
%             %    filename = ['resultsSVMlightUSPS' num2str(i) 'i.mat'];
%             try
%                 load(filename)
%                 allResults(:,:,i+1,g,c) = results;
%                 c=c+1;
%                 %        allResults(i+1,:,:) = results(i+1,:,:);
%                 %        i=i+1;
%             catch exception
%                 
%                 %         if (g==1 && c==1)
%                 %             break;
%                 %         else if c==1
%                 %                 g=1;
%                 %                 i=i+1;
%                 %             else
%                 %                 c=1;
%                 %                 g=g+1;
%                 %             end
%                 %         end
%                 %
%             end
%         end
%     end
% end

while true
    filename = ['resultsTSVM' num2str(i) 'i'...
        num2str(g) 'g'...
        num2str(c) 'c'...
        '.mat'];
    %    filename = ['resultsSVMlightUSPS' num2str(i) 'i.mat'];
    try
        load(filename)
        allResults(:,:,i+1,g,c) = results;
        c=c+1;
        %        allResults(i+1,:,:) = results(i+1,:,:);
        %        i=i+1;
    catch exception
        
        if (g==1 && c==1)
            break;
        else if c==1
                g=1;
                i=i+1;
            else
                c=1;
                g=g+1;
            end
        end        
    end    
end