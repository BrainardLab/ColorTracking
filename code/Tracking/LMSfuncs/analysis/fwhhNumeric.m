%%

x = -1:0.0005:1;

for i = 1:100
   y(:,i) = normpdf(x,rand-0.5,0.1)'; 
end

% figure;
% plot(x,y);
% axis square;
% formatFigure('x','y');

[mu,muInd] = max(y);

%%

profile on;
for i = 1:108
    indLT = bsxfun(@lt,[1:length(x)]',muInd);
    indLT = indLT(1:max(sum(indLT,1)),:);
    yLT = y(1:size(indLT,1),:);
    yLT(~indLT)=0;
    [hh1,hh1ind] = min(abs(bsxfun(@minus,yLT,mu./2)));

    indGT = bsxfun(@gt,[1:length(x)]',muInd);
    indGT = indGT(min(sum(~indGT)):end,:);
    yGT = y(size(y,1)-size(indGT,1)+1:size(y,1),:);
    yGT(~indGT) = 0;
    [hh2,hh2indTmp] = min(abs(bsxfun(@minus,yGT,mu./2)));
    [~,muInd2GT] = max(yGT);
    hh2ind = hh2indTmp-muInd2GT+muInd+1;
end
profile off;
profile viewer; 
