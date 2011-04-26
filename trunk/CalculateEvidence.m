function Q = CalculateEvidence(dval, K, C, a, supportIdx)
%CalculateEvidence returns Q(Y|X) by using 
% a laplace aproximation to the posterior

aSupp = a(supportIdx);
Lm = 2*pi*((aSupp.*(C-aSupp)).^2);
Lm = diag(Lm);

Km = K(supportIdx, supportIdx);

D = det(eye(length(supportIdx)) + Lm*Km);

Q = dval + log(D)/2;

end

