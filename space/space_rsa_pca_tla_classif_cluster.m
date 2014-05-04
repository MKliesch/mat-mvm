function space_rsa_pca_tla_classif_cluster(subjects,sesNames)

% space RSA

%% load the analysis details

subDir = '';
dataDir = fullfile('SPACE','EEG','Sessions','ftpp',subDir);
% Possible locations of the data files (dataroot)
serverDir = fullfile(filesep,'Volumes','curranlab','Data');
serverLocalDir = fullfile(filesep,'Volumes','RAID','curranlab','Data');
dreamDir = fullfile(filesep,'data','projects','curranlab');
localDir = fullfile(getenv('HOME'),'data');

% pick the right dataroot
if exist('serverDir','var') && exist(serverDir,'dir')
  dataroot = serverDir;
  %runLocally = 1;
elseif exist('serverLocalDir','var') && exist(serverLocalDir,'dir')
  dataroot = serverLocalDir;
  %runLocally = 1;
elseif exist('dreamDir','var') && exist(dreamDir,'dir')
  dataroot = dreamDir;
  %runLocally = 0;
elseif exist('localDir','var') && exist(localDir,'dir')
  dataroot = localDir;
  %runLocally = 1;
else
  error('Data directory not found.');
end

% procDir = '/Users/matt/data/SPACE/EEG/Sessions/ftpp/ft_data/cued_recall_stim_expo_stim_multistudy_image_multistudy_word_art_ftManual_ftICA/tla';
procDir = fullfile(dataroot,dataDir,'ft_data/cued_recall_stim_expo_stim_multistudy_image_multistudy_word_art_ftManual_ftICA/tla');

% subjects = {
%   %'SPACE001'; % low trial counts
%   'SPACE002';
% %   'SPACE003';
% %   'SPACE004';
% %   'SPACE005';
% %   'SPACE006';
% %   'SPACE007';
% %   %'SPACE008'; % didn't perform task correctly, didn't perform well
% %   'SPACE009';
% %   'SPACE010';
% %   'SPACE011';
% %   'SPACE012';
% %   'SPACE013';
% %   'SPACE014';
% %   'SPACE015';
% %   'SPACE016';
% %   %'SPACE017'; % old assessment: really noisy EEG, half of ICA components rejected
% %   'SPACE018';
% %   %'SPACE019';
% %   'SPACE020';
% %   'SPACE021';
% %   'SPACE022';
% %   'SPACE027';
% %   'SPACE029';
% %   'SPACE037';
% %   %'SPACE039'; % noisy EEG; original EEG analyses stopped here
% %   'SPACE023';
% %   'SPACE024';
% %   'SPACE025';
% %   'SPACE026';
% %   'SPACE028';
% %   %'SPACE030'; % low trial counts
% %   'SPACE032';
% %   'SPACE034';
% %   'SPACE047';
% %   'SPACE049';
% %   'SPACE036';
%   };

% % only one cell, with all session names
% sesNames = {'session_1'};

allowRecallSynonyms = true;

% replaceDataroot = {'/Users/matt/data','/Volumes/curranlab/Data'};
replaceDataroot = true;

[exper,ana,dirs,files] = mm_loadAD(procDir,subjects,sesNames,replaceDataroot);

%% set up channel groups

% pre-defined in this function
ana = mm_ft_elecGroups(ana);

%% list the event values to analyze; specific to each experiment

% this is useful for when there are multiple types of event values, for
% example, hits and CRs in two conditions. You don't have to enter anything
% if you just want all events from exper.eventValues together in a single
% cell because it will get set to {exper.eventValues}, but it needs to be a
% cell containing a cell of eventValue strings

% this is only used by mm_ft_checkCondComps to create pairwise combinations
% either within event types {'all_within_types'} or across all event types
% {'all_across_types'}; mm_ft_checkCondComps is called within subsequent
% analysis functions

%% expo images and multistudy images

sesNum = 1;

% ana.trl_order.multistudy_image = {'eventNumber', 'sesType', 'phaseType', 'phaseCount', 'trial', 'stimNum', 'catNum', 'targ', 'spaced', 'lag', 'presNum', 'pairOrd', 'pairNum', 'cr_recog_acc', 'cr_recall_resp', 'cr_recall_spellCorr'};

