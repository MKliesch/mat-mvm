function [cfg_ana] = mm_ft_ttestER(cfg_ft,cfg_ana,cfg_plot,exper,ana,files,dirs,data)
%MM_FT_TTESTER t-test between combinations of event types for ERP data
% 
% Will compare the event values in cfg_ana.conditions using FieldTrip's
% analytic-method dependent-samples T statistical function.
%
% cfg_ana.conditions should be a cell containing cells with a row strings
% of the events to compare. Instead, it can be {{'all_within_types'}} or
% {{'all_across_types'}} to automatically create pairwise comparisons of
% event values. See MM_FT_CHECKCONDITIONS for more details.
%
% See also:
%   MM_FT_CHECKCONDITIONS

if ~isfield(cfg_ft,'parameter')
  error('Must specify cfg_ft.parameter, denoting the data to test (e.g., ''avg'' or ''individual'')');
end

cfg_ft.method = 'analytic';
cfg_ft.statistic = 'depsamplesT';
cfg_ft.computestat = 'yes';
cfg_ft.computecritval = 'yes';
cfg_ft.computeprob = 'yes';
if ~isfield(cfg_ft,'tail')
  cfg_ft.tail = 0; % -1=left, 0=both, 1=right
end
if ~isfield(cfg_ft,'alpha')
  cfg_ft.alpha = 0.05;
end
if ~isfield(cfg_ft,'correctm')
  cfg_ft.correctm = 'no';
end

if ~isfield(cfg_plot,'individ_plots')
  cfg_plot.individ_plots = 0;
end
if ~isfield(cfg_plot,'line_plots')
  cfg_plot.line_plots = 0;
end

if ~isfield(cfg_ana,'excludeBadSub')
  cfg_ana.excludeBadSub = 1;
elseif isfield(cfg_ana,'excludeBadSub') && cfg_ana.excludeBadSub ~= 1
  fprintf('Must exclude bad subjects. Setting cfg_ana.excludeBadSub = 1;');
  cfg_ana.excludeBadSub = 1;
end

% get the label info for this data struct
if isfield(data.(exper.eventValues{1}).sub(1).ses(1).data,'label');
  lab = data.(exper.eventValues{1}).sub(1).ses(1).data.label;
else
  error('label information not found in data struct');
end

% set the channel information
if ~isfield(cfg_ana,'roi')
  error('Must specify either ROI names or channel names in cfg_ana.roi');
elseif isfield(cfg_ana,'roi')
  if ismember(cfg_ana.roi,ana.elecGroupsStr)
    % if it's in the predefined ROIs, get the channel numbers
    cfg_ft.channel = cat(2,ana.elecGroups{ismember(ana.elecGroupsStr,cfg_ana.roi)});
    % find the channel indices for averaging
    cfg_ana.chansel = ismember(lab,cfg_ft.channel);
    % set the string for the filename
    cfg_plot.chan_str = sprintf(repmat('%s_',1,length(cfg_ana.roi)),cfg_ana.roi{:});
  else
    % otherwise it should be the channel number(s) or 'all'
    if ~iscell(cfg_ana.roi)
      cfg_ana.roi = {cfg_ana.roi};
    end
    cfg_ft.channel = cfg_ana.roi;
    
    % find the channel indices for averaging
    if strcmp(cfg_ft.channel,'all')
      cfg_ana.chansel = ismember(lab,ft_channelselection(cfg_ft.channel,lab));
    else
      cfg_ana.chansel = ismember(lab,cfg_ft.channel);
    end
    % set the string for the filename
    cfg_plot.chan_str = sprintf(repmat('%s_',1,length(cfg_ft.channel)),cfg_ft.channel{:});
  end
end

% exclude the bad subjects from the subject count
cfg_ana.numSub = length(exper.subjects) - sum(exper.badSub);

% make sure cfg_ana.conditions is set correctly
if ~isfield(cfg_ana,'condMethod') || isempty(cfg_ana.condMethod)
  if ~iscell(cfg_ana.conditions) && (strcmp(cfg_ana.conditions,'all') || strcmp(cfg_ana.conditions,'all_across_types') || strcmp(cfg_ana.conditions,'all_within_types'))
    cfg_ana.condMethod = 'pairwise';
  elseif iscell(cfg_ana.conditions) && ~iscell(cfg_ana.conditions{1}) && length(cfg_ana.conditions) == 1 && (strcmp(cfg_ana.conditions{1},'all') || strcmp(cfg_ana.conditions{1},'all_across_types') || strcmp(cfg_ana.conditions{1},'all_within_types'))
    cfg_ana.condMethod = 'pairwise';
  elseif iscell(cfg_ana.conditions) && iscell(cfg_ana.conditions{1}) && length(cfg_ana.conditions{1}) == 1 && (strcmp(cfg_ana.conditions{1},'all') || strcmp(cfg_ana.conditions{1},'all_across_types') || strcmp(cfg_ana.conditions{1},'all_within_types'))
    cfg_ana.condMethod = 'pairwise';
  else
    cfg_ana.condMethod = [];
  end
