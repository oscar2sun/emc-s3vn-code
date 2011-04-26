iMax = 10;
gMax = 3;
cMax = 2;
for procNum = 1:60
    i = mod(procNum,iMax);
    g = mod(floor(procNum/iMax),gMax)+1;
    c = mod(floor(floor(procNum/iMax)/gMax),cMax)+1; 
    fprintf('%d %d %d\n', i, g, c);
end