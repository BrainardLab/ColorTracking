function [fixRect,color] = psyFixStm_CrossHairs(posXYpix, plySzXYpix, hairXYpix, fixType, colors, bPLOT, spcFctr)

% function [fixRect,color] = psyFixStm_CrossHairs(posXYpix, plySzXYpix, hairXYpix, fixType, colors, bPLOT, spcFctr)
%
%   example call:  % PLUS CROSSHAIRS
%                    psyFixStm_CrossHairs([0 0],[20 20],[2 10],'+',[],1);
%
%                  % 5  PICKET FENCE CROSSHAIRS
%                    psyFixStm_CrossHairs([0 0],[50 50],[2 50],'|||||',[],1);  
%  
%                  % 7  PICKET FENCE SLATS
%                    psyFixStm_CrossHairs([0 0],[50 50],[2 50],'|||||||',[],1);  
% 
%                  % 9  PICKET FENCE SLATS W. REDUCED SPACING
%                    psyFixStm_CrossHairs([0 0],[50 50],[2 50],'|||||||||',[],1,0.75);
% 
%                  % 11 PICKET FENCE SLATS W. REDUCED SPACING
%                    psyFixStm_CrossHairs([0 0],[50 50],[2 50],'|||||||||||',[],1,0.60);
%
%                  % 13 PICKET FENCE SLATS W. REDUCED SPACING
%                    psyFixStm_CrossHairs([0 0],[50 50],[2 50],'|||||||||||||',[],1,0.50);
%
%                  % 15 PICKET FENCE SLATS W. REDUCED SPACING
%                    psyFixStm_CrossHairs([0 0],[50 50],[2 50],'|||||||||||||||',[],1,3/7);
% 
% generates crosshair stimuli to mark targets in psychophysical experiments.
%
% posXYpix:     x,y position of fixation cross in pixels [1 x 2]
% plySzXYpix:   size of destination/target--tells the function how far away
% hairXYPix(1): thicknPix: the thicknPixess of each hair
% hairXYPix(2): lengthPix: the length of each hair
% fixType:      used to specify the type of crosshair
%               '+'               -> default, plus crosshair, monocular
%		        'L'               -> binocular left plus crosshairs, up and left hairs only
%		        'R'               -> binocular right plus crosshairs, down and right hairs only
%		        'O'               -> outer circle crosshair, used in conjunction with inner circle crosshair
%		        'o'               -> inner circle crosshair, used in con with outer circle crosshair
%               '|'               -> picket fence with 1  slat
%               '||'              -> picket fence with 2  slats
%               '|||'             -> picket fence with 3  slats (ODD)
%               '||||'            -> picket fence with 4  slats
%               '|||||'           -> picket fence with 5  slats (ODD)
%               '|||||||'         -> picket fence with 7  slats (ODD)
%               '|||||||||'       -> picket fence with 9  slats (ODD)
%               '|||||||||||'     -> picket fence with 11 slats (ODD)
%               '|||||||||||||'   -> picket fence with 13 slats (ODD)
%               '|||||||||||||||' -> picket fence with 15 slats (ODD)
% bPLOT:         plot or not
%                1 -> plot
%                0 -> not
% spcFctr:       factor   determining the spacing of picket fence fixations
%                NOTE! now functional only for (ODD) picket fence fixType 
%                [] -> default = 1.0      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fixRect:      coordinates for fixation stimulus crosshairs [ 4 x nRct ]
%               each column contains the Xmin, Ymax, Xmax, Ymin pix coord
%
% TODO
%     Accept arcmins instead fo  pixels
%
% -------------------------------------------------------------------------------

%INPUT CHECK
if ~exist('colors','var')  || isempty(colors) colors = {[0 0 0]; [.4 .4 .4]}; end
if ~exist('fixType','var') || isempty(fixType) fixType = '';                  end
if ~exist('bPLOT','var')   || isempty(bPLOT)   bPLOT   = 0;                   end
if ~exist('spcFctr','var') || isempty(spcFctr) spcFctr = 1;                   end

%MAKE INPUTS READABLE
X         = posXYpix(1);   %X coordinates to center
Y         = posXYpix(2);   %Y coordinates to center
XdistPix  = plySzXYpix(1); %X coordinate distance from center
YdistPix  = plySzXYpix(2); %Y coordinate distance from center
thicknPix = hairXYpix(1);  %thickness of crosshair
lengthPix = hairXYpix(2);  %length of crosshair

