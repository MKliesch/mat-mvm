function [events,goodEv] = ns_addArtifactInfo(dataroot,subject,session,nsEvFilters,overwriteArtFields)
%NS_ADDARTIFACTINFO Add NS artifact information to a PyEPL event structure
%for doing behavioral analyses on the artifact-free subset of events
%
% [events,goodEv] = ns_addArtifactInfo(dataroot,subject,session,nsEvFilters,overwriteArtFields)
%
% Expects rereferenced data with 129 channels (in the bci file)
%
% create the bci file from the pare average rereferenced files (step 7)
% using the export metadata NS function. 'segment information' exports the
% bci file.
%
% dataroot is: /Volumes/data/experiment/eeg/processing/time/ (or something
% like that, whatever contains ns_bci)
%
% assumes events are stored in
% /Volumes/data/experiment/eeg/behavioral/subject/session/events/events.mat
% (gets automatically created from dataroot)
%
% assumes bci files are stored in dataroot/ns_bci/
%
% TODO: Can I also bring the more-detailed information into FT?  Maybe
% create an event struct with events sorted alphabetically by category (and
% within that sort by time) of only the good events.
%
% See inline code for some better explanations of what this function does

if nargin < 5
  overwriteArtFields = 0;
end

nChan = 129;
format_str = ['%s%d8%d8%s',repmat('%d8',[1,nChan*2]),'%s'];
%format_str = ['%s%s%s%s',repmat('%s',[1,nChan*2]),'%s'];

% % debug
% dataroot = '/Volumes/curranlab/Data/COSI/eeg/eppp/-1000_2000';
% subject = 'COSI001';
% session = 'session_0';

% assuming events are stored in
% eperiment/eeg/behavioral/subject/session/events/events.mat
behroot = fullfile(dataroot(1:strfind(dataroot,'eeg')+2),'behavioral');

% load in the newest PyEPL events
eventsDir = fullfile(behroot,subject,session,'events');
fprintf('Loading events for %s, %s...\n',subject,session);
events = loadEvents(fullfile(eventsDir,'events.mat'));
fprintf('Done.\n');

fprintf('Getting NS artifact info for %s, %s...\n',subject,session);

% define the metadata NS export file with the session summary
summaryFile = dir(fullfile(dataroot,'ns_bci',[subject,'*.bci']));

% make sure we got only one bci file
if length(summaryFile) > 1
  if isfield(events,'nsFile')
    summaryFile = dir(fullfile(dataroot,'ns_bci',[events(1).nsFile,'.bci']));
  else
    error('More than one bci file, and no nsFile field to denote which to choose: %s',fullfile(dataroot,'ns_bci',[subject,'*.bci']));
  end
end

if ~isempty(summaryFile)
  summaryFile = fullfile(dataroot,'ns_bci',summaryFile.name);
  % read in session summary file
  fid = fopen(summaryFile,'r');
  sesSummary = textscan(fid,format_str,'Headerlines',1,'delimiter','\t');
  fclose(fid);
else
  warning([mfilename,':no_bci_file'],'MISSING FILE: %s',fullfile(dataroot,'ns_bci',[subject,'*.bci']));
  return
end

% create event struct for session summary
artEv_ns = struct('category',sesSummary{1},'status',sesSummary{4},'badChan',[],'reason',sesSummary{length(sesSummary)});
for ev = 1:length(artEv_ns)
  % if we find a bad event
  if strcmp(artEv_ns(ev).status,'bad')
    % find the channels that were bad
    for c = 1:nChan
      if sesSummary{5+(c*2-1)}(ev) == 0
        artEv_ns(ev).badChan = [artEv_ns(ev).badChan c];
      end
    end
  end
end

% make it so the event value cell array is easier to access
eventValues = nsEvFilters.eventValues;

% determine whether there are extra fields are so we can include them in
% filtering; this relies on the assumption that there are always fields for
% 'type' and 'filters'; currently any extra fields must be strings
%
% The purpose of extraFilters is to provide additional filters. The name of
% the extraFilter fild and its value (a string) correspond to this info
% in a struct. For example, if you wanted to separate two conditions, color
% and side, and the field in events.mat is 'cond', the extraFilter field
% name is cond and its value is 'color' for one condition, and cond='side'
% for the other.
fn = fieldnames(nsEvFilters.(eventValues{1}));
if sum(~ismember(fieldnames(nsEvFilters.(eventValues{1})),'filters') & ~ismember(fieldnames(nsEvFilters.(eventValues{1})),'type')) > 0
  extraFilters = fn(~ismember(fieldnames(nsEvFilters.(eventValues{1})),'filters') & ~ismember(fieldnames(nsEvFilters.(eventValues{1})),'type'));
else
  extraFilters = [];
end

% separate the NS event categories
for evVal = 1:length(eventValues)
  nsEvents.(eventValues{evVal}) = filterStruct(artEv_ns,'ismember(category,varargin{1})',eventValues{evVal});
end

% exit out if we don't want to overwriteArtFields
if isfield(events,'nsArt')
  if overwriteArtFields == 0
    fprintf('NS artifact information has already been added to this struct. Moving on.\n');
    return
  elseif overwriteArtFields == 1
    fprintf('Removing NS artifact information from this struct; will overwriteArtFields them with current information.\n');
    events = rmfield(events,{'nsArt','nsBadChan','nsBadReason'});
  end
