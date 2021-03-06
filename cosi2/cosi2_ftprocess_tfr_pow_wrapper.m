function cosi2_ftprocess_tfr_pow_wrapper(whichStages)
% cosi2_ftprocess_tfr_pow_wrapper(whichStages)
%
% To run on dream, at the command line type: distmsub2011 cosi2_ftprocess_tfr_pow_wrapper.m
%
% To run on a local computer, type the command in MATLAB
%
% There are two stages:
%  stage1 = call wrapper that calls create_ft_struct (which calls seg2ft),
%  saves the raw files
%  stage2 = calls ft_freqanalysis and saves the processed files
%
% Input:
%  whichStages: the stage number(s) to run (default = 1:2)
%
% Output:
%  time-frequency data

% check/handle arguments
error(nargchk(0,1,nargin))
%narginchk(0,1)
STAGES = 1:2;
if nargin == 1
  STAGES = whichStages;
end

% initialize the analysis structs
exper = struct;
files = struct;
dirs = struct;
ana = struct;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODIFY THIS STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Experiment-specific setup

exper.name = 'COSI2';

exper.sampleRate = 500;

% pre- and post-stimulus times to read, in seconds (pre is negative)
exper.prepost = [-1.0 2.0];

% equate the number of trials across event values?
exper.equateTrials = 0;

% type of NS file for FieldTrip to read; raw or sbin must be put in
% dirs.dataroot/ns_raw; egis must be put in dirs.dataroot/ns_egis
%exper.eegFileExt = 'egis';
exper.eegFileExt = 'raw';

% types of events to find in the NS file; these must be the same as the
% events in the NS files
exper.eventValues = sort({...
  'CFSC','CFSI','CNM','CNS','CROSC','CROSI','CRSSC','CRSSI',...
  'SFSC','SFSI','SNM','SNS','SROSC','SROSI','SRSSC','SRSSI'});

% combine the two types of hits into one category
exper.eventValuesExtra.toCombine = {...
  {'CNS','CNM'},{'CFSC','CROSC','CRSSC'},{'CFSI','CROSI','CRSSI'},...
  {'SNS','SNM'},{'SFSC','SROSC','SRSSC'},{'SFSI','SROSI','SRSSI'}};
exper.eventValuesExtra.newValue = {...
  {'CCR'},{'CSC'},{'CSI'},...
  {'SCR'},{'SSC'},{'SSI'}};

% keep only the combined (extra) events and throw out the original events?
exper.eventValuesExtra.onlyKeepExtras = 0;
exper.eventValuesExtra.equateExtrasSeparately = 0;

exper.subjects = {
%   'COSI2001';
%   'COSI2002';
%   'COSI2003';
%   'COSI2004';
%   'COSI2005';
%   'COSI2006';
%   'COSI2007';
  'COSI2008';
  'COSI2009';
  'COSI2010';
%   'COSI2011'; % will not have a session_1, didn't like EEG
  'COSI2012';
  'COSI2013';
%   'COSI2014'; % no session_1, didn't perform well in session_0
  'COSI2015';
  'COSI2016';
  'COSI2017';
  'COSI2018';
  'COSI2019';
  'COSI2020';
  'COSI2021';
  'COSI2022';
  'COSI2023';
  'COSI2024';
  'COSI2025';
  'COSI2026';
  'COSI2027';
  'COSI2028';
  'COSI2029';
  'COSI2030';
%   'COSI2031'; % Thought reference electrode messed up. No session_1.
  'COSI2032';
  'COSI2033';
  'COSI2034';
  'COSI2035';
  'COSI2036';
  'COSI2037';
%   'COSI2038'; % COSI2038: potentially bad session_1 (bathroom, sick)
  'COSI2039';
  'COSI2040';
%   'COSI2041'; % COSI2041: no-show, no session_1
  'COSI2042';
  'COSI2043';
  'COSI2044';
  'COSI2045';
  };

