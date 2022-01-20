clear all;

nTrials = 10;
%%
for ii = 1:nTrials
    fprintf('Press either the ''A'' or ''Y'' button: ')
    resp(ii) = getGamepadResp2AFC;
    fprintf('%1.0f\n',resp(ii));
end
fprintf('Done\n')
