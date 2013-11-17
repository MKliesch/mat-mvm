function trl = space_trialfun(cfg)

% operates using Net Station evt files

% convert single string into cell-array, otherwise intersection does not
% work as intended
if ischar(cfg.trialdef.eventvalue)
  cfg.trialdef.eventvalue = {cfg.trialdef.eventvalue};
end

% get the header and event information
ft_hdr = ft_read_header(cfg.dataset);
ft_event = ft_read_event(cfg.dataset);

% offset should be negative
offsetSamp = round(-cfg.trialdef.prestim*ft_hdr.Fs);
% duration should be 1 sample less than the whole length of an event
durationSamp = round((cfg.trialdef.poststim+cfg.trialdef.prestim)*ft_hdr.Fs) - 1;
% TODO: should this be ceil instead of round?

ns_evt = cfg.eventinfo.ns_evt;
events_all = cfg.eventinfo.events;
% expParam = cfg.eventinfo.expParam;

% initialize the trl matrix
trl = [];

% all trls need to have the same length
maxTrl = -Inf;
fn_trl_ord = fieldnames(cfg.eventinfo.trl_order);
for fn = 1:length(fn_trl_ord)
  if length(cfg.eventinfo.trl_order.(fn_trl_ord{fn})) > maxTrl
    maxTrl = length(cfg.eventinfo.trl_order.(fn_trl_ord{fn}));
  end
end
timeCols = 3;
trl_ini = -1 * ones(1, timeCols + maxTrl);

%% set up the exposure phase

cols.expo = [];
cols.expo.sub = 7;
cols.expo.ses = 9;
cols.expo.phase = 11;
cols.expo.phaseCount = 13;
cols.expo.isExp = 15;
cols.expo.trial = 17;
cols.expo.type = 19;
% cols.expo.inum = 23;
cols.expo.icat_str = 25;

% cols.expo.icat_num = 27;
% cols.expo.targ = 29;
% cols.expo.spaced = 31;
% cols.expo.lag = 33;
% cols.expo.resp_str = 35;
% cols.expo.rt = 39;
% cols.expo.keypress = 41;

%% set up the multistudy phase

cols.multistudy = [];
cols.multistudy.sub = 7;
cols.multistudy.ses = 9;
cols.multistudy.phase = 11;
cols.multistudy.phaseCount = 13;
cols.multistudy.isExp = 15;
cols.multistudy.trial = 17;

cols.multistudy.type_image = 19;
cols.multistudy.type_word = 27;

%% set up the math distractor phase

cols.distract_math = [];
cols.distract_math.sub = 7;
cols.distract_math.ses = 9;
cols.distract_math.phase = 11;
cols.distract_math.phaseCount = 13;
cols.distract_math.isExp = 15;
cols.distract_math.trial = 17;

%% set up the cued recall phase

cols.cued_recall = [];
cols.cued_recall.sub = 7;
cols.cued_recall.ses = 9;
cols.cued_recall.phase = 11;
cols.cued_recall.phaseCount = 13;
cols.cued_recall.isExp = 15;

cols.cued_recall.type = 17;
cols.cued_recall.trial = 19;

%% go through the events

