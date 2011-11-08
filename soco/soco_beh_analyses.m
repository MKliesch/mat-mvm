figFontName = 'Arial';

subjects = {
  'SOCO001';
  'SOCO002';
  'SOCO003';
  'SOCO004';
  'SOCO005';
  'SOCO006';
  'SOCO007';
  'SOCO008';
  'SOCO009';
  'SOCO010';
  'SOCO011';
  'SOCO012';
  'SOCO013';
  'SOCO014';
  'SOCO015';
  'SOCO016';
  'SOCO017';
  'SOCO018';
  'SOCO019';
  'SOCO020';
  'SOCO021';
  'SOCO022';
  'SOCO023';
  'SOCO024';
  'SOCO025';
  'SOCO026';
  'SOCO027';
  'SOCO028';
  'SOCO029';
  'SOCO030';
  };
% SOCO002 ended early by 6(?) trials because of fire alarm

% all events
C2_RS_WIR = [0.6304 0.7093 0.9323 0.9412 0.8333 0.4957 0.8769 0.8299 0.9322 0.7662 0.7875 0.7143 0.7674 0.5345 0.9167 0.8661 0.9975 0.6 0.9263 0.6263 0.6739 0.5455 0.9737 0.8182 0.7164 0.9975 0.7812 0.7333 0.5484 0.7857];
C2_RO_WIR = [0.3269 0.566 0.6176 0.9 0.4386 0.6923 0.5269 0.5455 0.4466 0.5455 0.5 0.5312 0.475 0.45 0.4615 0.5694 0.5849 0.5192 0.4615 0.5696 0.5882 0.5412 0.5957 0.5385 0.5122 0.6 0.6019 0.625 0.4565 0.4714];
C2_F_WIR = [0.5 0.7 0.5 0.5 0.7273 0.9975 0.5135 0.7143 0.5 0.0025 0.7 0.5806 0.561 0.6471 0.5 0.6667 0.6353 0.5 0.6 0.5 0.5217 0.6 0.5312 0.3571 0.5417 0.4091 0.25 0.5773 0.4894 0.5217];

C6_RS_WIR = [0.6119 0.8 0.9048 0.8333 0.6714 0.5091 0.9059 0.8168 0.9143 0.7415 0.9519 0.7576 0.7286 0.8904 0.8148 0.9391 0.963 0.5882 0.9024 0.6306 0.6496 0.3793 0.9556 0.88 0.8056 0.6 0.76 0.7742 0.5974 0.6364];
C6_RO_WIR = [0.4795 0.4082 0.5345 0.7561 0.5 0.4773 0.6479 0.6 0.598 0.5238 0.62 0.5283 0.5263 0.6216 0.6143 0.5745 0.5417 0.551 0.4528 0.5588 0.6207 0.5263 0.6386 0.5738 0.4643 0.5676 0.4321 0.6 0.4872 0.5];
C6_F_WIR = [0.375 0.5833 0.3571 0.5769 0.6364 0.4286 0.6111 0.75 0.4615 0.3333 0.6562 0.5147 0.4091 0.5 0.3684 0.6957 0.5068 0.625 0.2105 0.0025 0.4545 0.4545 0.4828 0.4583 0.8 0.551 0.7143 0.5242 0.5581 0.525];

%% separate 2/6 colors

% setup
badSub = {'SOCO002','SOCO003','SOCO004','SOCO006','SOCO007','SOCO018','SOCO019','SOCO026'};
chanceVec = 0.5*ones(1,sum(~ismember(subjects,badSub)));

C2_RS_avg = mean(C2_RS_WIR(~ismember(subjects,badSub)));
C2_RO_avg = mean(C2_RO_WIR(~ismember(subjects,badSub)));
C2_F_avg = mean(C2_F_WIR(~ismember(subjects,badSub)));

C2_RS_sem = std(C2_RS_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));
C2_RO_sem = std(C2_RO_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));
C2_F_sem = std(C2_F_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));

