function computerInfo = psyGetComputerInfo()

% function computerInfo = psyGetComputerInfo()
%  
%   example call: computerInfo = psyGetComputerInfo()
%
% gets basic information about the computer and user.
%
%%%%%%%%%%%%%%%%%%%%%%%%%
% computerInfo: structure containing computer & user information w fields
%                  .localHostName
%                  .architecture
%                  .platform
%                  .numCPUs
%                  .physicalMemory
%                  .userShortName
%                  .userLongName
%                  .OSversion 
%                  .networkName
%                  .macAddress


% LOCAL HOST NAME
[~, localHostName] = system('scutil --get LocalHostName');
computerInfo.localHostName = localHostName(1:end-1);

% MAC ARCHITECTURE (i.e. chip type) 
[~, architecture] = system('uname -p');
computerInfo.architecture = architecture(1:end-1);

% MATLAB PLATFORM: MAC (PPC), MACI (32-bit Intel), or MACI64 (64-bit Intel).
computerInfo.platform = computer;

% NUMBER OF CPUS
[~, numCPUs] = system('sysctl -n hw.ncpu');
computerInfo.numCPUs = str2double(numCPUs(1:end-1));

% PHYSICAL MEMORY
[~, physicalMemory] = system('sysctl -n hw.physmem');
computerInfo.physicalMemory = str2double(physicalMemory(1:end-1)) / 1024^2;

% SHORT NAME OF CURRENT USER
[~, userShortName] = system('id -un');
computerInfo.userShortName = userShortName(1:end-1);

% LONG NAME OF CURRENT USER
directoryCommand = sprintf('dscl . read /users/%s RealName', ...
	computerInfo.userShortName);
[~, userLongName] = system(directoryCommand);
computerInfo.userLongName = userLongName(11:end-1);

% OS VERSION
[~, OSversion] = system('sw_vers -productVersion');
computerInfo.OSversion = OSversion(1:end-1);

% NETWORK NAME OF COMPUTER
[~, networkName] = system('uname -n');
computerInfo.networkName = networkName(1:end-1);

% MAC ADDRESS
[~, s] = system('ifconfig en0 ether');
i = strfind(s, 'ether ');
computerInfo.macAddress = upper(s(i+length('ether '):end-2));
