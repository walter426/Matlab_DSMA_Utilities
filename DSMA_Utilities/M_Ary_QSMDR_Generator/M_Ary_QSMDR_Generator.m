%{
/***************************************************************************
         M-Ary-Quadrature Signal Modulation Decision Region Generator
                             -------------------
    begin                : 2013-08-16
    copyright            : (C) 2013 by Walter Tsui
    email                : waltertech426@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

%}

clc
clear all;

%Add Utilities
[Dir, file, ext] = fileparts(mfilename('fullpath'));
addpath(strcat(Dir, '\..\utils'))

%generate own symbol set
seed = 06098231;
SymbolSet = RandomQSS_Generator(seed, 4, [1:3]);


%for convinience, different SymbolSet are typed below
%the first one is my own symbol set used in this project
%SymbolSet = [1 1; -2 1; -2 -3; 3 -1];

%SymbolSet = [1 2; -3 3; -2 -2; 1 -2];
%SymbolSet = [2 1; -3 1; -2 -2; 1 -1];
%SymbolSet = [1 2; -1 2; -2 -1; 3 -2];
%SymbolSet = [1 2; -3 1; -1 -3; 2 -3];
%SymbolSet = [1 1; -1 3; -3 -1; 3 -2];
%SymbolSet = [1 2; -3 1; -1 -2; 1 -1];
%SymbolSet = [2 1; -1 1; -2 -2; 2 -3];
%SymbolSet = [1 3; -1 3; -3 -3; 1 -1];
%SymbolSet = [3 3; -1 1; -2 -2; 3 -3];
%SymbolSet = [2 1; -2 3; -2 -1; 3 -1];
%SymbolSet = [3 1; -2 2; -2 -2; 2 -1];
%SymbolSet = [3 2; -2 1; -2 -2; 1 -1];
%SymbolSet = [1 1; -2 2; -1 -2; 1 -3];
%SymbolSet = [1 1; 1 -1; -1 1; -1 -1; 1 0; -1 0; 0 1; 0 -1];

[NumOfSignal, dim] = size(SymbolSet);
ProbSet = ones(1,NumOfSignal)/NumOfSignal;
%ProbSet = [0.2,0.2,0.2,0.2,0.2];
%ProbSet = [0.25,0.25,0.25,0.25];
%ProbSet = [0.5, 0.3, 0.1, 0.1];
%ProbSet = [1/15, 2/15, 4/15, 8/15];

No = 2;
%Generate the Decision Region Diagram of the input Signal Symbol Set
SignalSymbolDecisionRegionGenerator(SymbolSet, ProbSet, No);