% The sessions that each subject ran; the strings in this cell are the
% directories in dirs.dataDir (set below) containing the ns_egis/ns_raw
% directory and, if applicable, the ns_bci directory. They are not
% necessarily the session directory names where the FieldTrip data is saved
% for each subject because of the option to combine sessions. See 'help
% create_ft_struct' for more information.

%exper.sessions = {'session_0'};
%exper.sessions = {'session_1'};
exper.sessions = {{'session_0','session_1'}};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% POSSIBLY MODIFY THIS STUFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set up file and directory handling parameters

% directory where the data to read is located
% directory where the data to read is located
dirs.dataDir = fullfile(exper.name,'eeg','eppp',sprintf('%d_%d',exper.prepost(1)*1000,exper.prepost(2)*1000));
%dirs.subDir = 'RK';
%dirs.dataDir = fullfile('eeg','eppp',sprintf('%d_%d',exper.prepost(1)*1000,exper.prepost(2)*1000),dirs.subDir);

% Possible locations of the data files (dataroot)
dirs.serverDir = fullfile(filesep,'Volumes','curranlab','Data');
dirs.serverLocalDir = fullfile(filesep,'Volumes','RAID','curranlab','Data');
dirs.dreamDir = fullfile(filesep,'data','projects','curranlab');
dirs.localDir = fullfile(getenv('HOME'),'data');

% pick the right dirs.dataroot
if exist(dirs.serverDir,'dir')
  dirs.dataroot = dirs.serverDir;
  runLocally = 1;
elseif exist(dirs.serverLocalDir,'dir')
  dirs.dataroot = dirs.serverLocalDir;
  runLocally = 1;
elseif exist(dirs.localDir,'dir')
  dirs.dataroot = dirs.localDir;
  runLocally = 1;
elseif exist(dirs.dreamDir,'dir')
  dirs.dataroot = dirs.dreamDir;
  runLocally = 0;
else
  error('Data directory not found.');
end

% Use the FT chan locs file
files.elecfile = 'GSN-HydroCel-129.sfp';
files.locsFormat = 'besa_sfp';
ana.elec = ft_read_sens(files.elecfile,'fileformat',files.locsFormat);

%% set up analysis parameters

ana.segFxn = 'seg2ft';
ana.ftFxn = 'ft_freqanalysis';
ana.artifact.type = {'zeroVar'};
%ana.artifact.type = {'nsAuto'};
%ana.artifact.type = {'nsAuto','preRejManual','ftICA'};

ana.otherFxn = {};
ana.cfg_other = [];
ana.otherFxn{1} = 'ft_resampledata';
ana.cfg_other{1}.resamplefs = 256;
ana.cfg_other{1}.detrend = 'no';
ana.cfg_other{1}.ftype = 'resample256';

% ana.otherFxn = {};
% ana.otherFxn{1} = 'ft_scalpcurrentdensity';
% ana.cfg_other = [];
% ana.cfg_other{1}.elecfile = files.elecfile;
% ana.cfg_other{1}.method = 'spline';
% ana.cfg_other{1}.ftype = 'scd';

% any preprocessing?
cfg_pp = [];
% single precision to save space
%cfg_pp.precision = 'single';
% baseline correct
cfg_pp.demean = 'yes';
cfg_pp.baselinewindow = [-0.2 0];
% cfg_pp.detrend = 'yes';
% cfg_pp.dftfilter = 'yes';
% cfg_pp.dftfreq = [60 120 180];
% % cfg_pp.bsfilter = 'yes';
% % cfg_pp.bsfreq = [59 61; 119 121; 179 181];
% % cfg_pp.bsfreq = [58 62; 118 122; 178 182];
% % cfg_pp.lpfilter = 'yes';
% % cfg_pp.lpfreq = [35];
    
cfg_proc = [];
cfg_proc.pad = 'maxperlen';

% cfg_proc.output = 'pow';
% % cfg_proc.output = 'powandcsd';
% % cfg_proc.keeptrials = 'yes';
% cfg_proc.keeptrials = 'no';
% cfg_proc.keeptapers = 'no';