end
cfg_ana.conditions = mm_ft_checkConditions(cfg_ana.conditions,ana,cfg_ana.condMethod);

% collect all conditions into one cell
allConds = unique(cat(2,cfg_ana.conditions{:}));

% get times, data, SEM
for evVal = 1:length(allConds)
  ev = allConds{evVal};
  cfg_ana.values.(ev) = nan(cfg_ana.numSub,length(exper.sessions));
  goodSubInd = 0;
  for sub = 1:length(exper.subjects)
    ses = 1;
    %for ses = 1:length(exper.sessions)
    if exper.badSub(sub,ses)
      fprintf('Skipping bad subject: %s\n',exper.subjects{sub});
      continue
    else
      goodSubInd = goodSubInd + 1;
      cfg_ana.timesel.(ev) = find(data.(ev).sub(sub).ses(ses).data.time >= cfg_ft.latency(1) & data.(ev).sub(sub).ses(ses).data.time <= cfg_ft.latency(2));
      cfg_ana.values.(ev)(goodSubInd,ses) = mean(mean(data.(ev).sub(sub).ses(ses).data.(cfg_ft.parameter)(cfg_ana.chansel,cfg_ana.timesel.(ev)),1),2);
    end
    %end % ses
  end % sub
  cfg_ana.sem.(ev) = std(cfg_ana.values.(ev))/sqrt(length(cfg_ana.values.(ev)));
end % evVal