%PLUS CROSS HALF COMPONENTS, SPECIFIC TO EACH EYE
if strcmp(fixType,'L') || strcmp(fixType,'R')
	color=colors{1};
    if     strcmp(fixType,'L') %LEFT COMPONENTS
        fixRect = [ ...
            X,            Y+YdistPix, X,                    Y+YdistPix+lengthPix; ... %up
            X - XdistPix, Y,          X-XdistPix-lengthPix, Y;   ... %left
        ]';

    elseif strcmp(fixType,'R') %RIGHT COMPONENTS
        fixRect = [ ...
            X,            Y-YdistPix, X,                    Y-YdistPix-lengthPix; ... %down
            X + XdistPix, Y,          X+XdistPix+lengthPix, Y;  ... %right
        ]';
    end

%DIAGNOL CROSS STIMUlUS (THESE WILL BE LINES NOT RECTANGLES)
elseif strcmp(fixType,'X')
	color=colors{1};
    fixRect = [...
        X+XdistPix*cos(pi*1/4), Y+XdistPix*sin(pi*1/4), X+(lengthPix+XdistPix)*cos(pi*1/4), Y+(lengthPix+XdistPix)*sin(pi*1/4); ...
        X+XdistPix*cos(pi*3/4), Y+XdistPix*sin(pi*3/4), X+(lengthPix+XdistPix)*cos(pi*3/4), Y+(lengthPix+XdistPix)*sin(pi*3/4); ...
        X+XdistPix*cos(pi*5/4), Y+XdistPix*sin(pi*5/4), X+(lengthPix+XdistPix)*cos(pi*5/4), Y+(lengthPix+XdistPix)*sin(pi*5/4); ...
        X+XdistPix*cos(pi*7/4), Y+XdistPix*sin(pi*7/4), X+(lengthPix+XdistPix)*cos(pi*7/4), Y+(lengthPix+XdistPix)*sin(pi*7/4)  ...
    ]';

%OUTER CIRCLE
elseif strcmp(fixType,'O')
	color=colors{1};
	R=sqrt(YdistPix^2+YdistPix^2);
	fixRect = [ ...
        X + XdistPix, Y + YdistPix, X-XdistPix, Y-YdistPix; ...
        X + XdistPix, Y + YdistPix, X-XdistPix, Y-YdistPix  ...
    ]';

% INNER CIRCLE
elseif strcmp(fixType,'o')
	color=colors{2};
    R=sqrt((YdistPix-thicknPix)^2+(XdistPix-thicknPix)^2);
    fixRect = [ ...
        X + XdistPix - thicknPix, Y + YdistPix - thicknPix, X-XdistPix + thicknPix, Y-YdistPix + thicknPix; ...
        X + XdistPix - thicknPix, Y + YdistPix - thicknPix, X-XdistPix + thicknPix, Y-YdistPix + thicknPix  ...
    ]';

%FULL PLUS CROSS FOR NON-BI
elseif  strcmp(fixType,'') || strcmp(fixType,'+')
	color=colors{1};
    fixRect = [...
        X - thicknPix, Y+YdistPix,  X+thicknPix,          Y+YdistPix+lengthPix; ...   %up
        X - thicknPix, Y-YdistPix,  X+thicknPix,          Y-YdistPix-lengthPix; ...   %down
        X + XdistPix,  Y+thicknPix, X+XdistPix+lengthPix, Y-thicknPix;          ...   %right
        X - XdistPix,  Y+thicknPix, X-XdistPix-lengthPix, Y-thicknPix           ...   %left
    ]';

%PICKET FENCE FIXATION FOR NON-BI WITH 1 SLAT
elseif  strcmp(fixType,'|')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
XdistPix = XdistPix/2;

fixRect = [...
    X - thicknPix,              Y+YdistPix,  X+thicknPix,            Y+YdistPix+lengthPix; ...   %up
    X - thicknPix,              Y-YdistPix,  X+thicknPix,            Y-YdistPix-lengthPix; ...   %down
]';


%PICKET FENCE FIXATION FOR NON-BI WITH 2 SLATS
elseif  strcmp(fixType,'||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix + XdistPix/2, Y+YdistPix,  X+thicknPix + XdistPix/2, Y+YdistPix+lengthPix; ...   %up right
        X - thicknPix - XdistPix/2, Y+YdistPix,  X+thicknPix - XdistPix/2, Y+YdistPix+lengthPix; ...   %up left
        X - thicknPix + XdistPix/2, Y-YdistPix,  X+thicknPix + XdistPix/2, Y-YdistPix-lengthPix; ...   %down right
        X - thicknPix - XdistPix/2, Y-YdistPix,  X+thicknPix - XdistPix/2, Y-YdistPix-lengthPix; ...   %down left
    ]';