else
  fprintf('No NS artifact information exists. Adding it.\n');
end

% initialize the count of the number of NS events we've gone through
for evVal = 1:length(eventValues)
  countAll.(eventValues{evVal}) = 0;
end

for i = 1:length(events)
  % initialize to see if we match the filter in one of the event types
  matchedFilter = 0;
  
  for evVal = 1:length(eventValues)
    % start the string to evaluate using the type field, because that will
    % always be there
    evValStr = sprintf('strcmp(''%s'',''%s'')',events(i).type,nsEvFilters.(eventValues{evVal}).type);
    % add any extra fields if necessary
    if ~isempty(extraFilters)
      for ef = 1:size(extraFilters,1)
        evValStr = sprintf('%s && strcmp(''%s'',''%s'')',evValStr,events(i).(extraFilters{ef}),nsEvFilters.(eventValues{evVal}).(extraFilters{ef}));
      end
    end
    
    % see if it matches this eventValue (and any extra fields)
    if eval(evValStr)
      % construct the filter requirements statement
      filtStr = sprintf('events(i).%s',nsEvFilters.(eventValues{evVal}).filters{1});
      % continue constructing
      if length(nsEvFilters.(eventValues{evVal}).filters) > 1
        for filt = 2:length(nsEvFilters.(eventValues{evVal}).filters)
          filtStr = cat(2,filtStr,sprintf(' && events(i).%s',nsEvFilters.(eventValues{evVal}).filters{filt}));
        end
      end
      % then see if it matches the filter requirements
      if eval(filtStr)
        % mark that we matched the filter
        matchedFilter = 1;
        % increase the count for this eventValue
        countAll.(eventValues{evVal}) = countAll.(eventValues{evVal}) + 1;
        if strcmp(nsEvents.(eventValues{evVal})(countAll.(eventValues{evVal})).status,'bad')
          % mark it as an artifact
          events(i).nsArt = 1;
          events(i).nsBadChan = nsEvents.(eventValues{evVal})(countAll.(eventValues{evVal})).badChan;
          events(i).nsBadReason = nsEvents.(eventValues{evVal})(countAll.(eventValues{evVal})).reason;
        else
          % mark it as good
          events(i).nsArt = 0;
          events(i).nsBadChan = [];
          events(i).nsBadReason = '';
        end
      end % if matches filter requirements
    end % if matches event type
  end % for each event type
  
  % if this doesn't match any of the filter requirements for any of the
  % events, then we don't want to see this event
  if matchedFilter == 0
    events(i).nsArt = -1;
    events(i).nsBadChan = [];
    events(i).nsBadReason = '';
  end
end

% badcEv = filterStruct(events,'nsArt == 1 & ismember(nsBadReason,varargin{1})','badc');
% badc = unique(getStructField(badcEv,'nsBadChan'));
% 
% eyemeyebEv = filterStruct(events,'nsArt == 1 & ismember(nsBadReason,varargin{1})','eyem,eyeb');
% eyemEv = filterStruct(events,'nsArt == 1 & ismember(nsBadReason,varargin{1})','eyem');
% eyebEv = filterStruct(events,'nsArt == 1 & ismember(nsBadReason,varargin{1})','eyeb');

% grab only the good events
goodEv = {};
for evVal = 1:length(eventValues)
  % construct the filter
  filtStr = [sprintf('nsArt == 0 & ismember(type,varargin{1})'),sprintf(repmat(' & %s',1,length(nsEvFilters.(eventValues{evVal}).filters)),nsEvFilters.(eventValues{evVal}).filters{:})];
  varargStr = sprintf('{''%s''}',nsEvFilters.(eventValues{evVal}).type);
  if ~isempty(extraFilters)
    for ef = 1:size(extraFilters,1)
      filtStr = sprintf('%s & ismember(%s,varargin{%d})',filtStr,extraFilters{ef},ef+1);
      varargStr = sprintf('%s,{''%s''}',varargStr,nsEvFilters.(eventValues{evVal}).(extraFilters{ef}));
    end
  end
  % filter the struct so we only get good events
  goodEvAll.(eventValues{evVal}) = eval(sprintf('filterStruct(events,''%s'',%s)',filtStr,varargStr));
  % concatenate good event structs together
  goodEv = cat(2,goodEv,struct2cell(goodEvAll.(eventValues{evVal})));
end
goodEv = cell2struct(goodEv,fieldnames(events),1);

% always save backup events
oldEv = flipud(dir(fullfile(eventsDir,'*events*mat*')));
if ~isempty(oldEv)
  for oe = 1:length(oldEv)
    backupfile = [fullfile(eventsDir,oldEv(oe).name),'.old'];
    fprintf('Making backup: copying %s to %s\n',fullfile(eventsDir,oldEv(oe).name),backupfile);
    
    unix(sprintf('cp %s %s',fullfile(eventsDir,oldEv(oe).name),backupfile));
    
    %saveEvents(events,backupfile);
  end
  fprintf('Done.\n');
end

% save the events
fprintf('Saving events with NS artifact information...\n');
saveEvents(events,fullfile(eventsDir,'events.mat'));
fprintf('Done.\n');
% save the good events
fprintf('Saving only good events...\n');
saveEvents(goodEv,fullfile(eventsDir,'events_good.mat'));
fprintf('Done.\n');