for ses = 1:length(cfg.eventinfo.sessionNames)
  sesName = cfg.eventinfo.sessionNames{ses};
  sesType = find(ismember(cfg.eventinfo.sessionNames,cfg.eventinfo.sessionNames{ses}));
  
  for pha = 1:length(cfg.eventinfo.phaseNames{sesType})
    phaseName = cfg.eventinfo.phaseNames{sesType}{pha};
    phaseType = find(ismember(cfg.eventinfo.phaseNames{sesType},cfg.eventinfo.phaseNames{sesType}{pha}));
    
    switch phaseName
      
      case {'expo', 'prac_expo'}
        %% process the exposure phase
        
        fprintf('Processing %s...\n',phaseName);
        
        %expo_events = events_all.(sessionNames{ses}).(phaseName).data;
        
        %trl_order_expo = cfg.eventinfo.trl_order.(phaseName);
        
        % keep track of how many real evt events we have counted
        ec = 0;
        
        for i = 1:length(ft_event)
          if strcmp(ft_event(i).type,cfg.trialdef.eventtype)
            % found a trigger in the evt file; increment index if value is correct.
            
            %if ~ismember(event(i).value,{'epoc'})
            if ismember(ft_event(i).value,{'STIM', 'RESP', 'FIXT', 'PROM', 'REST', 'REND'})
              ec = ec + 1;
            end
            
            switch ft_event(i).value
              case 'STIM'
                if strcmp(ns_evt{cols.(phaseName).isExp}(ec),'expt') && strcmpi(ns_evt{cols.(phaseName).isExp+1}(ec),'true') &&...
                    strcmp(ns_evt{cols.(phaseName).phase}(ec),'phas') && strcmp(ns_evt{cols.(phaseName).phase+1}(ec),phaseName) &&...
                    strcmp(ns_evt{cols.(phaseName).phaseCount}(ec),'pcou') &&...
                    strcmp(ns_evt{cols.(phaseName).type}(ec),'type') && strcmp(ns_evt{cols.(phaseName).type+1}(ec),'image') &&...
                    strcmp(ns_evt{cols.(phaseName).icat_str}(ec),'icts')
                  
                  % type is not actually necessary; I don't think icat_str
                  % is either
                  
                  stimType = 'EXPO_IMAGE';
                  
                  % find the entry in the event struct
                  this_event = events_all.(sesName).(phaseName).data(...
                    [events_all.(sesName).(phaseName).data.isExp] == 1 &...
                    ismember({events_all.(sesName).(phaseName).data.phaseName},{phaseName}) &...
                    [events_all.(sesName).(phaseName).data.phaseCount] == str2double(ns_evt{cols.(phaseName).phaseCount+1}(ec)) &...
                    ismember({events_all.(sesName).(phaseName).data.type},{stimType}) &...
                    [events_all.(sesName).(phaseName).data.trial] == str2double(ns_evt{cols.(phaseName).trial+1}(ec)) ...
                    );
                  
                  if length(this_event) > 1
                    warning('More than one event found! Fix this script before continuing analysis.')
                    keyboard
                    %elseif isempty(this_event)
                    %  warning('No event found! Fix this script before continuing analysis.')
                    %  keyboard
                  elseif length(this_event) == 1
                    
                    if ~isempty(this_event.i_catStr)
                      if strcmp(this_event.i_catStr,'Faces')
                        category = 'expo_face';
                      elseif strcmp(this_event.i_catStr,'HouseInside')
                        category = 'expo_house';
                      end
                    else
                      category = '';
                    end
                    
                    phaseCount = this_event.phaseCount;
                    trial = this_event.trial;
                    stimNum = this_event.stimNum;
                    i_catNum = this_event.i_catNum;
                    targ = this_event.targ;
                    spaced = this_event.spaced;
                    lag = this_event.lag;
                    expo_response = this_event.resp;
                    cr_recog_acc = this_event.cr_recog_acc;
                    cr_recall_resp = this_event.cr_recall_resp;
                    cr_recall_spellCorr = this_event.cr_recall_spellCorr;
                    
                    rt = this_event.rt;
                    
                    % Critical: set up the event string to match eventValues
                    %evVal = sprintf('%s%s',category,rating);
                    %evVal = category;
                    evVal = 'expo_stim';
                    
                    % find where this event type occurs in the list
                    eventNumber = find(ismember(cfg.trialdef.eventvalue,evVal));
                    if isempty(eventNumber)
                      eventNumber = -1;
                    end
                    
                    % add it to the trial definition
                    this_trl = trl_ini;
                    
                    this_trl(1) = ft_event(i).sample;
                    this_trl(2) = (ft_event(i).sample + durationSamp);
                    this_trl(3) = offsetSamp;
                    
                    for to = 1:length(cfg.eventinfo.trl_order.(phaseName))
                      thisInd = find(ismember(cfg.eventinfo.trl_order.(phaseName),cfg.eventinfo.trl_order.(phaseName){to}));
                      if ~isempty(thisInd)
                        if exist(cfg.eventinfo.trl_order.(phaseName){to},'var')
                          this_trl(timeCols + thisInd) = eval(cfg.eventinfo.trl_order.(phaseName){to});
                        else
                          fprintf('variable %s does not exist!\n',cfg.eventinfo.trl_order.(phaseName){to});
                          keyboard
                        end
                      end
                    end
                    
                    % put all the trials together
                    trl = cat(1,trl,double(this_trl));
                    
                    % hardcoded old method
                    % trl = cat(1,trl,double([event(i).sample, (event(i).sample + durationSamp), offsetSamp,...
                    %   eventNumber, sesType, phaseType, phaseCount, trial, stimNum, i_catNum, targ, spaced, lag, expo_response, expo_keypress, rt]));
                    
                  end % check the event struct
                end % check the evt event
                
              case 'RESP'
                
              case 'FIXT'
                
              case 'PROM'
                
              case 'REST'
                
              case 'REND'
                
            end
            
          end
        end
        
      case {'multistudy', 'prac_multistudy'}
        
        %% process the multistudy phase
        
        fprintf('Processing %s...\n',phaseName);
        
        %multistudy_events = events_all.(sesName).(phaseName).data;
        
        %trl_order_multistudy = cfg.eventinfo.trl_order.multistudy;
        
        % keep track of how many real evt events we have counted
        ec = 0;
        
        for i = 1:length(ft_event)
          if strcmp(ft_event(i).type,cfg.trialdef.eventtype)
            % found a trigger in the evt file; increment index if value is correct.
            
            %if ~ismember(event(i).value,{'epoc'})
            if ismember(ft_event(i).value,{'STIM', 'RESP', 'FIXT', 'PROM', 'REST', 'REND'})
              ec = ec + 1;
            end
            
            switch ft_event(i).value
              case 'STIM'
                if strcmp(ns_evt{cols.(phaseName).isExp}(ec),'expt') && strcmpi(ns_evt{cols.(phaseName).isExp+1}(ec),'true') &&...
                    strcmp(ns_evt{cols.(phaseName).phase}(ec),'phas') && strcmp(ns_evt{cols.(phaseName).phase+1}(ec),phaseName) &&...
                    strcmp(ns_evt{cols.(phaseName).phaseCount}(ec),'pcou')
                  %&&...
                  %strcmp(ns_evt{cols.(phaseName).lag}(ec),'slag') && ~strcmp(ns_evt{cols.(phaseName).lag+1}(ec),'-1') &&...
                  %strcmp(evt{cols.(phaseName).type}(ec),'type') && strcmp(evt{cols.(phaseName).type+1}(ec),'image') &&...
                  %strcmp(evt{cols.(phaseName).icat_str}(ec),'icts')
                  
                  % Critical: set up the stimulus type, as well as the
                  % event string to match eventValues
                  if strcmp(ns_evt{cols.(phaseName).type_word+1}(ec),'word')
                    stimType = 'STUDY_WORD';
                    evVal = 'multistudy_word';
                  elseif strcmp(ns_evt{cols.(phaseName).type_image+1}(ec),'image')
                    stimType = 'STUDY_IMAGE';
                    evVal = 'multistudy_image';
                  end
                  
                  % find the entry in the event struct; not buffers (lag~=-1)
                  
                  this_event = events_all.(sesName).(phaseName).data(...
                    [events_all.(sesName).(phaseName).data.isExp] == 1 &...
                    ismember({events_all.(sesName).(phaseName).data.phaseName},{phaseName}) &...
                    [events_all.(sesName).(phaseName).data.phaseCount] == str2double(ns_evt{cols.(phaseName).phaseCount+1}(ec)) &...
                    ismember({events_all.(sesName).(phaseName).data.type},{stimType}) &...
                    [events_all.(sesName).(phaseName).data.trial] == str2double(ns_evt{cols.(phaseName).trial+1}(ec)) &...
                    [events_all.(sesName).(phaseName).data.lag] ~= -1 ...
                    );
                  
                  if length(this_event) > 1
                    warning('More than one event found! Fix this script before continuing analysis.')
                    keyboard
                    %elseif isempty(this_event)
                    %  warning('No event found! Fix this script before continuing analysis.')
                    %  keyboard
                  elseif length(this_event) == 1
                    %                   if ~isempty(this_event.catStr) && strcmp(stimType,'STUDY_IMAGE')
                    %                     if strcmp(this_event.catStr,'Faces')
                    %                       category = 'Face';
                    %                     elseif strcmp(this_event.catStr,'HouseInside')
                    %                       category = 'House';
                    %                     end
                    %                   else
                    %                     category = 'Word';
                    %                   end
                    
                    phaseCount = this_event.phaseCount;
                    trial = this_event.trial;
                    stimNum = this_event.stimNum;
                    catNum = this_event.catNum;
                    targ = this_event.targ;
                    spaced = this_event.spaced;
                    lag = this_event.lag;
                    presNum = this_event.presNum;
                    pairOrd = this_event.pairOrd;
                    pairNum = this_event.pairNum;
                    cr_recog_acc = this_event.cr_recog_acc;
                    cr_recall_resp = this_event.cr_recall_resp;
                    cr_recall_spellCorr = this_event.cr_recall_spellCorr;
                    
                    % find where this event type occurs in the list
                    eventNumber = find(ismember(cfg.trialdef.eventvalue,evVal));
                    if isempty(eventNumber)
                      eventNumber = -1;
                    end
                    
                    % add it to the trial definition
                    this_trl = trl_ini;
                    
                    this_trl(1) = ft_event(i).sample;
                    this_trl(2) = (ft_event(i).sample + durationSamp);
                    this_trl(3) = offsetSamp;
                    
                    for to = 1:length(cfg.eventinfo.trl_order.(phaseName))
                      thisInd = find(ismember(cfg.eventinfo.trl_order.(phaseName),cfg.eventinfo.trl_order.(phaseName){to}));
                      if ~isempty(thisInd)
                        if exist(cfg.eventinfo.trl_order.(phaseName){to},'var')
                          this_trl(timeCols + thisInd) = eval(cfg.eventinfo.trl_order.(phaseName){to});
                        else
                          fprintf('variable %s does not exist!\n',cfg.eventinfo.trl_order.(phaseName){to});
                          keyboard
                        end
                      end
                    end
                    
                    % put all the trials together
                    trl = cat(1,trl,double(this_trl));
                    
                  end % check the event struct
                end % check the evt event
                
              case 'RESP'
                
              case 'FIXT'
                
              case 'PROM'
                
              case 'REST'
                
              case 'REND'
                
            end
            
          end
        end
        
      case {'distract_math', 'prac_distract_math'}
        
        %% process the math distractor phase phase
        
        fprintf('Processing %s...\n',phaseName);
        
        % keep track of how many real evt events we have counted
        ec = 0;
        
        for i = 1:length(ft_event)
          if strcmp(ft_event(i).type,cfg.trialdef.eventtype)
            % found a trigger in the evt file; increment index if value is correct.
            
            %if ~ismember(event(i).value,{'epoc'})
            if ismember(ft_event(i).value,{'STIM', 'RESP', 'FIXT', 'PROM', 'REST', 'REND'})
              ec = ec + 1;
            end
            
            switch ft_event(i).value
              case 'STIM'
                if strcmp(ns_evt{cols.(phaseName).isExp}(ec),'expt') && strcmpi(ns_evt{cols.(phaseName).isExp+1}(ec),'true') &&...
                    strcmp(ns_evt{cols.(phaseName).phase}(ec),'phas') && strcmp(ns_evt{cols.(phaseName).phase+1}(ec),phaseName) &&...
                    strcmp(ns_evt{cols.(phaseName).phaseCount}(ec),'pcou')
                  
                  % Critical: set up the stimulus type, as well as the
                  % event string to match eventValues
                  evVal = 'distract_math_stim';
                  stimType = 'MATH_PROB';
                  
                  % find the entry in the event struct; not buffers (lag~=-1)
                  
                  this_event = events_all.(sesName).(phaseName).data(...
                    [events_all.(sesName).(phaseName).data.isExp] == 1 &...
                    ismember({events_all.(sesName).(phaseName).data.phaseName},{phaseName}) &...
                    [events_all.(sesName).(phaseName).data.phaseCount] == str2double(ns_evt{cols.(phaseName).phaseCount+1}(ec)) &...
                    ismember({events_all.(sesName).(phaseName).data.type},{stimType}) &...
                    [events_all.(sesName).(phaseName).data.trial] == str2double(ns_evt{cols.(phaseName).trial+1}(ec)) ...
                    );
                  
                  if length(this_event) > 1
                    warning('More than one event found! Fix this script before continuing analysis.')
                    keyboard
                    %elseif isempty(this_event)
                    %  warning('No event found! Fix this script before continuing analysis.')
                    %  keyboard
                  elseif length(this_event) == 1
                    
                    phaseCount = this_event.phaseCount;
                    trial = this_event.trial;
                    response = this_event.resp;
                    acc = this_event.acc;
                    rt = this_event.rt;
                    
                    % find where this event type occurs in the list
                    eventNumber = find(ismember(cfg.trialdef.eventvalue,evVal));
                    if isempty(eventNumber)
                      eventNumber = -1;
                    end
                    
                    % add it to the trial definition
                    this_trl = trl_ini;
                    
                    this_trl(1) = ft_event(i).sample;
                    this_trl(2) = (ft_event(i).sample + durationSamp);
                    this_trl(3) = offsetSamp;
                    
                    for to = 1:length(cfg.eventinfo.trl_order.(phaseName))
                      thisInd = find(ismember(cfg.eventinfo.trl_order.(phaseName),cfg.eventinfo.trl_order.(phaseName){to}));
                      if ~isempty(thisInd)
                        if exist(cfg.eventinfo.trl_order.(phaseName){to},'var')
                          this_trl(timeCols + thisInd) = eval(cfg.eventinfo.trl_order.(phaseName){to});
                        else
                          fprintf('variable %s does not exist!\n',cfg.eventinfo.trl_order.(phaseName){to});
                          keyboard
                        end
                      end
                    end
                    
                    % put all the trials together
                    trl = cat(1,trl,double(this_trl));
                    
                  end % check the event struct
                end % check the evt event
                
              case 'RESP'
                
              case 'FIXT'
                
              case 'PROM'
                
              case 'REST'
                
              case 'REND'
                
            end
            
          end
        end
        
      case {'cued_recall', 'prac_cued_recall'}
        
        %% process the cued recall phase
        
        fprintf('Processing %s...\n',phaseName);
        
        recog_responses = {'old', 'new'};
        new_responses = {'sure', 'maybe'};
        
        % keep track of how many real evt events we have counted
        ec = 0;
        
        for i = 1:length(ft_event)
          if strcmp(ft_event(i).type,cfg.trialdef.eventtype)
            % found a trigger in the evt file; increment index if value is correct.
            
            %if ~ismember(event(i).value,{'epoc'})
            if ismember(ft_event(i).value,{'STIM', 'RESP', 'FIXT', 'PROM', 'REST', 'REND'})
              ec = ec + 1;
            end
            
            switch ft_event(i).value
              case 'STIM'
                if strcmp(ns_evt{cols.(phaseName).isExp}(ec),'expt') && strcmpi(ns_evt{cols.(phaseName).isExp+1}(ec),'true') &&...
                    strcmp(ns_evt{cols.(phaseName).phase}(ec),'phas') && strcmp(ns_evt{cols.(phaseName).phase+1}(ec),phaseName) &&...
                    strcmp(ns_evt{cols.(phaseName).phaseCount}(ec),'pcou')
                  
                  % Critical: set up the stimulus type, as well as the
                  % event string to match eventValues
                  if strcmp(ns_evt{cols.(phaseName).type+1}(ec),'recognition')
                    stimType = 'RECOGTEST_STIM';
                    evVal = 'cued_recall_stim';
                  end
                  
                  % find the entry in the event struct; excluding buffers
                  % (lag~=-1) and NO_RESPONSE trials.
                  this_event = events_all.(sesName).(phaseName).data(...
                    [events_all.(sesName).(phaseName).data.isExp] == 1 &...
                    ismember({events_all.(sesName).(phaseName).data.phaseName},{phaseName}) &...
                    [events_all.(sesName).(phaseName).data.phaseCount] == str2double(ns_evt{cols.(phaseName).phaseCount+1}(ec)) &...
                    ismember({events_all.(sesName).(phaseName).data.type},{stimType}) &...
                    [events_all.(sesName).(phaseName).data.trial] == str2double(ns_evt{cols.(phaseName).trial+1}(ec)) &...
                    ismember({events_all.(sesName).(phaseName).data.recog_resp},{'old', 'new'}) &...
                    ismember({events_all.(sesName).(phaseName).data.new_resp},{'sure', 'maybe', ''}) ...
                    );
                  
                  if length(this_event) > 1
                    warning('More than one event found! Fix this script before continuing analysis.')
                    keyboard
                    %elseif isempty(this_event)
                    %  warning('No event found! Fix this script before continuing analysis.')
                    %  keyboard
                  elseif length(this_event) == 1
