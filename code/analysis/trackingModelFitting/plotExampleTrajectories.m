%%

load(fullfile(getpref('ColorTracking','rawDataDir'),'LS1','BMC','LS1_TRK_jburge-hubel_CGB_BMC_003.mat'));

%%

ind = 2;

figure;
hold on;
plot(S.tSec,S.tgtXmm(:,ind),'-','Color',[1 1 1].*0.7,'LineWidth',1.5);
plot(S.tSec,S.rspXmm(:,ind),'-','Color',[1 1 1].*0,'LineWidth',1.5);
set(gca,'FontSize',15);
xlabel('Time (s)');
ylabel('Position (mm)');

tInterval = 0.0167;

figure;
hold on;
plot(S.tSec(2:end),diff(S.tgtXmm(:,ind))./tInterval,'-','Color',[1 1 1].*0.7,'LineWidth',1.5);
plot(S.tSec(2:end),diff(S.rspXmm(:,ind))./tInterval,'-','Color',[1 1 1].*0,'LineWidth',1.5);
set(gca,'FontSize',15);
xlabel('Time (s)');
ylabel('Velocity (mm/s)');
