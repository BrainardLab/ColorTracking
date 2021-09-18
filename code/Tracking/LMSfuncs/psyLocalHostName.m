function localHostName = psyLocalHostName()

% function localHostName = psyLocalHostName()
%
%   example call: localHostName = psyLocalHostName()
%
% returns the computer's local host name
% %%%%%%%%%%%%%%%%%%%%%%%
% localHostName:  duh!

if strcmp(computer,'GLNXA64')
    [~, localHostName] = system('hostname');
else
    [~, localHostName] = system('scutil --get LocalHostName');
end
localHostName = localHostName(1:end-1);
