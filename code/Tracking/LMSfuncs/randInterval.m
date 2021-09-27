function r = randInterval(range,n,m,p,loc)

% function randInterval(range,n,m,p,loc)
%
%   example calls: % TO GET 1 SAMPLES FROM INTERVAL [0 10]
%                    randInterval([0 10])           
%
%                  % TO GET 10 SAMPLES FROM INTERVAL [0 10]
%                    randInterval([0 10],10,1)           
% 
%                  % TO GET 10 SAMPLES FROM EACH OF THREE RANGES
%                    randInterval([-1 -10 -100; 1 10 100],10,3)
%                     
%                  % TO GET 100000 SAMPLES FROM RIGHTMOST 40% OF INTERVAL [0 10]
%                  hist(randInterval([0 10]',1,100000,.4,'right'),linspace(0,10,100)); xlim([0 10])
%                    
% random sample from uniform distribution within specified range
%
% range:      minimum and maximum intervals of range          [2 x numDims]
% n:          num rows of matrix of randomly sampled values      
% m:          num cols of matrix of randomly sampled values 
% p:          proportion of range to sample from
%             []   -> defaults to one
%             0.25 -> central 1/4 of range
% %%%%%%%%%%%
% r:      random sample(s)

% INPUT HANDLING
if ~exist('n','var')   || isempty(n)     n=1;             end
if ~exist('m','var')   || isempty(m)     m=size(range,2); end
if ~exist('p','var')   || isempty(p)     p=1;             end
if ~exist('loc','var') || isempty(loc)   loc = 'middle';  end

% SETUP RANGE
if size(range,1)==1 & size(range,2)==2 range = range';  end 

% ALGORITHM
% r = range(:,1) + (range(:,2)-(range(:,1))).*rand(n,m);
if    strcmp(loc,'left')
    r = bsxfun(@plus,range(1,:),                                     p.*bsxfun(@times,(range(2,:)-range(1,:)),rand(n,m)) );
elseif strcmp(loc,'middle')
    r = bsxfun(@plus,range(1,:) + 0.5.*(1-p).*(range(2,:)-range(1,:)),    p.*bsxfun(@times,(range(2,:)-range(1,:)),rand(n,m)) );
elseif strcmp(loc,'right')
    r = bsxfun(@plus,range(1,:) +     p.*(range(2,:)-range(1,:)),0.5.*(1-p).*bsxfun(@times,(range(2,:)-range(1,:)),rand(n,m)) );
    r = bsxfun(@minus,range(2,:),                                    p.*bsxfun(@times,(range(2,:)-range(1,:)),rand(n,m)) );
else
    error(['randInterval: WARNING! unhandled loc=' num2str(loc,'%.2f')]);
end