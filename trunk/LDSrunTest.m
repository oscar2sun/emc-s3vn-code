clear;

i=0;
g=1;
c=1;

while true
    try
        results(i+1,g,c) = LDStest(i,g,c);
        c=c+1;
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