% run the t-tests
for cnd = 1:length(cfg_ana.conditions)
  % set the number of conditions that we're testing
  cfg_ana.numConds = size(cfg_ana.conditions{cnd},2);
  
  if cfg_ana.numConds > 2
    error('mm_ft_ttestER:numCondsGT2','Trying to compare %s, but this is a t-test and thus can only compare 2 conditions.\n',vs_str);
  end
  
  % get the strings of all the subjects in the conditions we're testing
  cfg = [];
  cfg.conditions = cfg_ana.conditions{cnd};
  cfg.data_str = 'data';
  cfg.is_ga = 0;
  cfg.excludeBadSub = cfg_ana.excludeBadSub;
  ana_str = mm_ft_catSubStr(cfg,exper);
  
  ses = 1;
  vs_str = sprintf('%s%s',cfg_ana.conditions{cnd}{1},sprintf(repmat('vs%s',1,cfg_ana.numConds-1),cfg_ana.conditions{cnd}{2:end}));
  subj_str = sprintf('%s',ana_str.(cfg_ana.conditions{cnd}{1}){ses});
  for i = 2:cfg_ana.numConds
    subj_str = cat(2,subj_str,sprintf(',%s',ana_str.(cfg_ana.conditions{cnd}{i}){ses}));
  end
  
  % make the design matrix
  cfg_ft.design = zeros(2,cfg_ana.numSub*cfg_ana.numConds);
  % set the unit and independent variables
  cfg_ft.uvar = 1; % the 1st row in cfg_ft.design contains the units of observation (subject number)
  cfg_ft.ivar = 2; % the 2nd row in cfg_ft.design contains the independent variable (data/condition)
  for i = 1:cfg_ana.numSub
    for j = 1:cfg_ana.numConds
      subIndex = i + ((j - 1)*cfg_ana.numSub);
      cfg_ft.design(1,subIndex) = i; % UO/DV (subject #s)
      cfg_ft.design(2,subIndex) = j; % IV (condition #s)
    end
  end
  
  cfg_ana.(vs_str) = eval(sprintf('ft_timelockstatistics(cfg_ft,%s);',subj_str));
  
  % % matlab dependent samples ttest
  % cfg_ana.(vs_str).diff = cfg_ana.values.(cfg_ana.conditions{cnd}{1}) - cfg_ana.values.(cfg_ana.conditions{cnd}{2});
  % [h,p,ci,stats] = ttest(cfg_ana.(vs_str).diff,0,cfg_ft.alpha,'both'); % H0: mean = 0
end

fprintf('\n-------------------------------------\n');
fprintf('ROI: %s; Times: %.3f--%.3f s\n',strrep(cfg_plot.chan_str,'_',' '),cfg_ft.latency(1),cfg_ft.latency(2));
fprintf('-------------------------------------\n\n');

% print GA and sub avg voltages
cfg_ana.goodSub = exper.subjects(~exper.badSub);
if length(exper.subjects{1}) > 7
  tabchar = '\t';
else
  tabchar = '';
end

% ga
fprintf('GA%s%s\n',sprintf(tabchar),sprintf(repmat('\t%s',1,length(allConds)),allConds{:}));
gaStr = sprintf('GA%s',sprintf(tabchar));
for evVal = 1:length(allConds)
  if length(allConds{evVal}) > 7
    tabchar_ev = '\t';
  else
    tabchar_ev = '';
  end
  gaStr = cat(2,gaStr,sprintf('\t%.2f%s',mean(cfg_ana.values.(allConds{evVal})),sprintf(tabchar_ev)));
end
fprintf('%s\n',gaStr);
% sub avg
fprintf('Subject%s%s\n',sprintf(tabchar),sprintf(repmat('\t%s',1,length(allConds)),allConds{:}));
goodSubInd = 0;
for sub = 1:length(exper.subjects)
  ses = 1;
  %for ses = 1:length(exper.sessions)
  if exper.badSub(sub,ses)
    continue
  else
    goodSubInd = goodSubInd + 1;
    subStr = exper.subjects{sub};
    for evVal = 1:length(allConds)
      if length(allConds{evVal}) > 7
        tabchar_ev = '\t';
      else
        tabchar_ev = '';
      end
      subStr = cat(2,subStr,sprintf('\t%.2f%s',cfg_ana.values.(allConds{evVal})(goodSubInd),sprintf(tabchar_ev)));
    end
    fprintf('%s\n',subStr);
  end
  %end
end
fprintf('\n');

% print out the results
for cnd = 1:length(cfg_ana.conditions)
  % set the number of conditions that we're testing
  cfg_ana.numConds = size(cfg_ana.conditions{cnd},2);
  
  vs_str = sprintf('%s%s',cfg_ana.conditions{cnd}{1},sprintf(repmat('vs%s',1,cfg_ana.numConds-1),cfg_ana.conditions{cnd}{2:end}));
  
  % calculate Cohen's d
  
%   % METHOD 1
%   %
%   % I found this calculation method online and hobbled it together myself;
%   % I don't know if it is correct because someone on the fieldtrip list
%   % said to just divide t by the sqrt(df) (calculated below)
%   ev1 = cfg_ana.conditions{cnd}{1};
%   ev2 = cfg_ana.conditions{cnd}{2};
%   
%   std_pooled = sqrt((((length(cfg_ana.values.(ev1)) - 1) * (std(cfg_ana.values.(ev1),0)^2)) + ...
%     ((length(cfg_ana.values.(ev2)) - 1) * (std(cfg_ana.values.(ev2),0)^2))) / ...
%     (length(cfg_ana.values.(ev1)) - 1 + length(cfg_ana.values.(ev2)) - 1));
%   cohens_d = (mean(cfg_ana.values.(ev1),1) - mean(cfg_ana.values.(ev2),1)) / std_pooled;
  
  % METHOD 2
  %
  % other method mentioned on the fieldtrip email list (Rosnow &
  % Rosenthal, Effect sizes for Experimenting Psychologists, Canadian
  % Journal of Experimental Psychology, 2003, 57:3, 221-237.)
  cohens_d = cfg_ana.(vs_str).stat / sqrt(cfg_ana.(vs_str).df);
  
  fprintf('%s (M=%.3f; SEM=%.3f)\tvs %s (M=%.3f; SEM=%.3f):\tt(%d)=%.4f, p=%.10f (d=%.3f)',cfg_ana.conditions{cnd}{1},mean(cfg_ana.values.(ev1),1),cfg_ana.sem.(ev1),cfg_ana.conditions{cnd}{2},mean(cfg_ana.values.(ev2),1),cfg_ana.sem.(ev2),cfg_ana.(vs_str).df,cfg_ana.(vs_str).stat,cfg_ana.(vs_str).prob,cohens_d);
  if cfg_ana.(vs_str).prob < cfg_ft.alpha
    fprintf(' *');
  end
  fprintf('\n');
  warning('ttest:cohens_d','I do not know if these cohen''s d caluclations are correct!\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%
% Plots
%%%%%%%%%%%%%%%%%%%%%%%%%

if cfg_plot.individ_plots == 1
  % plot with all subjects on it to see the effect in each subject
  for cnd = 1:length(cfg_ana.conditions)
    ev1 = cfg_ana.conditions{cnd}{1};
    ev2 = cfg_ana.conditions{cnd}{2};
    figure
    plot([cfg_ana.values.(ev1) cfg_ana.values.(ev2)]','o-');
    xlim([0.5 2.5])
    set(gcf,'Name',sprintf('%s, %.1fs--%.1f s',strrep(cfg_plot.chan_str,'_',' '),cfg_ft.latency(1),cfg_ft.latency(2)))
    title(sprintf('%s, %.1fs--%.1f s',strrep(cfg_plot.chan_str,'_',' '),cfg_ft.latency(1),cfg_ft.latency(2)));
    ylabel('Voltage (\muV)');
    set(gca,'XTickLabel',{'',ev1,'',ev2,''})
  end
end

if cfg_plot.line_plots == 1
  % do the mean amplitude line plots
  if ~isfield(cfg_plot,'ylim')
    cfg_plot.ylim = eval(sprintf('[floor(min([%s])) ceil(max([%s]))]',sprintf(repmat('mean(cfg_ana.values.%s,1) ',1,length(allConds)),allConds{:}),sprintf(repmat('mean(cfg_ana.values.%s,1) ',1,length(allConds)),allConds{:})));
  elseif isfield(cfg_plot,'ylim') && strcmp(cfg_plot.ylim,'minmax')
    cfg_plot.ylim = eval(sprintf('[floor(min([%s])) ceil(max([%s]))]',sprintf(repmat('mean(cfg_ana.values.%s,1) ',1,length(allConds)),allConds{:}),sprintf(repmat('mean(cfg_ana.values.%s,1) ',1,length(allConds)),allConds{:})));
  end
  
  % set up how the lines will look
  cfg_plot.linewidth = 2;
  cfg_plot.marksize = 10;
  cfg_plot.linespec = 'k--o';
  cfg_plot.markcolor = 'w';
  cfg_plot.errwidth = 1;
  cfg_plot.errBarEndMarkerInd = [4 5 7 8];
  cfg_plot.removeErrBarEnds = 1;
  
  if ~isfield(cfg_plot,'plot_order')
    cfg_plot.plot_order = allConds;
  end
  
  figure
  % plot the lines
  eval(sprintf('plot([%s],cfg_plot.linespec,''LineWidth'',cfg_plot.linewidth);',sprintf(repmat('mean(cfg_ana.values.%s,1) ',1,length(cfg_plot.plot_order)),cfg_plot.plot_order{:})));
  hold on
  for c = 1:length(cfg_plot.plot_order)
    % errorbars
    h = errorbar(c,mean(cfg_ana.values.(cfg_plot.plot_order{c}),1),cfg_ana.sem.(cfg_plot.plot_order{c}),cfg_plot.linespec,'LineWidth',cfg_plot.errwidth);
    % remove errorbar ends
    if cfg_plot.removeErrBarEnds
      chil = get(h,'Children');
      xdata = get(chil(2),'XData');
      ydata = get(chil(2),'YData');
      xdata(cfg_plot.errBarEndMarkerInd) = NaN;
      ydata(cfg_plot.errBarEndMarkerInd) = NaN;
      set(chil(2),'XData',xdata);
      set(chil(2),'YData',ydata);
      set(h,'Children',chil);
    end
    % plot the markers
    plot(c,mean(cfg_ana.values.(cfg_plot.plot_order{c}),1),cfg_plot.linespec,'LineWidth',cfg_plot.linewidth,'MarkerSize',cfg_plot.marksize,'MarkerFaceColor',cfg_plot.markcolor);
  end
  hold off
  
  set(gcf,'Name',sprintf('%s, %.1fs--%.1f s',strrep(cfg_plot.chan_str,'_',' '),cfg_ft.latency(1),cfg_ft.latency(2)))
  
  % make it look good
  axis([.5 (length(cfg_plot.plot_order) + .5) cfg_plot.ylim(1) cfg_plot.ylim(2)])
  xlabel('Condition');
  ylabel('Voltage (\muV)');
  set(gca,'XTick',(1:length(cfg_plot.plot_order)))
  set(gca,'XTickLabel',strrep(cfg_plot.plot_order,'_',''))
  set(gca,'YTick',(cfg_plot.ylim(1):.5:cfg_plot.ylim(2)))
  axis square
  publishfig(gcf,0);
  if files.saveFigs
    cfg_plot.figfilename = sprintf('tla_line_ga_%s%s%d_%d.%s',sprintf(repmat('%s_',1,length(cfg_plot.plot_order)),cfg_plot.plot_order{:}),cfg_plot.chan_str,cfg_ft.latency(1)*1000,cfg_ft.latency(2)*1000,files.figFileExt);
    dirs.saveDirFigsLine = fullfile(dirs.saveDirFigs,'tla_line');
    if ~exist(dirs.saveDirFigsLine,'dir')
      mkdir(dirs.saveDirFigsLine)
    end
    print(gcf,files.figPrintFormat,fullfile(dirs.saveDirFigsLine,cfg_plot.figfilename));
  end
end % cfg_plot.line_plots

end
