%CREATE CLASS P (which contains methods for plotting and closing)
%XXX Handle Struct inputs
classdef PCclass < handle
    properties
        bPlot;
        bDataPixx;
    end
    methods
        function obj = PCclass(varargin)
            %Pass any varargin variable into class with variable name from parent function
            vn=cell(length(varargin),1);
            for i = 1:length(varargin);
                vn{i}=genvarname(inputname(i));
                evalc([vn{i} '=varargin{i}']);
            end

            if exist('D.bPlot')==1
                a=D.bPlot;
            elseif exist('D.bPLOT')==1
                a=D.bPLOT;
            elseif exist('bPlot')==1
                a=bPlot;
            elseif exist('bPLOT')==1
                a=bPLOT;
            else
                a=0;
            end

            if exist('D.bDataPixx')==1
                b=D.bDataPixx;
            elseif exist('bDataPixx')==1
                b=bDataPixx;
            else
                b=0;
            end

            obj.bPlot = a;
            obj.bDataPixx = b;
        end

        function [] = PC(obj,S)
            if obj.bPlot == 1                               % PLOT DATA %
                psyfitgengauss(S.stdX,S.cmpX,S.R==S.cmpIntrvl,[],[],1,1.36,1);
            end
            sca
            if obj.bDataPixx    == 1;
                psyDatapixxClose();
            end
        end
    end
end
