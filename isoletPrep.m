clear;
load isolet1234.data;
load isolet5.data;
isolet = [isolet1234; isolet5];
clear isolet1234;
clear isolet5;


sel = [2,3,4,5,7,16,20,22,26];
data = [];

for i = 1:length(isolet)
    if (sum(isolet(i,end)==sel))
        data = [data; isolet(i,:)];
    end
end

    