cfg_proc.output = 'fourier';
cfg_proc.keeptrials = 'yes';
cfg_proc.keeptapers = 'yes';

% % MTM FFT
% cfg_proc.method = 'mtmfft';
% cfg_proc.taper = 'dpss';
% %cfg_proc.foilim = [3 50];
% freqstep = (exper.sampleRate/(diff(exper.prepost)*exper.sampleRate)) * 2;
% %cfg_proc.foi = 3:freqstep:50;
% cfg_proc.foi = 3:freqstep:9;
% cfg_proc.tapsmofrq = 5;
% cfg_proc.toi = -0:0.04:1.0;

% % multi-taper method
% cfg_proc.method = 'mtmconvol';
% cfg_proc.taper = 'hanning';
% %cfg_proc.taper = 'dpss';
% %cfg_proc.toi = -0.8:0.04:3.0;
% cfg_proc.toi = -0.5:0.04:1.0;
% freqstep = (exper.sampleRate/(diff(exper.prepost)*exper.sampleRate)) * 2;
% cfg_proc.foi = 2:freqstep:40;
% %cfg_proc.foi = 3:freqstep:9;
% %cfg_proc.foi = 3:1:9;
% %cfg_proc.foi = 2:2:30;
% cfg_proc.t_ftimwin = 4./cfg_proc.foi;
% % tapsmofrq is not used for hanning taper; it is used for dpss
% %cfg_proc.tapsmofrq = 0.4*cfg_proc.foi;

% wavelet
cfg_proc.method = 'wavelet';
cfg_proc.width = 6;
%cfg_proc.toi = -0.8:0.04:3.0;
cfg_proc.toi = -0.5:0.04:1.0;
% % evenly spaced frequencies, but not as many as foilim makes
% freqstep = (exper.sampleRate/(diff(exper.prepost)*exper.sampleRate)) * 2;
% % cfg_proc.foi = 3:freqstep:9;
% cfg_proc.foi = 3:freqstep:60;
cfg_proc.foi = 4:1:100;
%cfg_proc.foi = 4:1:60;
%cfg_proc.foilim = [3 9];

% set the save directories; final argument is prefix of save directory
%[dirs,files] = mm_ft_setSaveDirs(exper,ana,cfg_proc,dirs,files,'conn');
%[dirs,files] = mm_ft_setSaveDirs(exper,ana,cfg_proc,dirs,files,'pow');
[dirs,files] = mm_ft_setSaveDirs(exper,ana,cfg_proc,dirs,files,cfg_proc.output);

ana.ftype = cfg_proc.output;

%% set up for running stages and specifics for Dream

% name(s) of the functions for different stages of processing
%stageFun = {@stage1};
%timeOut  = {2}; % in HOURS
stageFun = {@stage1,@stage2};
timeOut  = {2,2}; % in HOURS

if runLocally == 0
  % need to export DISPLAY to an offscreen buffer for MATLAB DCS graphics
  sched = findResource();
  %sched = parcluster();
  if strcmp(sched.Type, 'generic')
    setenv('DISPLAY', 'dream:99');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%capture diary and time statistics
thisRun = [exper.name,'_overview_',datestr(now,'ddmmmyyyy-HHMMSS')];
diary(fullfile(dirs.saveDirProc,[thisRun '.log']));
tStart = tic;
fprintf('START TIME: %s\n',datestr(now,13));
for i = STAGES
  tS = tic;
  fprintf('STAGE%d START TIME: %s\n',i, datestr(now,13));
  
  % execute the processing stages
  if i == 1
    stageFun{i}(ana,cfg_pp,cfg_proc,exper,dirs,files,runLocally,timeOut{i});
  elseif i == 2
    stageFun{i}(ana,cfg_proc,exper,dirs,runLocally,timeOut{i});
  end
  
  fprintf('STAGE%d END TIME: %s\n',i, datestr(now,13));
  fprintf('%.3f -- elapsed time STAGE%d (seconds)\n', toc(tS), i);