%PICKET FENCE FIXATION FOR NON-BI WITH 3 SLATS
elseif  strcmp(fixType,'|||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
    XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix,                         Y+YdistPix,  X+thicknPix                       ,   Y+YdistPix+lengthPix; ...   %up
        X - thicknPix +    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x right
        X - thicknPix -    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x left
        X - thicknPix,                         Y-YdistPix,  X+thicknPix                       ,   Y-YdistPix-lengthPix; ...   %down
        X - thicknPix +    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x right
        X - thicknPix -    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x left
              ]'; 

%PICKET FENCE FIXATION FOR NON-BI WITH 4 SLATS
elseif  strcmp(fixType,'||||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
    XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix + XdistPix/2,   Y+YdistPix,  X+thicknPix + XdistPix/2,    Y+YdistPix+lengthPix; ...   %up right
        X - thicknPix - XdistPix/2,   Y+YdistPix,  X+thicknPix - XdistPix/2,    Y+YdistPix+lengthPix; ...   %up left
        X - thicknPix + 3*XdistPix/2, Y+YdistPix,  X+thicknPix + 3*XdistPix/2,  Y+YdistPix+lengthPix; ...   %up 1.5x right
        X - thicknPix - 3*XdistPix/2, Y+YdistPix,  X+thicknPix - 3*XdistPix/2,  Y+YdistPix+lengthPix; ...   %up 1.5x right
        X - thicknPix + XdistPix/2,   Y-YdistPix,  X+thicknPix + XdistPix/2,    Y-YdistPix-lengthPix; ...   %down right
        X - thicknPix - XdistPix/2,   Y-YdistPix,  X+thicknPix - XdistPix/2,    Y-YdistPix-lengthPix; ...   %down left
        X - thicknPix + 3*XdistPix/2, Y-YdistPix,  X+thicknPix + 3*XdistPix/2,  Y-YdistPix-lengthPix; ...   %up 1.5x right
        X - thicknPix - 3*XdistPix/2, Y-YdistPix,  X+thicknPix - 3*XdistPix/2,  Y-YdistPix-lengthPix; ...   %up 1.5x left
              ]';

%PICKET FENCE FIXATION FOR NON-BI WITH 5 SLATS
elseif  strcmp(fixType,'|||||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
    XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix,                         Y+YdistPix,  X+thicknPix                       ,   Y+YdistPix+lengthPix; ...   %up
        X - thicknPix +    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x right
        X - thicknPix -    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x left
        X - thicknPix,                         Y-YdistPix,  X+thicknPix                       ,   Y-YdistPix-lengthPix; ...   %down
        X - thicknPix +    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x right
        X - thicknPix -    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x left
              ]'; 

%PICKET FENCE FIXATION FOR NON-BI WITH 7 SLATS
elseif  strcmp(fixType,'|||||||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
    XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix,                         Y+YdistPix,  X+thicknPix                       ,   Y+YdistPix+lengthPix; ...   %up
        X - thicknPix +    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x right
        X - thicknPix -    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x left
        X - thicknPix,                         Y-YdistPix,  X+thicknPix                       ,   Y-YdistPix-lengthPix; ...   %down
        X - thicknPix +    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x right
        X - thicknPix -    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x left
              ]';    

%PICKET FENCE FIXATION FOR NON-BI WITH 9 SLATS WITH REDUCED SPACING
elseif  strcmp(fixType,'|||||||||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
    XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix,                         Y+YdistPix,  X+thicknPix                       ,   Y+YdistPix+lengthPix; ...   %up
        X - thicknPix +    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x right
        X - thicknPix + 4.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 4.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   4x right
        X - thicknPix -    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x left
        X - thicknPix - 4.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 4.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   4x left
        X - thicknPix,                         Y-YdistPix,  X+thicknPix                       ,   Y-YdistPix-lengthPix; ...   %down
        X - thicknPix +    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x right
        X - thicknPix + 4.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 4.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 4x right
        X - thicknPix -    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x left
        X - thicknPix - 4.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 4.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 4x left
              ]';     
