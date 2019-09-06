% MIT License
%
% Copyright (c) 2019
% Marcus Vinicius Sousa Leite de Carvalho
% marcus.decarvalho@ntu.edu.sg
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

classdef ElasticNodes < handle
    %ELASTICNODES It encapsulate global variables necessary for width
    %adaptation
    %
    %   This class enabless elastic network width. Network width adaptation
    %   supports automatic generation of new hidden nodes and prunning of 
    %   inconsequential nodes. This mechanism is controlled by the NS 
    %   (Network Significance) method which estimates the network 
    %   generalization power in terms of bias and variance
    properties (Access = public)
        
        growable; % See full comment below
        % Hold an array of boolean elements indicating if that layer can 
        % receive grow or not during width adaptation procedure
        
        prunable; % See full comment below
        % Hold an array of integer elements indicating if that layer can 
        % receive prune or not during width adaptation procedure.
        % 0 indicates that no node should be pruned. Anything different
        % than zero indicantes which node should be pruned in that layer. 
    end
    properties (Access = public)
        dataMean = 0;
        dataStd = 0;
        dataVar = 0;
        
        nSamplesFeed = 0;
        nSamplesLayer;
        
        % NS = Network Significance
        %BIAS VARIABLES
        meanBIAS;
        varBIAS;
        stdBIAS;
        minMeanBIAS;
        minStdBIAS;
        BIAS2;
        %VAR VARIABLES
        meanVAR;
        varVAR;
        stdVAR;
        minMeanVAR;
        minStdVAR;
        VAR;
        
        % metrics
        nodeEvolution = {}; % TODO: Need to include at the grow/prune part
    end
    %% Evolving layers properties
    properties (Access = public)
        alpha = 0.005;
        gradientBias = [];
        meanNetBias2;
        meanNetVar;
    end
    
    methods (Access = protected)
        function self = ElasticNodes(nHiddenLayers)
            nhl = nHiddenLayers; % readability
            
            self.nSamplesLayer = zeros(1,nhl);
            self.meanBIAS = zeros(1,nhl);
            self.varBIAS = zeros(1,nhl);
            self.stdBIAS = zeros(1,nhl);
            self.minMeanBIAS = ones(1,nhl) * inf;
            self.minStdBIAS = ones(1,nhl) * inf;
            self.BIAS2 = num2cell(zeros(1,nhl));
            
            self.meanVAR = zeros(1,nhl);
            self.varVAR = zeros(1,nhl);
            self.stdVAR = zeros(1,nhl);
            self.minMeanVAR = ones(1,nhl) * inf;
            self.minStdVAR = ones(1,nhl) * inf;
            self.VAR = num2cell(zeros(1,nhl));
        
            self.growable = zeros(1,nhl);
%             self.prunable = zeros(1,nhl);
            self.prunable = cell(1,nhl);
            for i = 1 : nhl
               self.prunable{i} = 0;
            end
        end
        
        function growLayerEvolutiveParameter(self, numberHiddenLayers)
            nhl = numberHiddenLayers; %readability
            
            self.nSamplesLayer = [self.nSamplesLayer, 0];
            self.meanBIAS      = [self.meanBIAS, 0];
            self.varBIAS       = [self.varBIAS, 0];
            self.stdBIAS       = [self.stdBIAS, 0];
            self.minMeanBIAS   = [self.minMeanBIAS, 0];
            self.minStdBIAS    = [self.minStdBIAS, 0];
            self.BIAS2         = [self.BIAS2, 0];
            
            self.meanVAR    = [self.meanVAR, 0];
            self.varVAR     = [self.varVAR, 0];
            self.stdVAR     = [self.stdVAR, 0];
            self.minMeanVAR = [self.minMeanVAR, 0];
            self.minStdVAR  = [self.minStdVAR, 0];
            self.VAR        = [self.VAR, 0];
            
            self.growable = zeros(1, nhl + 1);
            self.prunable = cell(1, nhl + 1);
            for i = 1 : nhl + 1
               self.prunable{i} = 0;
            end
        end
    end
end