end
time = toc(tStart);
fprintf('%.3f -- elapsed time OVERALL (seconds)\n', time);
fprintf('END TIME: %s\n',datestr(now,13));
diary off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stage1(ana,cfg_pp,cfg_proc,exper,dirs,files,runLocally,timeOut)
% stage1: process the input files with FieldTrip based on the analysis
% parameters

%% Process the data
if runLocally == 0
  %% Dream: create one task for each subject (i.e., submit one to each node)
  
  % start a new job
  job = newJob(dirs);
  
  % save the original subjects array so we can set exper to have single
  % subjects, one for each task created
  allSubjects = exper.subjects;
  
  for i = 1:length(allSubjects)
    fprintf('Processing %s...\n',allSubjects{i});
    
    % Dream: create one task for each subject
    exper.subjects = allSubjects(i);
    
    inArg = {ana,cfg_pp,exper,dirs,files};
    
    % save the exper struct (output 1) so we can use it later
    createTask(job,@create_ft_struct,1,inArg);
  end
  
  runJob(job,timeOut,fullfile(dirs.saveDirProc,[exper.name,'_stage1_',datestr(now,'ddmmmyyyy-HHMMSS'),'.log']));
  
  % get the trial counts together across subjects, sessions, and events
  [exper] = mm_ft_concatTrialCounts_cluster(job,exper,allSubjects);

  % save the analysis details; overwrite if it already exists
  saveFile = fullfile(dirs.saveDirProc,sprintf('analysisDetails.mat'));
  %if ~exist(saveFile,'file')
  fprintf('Saving %s...',saveFile);
  save(saveFile,'exper','ana','dirs','files','cfg_proc','cfg_pp');
  fprintf('Done.\n');
  %else
  %  error('Not saving! %s already exists.\n',saveFile);
  %end
  
  % final step: destroy the job because this doesn't happen in runJob
  destroy(job);
  
else
  %% run the function locally
  
  % create a log of the command window output
  thisRun = [exper.name,'_stage1_',datestr(now,'ddmmmyyyy-HHMMSS')];
  % turn the diary on
  diary(fullfile(dirs.saveDirProc,[thisRun,'.log']));
  
  % use the peer toolbox
  %ana.usePeer = 1;
  ana.usePeer = 0;
  
  % Local: run all the subjects
  [exper] = create_ft_struct(ana,cfg_pp,exper,dirs,files);
  
  % save the analysis details; overwrite if it already exists
  saveFile = fullfile(dirs.saveDirProc,sprintf('analysisDetails.mat'));
  %if ~exist(saveFile,'file')
  fprintf('Saving %s...',saveFile);
  save(saveFile,'exper','ana','dirs','files','cfg_proc','cfg_pp');
  fprintf('Done.\n');
  %else
  %  error('Not saving! %s already exists.\n',saveFile);
  %end
  
  % turn the diary off
  diary off
end

function stage2(ana,cfg_proc,exper,dirs,runLocally,timeOut)
% stage2: process the input files with FieldTrip based on the analysis
% parameters

%% Process the data
if runLocally == 0
  %% Dream: create one task for each subject (i.e., submit one to each node)
  
  % start a new job
  job = newJob(dirs);
  
  adFile = fullfile(dirs.saveDirProc,'analysisDetails.mat');
  [exper,ana,dirs,files,cfg_proc,cfg_pp] = mm_ft_loadAD(adFile,true);
  
  % save the original subjects array so we can set exper to have single
  % subjects, one for each task created
  allSubjects = exper.subjects;
  
  for i = 1:length(allSubjects)
    fprintf('Processing %s...\n',allSubjects{i});
    
    % Dream: create one task for each subject
    exper.subjects = allSubjects(i);
    
    inArg = {ana,cfg_proc,exper,dirs};
    
    % save the exper struct (output 1) so we can use it later
    createTask(job,@process_ft_data,0,inArg);
  end
  
  runJob(job,timeOut,fullfile(dirs.saveDirProc,[exper.name,'_stage2_',datestr(now,'ddmmmyyyy-HHMMSS'),'.log']));
  
  % final step: destroy the job because this doesn't happen in runJob
  destroy(job);
  