C6_RS_avg = mean(C6_RS_WIR(~ismember(subjects,badSub)));
C6_RO_avg = mean(C6_RO_WIR(~ismember(subjects,badSub)));
C6_F_avg = mean(C6_F_WIR(~ismember(subjects,badSub)));

C6_RS_sem = std(C6_RS_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));
C6_RO_sem = std(C6_RO_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));
C6_F_sem = std(C6_F_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));

[h,p,ci,stats] = ttest(C2_RS_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('C2_RS_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(C2_RS_avg),stats.df,stats.tstat,p);
[h,p,ci,stats] = ttest(C2_RO_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('C2_RO_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(C2_RO_avg),stats.df,stats.tstat,p);
[h,p,ci,stats] = ttest(C2_F_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('C2_F_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(C2_F_avg),stats.df,stats.tstat,p);

[h,p,ci,stats] = ttest(C6_RS_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('C6_RS_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(C6_RS_avg),stats.df,stats.tstat,p);
[h,p,ci,stats] = ttest(C6_RO_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('C6_RO_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(C6_RO_avg),stats.df,stats.tstat,p);
[h,p,ci,stats] = ttest(C6_F_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('C6_F_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(C6_F_avg),stats.df,stats.tstat,p);

bw_groupnames = {'Rem. Src.';'Rem. Other';'Familiar'};
bw_title = 'Proportion of Source Correct responses';
bw_legend = {'2 Colors','6 Colors'};
bw_colormap = 'gray';
bw_data = [C2_RS_avg, C6_RS_avg; C2_RO_avg, C6_RO_avg; C2_F_avg, C6_F_avg];
bw_errors = [C2_RS_sem, C6_RS_sem; C2_RO_sem, C6_RO_sem; C2_F_sem, C6_F_sem];
bw_xlabel = 'RK Response';
bw_ylabel = 'Proportion Correct';

figure
h = barweb(bw_data,bw_errors,[],bw_groupnames,bw_title,bw_xlabel,bw_ylabel,bw_colormap,[],bw_legend);
set(h.legend,'Location','NorthEast');
axis([0.5 3.5 0 1]);
publishfig(gcf,0,[],[],figFontName);
hold on
plot([0.5 3.5], [0.5 0.5],'r--','LineWidth',2); % horiz chance line
print(gcf,'-dpng','~/Desktop/SOCO_C2_C6_RS_RO_F_accuracy');
print(gcf,'-depsc2','~/Desktop/SOCO_C2_C6_RS_RO_F_accuracy');

%% collapse across colors

badSub = {'SOCO018','SOCO026'};
chanceVec = 0.5*ones(1,sum(~ismember(subjects,badSub)));

%RS_WIR = (C2_RS_WIR + C6_RS_WIR)./2;
%RO_WIR = (C2_RO_WIR + C6_RO_WIR)./2;
%F_WIR = (C2_F_WIR + C6_F_WIR)./2;

RS_WIR = [0.6226 0.7483 0.9202 0.8644 0.7462 0.5022 0.8933 0.8237 0.9225 0.7542 0.8804 0.7333 0.75 0.7328 0.873 0.9031 0.975 0.5909 0.9153 0.6286 0.6603 0.451 0.9639 0.8611 0.7714 0.7857 0.7719 0.7473 0.5755 0.72];
RO_WIR = [0.416 0.4902 0.5652 0.8443 0.466 0.5571 0.5793 0.5769 0.522 0.5312 0.5526 0.5299 0.5052 0.5325 0.5407 0.5714 0.5644 0.5347 0.4565 0.5646 0.6032 0.5352 0.6158 0.5547 0.4928 0.5806 0.5272 0.6154 0.4706 0.4853];
F_WIR = [0.4231 0.625 0.4 0.5588 0.6818 0.6667 0.5455 0.7273 0.4839 0.25 0.6806 0.5462 0.5079 0.5714 0.4419 0.6875 0.5759 0.6 0.4103 0.3333 0.5 0.5 0.5082 0.4211 0.5862 0.507 0.6111 0.5475 0.5222 0.5238];

RS_avg = mean(RS_WIR(~ismember(subjects,badSub)));
RO_avg = mean(RO_WIR(~ismember(subjects,badSub)));
F_avg = mean(F_WIR(~ismember(subjects,badSub)));

RS_sem = std(RS_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));
RO_sem = std(RO_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));
F_sem = std(F_WIR(~ismember(subjects,badSub)))/sqrt(sum(~ismember(subjects,badSub)));

[h,p,ci,stats] = ttest(RS_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('RS_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(RS_avg),stats.df,stats.tstat,p);
[h,p,ci,stats] = ttest(RO_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('RO_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(RO_avg),stats.df,stats.tstat,p);
[h,p,ci,stats] = ttest(F_WIR(~ismember(subjects,badSub)),chanceVec,0.05,'both');
fprintf('F_WIR (M=%.2f): t(%d)=%.4f, p=%.10f\n',mean(F_avg),stats.df,stats.tstat,p);

bw_groupnames = {'Rem. Src.';'Rem. Other';'Familiar'};
bw_title = 'Proportion of Source Correct responses';
bw_legend = {'Color, Collapsed'};
%bw_colormap = 'gray';
bw_colormap = [.5 .5 .5];
%bw_data = [RS_avg 0; RO_avg 0; F_avg 0];
%bw_errors = [RS_sem 0; RO_sem 0; F_sem 0];
bw_data = [RS_avg; RO_avg; F_avg];
bw_errors = [RS_sem; RO_sem; F_sem];
bw_xlabel = 'RK Response';
bw_ylabel = 'Proportion Correct';

cfg_plot = [];
% set up how the lines will look
cfg_plot.linewidth = 2;
cfg_plot.errwidth = 2;
cfg_plot.errspec = 'k.';

figure
% plot the stuff
bar(bw_data,'LineWidth',cfg_plot.linewidth);
colormap(bw_colormap);
hold on
errorbar(bw_data,bw_errors,cfg_plot.errspec,'LineWidth',cfg_plot.errwidth);
% set up the information
set(gca, 'XTickLabel', bw_groupnames, 'box', 'off', 'ticklength', [0 0]);
legend(bw_legend,'Location','NorthEast');
legend boxoff
axis([0.5 3.5 0 1]);
title(bw_title);
xlabel(bw_xlabel)
ylabel(bw_ylabel)
publishfig(gcf,0,[],[],figFontName);
% horiz chance line
plot([0.5 3.5], [0.5 0.5],'r--','LineWidth',2);
hold off
% print it
print(gcf,'-dpng','~/Desktop/SOCO_RS_RO_F_accuracy');
print(gcf,'-depsc2','~/Desktop/SOCO_RS_RO_F_accuracy');

% figure
% bw_groupnames = {'Rem. Src.';'Rem. Other';'Familiar'};
% bw_title = 'Proportion of Source Correct responses';
% bw_legend = {'Color'};
% %bw_colormap = 'gray';
% bw_colormap = [.5 .5 .5];
% bw_data = [RS_avg 0; RO_avg 0; F_avg 0];
% bw_errors = [RS_sem 0; RO_sem 0; F_sem 0];
% h = barweb(bw_data,bw_errors,[],bw_groupnames,bw_title,[],[],bw_colormap,[],bw_legend);
% set(h.legend,'Location','NorthEast');
% axis([0.5 3.5 0 1]);
% publishfig(gcf,0,[],[],figFontName);
% hold on
% plot([0.5 3.5], [0.5 0.5],'r--','LineWidth',2); % horiz chance line
% print(gcf,'-dpng','~/Desktop/SOCO_RS_RO_F_accuracy');