ana.eventValues = {{'expo_stim','multistudy_image'}};
ana.eventValuesSplit = { ...
  { ...
  {'Face','House'} ...
  { ...
  %'img_onePres' ...
  'img_RgH_rc_spac_p1','img_RgH_rc_spac_p2','img_RgH_rc_mass_p1','img_RgH_rc_mass_p2' ...
  'img_RgH_fo_spac_p1','img_RgH_fo_spac_p2','img_RgH_fo_mass_p1','img_RgH_fo_mass_p2' ...
  %'img_RgM_spac_p1','img_RgM_spac_p2','img_RgM_mass_p1','img_RgM_mass_p2' ...
  } ...
  } ...
  };

if allowRecallSynonyms
  ana.trl_expr = { ...
    { ...
    { ...
    sprintf('eventNumber == %d & i_catNum == 1 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))) ...
    sprintf('eventNumber == %d & i_catNum == 2 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))) ...
    } ...
    { ...
    %sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    } ...
    } ...
    };
else
  ana.trl_expr = { ...
    { ...
    { ...
    sprintf('eventNumber == %d & i_catNum == 1 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))) ...
    sprintf('eventNumber == %d & i_catNum == 2 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))) ...
    } ...
    { ...
    %sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
    } ...
    } ...
    };
end


% %% expo
% 
% % can include targ==-1 because those are simply buffers for multistudy
% 
% sesNum = 1;
% 
% ana.eventValues = {{'expo_stim'}};
% ana.eventValuesSplit = {{{'Face','House'}}};
% ana.trl_expr = {...
%   { ...
%   { ...
%   sprintf('eventNumber == %d & i_catNum == 1 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))) ...
%   sprintf('eventNumber == %d & i_catNum == 2 & expo_response ~= 0 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))) ...
%   } ...
%   } ...
%   };
% 
% % ana.eventValues = {{'expo_stim'}};
% % ana.eventValuesSplit = {{{'Face_VU','Face_SU','Face_SA','Face_VA','House_VU','House_SU','House_SA','House_VA',}}};
% % ana.trl_expr = {...
% %   {{sprintf('eventNumber == %d & i_catNum == 1 & expo_response == 1 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
% %   sprintf('eventNumber == %d & i_catNum == 1 & expo_response == 2 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
% %   sprintf('eventNumber == %d & i_catNum == 1 & expo_response == 3 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
% %   sprintf('eventNumber == %d & i_catNum == 1 & expo_response == 4 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
% %   sprintf('eventNumber == %d & i_catNum == 2 & expo_response == 1 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
% %   sprintf('eventNumber == %d & i_catNum == 2 & expo_response == 2 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
% %   sprintf('eventNumber == %d & i_catNum == 2 & expo_response == 3 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim'))), ...
% %   sprintf('eventNumber == %d & i_catNum == 2 & expo_response == 4 & rt < 3000',find(ismember(exper.eventValues{sesNum},'expo_stim')))}}};
% 
% %% multistudy events
% 
% sesNum = 1;
% 
% % ana.trl_order.multistudy_image = {'eventNumber', 'sesType', 'phaseType', 'phaseCount', 'trial', 'stimNum', 'catNum', 'targ', 'spaced', 'lag', 'presNum', 'pairOrd', 'pairNum', 'cr_recog_acc', 'cr_recall_resp', 'cr_recall_spellCorr'};
% 
% ana.eventValues = {{'multistudy_image','multistudy_word'}};
% % ana.eventValues = {{'multistudy_image'}};
% % ana.eventValues = {{'multistudy_word'}};
% ana.eventValuesSplit = { ...
%   { ...
%   { ...
%   %'img_onePres' ...
%   'img_RgH_rc_spac_p1','img_RgH_rc_spac_p2','img_RgH_rc_mass_p1','img_RgH_rc_mass_p2' ...
%   'img_RgH_fo_spac_p1','img_RgH_fo_spac_p2','img_RgH_fo_mass_p1','img_RgH_fo_mass_p2' ...
%   %'img_RgM_spac_p1','img_RgM_spac_p2','img_RgM_mass_p1','img_RgM_mass_p2' ...
%   } ...
%   { ...
%   %'word_onePres' ...
%   'word_RgH_rc_spac_p1','word_RgH_rc_spac_p2','word_RgH_rc_mass_p1','word_RgH_rc_mass_p2' ...
%   'word_RgH_fo_spac_p1','word_RgH_fo_spac_p2','word_RgH_fo_mass_p1','word_RgH_fo_mass_p2' ...
%   %'word_RgM_spac_p1','word_RgM_spac_p2','word_RgM_mass_p1','word_RgM_mass_p2' ...
%   } ...
%   } ...
%   };
% 
% if allowRecallSynonyms
%   ana.trl_expr = { ...
%     { ...
%     { ...
%     %sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     } ...
%     { ...
%     %sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr > 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0  & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     } ...
%     } ...
%     };
% else
%   ana.trl_expr = { ...
%     { ...
%     { ...
%     %sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_image'))) ...
%     } ...
%     { ...
%     %sprintf('eventNumber == %d & targ == 1 & spaced == 0 & lag == -1 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr == 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 1 & cr_recall_spellCorr < 1 & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 1 & lag > 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0 & spaced == 0 & lag == 0 & presNum == 1',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     %sprintf('eventNumber == %d & targ == 1 & cr_recog_acc == 0  & spaced == 0 & lag == 0 & presNum == 2',find(ismember(exper.eventValues{sesNum},'multistudy_word'))) ...
%     } ...
%     } ...
%     };
% end
% 
% %% recognition events
% 
% % sesNum = 1;
% 
% % ana.trl_order.cued_recall_stim = {'eventNumber', 'sesType', 'phaseType', 'phaseCount', 'trial', 'stimNum', 'i_catNum', 'targ', 'spaced', 'lag', 'pairNum', 'recog_resp', 'recog_acc', 'recog_rt', 'new_resp', 'new_acc', 'new_rt', 'recall_resp', 'recall_spellCorr', 'recall_rt'};
% 
% % ana.eventValues = {{'cued_recall_stim'}};
% % ana.eventValuesSplit = {{{'RgH','CR'}}};
% % ana.trl_expr = {...
% %   {{sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %   sprintf('eventNumber == %d & targ == 0 & recog_resp == 2 & recog_acc == 1 & recog_rt < 3000 & new_resp ~= 0 & new_acc == 1',find(ismember(exper.eventValues{sesNum},'cued_recall_stim')))}}};
% 
% % ana.eventValues = {{'cued_recall_stim'}};
% % ana.eventValuesSplit = {{{'RgH_rc_spac','RgH_rc_mass','RgH_fo_spac','RgH_fo_mass','CR'}}};
% % if allowRecallSynonyms
% %   ana.trl_expr = {...
% %     {{sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr > 0 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr > 0 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr == 0 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr == 0 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %     sprintf('eventNumber == %d & targ == 0 & recog_resp == 2 & recog_acc == 1 & recog_rt < 3000 & new_resp ~= 0 & new_acc == 1',find(ismember(exper.eventValues{sesNum},'cued_recall_stim')))}}};
% % else
% %   ana.trl_expr = {...
% %     {{sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr == 1 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr == 1 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr < 1 & spaced == 1 & lag > 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %     sprintf('eventNumber == %d & targ == 1 & recog_resp == 1 & recog_acc == 1 & recog_rt < 3000 & recall_spellCorr < 1 & spaced == 0 & lag == 0',find(ismember(exper.eventValues{sesNum},'cued_recall_stim'))), ...
% %     sprintf('eventNumber == %d & targ == 0 & recog_resp == 2 & recog_acc == 1 & recog_rt < 3000 & new_resp ~= 0 & new_acc == 1',find(ismember(exper.eventValues{sesNum},'cued_recall_stim')))}}};
% % end

%% load in the subject data

% % make sure ana.eventValues is set properly
% if ~iscell(ana.eventValues{1})
%   ana.eventValues = {ana.eventValues};
% end
% if ~isfield(ana,'eventValues') || isempty(ana.eventValues{1})
%   ana.eventValues = {exper.eventValues};
% end

keeptrials = true;
% [data_tla,exper] = mm_ft_loadSubjectData(exper,dirs,ana,'tla',keeptrials,'trialinfo');
[data_tla,exper] = mm_loadSubjectData(exper,dirs,ana,'tla',keeptrials,'trialinfo');

% %% get rid of the bad channels
% 
% cfg = [];
% cfg.printRoi = {{'LAS'},{'RAS'},{'LPS'},{'RPS'}};
% [data_tla] = mm_rmBadChan(cfg,exper,ana,data_tla);

% overwrite ana.eventValues with the new split events
ana.eventValues = ana.eventValuesSplit;

%% decide who to kick out based on trial counts

% Subjects with bad behavior
% exper.badBehSub = {{}};
exper.badBehSub = {{'SPACE001','SPACE008','SPACE017','SPACE019','SPACE030','SPACE039'}};

% SPACE019 has particularly low distance (high similarity) values

% exclude subjects with low event counts
[exper,ana] = mm_threshSubs_multiSes(exper,ana,5,[],'vert');

%% set up similarity analysis

% first set up classifier

dataTypes_train = {'Face', 'House'};
equateTrainTrials = true;
standardizeTrain = true;
alpha = 0.2;

% then set up similarity comparisons

dataTypes = {'img_RgH_rc_spac', 'img_RgH_rc_mass','img_RgH_fo_spac', 'img_RgH_fo_mass'};

% do both P1 and P2 need to be classified correctly to use this trial?
classifRequireP1 = true;
classifRequireP2 = true;

% dataTypes = {'img_RgH_rc_spac', 'img_RgH_rc_mass','img_RgH_fo_spac', 'img_RgH_fo_mass', ...
%   'word_RgH_rc_spac', 'word_RgH_rc_mass','word_RgH_fo_spac', 'word_RgH_fo_mass'};

parameter = 'trial';

latencies = [0.0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0; ...
  0.1 0.3; 0.3 0.5; 0.5 0.7; 0.7 0.9; ...
  0 0.3; 0.3 0.6; 0.6 0.9; ...
  0 0.5; 0.5 1.0; ...
  0.3 0.8; ...
  0 0.6; 0.1 0.7; 0.2 0.8; 0.3 0.9; 0.4 1.0; ...
  0 0.8; 0.1 0.9; 0.2 1.0];

% column numbers in trialinfo
% trialNumCol = 5;
phaseCountCol = 4;
stimNumCol = 6;
categNumCol = 7;
% pairNumCol = 13;

% thisROI = {'LPI2','LPS','LT','RPI2','RPS','RT'};
thisROI = {'center109'};
% thisROI = {'all129'};
% thisROI = {'LPI', 'PI', 'RPI'};
% thisROI = {'LPS'};
% thisROI = {'LPS', 'RPS'};
% thisROI = {'LAS', 'RAS'};
% thisROI = {'Fz'};
% thisROI = {'Cz'};
% thisROI = {'Pz'};
% thisROI = {'PI'};
% thisROI = {'posterior'};
% thisROI = {'LPS', 'RPS', 'LPI', 'PI', 'RPI'};
% thisROI = {'E70', 'E83'};
% thisROI = {'E83'};
cfg_sel = [];
% cfg_sel.latency = [0.2 0.8];
% cfg_sel.latency = [0 0.5];
% cfg_sel.latency = [0 0.8];
% cfg_sel.latency = [0.4 0.6];
% cfg_sel.avgoverfreq = 'yes';
cfg_sel.avgoverchan = 'no';
cfg_sel.avgovertime = 'no';
% cfg_sel.avgovertime = 'yes';

% % keep components with eigenvalue >= 1
% eig_criterion = 'kaiser';

% % compute the percent explained variance expected from each component if
% % all events are uncorrelated with each other; keep it if above this level.
% % So, each component would explain 100/n, where n is the number of
% % events/components.
% eig_criterion = 'analytic';

% keep components that cumulatively explain at least 85% of the variance
eig_criterion = 'CV85';

similarity_all = cell(length(exper.subjects),length(exper.sesStr),length(dataTypes),size(latencies,1));
similarity_ntrials = nan(length(exper.subjects),length(exper.sesStr),length(dataTypes),size(latencies,1));

%% run similarity comparison

for sub = 1:length(exper.subjects)
  
  for ses = 1:length(exper.sesStr)
    sesStr = exper.sesStr{ses};
    
    %sesNum = find(ismember(exper.sessions{ses},exper.sesStr(ses)));
    
    if ~exper.badSub(sub,ses)
      fprintf('\t%s %s...\n',exper.subjects{sub},exper.sesStr{ses});
      
      % equate the training categories
      trlIndTrain = cell(length(dataTypes_train),1);
      if equateTrainTrials
        nTrainTrial = nan(length(dataTypes_train),1);
        for dt = 1:length(dataTypes_train)
          nTrainTrial(dt) = size(data_tla.(sesStr).(dataTypes_train{dt}).sub(sub).data.(parameter),1);
        end
        fprintf('\tEquating training categories to have %d trials.\n',min(nTrainTrial));
        for dt = 1:length(dataTypes_train)
          trlInd = randperm(nTrainTrial(dt));
          trlIndTrain{dt,1} = sort(trlInd(1:min(nTrainTrial)));
        end
      else
        fprintf('\tNot equating training category trial counts.\n');
        for dt = 1:length(dataTypes_train)
          trlIndTrain{dt,1} = 'all';
        end
      end
      
      % train for a given latency and set of electrodes
      for lat = 1:size(latencies,1)
        cfg_sel.latency = latencies(lat,:);
        cfg_sel.channel = cat(2,ana.elecGroups{ismember(ana.elecGroupsStr,thisROI)});

        % select the training data
        data_train = struct;
        
        % select the data
        for dt = 1:length(dataTypes_train)
          cfg_sel.trials = trlIndTrain{dt};
          data_train.(dataTypes_train{dt}) = ft_selectdata_new(cfg_sel,data_tla.(exper.sesStr{ses}).(dataTypes_train{dt}).sub(sub).data);
        end
        
        % get the category number for each training image
        imageCategory_train = data_train.(dataTypes_train{1}).trialinfo(:,categNumCol);
        for dt = 2:length(dataTypes_train)
          imageCategory_train = cat(1,imageCategory_train,data_train.(dataTypes_train{dt}).trialinfo(:,categNumCol));
        end
        
        % concatenate the data
        dat_train = data_train.(dataTypes_train{1}).(parameter);
        for dt = 2:length(dataTypes_train)
          dat_train = cat(1,dat_train,data_train.(dataTypes_train{dt}).(parameter));
        end
        
        dim = size(dat_train);
        dat_train = reshape(dat_train, dim(1), prod(dim(2:end)));
        
        if standardizeTrain
          fprintf('\t\tStandardizing the training data...');
          
          m = dml.standardizer;
          m = m.train(dat_train);
          dat_train = m.test(dat_train);
          fprintf('Done.\n');
        end
        
        fprintf('\t\tTraining classifier...');
        %facehouse = {dml.standardizer dml.enet('family','binomial','alpha',alpha)};
        facehouse = dml.enet('family','binomial','alpha',alpha);
        facehouse = facehouse.train(dat_train,imageCategory_train);
        %facehouse_svm = dml.svm;
        %facehouse_svm = facehouse_svm.train(dat_train,imageCategory_train);
        fprintf('Done.\n');
      
      for d = 1:length(dataTypes)
        dataType = dataTypes{d};
        
        fprintf('Processing %s...\n',dataType);
        
%         if all(ismember(thisROI,ana.elecGroupsStr))
%           elecInd = ismember(data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.label,unique(cat(2,ana.elecGroups{ismember(ana.elecGroupsStr,thisROI)})));
%         elseif ~all(ismember(thisROI,ana.elecGroupsStr)) && all(ismember(thisROI,data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.label))
%           elecInd = ismember(data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.label,unique(thisROI));
%         else
%           error('Cannot find specified electrode(s)');
%         end
%         cfg_sel.channel = data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.label(elecInd);
        
        p1_ind = [];
        p2_ind = [];
        imageCategory_test = []; % 1=face, 2=house
        for p = 1:size(data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.(parameter),1)
          p1_trlInd = p;
          p1_phaseCount = data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.trialinfo(p1_trlInd,phaseCountCol);
          p1_stimNum = data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.trialinfo(p1_trlInd,stimNumCol);
          p1_categNum = data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.trialinfo(p1_trlInd,categNumCol);
          
          p2_trlInd = find(...
            data_tla.(sesStr).(sprintf('%s_p2',dataType)).sub(sub).data.trialinfo(:,phaseCountCol) == p1_phaseCount & ...
            data_tla.(sesStr).(sprintf('%s_p2',dataType)).sub(sub).data.trialinfo(:,stimNumCol) == p1_stimNum & ...
            data_tla.(sesStr).(sprintf('%s_p2',dataType)).sub(sub).data.trialinfo(:,categNumCol) == p1_categNum);
          
          if ~isempty(p2_trlInd)
            p1_ind = cat(2,p1_ind,p1_trlInd);
            p2_ind = cat(2,p2_ind,p2_trlInd);
            imageCategory_test = cat(2,imageCategory_test,p1_categNum);
          end
        end
        
        % test trials for classification
        probabilityClassP1 = nan(length(p1_ind),2);
        correctClassP1 = true(size(p1_ind));
        if classifRequireP1
          for p = 1:length(p1_ind)
            cfg_sel.trials = p1_ind(p);
            dat1 = ft_selectdata_new(cfg_sel,data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data);
            %data_p1(:,:,:) = dat1.(parameter);
            data_p1 = dat1.(parameter);
            dim = size(data_p1);
            data_p1 = reshape(data_p1, dim(1), prod(dim(2:end)));
            
            Z = facehouse.test(zscore(data_p1));
            probabilityClassP1(p,:) = Z;
            
            [Y,I] = max(Z,[],2);
            
            correctClassP1(p) = I == imageCategory_test(p);
          end
        end
        
        probabilityClassP2 = nan(length(p1_ind),2);
        correctClassP2 = true(size(p2_ind));
        if classifRequireP2
          for p = 1:length(p2_ind)
            cfg_sel.trials = p2_ind(p);
            dat2 = ft_selectdata_new(cfg_sel,data_tla.(sesStr).(sprintf('%s_p2',dataType)).sub(sub).data);
            %data_p2(:,:,:) = dat2.(parameter);
            data_p2 = dat2.(parameter);
            dim = size(data_p2);
            data_p2 = reshape(data_p2, dim(1), prod(dim(2:end)));
            
            Z = facehouse.test(zscore(data_p2));
            probabilityClassP2(p,:) = Z;
            
            [Y,I] = max(Z,[],2);
            
            correctClassP2(p) = I == imageCategory_test(p);
          end
        end
        
        % only compare these trials
        p1_ind = p1_ind(correctClassP1 & correctClassP2);
        p2_ind = p2_ind(correctClassP1 & correctClassP2);
        
        if ~isempty(p1_ind) && ~isempty(p2_ind)
          
            
%             if strcmp(cfg_sel.avgovertime,'yes')
%               data_p1 = nan(length(p1_ind),length(cfg_sel.channel));
%               data_p2 = nan(length(p2_ind),length(cfg_sel.channel));
%             elseif strcmp(cfg_sel.avgovertime,'no')
%               tbeg = nearest(data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.time,cfg_sel.latency(1));
%               tend = nearest(data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data.time,cfg_sel.latency(2));
%               data_p1 = nan(length(p1_ind),length(cfg_sel.channel),length(tbeg:tend));
%               data_p2 = nan(length(p2_ind),length(cfg_sel.channel),length(tbeg:tend));
%             end
            
            cfg_sel.trials = p1_ind;
            dat1 = ft_selectdata_new(cfg_sel,data_tla.(sesStr).(sprintf('%s_p1',dataType)).sub(sub).data);
            %data_p1(:,:,:) = dat1.(parameter);
            data_p1 = dat1.(parameter);
            
            cfg_sel.trials = p2_ind;
            dat2 = ft_selectdata_new(cfg_sel,data_tla.(sesStr).(sprintf('%s_p2',dataType)).sub(sub).data);
            %data_p2(:,:,:) = dat2.(parameter);
            data_p2 = dat2.(parameter);
            
            % unroll data for each trial in the second dimension
            dim1 = size(data_p1);
            dim2 = size(data_p2);
            data_p1_p2 = cat(1,reshape(data_p1, dim1(1), prod(dim1(2:end))),reshape(data_p2, dim2(1), prod(dim2(2:end))));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Compute similarity
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % variables: columns = electrode x time (unrolled)
            % observations/instances: rows = events
            
            % apply PCA to data
            %[evec_p1_p2, data_pcaspace, eval_p1_p2] = pca(zscore(data_p1_p2), 'Economy', true);
            [evec_p1_p2, data_pcaspace, eval_p1_p2] = princomp(zscore(data_p1_p2),'econ');
            
            if strcmp(eig_criterion,'kaiser')
              crit_eig = eval_p1_p2 >= 1;
            elseif strcmp(eig_criterion,'analytic')
              % analytic: keep PC if percent variance explained is above
              % 100 / number of variables
              
              % convert to percent variance explained
              eval_PVE = (eval_p1_p2 ./ sum(eval_p1_p2)) .* 100;
              crit_eig = eval_PVE > (100 / size(eval_PVE,1));
            elseif strcmp(eig_criterion,'CV85')
              % Cumulative variance 85%: keep PCs that explain at least 85%
              % of variance
              
              % convert to percent variance explained
              eval_PVE = (eval_p1_p2 ./ sum(eval_p1_p2)) .* 100;
              eval_CV = cumsum(eval_PVE);
              cutoff_eval = find(eval_CV>=85,1,'first');
              
              crit_eig = false(size(eval_p1_p2));
              crit_eig(1:cutoff_eval) = true;
            elseif strcmp(eig_criterion,'none')
              crit_eig = true(length(eval_p1_p2),1);
            end
            % remove features with eigenvalues that didn't pass criterion
            %
            % evec_p1_p2 (coeff) lets you map from PCA space to original
            % feature space
            evec_p1_p2_crit = evec_p1_p2(:, crit_eig);
            feature_vectors = data_pcaspace(:, crit_eig);
            
            %%%%%%
            % more feature selection is done here (my paradigm is about
            % comparing individual event representations, so the
            % autocorrelation criterion is not appropriate. I'm still
            % thinking about how to select the most important features.)
            %%%%%%
            
            % dummy selection. replace with actual technique for selecting
            % important features.
            %
            % important: for autocorrelation, only use study events for selection
            select_inds = true(1, size(feature_vectors, 2));
            
            evec_p1_p2_final = evec_p1_p2_crit(:, select_inds);
            feature_vectors = feature_vectors(:, select_inds);
            
            % normalize the vector lengths of each event
            feature_vectors = feature_vectors ./ repmat(sqrt(sum(feature_vectors.^2, 2)), 1, size(feature_vectors, 2));
            
            % compute the similarities between each pair of events
            similarities = 1 - squareform(pdist(feature_vectors, 'cosine'));
            
            % add it to the full set
            similarity_all{sub,ses,d,lat} = similarities;
            similarity_ntrials(sub,ses,d,lat) = length(p1_ind);
            
          end % lat
          
        end % ~isempty
        
      end % d
    end % ~badSub
    
    if iscell(thisROI)
      roi_str = sprintf(repmat('%s',1,length(thisROI)),thisROI{:});
    elseif ischar(thisROI)
      roi_str = thisROI;
    end
    saveFile = fullfile(dirs.saveDirProc,exper.subjects{sub},exper.sesStr{ses},sprintf('RSA_PCA_tla_classif_%s_%s_%dlat_%sAvgT_%s.mat',eig_criterion,roi_str,size(latencies,1),cfg_sel.avgovertime,date));
    save(saveFile,'exper','dataTypes','thisROI','cfg_sel','eig_criterion','latencies','similarity_all','similarity_ntrials');
  end % ses
end % sub


% %% stats
% 
% plotit = false;
% 
% mean_similarity = struct;
% for d = 1:length(dataTypes)
%   mean_similarity.(dataTypes{d}) = nan(length(exper.subjects),length(exper.sesStr),size(latencies,1));
%   for lat = 1:size(latencies,1)
%     
%     for sub = 1:length(exper.subjects)
%       for ses = 1:length(exper.sesStr)
%         
%         % Average Pres1--Pres2 similarity
%         mean_similarity.(dataTypes{d})(sub,ses,lat) = mean(diag(similarity_all{sub,ses,d,lat},size(similarity_all{sub,ses,d,lat},1) / 2));
%         %mean_similarity.(dataTypes{d}) = cat(1,mean_similarity.(dataTypes{d}),mean(diag(similarity_all{sub,ses,d,lat},size(similarity_all{sub,ses,d,lat},1) / 2)));
%         
%         if plotit
%           figure
%           imagesc(similarity_all{sub,ses,d,lat});
%           colorbar;
%           axis square;
%           title(sprintf('%s, %.2f to %.2f',strrep(dataTypes{d},'_','-'),latencies(lat,1),latencies(lat,2)));
%         end
%       end
%     end
%     
%   end
% end
% 
% % disp(mean_similarity);
% 
% 
% %% RMANOVA
% 
% % dataTypes = {'img_RgH_rc_spac', 'img_RgH_rc_mass','img_RgH_fo_spac', 'img_RgH_fo_mass', ...
% %   'word_RgH_rc_spac', 'word_RgH_rc_mass','word_RgH_fo_spac', 'word_RgH_fo_mass'};
% 
% % latencies = [0.0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0; ...
% %   0.1 0.3; 0.3 0.5; 0.5 0.7; 0.7 0.9; ...
% %   0 0.3; 0.3 0.6; 0.6 0.9; ...
% %   0 0.5; 0.5 1.0; ...
% %   0.3 0.8; ...
% %   0 0.6; 0.1 0.7; 0.2 0.8; 0.3 0.9; 0.4 1.0; ...
% %   0 0.8; 0.1 0.9; 0.2 1.0];
% 
% % 0 to 1, in 200 ms chunks
% latInd = [1 5];
% 
% % % 0.1 to 0.9, in 200 ms chunks
% % latInd = [6 9];
% 
% % % 0-0.3, 0.3-0.6, 0.6-0.9
% % latInd = [10 12];
% 
% % % 0-0.5, 0.5-1
% % latInd = [13 14];
% 
% % % 0 to 1, in 600 ms chunks
% % latInd = [16 20];
% 
% % % 0 to 1 in 800 ms chunks
% % latInd = [21 23];
% 
% fprintf('=======================================\n');
% fprintf('Latency: %.1f-%.1f\n\n',latencies(latInd(1),1),latencies(latInd(2),2));
% 
% anovaData = [];
% 
% for sub = 1:length(exper.subjects)
%     for ses = 1:length(exper.sesStr)
%       theseData = [];
%       
%       for d = 1:length(dataTypes)
%         for lat = latInd(1):latInd(2)
%           theseData = cat(2,theseData,mean_similarity.(dataTypes{d})(sub,ses,lat));
%         end
%       end
%     end
%     anovaData = cat(1,anovaData,theseData);
% end
% 
% latStr = cell(1,length(latInd(1):latInd(2)));
% for i = 1:length(latStr)
%   latStr{i} = sprintf('%.1f-%.1f',latencies(latInd(1)+i-1,1),latencies(latInd(1)+i-1,2));
% end
% levelnames = {{'img','word'}, {'rc', 'fo'}, {'spac','mass'}, latStr};
% 
% varnames = {'stimType','subseqMem','spacing','time'};
% O = teg_repeated_measures_ANOVA(anovaData, [2 2 2 length(latInd(1):latInd(2))], varnames,[],[],[],[],[],[],levelnames);
% 
% fprintf('Latency: %.1f-%.1f\n',latencies(latInd(1),1),latencies(latInd(2),2));
% fprintf('=======================================\n\n');
% 
% %% RMANOVA - no time dimension
% 
% % dataTypes = {'img_RgH_rc_spac', 'img_RgH_rc_mass','img_RgH_fo_spac', 'img_RgH_fo_mass', ...
% %   'word_RgH_rc_spac', 'word_RgH_rc_mass','word_RgH_fo_spac', 'word_RgH_fo_mass'};
% 
% % latencies = [0.0 0.2; 0.2 0.4; 0.4 0.6; 0.6 0.8; 0.8 1.0; ...
% %   0.1 0.3; 0.3 0.5; 0.5 0.7; 0.7 0.9; ...
% %   0 0.3; 0.3 0.6; 0.6 0.9; ...
% %   0 0.5; 0.5 1.0; ...
% %   0.3 0.8; ...
% %   0 0.6; 0.1 0.7; 0.2 0.8; 0.3 0.9; 0.4 1.0; ...
% %   0 0.8; 0.1 0.9; 0.2 1.0];
% 
% % 0-0.5
% lat = 13;
% % % 0.5-1.0
% % lat = 14;
% 
% % % 0.3-0.8
% % lat = 15;
% 
% % % 0-0.6
% % lat = 16;
% % % 0.1-0.7
% % lat = 17;
% % % 0.2-0.8
% % lat = 18;
% % % 0.3-0.9
% % lat = 19;
% % % 0.4-1.0
% % lat = 20;
% 
% % % 0-0.8
% % lat = 21;
% % % 0.1-0.9
% % lat = 22;
% % % 0.2-1.0
% % lat = 23;
% 
% fprintf('=======================================\n');
% fprintf('Latency: %.1f-%.1f\n\n',latencies(lat,:));
% 
% anovaData = [];
% 
% for sub = 1:length(exper.subjects)
%     for ses = 1:length(exper.sesStr)
%       theseData = [];
%       
%       for d = 1:length(dataTypes)
%           theseData = cat(2,theseData,mean_similarity.(dataTypes{d})(sub,ses,lat));
%       end
%     end
%     anovaData = cat(1,anovaData,theseData);
% end
% 
% % no time dimension
% varnames = {'stimType','subseqMem','spacing'};
% levelnames = {{'img','word'}, {'rc', 'fo'}, {'spac','mass'}};
% O = teg_repeated_measures_ANOVA(anovaData, [2 2 2], varnames,[],[],[],[],[],[],levelnames);
% 
% 
% fprintf('Latency: %.1f-%.1f\n',latencies(lat,:));
% fprintf('=======================================\n\n');