else
  %% run the function locally
  
  % create a log of the command window output
  thisRun = [exper.name,'_stage2_',datestr(now,'ddmmmyyyy-HHMMSS')];
  % turn the diary on
  diary(fullfile(dirs.saveDirProc,[thisRun,'.log']));
  
  % use the peer toolbox
  %ana.usePeer = 1;
  ana.usePeer = 0;
  
  % Local: run all the subjects
  process_ft_data(ana,cfg_proc,exper,dirs);
  
  % turn the diary off
  diary off
end

function job = newJob(dirs)
% newJob Creates a new PCT job and sets job's dependencies
%
%   dirs -- data structure with necessary fields like data locations

% Set up scheduler, job
sched = findResource();
% sched = parcluster();
job = createJob(sched);
% define the directories to add to worker sessions' matlab path
homeDir = getenv('HOME');
myMatlabDir = fullfile(homeDir,'Documents','MATLAB');
p = path();
set(job, 'PathDependencies', {homeDir, myMatlabDir, pwd(), p, dirs.dataroot});

function runJob( job, timeOut, logFile )
% runJob Submits and waits on job to finish or timeout
%  runJob will submit the supplied job to the scheduler and will
% wait for the job to finish or until the timeout has been reached. 
% If the job finishes, then the command window outputs of all tasks
% are appended to the log file and the job is destroyed.
%   If the timeout is reached, an error is reported but the job is not
% destroyed.
%
%   job -- the job object to submit
%   timeOut -- the timeout value in hours
%   logFile -- full file name of the log file to append output to
%
% Example:
%       runJob( job, 5, 'thisrun.log');

% check/handle arguments
error(nargchk(1,3,nargin))
%narginchk(1,3)
TIMEOUT=3600*5; % default to 5 hours 
if nargin > 1
  TIMEOUT=timeOut*3600;
end
LOGFILE=[job.Name '.log'];
if nargin > 2
  LOGFILE = logFile;
end

% Capture command window output from all tasks
alltasks = get(job, 'Tasks');
set(alltasks, 'CaptureCommandWindowOutput', true);

% Submit Job/Tasks and wait for completion (or timeout)
submit(job)
finished = waitForState(job, 'finished', TIMEOUT);
if finished
  errors = logOutput(alltasks, LOGFILE);
  if errors
    error([mfilename ':logOutput'],'%s had %d errors',job.Name, errors)
  %elseif ~errors
  %  destroy(job);
  end
else
  error([mfilename ':JobTimeout'],'%s: Timed out waiting for job...NAME: %s',...
    datestr(now, 13), job.Name, job.ID, job.StartTime)
end

function numErrors=logOutput( tasks, logFile )
% logOutput - concatenates tasks' output into a logfile
%   tasks -- the tasks to capture output from 
%   logFile -- the file to log the output to
%   numErrors -- number of tasks which failed

% check for argument(s)
error(nargchk(2,2,nargin))
%narginchk(2,2)

numErrors=0;
try
  fid=fopen(logFile, 'a+');
  for i=1:length(tasks)
    fprintf(fid,'\n***** START TASK %d *****\n',i);
    fprintf(fid,'%s\n', tasks(i).CommandWindowOutput);
    if ~isempty(tasks(i).Error.stack)
      numErrors = numErrors +1;
      % write to log file
      fprintf( fid, 'ERROR: %s\n', tasks(i).Error.message );
      fprintf( fid, '%s\n', tasks(i).Error.getReport );
      % write to standard error
      fprintf( 2, 'ERROR: %s\n', tasks(i).Error.message );
      fprintf( 2, '%s\n', tasks(i).Error.getReport );
    end
    fprintf(fid,'\n***** END TASK %d *****\n',i);
  end
  fclose(fid);
catch ME
  disp(ME)
  warning([mfilename ':FailOpenLogFile'],...
    'Unable to write log file with task output...');
end