%                     if ~isempty(this_event.i_catStr) && strcmp(stimType,'RECOGTEST_STIM')
%                       if strcmp(this_event.i_catStr,'Faces')
%                         category = 'Face';
%                       elseif strcmp(this_event.i_catStr,'HouseInside')
%                         category = 'House';
%                       end
%                     else
%                       category = '';
%                     end
                    
                    phaseCount = this_event.phaseCount;
                    trial = this_event.trial;
                    stimNum = this_event.stimNum;
                    i_catNum = this_event.i_catNum;
                    targ = this_event.targ;
                    spaced = this_event.spaced;
                    lag = this_event.lag;
                    pairNum = this_event.pairNum;
                    
                    if ~isempty(this_event.recog_resp) && ismember(this_event.recog_resp,recog_responses)
                      recog_resp = find(ismember(recog_responses,this_event.recog_resp));
                    else
                      recog_resp = 0;
                    end
                    recog_acc = this_event.recog_acc;
                    recog_rt = this_event.recog_rt;
                    
                    if ~isempty(this_event.new_resp) && ismember(this_event.new_resp,new_responses)
                      new_resp = find(ismember(new_responses,this_event.new_resp));
                    else
                      new_resp = 0;
                    end
                    new_acc = this_event.new_acc;
                    new_rt = this_event.new_rt;
                    
                    if ~isempty(this_event.recall_resp) && ~ismember(this_event.recall_resp,{'NO_RESPONSE'})
                      recall_resp = 1;
                    else
                      recall_resp = 0;
                    end
                    recall_spellCorr = this_event.recall_spellCorr;
                    recall_rt = this_event.recall_rt;
            
                    % find where this event type occurs in the list
                    eventNumber = find(ismember(cfg.trialdef.eventvalue,evVal));
                    if isempty(eventNumber)
                      eventNumber = -1;
                    end
                    
                    % add it to the trial definition
                    this_trl = trl_ini;
                    
                    this_trl(1) = ft_event(i).sample;
                    this_trl(2) = (ft_event(i).sample + durationSamp);
                    this_trl(3) = offsetSamp;
                    
                    for to = 1:length(cfg.eventinfo.trl_order.(phaseName))
                      thisInd = find(ismember(cfg.eventinfo.trl_order.(phaseName),cfg.eventinfo.trl_order.(phaseName){to}));
                      if ~isempty(thisInd)
                        if exist(cfg.eventinfo.trl_order.(phaseName){to},'var')
                          this_trl(timeCols + thisInd) = eval(cfg.eventinfo.trl_order.(phaseName){to});
                        else
                          fprintf('variable %s does not exist!\n',cfg.eventinfo.trl_order.(phaseName){to});
                          keyboard
                        end
                      end
                    end
                    
                    % put all the trials together
                    trl = cat(1,trl,double(this_trl));
                    
                  end % check the event struct
                end % check the evt event
                
              case 'RESP'
                
              case 'FIXT'
                
              case 'PROM'
                
              case 'REST'
                
              case 'REND'
                
            end
            
          end
        end
        
    end % switch phase
  end % pha
end % ses
