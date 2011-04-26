function results = SVMlightRunTest(i)

g=1;
c=1;

while true
    try        
        results(i+1,g,c) = SVMlightTest(i,g,c);
        fprintf('SVMlightTest(%d,%d,%d)',i,g,c);
        c=c+1;
    catch exception
    
        if c==1
            break;
        else 
            c=1;
            g=g+1;
        end
    
        
%         if (g==1 && c==1)
%             break;
%         else if c==1
%                 g=1;
%                 i=i+1;
%             else
%                 c=1;
%                 g=g+1;
%             end
%         end        

    end    
end

filename = ['resultsSVMlightUSPS' num2str(i) 'i.mat'];
save(filename, 'results');
exit;
end