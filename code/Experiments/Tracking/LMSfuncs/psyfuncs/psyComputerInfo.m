function cmpInfo = psyComputerInfo()

% function cmpInfo = psyComputerInfo()
%  
%   example call: cmpInfo = psyComputerInfo()
%
% gets basic information about the computer and user
%
%%%%%%%%%%%%%%%%%%%%%%%%%
% cmpInfo: structure containing computer & user information w fields
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
if strcmp(computer,'GLNXA64')
    [~, localHostName] = system('hostname');
    cmpInfo.localHostName = localHostName(1:end-1);
elseif strcmp(computer,'PCWIN64')
    cmpInfo.localHostName = getenv('COMPUTERNAME');
else
    [~, localHostName] = system('scutil --get LocalHostName');
    cmpInfo.localHostName = localHostName(1:end-1);
end


% MAC ARCHITECTURE (i.e. chip type) 
if strcmp(computer,'GLNXA64')
    [~, localHostName] = system('lscpu | grep Architecture: | awk ''{print $2}''');
else
    [~, architecture] = system('uname -p');
    cmpInfo.architecture = architecture(1:end-1);
end

% MATLAB PLATFORM: MAC (PPC), MACI (32-bit Intel), or MACI64 (64-bit Intel).
cmpInfo.platform = computer;

% NUMBER OF CPUS
if strcmp(computer,'GLNXA64')
    [~, numCPUs] = system('nproc');
else
    [~, numCPUs] = system('sysctl -n hw.ncpu');
end
cmpInfo.numCPUs = str2double(numCPUs(1:end-1));

% PHYSICAL MEMORY
if strcmp(computer,'GLNXA64')
    [~, physicalMemory] = system('cat /proc/meminfo | grep MemTotal: | awk ''{print $2}''');
    cmpInfo.physicalMemory = str2double(physicalMemory)*1e-6;
else
    [~, physicalMemory] = system('sysctl -n hw.physmem');
    cmpInfo.physicalMemory = str2double(physicalMemory(1:end-1)) / 1024^2;
end

% SHORT NAME OF CURRENT USER
[~, userShortName] = system('id -un');
cmpInfo.userShortName = userShortName(1:end-1);

% LONG NAME OF CURRENT USER
if strcmp(computer,'GLNXA64')
    [~, userLongName] = system('getent passwd "username" | cut -d ':' -f 5');
    cmpInfo.userLongName = userLongName;
else
    directoryCommand = sprintf('dscl . read /users/%s RealName', ...
        cmpInfo.userShortName);
    [~, userLongName] = system(directoryCommand);
    cmpInfo.userLongName = userLongName(11:end-1);
end

% OS VERSION
if strcmp(computer,'GLNXA64')
    [~, OSversion] = system('uname -r');
else
    [~, OSversion] = system('sw_vers -productVersion');
end
cmpInfo.OSversion = OSversion(1:end-1);

% NETWORK NAME OF COMPUTER
[~, networkName] = system('uname -n');
cmpInfo.networkName = networkName(1:end-1);

% MAC ADDRESS
if strcmp(computer,'GLNXA64')
    [~, s] = system('ip addr | grep ether | awk ''{print $2}''');
    cmpInfo.macAddres = s;
else
    [~, s] = system('ifconfig en0 ether');
    i = strfind(s, 'ether ');
    cmpInfo.macAddress = upper(s(i+length('ether '):end-2));
end