%PICKET FENCE FIXATION FOR NON-BI WITH 11 SLATS 
elseif  strcmp(fixType,'|||||||||||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
    XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix,                         Y+YdistPix,  X+thicknPix                       ,   Y+YdistPix+lengthPix; ...   %up
        X - thicknPix +    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x right
        X - thicknPix + 4.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 4.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   4x right
        X - thicknPix + 5.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 5.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   5x right
        X - thicknPix -    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x left
        X - thicknPix - 4.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 4.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   4x left
        X - thicknPix - 5.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 5.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   5x left
        X - thicknPix,                         Y-YdistPix,  X+thicknPix                       ,   Y-YdistPix-lengthPix; ...   %down
        X - thicknPix +    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x right
        X - thicknPix + 4.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 4.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 4x right
        X - thicknPix + 5.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 5.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 5x right
        X - thicknPix -    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x left
        X - thicknPix - 4.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 4.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 4x left
        X - thicknPix - 5.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 5.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 5x left
              ]';     
%PICKET FENCE FIXATION FOR NON-BI WITH 13 SLATS 
elseif  strcmp(fixType,'|||||||||||||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
    XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix,                         Y+YdistPix,  X+thicknPix                       ,   Y+YdistPix+lengthPix; ...   %up
        X - thicknPix +    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x right
        X - thicknPix + 4.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 4.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   4x right
        X - thicknPix + 5.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 5.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   5x right
        X - thicknPix + 6.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 6.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   6x right
        X - thicknPix -    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x left
        X - thicknPix - 4.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 4.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   4x left
        X - thicknPix - 5.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 5.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   5x left
        X - thicknPix - 6.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 6.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   6x left
        X - thicknPix,                         Y-YdistPix,  X+thicknPix                       ,   Y-YdistPix-lengthPix; ...   %down
        X - thicknPix +    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x right
        X - thicknPix + 4.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 4.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 4x right
        X - thicknPix + 5.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 5.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 5x right
        X - thicknPix + 6.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 6.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 6x right
        X - thicknPix -    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x left
        X - thicknPix - 4.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 4.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 4x left
        X - thicknPix - 5.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 5.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 5x left
        X - thicknPix - 6.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 6.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 6x left
              ]';   
%PICKET FENCE FIXATION FOR NON-BI WITH 15 SLATS 
elseif  strcmp(fixType,'|||||||||||||||')
	color=colors{1};
    if  thicknPix >= XdistPix/2;
        disp(['psyFixStm_CrossHairs: WARNING! Hairs will overlap. Decrease thickness or increase size of the destination target']);
    end
    XdistPix = XdistPix/2;

    fixRect = [...
        X - thicknPix,                         Y+YdistPix,  X+thicknPix                       ,   Y+YdistPix+lengthPix; ...   %up
        X - thicknPix +    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x right
        X - thicknPix + 4.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 4.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   4x right
        X - thicknPix + 5.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 5.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   5x right
        X - thicknPix + 6.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 6.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   6x right
        X - thicknPix + 7.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix + 7.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   7x right
        X - thicknPix -    spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   3x left
        X - thicknPix - 4.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 4.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   4x left
        X - thicknPix - 5.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 5.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   5x left
        X - thicknPix - 6.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 6.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   6x left
        X - thicknPix - 7.*spcFctr.*XdistPix,  Y+YdistPix,  X+thicknPix - 7.*spcFctr.*XdistPix,   Y+YdistPix+lengthPix; ...   %up   7x left
        X - thicknPix,                         Y-YdistPix,  X+thicknPix                       ,   Y-YdistPix-lengthPix; ...   %down
        X - thicknPix +    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix +    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x right
        X - thicknPix + 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x right
        X - thicknPix + 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x right
        X - thicknPix + 4.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 4.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 4x right
        X - thicknPix + 5.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 5.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 5x right
        X - thicknPix + 6.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 6.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 6x right
        X - thicknPix + 7.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix + 7.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 7x right
        X - thicknPix -    spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix -    spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 1x left
        X - thicknPix - 2.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 2.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 2x left
        X - thicknPix - 3.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 3.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 3x left
        X - thicknPix - 4.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 4.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 4x left
        X - thicknPix - 5.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 5.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 5x left
        X - thicknPix - 6.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 6.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 6x left
        X - thicknPix - 7.*spcFctr.*XdistPix,  Y-YdistPix,  X+thicknPix - 7.*spcFctr.*XdistPix,   Y-YdistPix-lengthPix; ...   %down 7x left
              ]';   
else
    error(['psyFixStm_CrossHairs: WARNING! unhandled fixType=' fixType]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT FIXATION %
%%%%%%%%%%%%%%%%%
if bPLOT == 1
    figure; hold on;
    for i = 1:size(fixRect,2)
    plot(fixRect([1 1 3 3 1],i),fixRect([2 4 4 2 2],i),'k');
    end
    formatFigure('X position','Y position');
    axis(max(abs(axis)).*[-1 1 -1 1]);
    axis square;
end
