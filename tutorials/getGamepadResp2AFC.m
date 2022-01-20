function bttnPress = getGamepadResp2AFC(varargin)
%% Get button responses from gamepad for 2 AFC task
%
% Synopsis
%    bttnPress = getGamepadResp2AFC(varargin)
%
% Description
%  This function get responses from 2 buttons from the gamepad and returns 
%  a 1 or 2 output response. The buttons can be defined as key/value pairs.
%
% Inputs
%  -none.
%
% Key/val pairs
%  bttnOneNum  -- The button number on the gamepad corresponding to the 
%                 first interval. default "A" on Longitech F310.
%  bttnTwoNum  -- The button number on the gamepad corresponding to the 
%                 second interval. default "Y" on Longitech F310.
% Output
%  bttnPress   -- The recorded button press corresponding to the button 
%                 mapping 

% MAB 01/20/22 -- started

% Input Parser
p = inputParser; p.KeepUnmatched = true; p.PartialMatching = false;
p.addParameter('bttnOneNum',1,@isnumeric);
p.addParameter('bttnTwoNum',4,@isnumeric);
p.addParameter('pauseTime',0,@isnumeric);
p.parse(varargin{:});
%% get the gamepad info
gamepadIndex = Gamepad('GetNumGamepads');

bttnOneNum = p.Results.bttnOneNum;
bttnTwoNum = p.Results.bttnTwoNum;
pauseTime  = p.Results.pauseTime;

buttonState1 = 0;
buttonState2 = 0;

while buttonState1 == false && buttonState2 == false
    
    buttonState1 = Gamepad('GetButton', gamepadIndex, bttnOneNum);
    buttonState2 = Gamepad('GetButton', gamepadIndex, bttnTwoNum);
end


if buttonState1 == true && buttonState2 == false
    bttnPress = 1;
elseif  buttonState1 == false && buttonState2 == true
    bttnPress = 2;
else
    bttnPress = 0;
end


while buttonState1 == true || buttonState2 == true
    buttonState1 = Gamepad('GetButton', gamepadIndex, bttnOneNum);
    buttonState2 = Gamepad('GetButton', gamepadIndex, bttnTwoNum);
end

pause(pauseTime)

end
