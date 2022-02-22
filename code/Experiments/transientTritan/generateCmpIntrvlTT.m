function cmpIntrvl = generateCmpIntrvlLSD(nCnd,nRepeats)
    
cmpIntrvl = repmat([ones([1 nRepeats/2]) zeros([1 nRepeats/2])],[nCnd 1]);
for i = 1:nCnd; cmpIntrvlperm(i,:) = randperm(nRepeats); end
for i = 1:nCnd; cmpIntrvl(i,:) = cmpIntrvl(i,cmpIntrvlperm(i,:)); end

end