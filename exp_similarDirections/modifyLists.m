%modify lists for different experiments
probCons = [10 50 90];

for probI = 1:length(probCons)
    load(['list' num2str(probCons(probI)) 'prob.mat'])
    idx = find(list.coh==1);
    idxLength = length(idx);
    idxRand = randperm(idxLength);
    list.coh(idx(idxRand(1:idxLength/2))) = 0.3;
    list.coh(idx(idxRand(idxLength/2+1:end))) = 0.2;
    save(['list' num2str(probCons(probI)) 'prob.mat'], 'list')
end