function [YUL, objVal, YULbest, objValBest]...
        = MCstep(XL, TL, XUL, YUL, K, C, kernelIsLinear, ...
        temperature, numSteps, args)

    NL = size(XL,1);
    NUL = size(XUL, 1);


    if kernelIsLinear
        model = svmperflearn([XL; XUL],[TL; YUL], args, K);
        DistanceUL = svmperfclassify(XUL,YUL,model,K);
    else
        model = svmlearn([XL; XUL],[TL; YUL], args);
        model.dval = model.loss + 0.5*model.model_length^2;
        [~, DistanceUL] = svmclassify(XUL,YUL,model);
    end

    supportIdx = find(model.a~=0);
    objVal = CalculateEvidence(model.dval,K,C,model.a,supportIdx);
    objValBest = objVal;
    YULbest = YUL;

    for i = 1:numSteps
        %fprintf('\n');
        %fprintf('Inner Loop = %d', i);

        % choose a direction and create swapList of indicies to swap
        if (rand(1) >= 0.5)
            direc = 1;
        else
            direc = -1;
        end

        swapNum = randi(8);
        swapList = getSwapList(YUL, DistanceUL, direc, K, NL, NUL, swapNum);

%         sortList = sortrows([DistanceUL(direc==YUL) find(direc==YUL)],...
%             direc);
%         if (size(sortList,1) == 0)
%             continue;
%         end
%         swapPoint =climing wal sortList(1,2);
%         nearestList = sortrows([K(NL+find(direc==YUL), NL+swapPoint) find(direc==YUL)], -1);
%         swapNum = min([randi(4) size(nearestList,1)]);
%         swapList = sortList(1:swapNum,2);

        if isempty(swapList)
            fprintf('swapList is empty\n');
            continue;
        end
        
        YUL2 = YUL;
        YUL2(swapList) = -direc;

        % if one class population drops
        if (abs(mean(YUL2)) > 0.7)
            continue;
        end

        if kernelIsLinear
            model2 = svmperflearn([XL; XUL],[TL; YUL2], args, K);
        else
            model2 = svmlearn([XL; XUL],[TL; YUL2], args);
            model2.dval = model2.loss + 0.5*model2.model_length^2;
        end

        %fprintf(' dval = %5.2f', model2.dval);
        supportIdx2 = find(model2.a~=0);
        objVal2 = CalculateEvidence(model2.dval,K,C,model2.a,supportIdx2);
        %objVal2 = model2.dval;
        
%         res = 0.1;
%         xpts = (-1.5:res:2.5)';
%         ypts = (1.5:-res:-1.5)';
%         for j = 1:length(xpts)
%             [~,height(:,j)] = svmclassify([repmat(xpts(j),length(ypts),1) ypts], ...
%                 zeros(length(ypts),1), model2);
%         end
%         area = 4*ones(size(XUL,1),1);
%         area(swapList) = 30;
%         fprintf(' drawing');
%         
%         scatter(XUL(:,1), XUL(:,2), area, (0.5*(YUL2+1)));
%         hold on;
%         contour(-1.5:res:2.5, 1.5:-res:-1.5, height, (-2:2));
%         hold off;
%         pause(0.01);


        if (objVal2 < objValBest)
            objValBest = objVal2;
            YULbest = YUL2;
        end

        if (objVal2 < objVal || (rand(1) < exp(-(objVal2-objVal)/temperature)))
            %fprintf(' step taken');
            objVal = objVal2;
            YUL = YUL2;
            if kernelIsLinear
                DistanceUL = svmperfclassify(XUL,YUL2,model,K);
            else
                [~, DistanceUL] = svmclassify(XUL,YUL2,model2);
            end
        end
    end
    %fprintf('\n');
end

function swapList = getSwapList(YUL, DistanceUL, direc, K, NL, NUL, swapNum)
    sortList = sortrows([DistanceUL(direc==YUL) find(direc==YUL)], direc);
    if (size(sortList,1) == 0)
        swapList = [];
        return;
    end
    swapList(1) = sortList(1,2);
    swapNum = min(swapNum, size(sortList,1));
    if (swapNum==1)
        return;
    end
    for i = 1:(swapNum-1)
        nearestList(:,:,i)...
            = sortrows([K(NL+find(direc==YUL), NL+swapList(i))...
                        find(direc==YUL)], -1);          
        % as the point will always be closest to itself we need to remove
        % this from the nearest list
        nearestList(1:end-1,:,i) = nearestList(2:end,:,i);
        swapList(i+1) = getNextPoint(swapList, nearestList);
    end
end

function nextPoint = getNextPoint(swapList, nearestList)
    nextNearestDist = 0;
    for i = 1:length(swapList)
        if (nearestList(1,1,i) > nextNearestDist)
            nextNearestDist = nearestList(1,1,i);
            nextNearestIdx = i;
        end
    end
    nextPoint = nearestList(1,2,nextNearestIdx);
    
    % check to see if nextPoint already in swapList
    if (sum(swapList==nextPoint) == 1)  
        % if so erase that points entry and call getNextPoint again
        nearestList(1:end-1,:,nextNearestIdx) = nearestList(2:end,:,nextNearestIdx);
        nextPoint = getNextPoint(swapList, nearestList);            
    end        
end