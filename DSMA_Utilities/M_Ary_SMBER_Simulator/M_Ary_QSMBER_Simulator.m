%{
/***************************************************************************
         M-Ary Signal Modulation Bit Error Rate Simulator
        
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

%Generate own symbol set
seed = 06098231;
SymbolSet = RandomMRS_Generator(seed, 4, 2, [1:3]);

%for convinience,  different symbol_set are typed below
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

%Plot the BER versus Eb/No graph for both binary and gray codes with lower
%and upper bound

%it is able to adjust the noise ratio;
No = 3;

%Obtain the binary and gray code set of the input symbol set by 'code_gen'
[BinaryCodeSet, GrayCodeSet] = SymbolCodeGenerator(SymbolSet);
[NumOfSignal, NumOfBitPerSym] = size(BinaryCodeSet);

%Normalize the input signals and then Obtain corresponding Symbol Set for
%different Eb 
Es_nor = mean(sum(SymbolSet.^2));        
SymbolSet_nor = SymbolSet./sqrt(Es_nor);    

%Calculate and then plot the lower and upper bound of the BER
Prob = ones(1, NumOfSignal)/NumOfSignal;
AWGN_SD = sqrt(No/dim);
k = 1;
lower_bound(1) = 1;

while(k == 1 || lower_bound(k - 1) > 10^-8)
    Eb_dB_Set(k) = -5 + 2*k;  
    Eb(k) = 10.^(Eb_dB_Set(k)/10);
    Es_sqrt(k) = sqrt(NumOfBitPerSym*Eb(k));   
    Es_signal(:, :, k) = Es_sqrt(k)*SymbolSet_nor;
    
    for i = 1:NumOfSignal
        for j = 1:NumOfSignal
            Bdry_DistSet(i, j, k) = SignalSymbolDecisionBdry(Es_signal(i, :, k), Es_signal(j, :, k), Prob(i), Prob(j), No);
        end;
    end;
    
    Pe = Q(Bdry_DistSet/AWGN_SD);
    
    for i = 1:NumOfSignal
        Pe(i, i, k) = 0;
    end;
    
    lower_bound(k) = 0;
    
    for i = 1:NumOfSignal
        lower_bound(k) = lower_bound(k) + Prob(i)*max(Pe(i, :, k));
    end;
    
    k = k + 1;
    
end;

upper_bound = (NumOfSignal/2)*lower_bound;
lower_bound = lower_bound/log2(NumOfSignal);

hold off;
semilogy(Eb_dB_Set, upper_bound, 'g');
hold on;

semilogy(Eb_dB_Set, lower_bound, 'r');
grid on;

ylim([1e-8 1]);
xlim([-3 max(Eb_dB_Set) + 10]);
xlabel('Eb/No (dB)');
ylabel('BER');

%Plot BER for both Binary and Gray code cases
%This program take about 20 mins to run it for the accuracy of BER up to
%0.0001
accuracy = 0.0001;

SignalSetBerSimulator(BinaryCodeSet, SymbolSet, Eb_dB_Set, No, accuracy, 'b');
SignalSetBerSimulator(GrayCodeSet, SymbolSet, Eb_dB_Set, No, accuracy, 'k');

title_str = strcat('BER over AWGN channel for No  =  ', num2str(No));
title(title_str);
legend('upper bound of BER',  'lower bound of BER', 'Exact BER for Binary Code', 'Exact BER for Gray Code');