%{
/***************************************************************************
         M-Ary Quadrature Signal Modulation Decision Region Generator
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

%compute the distance between the signal and its boundary,  
%coordinate of the decision boundary intersected with the line crossing the
%2 Signal Symbols
%and other parameters for the decision boundary line

%s1: Signal Symbol 1
%s2: Signal Symbol 2
%prob_1: Probability of Signal Symbol 1
%prob_2: Probability of Signal Symbol 2
%No: noise power spectral density

%Bdry_Y_Intcp: y-intercept of the boundary line
function [BdryDistFrmS1, Bdry_Coor, Bdry_Slope, Bdry_Y_Intcp] = SignalSymbolDecisionBdry(s1, s2, prob_1, prob_2, No)
    dim = length(s1);
    
    if(prob_1 == 0 || prob_2 == 0)
        for i = 1:dim
            Bdry_Coor(i) = 0;
        end;
        
        Bdry_Y_Intcp = 0;
        Bdry_Slope = 0;

        return;
        
    end;
    
    
    %Calculate the distance, d, between s1 and s2
    d = 0;
    
    for i = 1:dim
        d = d + (s2(i) - s1(i))^2;
    end;
    
    d = sqrt(d);
    
    
    %BdryDistFrmS1 is the distance of boundary line away from symbol 1
    %Decision Regions Equation, u = (No/(2*d))*log(prob_1/prob_2) + d/2;
    BdryDistFrmS1 = (No/(2*d))*log(prob_1/prob_2) + d/2;
    
    %Calculate the coordinate at the boundary at which S1 and S2 are orthogonal to the boundary
    for i = 1:dim
        Bdry_Coor(i) = BdryDistFrmS1*(s2(i) - s1(i))/d + s1(i);
    end; 

    %Calculate the boundary slope and y-intercept
    %for i = 1:dim
        if((s2(1) - s1(1)) == 0)
            Bdry_Slope = 0;
            Bdry_Y_Intcp = Bdry_Coor(2);
            
        else
            if((s2(2) - s1(2)) == 0)
                Bdry_Slope = Inf;
                Bdry_Y_Intcp = Bdry_Coor(1);
               
            else
                Bdry_Slope = (s2(2) - s1(2))/(s2(1) - s1(1));
                Bdry_Slope = -(1/Bdry_Slope);
                Bdry_Y_Intcp = Bdry_Coor(2) - Bdry_Slope*Bdry_Coor(1);
                
            end;
            
        end;
    %end