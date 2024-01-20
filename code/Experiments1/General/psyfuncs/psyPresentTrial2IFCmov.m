function screenStim = psyPresentTrial2IFCmov(D,S,t,stdStm,cmpStm,msk1oF)

% function psyPresentTrial2IFCmov(D,S,t,stdStm,cmpStm,msk1oF)
%
%   example call:
% 
% present 2IFC psychophysical trial with standard and comparison
% stimulus images (or movies)
%
% D:          display structure with critical fields
%             .winPtr       -> window pointer
%             .fixStm       -> fixation stimulus
% S:          subject structure with critical fields
%             .numIntrvl     -> number of intervals
%             .cmpIntrvl     -> which interval is comparison interval
%             .numFrm        -> number of frames per stimulus
%             .ISI           -> inter-stimulus interval
% t:          trial number
% stdStm:     standard   stimulus movie [ n x m x S.numFrm ]
% cmpStm:     comparison stimulus movie [ n x m x S.numFrm ]
% msk1oF:     optional 1/F surround
% screenStim: stimulus that was presented on the screen (x by y by t movie
%             array)

bVIDSWTCH = 0;

% INPUT HANDLING
if S.numFrm(t) ~= size(stdStm,length(size(stdStm))) error(['psyPresentTrial2IFCmov: WARNING! S.numFrm(t)=' num2str(S.numFrm(t)) ' ~= number of frames in stdStm=[' num2str(size(stdStm)) ']']); end
if S.numFrm(t) ~= size(cmpStm,length(size(cmpStm))) error(['psyPresentTrial2IFCmov: WARNING! S.numFrm(t)=' num2str(S.numFrm(t)) ' ~= number of frames in cmpStm=[' num2str(size(cmpStm)) ']']); end

% USE 1/F TEXTURE OR NOT
if ~exist('msk1oF','var') || isempty(msk1oF)
    bUseMsk = 0;
else
    if size(msk1oF,2) == D.scrnXYpix(1) && size(msk1oF,1) == D.scrnXYpix(2)
    bUseMsk = 1;
    else
        error(['psyPresentTrial2IFCmov: WARNING! texture mask ''msk1oF'' not sized properly... Double check inputs']);
    end
end

% INITIALIZE SCREEN STIMULUS ARRAY
screenStim = [];

%%%%%%%%%%%%%%%%%
% PRESENT TRIAL %
%%%%%%%%%%%%%%%%%
for i = 0:[S.numIntrvl-1]
%    sound(sin(0.54.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));
    % DRAW 1/F
    if bUseMsk, tex1oF = Screen('MakeTexture', D.wdwPtr, msk1oF,[],[],2); end % WARNING! REMEMBER TO CLOSE TEXTURES!
    for f = 1:S.numFrm(t)
        if bVIDSWTCH == 0
            % CREATE STIMULUS TEXTURE FOR EACH FRAME
            texStd  = Screen('MakeTexture', D.wdwPtr, stdStm(:,:,f),[],[],2);  % WARNING! REMEMBER TO CLOSE TEXTURES!
            texCmp  = Screen('MakeTexture', D.wdwPtr, cmpStm(:,:,f),[],[],2);
        elseif bVIDSWTCH == 1
            % CREATE STIMULUS TEXTURE FOR EACH FRAME
            texStd  = Screen('MakeTexture', D.wdwPtr, stdStm(:,:,:,f),[],[],2);  % WARNING! REMEMBER TO CLOSE TEXTURES!
            texCmp  = Screen('MakeTexture', D.wdwPtr, cmpStm(:,:,:,f),[],[],2);
        end
        % DRAW FIXATION STIMULUS
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
        %%%%%%%%%%%%%%
        % INTERVAL 1 % PRESENT STD or CMP STIMULUS (AS APPROPRIATE)
        %%%%%%%%%%%%%%
        if i == 0
            if     S.cmpIntrvl(t) == 0
                Screen('DrawTexture', D.wdwPtr, texCmp, [], D.plySqrPix);
            elseif S.cmpIntrvl(t) == 1
                Screen('DrawTexture', D.wdwPtr, texStd, [], D.plySqrPix);
            end
        end
        %%%%%%%%%%%%%%
        % INTERVAL 2 % PRESENT CMP or STD STIMULUS (AS APPROPRIATE)
        %%%%%%%%%%%%%%
        if i == 1
            if     S.cmpIntrvl(t) == 0
                % t0 = GetSecs;
                Screen('DrawTexture', D.wdwPtr, texStd, [], D.plySqrPix);
                % Secs_DrawTexture(t) = GetSecs-t0;
            elseif S.cmpIntrvl(t) == 1
                % t0 = GetSecs;
                Screen('DrawTexture', D.wdwPtr, texCmp, [], D.plySqrPix);
                % Secs_DrawTexture(t) = GetSecs-t0;
            end
        end
        % DRAW 1/F TEXTURE
        if bUseMsk, Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix); end

        % CLOSE TEXTURES
        Screen('Close', texStd);
        Screen('Close', texCmp);

        % FLIP SCREEN
        Screen('Flip', D.wdwPtr);
        % GRAB SCREEN STIMULUS IMMEDIATELY AFTER FLIP
        imageArray = double(Screen('GetImage',D.wdwPtr,D.plySqrPix));
        screenStim(:,:,:,f) = imageArray; 
    end

        % DRAW FIXATION CROSS
        Screen('FillRect', D.wdwPtr, [D.wht,D.wht,D.wht], D.fixStm);
        % DRAW 1/F TEXTURE
        if bUseMsk
        Screen('DrawTexture', D.wdwPtr, tex1oF, [],D.wdwXYpix);
        Screen('Close', tex1oF);
        end

        % FLIP SCREEN
        Screen('Flip', D.wdwPtr);

        % PAUSE FOR ISI BETWEEN INTERVALS
        if i == 0, pause(S.isi); end
end
