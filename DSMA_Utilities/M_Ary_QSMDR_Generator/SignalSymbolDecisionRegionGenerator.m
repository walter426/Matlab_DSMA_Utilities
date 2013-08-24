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

%Generate Decision Region diagram for any number of Signal Symbol points with different probability on 2-dimensional signal plane

%No: noise power spectral density
function SignalSymbolDecisionRegionGenerator(SymbolSet, ProbSet, No)
    %Check input argument
    %if(sum(ProbSet) ~= 1)
    %    sum(ProbSet) ~= 1
    %    sum(ProbSet) > 1
    %    sum(ProbSet) < 1
    %    display('total probability of the symbol is not equal to one !')
    %    return;
    %end;

    
    [NumOfSignal, dim] = size(SymbolSet);

    %Diagram Initialization
    DiagBdry_min = zeros(dim);
    DiagBdry_max = zeros(dim);
    
    DiagBdryOffset = 2;
    
    for i = 1:dim
        %{
        DiagBdry_min(1) = min(SymbolSet(:, i)) - abs(min(SymbolSet(:, i)));
        DiagBdry_max(1) = max(SymbolSet(:, i)) + abs(max(SymbolSet(:, i)));
        %}
        
        DiagBdry_min(i) = min(SymbolSet(:, i)) - DiagBdryOffset;
        DiagBdry_max(i) = max(SymbolSet(:, i)) + DiagBdryOffset;
    end
    
    hold off;
    
    plot(SymbolSet(:, 1), SymbolSet(:, 2), 'o');
    ylim([DiagBdry_min(2) DiagBdry_max(2)]);
    xlim([DiagBdry_min(1) DiagBdry_max(1)]);
    DiagBdry_x = [DiagBdry_min(1):0.1:DiagBdry_max(1)];

    hold on;

    
    %Decision Boundary Calculation Initialization
    Bdry_DistSet = zeros(NumOfSignal, NumOfSignal);
    Bdry_CoorSet = zeros(NumOfSignal, NumOfSignal, dim);
    Bdry_SlopeSet = zeros(NumOfSignal, NumOfSignal);
    Bdry_Y_IntcpSet = zeros(NumOfSignal, NumOfSignal);
    
    %Each boundary line is presented as two end points at the Diagram Boundary , start_Coor and Bdry_EndCoor,  as it is a straight line 
    Bdry_S_CoorSet = zeros(NumOfSignal, NumOfSignal, dim);
    Bdry_E_CoorSet = zeros(NumOfSignal, NumOfSignal, dim);
    
    
    %Calculate required parameters of each boundary line
    for i = 1:NumOfSignal
        for j = 1:NumOfSignal
            if i == j
                continue;
            end

            [Bdry_DistSet(i, j), Bdry_CoorSet(i, j, :), Bdry_SlopeSet(i, j), Bdry_Y_IntcpSet(i, j)] = SignalSymbolDecisionBdry(SymbolSet(i, :), SymbolSet(j, :), ProbSet(i), ProbSet(j), No);

            %Determine the two end points of the boundary
            if(Bdry_SlopeSet(i, j) == Inf)
                Bdry_S_CoorSet(i, j, 1) = Bdry_CoorSet(i, j, 1);
                Bdry_E_CoorSet(i, j, 1) = Bdry_CoorSet(i, j, 1);
                Bdry_S_CoorSet(i, j, 2) = DiagBdry_min(2);
                Bdry_E_CoorSet(i, j, 2) = DiagBdry_max(2);
            
            else
                Bdry_S_CoorSet(i, j, 1) = DiagBdry_min(1);
                Bdry_E_CoorSet(i, j, 1) = DiagBdry_max(1);
                Bdry_S_CoorSet(i, j, 2) = Bdry_SlopeSet(i, j) * DiagBdry_min(1) + Bdry_Y_IntcpSet(i, j);
                Bdry_E_CoorSet(i, j, 2) = Bdry_SlopeSet(i, j) * DiagBdry_max(1) + Bdry_Y_IntcpSet(i, j);
            
            end;
        end;
    end;

    
    %Calculate the intercept of each pair of boundary lines of a signal for all
    %signals
    for i = 1:NumOfSignal
        for j = 1:NumOfSignal
            if i == j
                continue;
            end
            
            for k = 1:NumOfSignal
                if(k == j || k == i)
                    continue;
                end
                
                if(Bdry_SlopeSet(i, j) == Bdry_SlopeSet(i, k))
                    Intcp_x = NaN;
                    Intcp_y = NaN;
                
                else
                    if(Bdry_SlopeSet(i, j) == Inf && Bdry_SlopeSet(i, k) ~= Inf)
                        Intcp_x = Bdry_CoorSet(i, j, 1);
                        Intcp_y = Bdry_SlopeSet(i, k) * Intcp_x + Bdry_Y_IntcpSet(i, k);
                        
                    elseif(Bdry_SlopeSet(i, j) ~= Inf && Bdry_SlopeSet(i, k) == Inf)
                        Intcp_x = Bdry_CoorSet(i, k, 1);
                        Intcp_y = Bdry_SlopeSet(i, j) * Intcp_x + Bdry_Y_IntcpSet(i, j);
                        
                    else
                        %line 1: y = ax + b
                        %line 2: y = cx + d
                        %=> x = (b-d)/(a-c)
                        Intcp_x = (Bdry_Y_IntcpSet(i, j) - Bdry_Y_IntcpSet(i, k))/(Bdry_SlopeSet(i, k) - Bdry_SlopeSet(i, j));
                        
                        if(Bdry_SlopeSet(i, k) == 0)
                            Intcp_y = Bdry_Y_IntcpSet(i, k);
                            
                        else
                            Intcp_y = Bdry_SlopeSet(i, j) * Intcp_x + Bdry_Y_IntcpSet(i, j);
                            
                        end;
                        
                    end;
                    
                end;
                
                
                u = strcat('Intcp_x_', num2str(i), '_', num2str(j));
                u = strcat(u, '_', num2str(i), '_', num2str(k));
                eval([u ' = Intcp_x;']);
                
                u = strcat('Intcp_y_', num2str(i), '_', num2str(j));
                u = strcat(u, '_', num2str(i), '_', num2str(k));
                eval([u ' = Intcp_y;']);
                
            end;
        end;
    end;

    
    %Cut the boundary line by vector method
    for i = 1:NumOfSignal
        %break;
        
        for j = 1:NumOfSignal
            if i == j
                continue;
            end
            
            w = strcat(num2str(i), '_', num2str(j));
            
            for k = 1:NumOfSignal
                if(k == i || k == j)
                    continue;
                end
                
                
                %Select Boundary lines if the two slopes are equal
                if(Bdry_SlopeSet(i, j) == Bdry_SlopeSet(i, k))
                    if(Bdry_Y_IntcpSet(i, j) == Bdry_Y_IntcpSet(i, k))
                        Bdry_S_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                        Bdry_E_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                        
                        continue;
                        
                    end
                
                    %Calculate the two vectors from the signal symbols to the two boundary lines
                    v_SToB1 = [Bdry_CoorSet(i, j, 1) - SymbolSet(i, 1), Bdry_CoorSet(i, j, 2) - SymbolSet(i, 2)];
                    v_SToB2 = [Bdry_CoorSet(i, k, 1) - SymbolSet(i, 1), Bdry_CoorSet(i, k, 2) - SymbolSet(i, 2)];
                    
                    len_v_SToB1 = sqrt(sum(v_SToB1.^2));
                    len_v_SToB2 = sqrt(sum(v_SToB2.^2));
                    
                    v_SToB1 = v_SToB1/len_v_SToB1;
                    v_SToB2 = v_SToB2/len_v_SToB2;
                    
                    if (v_SToB1 == v_SToB2)
                        if (Bdry_DistSet(i, j) > Bdry_DistSet(i, k))
                            Bdry_S_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                            Bdry_E_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                            
                        else
                            Bdry_S_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                            Bdry_E_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                            
                        end
                    end
                    
                    continue;
                    
                end
                
                %Cut Boundary lines from their end pts to their intercept
                v = strcat(w, '_', num2str(i), '_', num2str(k));
                
                u = strcat('Intcp_x_', v);
                eval(['Intcp_x = ' u ';']);
                
                u = strcat('Intcp_y_', v);
                eval(['Intcp_y = ' u ';']);
                
                if(Intcp_x == NaN || Intcp_y == NaN)
                    continue;
                end
                
                %The angle between boundary lines and angle between each of the boundary and the symbol signal can determine the correct boundary
                %Calculate the vectors of the two boundary lines intercepted
                %line: y = ax + c => vector: i + aj
                if(Bdry_SlopeSet(i, j) == Inf)
                    vector_1 = [0, 1];
                else
                    vector_1 = [1, Bdry_SlopeSet(i, j)];
                end;
                
                if(Bdry_SlopeSet(i, k) == Inf)
                    vector_2 = [0, 1];
                else
                    vector_2 = [1, Bdry_SlopeSet(i, k)];
                end;
                
                %Calculate the Angle and Supplement Angle between the two boundary vectors
                %By Dot Product Equation: v.u = |v||u|cos(a), 0 <= a <= pi
                %=> a = acos((v.u)/(|v||u|))
                len_v1 = sqrt(sum(vector_1.^2));
                len_v2 = sqrt(sum(vector_2.^2));
                
                v1v2_angle = sum(vector_1.* vector_2)/(len_v1 * len_v2);
                v1v2_angle = acos(v1v2_angle);
                v1v2_supp_angle = pi - v1v2_angle;
                
                %Create a vector from the signal symbol to the intercept
                v_IntcpToSigSym = [SymbolSet(i, 1) - Intcp_x, SymbolSet(i, 2) - Intcp_y];
                len_i2s = sqrt(sum(v_IntcpToSigSym.^2));
                
                v1vi2s_angle = sum(vector_1.* v_IntcpToSigSym)/(len_v1 * len_i2s);
                v1vi2s_angle = acos(v1vi2s_angle);
                v1vi2s_supp_angle = pi - v1vi2s_angle;
                
                v2vi2s_angle = sum(vector_2.* v_IntcpToSigSym)/(len_v2 * len_i2s);
                v2vi2s_angle = acos(v2vi2s_angle);
                v2vi2s_supp_angle = pi - v2vi2s_angle;
                
                %Create Vectors from Start to intercept and intercept to end for checking whether the intercept is within the current truncated boundary
                v_S1ToIntcp = [Intcp_x - Bdry_S_CoorSet(i, j, 1), Intcp_y - Bdry_S_CoorSet(i, j, 2)];
                v_E1ToIntcp = [Intcp_x - Bdry_E_CoorSet(i, j, 1), Intcp_y - Bdry_E_CoorSet(i, j, 2)];
                
                Dist_S1ToIntcp = sqrt(sum(v_S1ToIntcp.^2));
                Dist_E1ToIntcp = sqrt(sum(v_E1ToIntcp.^2));
                
                %{
                vS1ToInt_E1ToInt_angle = sum(v_S1ToIntcp.* v_E1ToIntcp)/(Dist_S1ToIntcp * Dist_E1ToIntcp);
                vS1ToInt_E1ToInt_angle = acos(vS1ToInt_E1ToInt_angle);
                
                if (vS1ToInt_E1ToInt_angle == NaN)
                    vS1ToInt_E1ToInt_angle = pi;
                end
                %}
                
                Dist_S1ToE1 = sqrt((Bdry_E_CoorSet(i, j, 1) - Bdry_S_CoorSet(i, j, 1))^2 + (Bdry_E_CoorSet(i, j, 2) - Bdry_S_CoorSet(i, j, 2))^2);
                
                
                v_S2ToIntcp = [Intcp_x - Bdry_S_CoorSet(i, k, 1), Intcp_y - Bdry_S_CoorSet(i, k, 2)];
                v_E2ToIntcp = [Intcp_x - Bdry_E_CoorSet(i, k, 1), Intcp_y - Bdry_E_CoorSet(i, k, 2)];
                
                Dist_S2ToIntcp = sqrt(sum(v_S2ToIntcp.^2));
                Dist_E2ToIntcp = sqrt(sum(v_E2ToIntcp.^2));
                
                %{
                vS2ToInt_E2ToInt_angle = sum(v_S2ToIntcp.* v_E2ToIntcp)/(Dist_S2ToIntcp * Dist_E2ToIntcp);
                vS2ToInt_E2ToInt_angle = acos(vS2ToInt_E2ToInt_angle);
                
                if (vS2ToInt_E2ToInt_angle == NaN)
                    vS2ToInt_E2ToInt_angle = pi;
                end
                %}
                
                Dist_S2ToE2 = sqrt((Bdry_E_CoorSet(i, k, 1) - Bdry_S_CoorSet(i, k, 1))^2 + (Bdry_E_CoorSet(i, k, 2) - Bdry_S_CoorSet(i, k, 2))^2);

                
                %%{
                if((v1vi2s_angle < v1v2_angle) && (v2vi2s_angle < v1v2_angle) && (v1vi2s_angle + v2vi2s_angle < pi))
                    if(Dist_S1ToE1 > 0)
                        %if(vS1ToInt_E1ToInt_angle == pi)
                        if(Dist_S1ToE1 > Dist_E1ToIntcp)
                            Bdry_S_CoorSet(i, j, 1) = Intcp_x;
                            Bdry_S_CoorSet(i, j, 2) = Intcp_y;
                        
                        elseif(Dist_S1ToIntcp > Dist_E1ToIntcp)
                            Bdry_S_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                            Bdry_E_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                        end;
                    end;
                    
                    if(Dist_S2ToE2 > 0)
                        %if(vS2ToInt_E2ToInt_angle == pi)
                        if(Dist_S2ToE2 > Dist_E2ToIntcp)
                            Bdry_S_CoorSet(i, k, 1) = Intcp_x;
                            Bdry_S_CoorSet(i, k, 2) = Intcp_y;
                            
                        elseif(Dist_S2ToIntcp > Dist_E2ToIntcp)
                            Bdry_S_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                            Bdry_E_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                        end;
                    end
                    
                %end
                
                %if((v1vi2s_angle + v2vi2s_angle > pi) && (v1vi2s_supp_angle < v1v2_angle) && (v2vi2s_supp_angle < v1v2_angle))
                elseif((v1vi2s_angle + v2vi2s_angle > pi) && (v1vi2s_supp_angle < v1v2_angle) && (v2vi2s_supp_angle < v1v2_angle))
                    if(Dist_S1ToE1 > 0)
                        %if(vS1ToInt_E1ToInt_angle == pi)
                        if(Dist_S1ToE1 > Dist_S1ToIntcp)
                            Bdry_E_CoorSet(i, j, 1) = Intcp_x;
                            Bdry_E_CoorSet(i, j, 2) = Intcp_y;
                            
                        elseif(Dist_S1ToIntcp < Dist_E1ToIntcp)
                            Bdry_S_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                            Bdry_E_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                        end;
                    end
                    
                    if(Dist_S2ToE2 > 0)
                        %if(vS2ToInt_E2ToInt_angle == pi)
                        if(Dist_S2ToE2 > Dist_S2ToIntcp)
                            Bdry_E_CoorSet(i, k, 1) = Intcp_x;
                            Bdry_E_CoorSet(i, k, 2) = Intcp_y;
                        
                        elseif(Dist_S2ToIntcp < Dist_E2ToIntcp)
                            Bdry_S_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                            Bdry_E_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                        end;
                    end
                
                %end
                
                %if(v1vi2s_angle > v1v2_angle && v1vi2s_angle > v2vi2s_angle && v2vi2s_angle + v1v2_angle < pi)
                elseif(v1vi2s_angle > v1v2_angle && v1vi2s_angle > v2vi2s_angle)
                    if(Dist_S1ToE1 > 0)
                        %if(vS1ToInt_E1ToInt_angle == pi)
                        if(Dist_S1ToE1 > Dist_S1ToIntcp)
                            Bdry_E_CoorSet(i, j, 1) = Intcp_x;
                            Bdry_E_CoorSet(i, j, 2) = Intcp_y;
                            
                        elseif(Dist_S1ToIntcp < Dist_E1ToIntcp)
                            Bdry_S_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                            Bdry_E_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                        end;
                    end;
                    
                    if(Dist_S2ToE2 > 0)
                        if(Dist_S2ToE2 > Dist_E2ToIntcp)
                        %if(vS2ToInt_E2ToInt_angle == pi)
                            Bdry_S_CoorSet(i, k, 1) = Intcp_x;
                            Bdry_S_CoorSet(i, k, 2) = Intcp_y;
                            
                        elseif(Dist_S2ToIntcp > Dist_E2ToIntcp)
                            Bdry_S_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                            Bdry_E_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                        end;
                    end
                 
                %end
                
                %if(v2vi2s_angle > v1v2_angle && v2vi2s_angle > v2vi2s_angle && v1vi2s_angle + v1v2_angle < pi)                 
                %elseif(v2vi2s_angle > v1v2_angle && v2vi2s_angle > v1vi2s_angle)
                else
                    if(Dist_S1ToE1 > 0)
                        %if(vS1ToInt_E1ToInt_angle == pi)
                        if(Dist_S1ToE1 > Dist_E1ToIntcp)
                            Bdry_S_CoorSet(i, j, 1) = Intcp_x;
                            Bdry_S_CoorSet(i, j, 2) = Intcp_y;
                        
                        elseif(Dist_S1ToIntcp > Dist_E1ToIntcp)
                            Bdry_S_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                            Bdry_E_CoorSet(i, j, :) = Bdry_CoorSet(i, j, :);
                        end;
                    end
                    
                    if(Dist_S2ToE2 > 0)
                        %if(vS2ToInt_E2ToInt_angle == pi)
                        if(Dist_S2ToE2 > Dist_S2ToIntcp)
                            Bdry_E_CoorSet(i, k, 1) = Intcp_x;
                            Bdry_E_CoorSet(i, k, 2) = Intcp_y;
                            
                        elseif(Dist_S2ToIntcp < Dist_E2ToIntcp)
                            Bdry_S_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                            Bdry_E_CoorSet(i, k, :) = Bdry_CoorSet(i, k, :);
                        end;
                    end
                    
                end;
                
                %%}
            end;
        end;
    end;
    
    
    %Draw the resultant boundary lines
    for i = 1:NumOfSignal
        for j = 1:NumOfSignal
            if i == j
                continue;
            end
            
            switch i
                case 1
                    color = 'r';
                    
                case 2
                    color = 'g';
                    
                case 3
                    color = 'b';
                    
                case 4
                    color = 'k';
            end
            
            %{
            if(i == 1)
                color = 'r';
                
            elseif(i == 2)
                color = 'g';
                
            elseif(i == 3)
                color = 'b';
                
            elseif(i == 4)
                color = 'k';
                
            end;
            %}
            
            if(Bdry_SlopeSet(i, j) == Inf)
                %line([Bdry_Y_IntcpSet;Bdry_Y_IntcpSet], [DiagBdry_min(2);DiagBdry_max(2)]);
                line([Bdry_Y_IntcpSet(i, j);Bdry_Y_IntcpSet(i, j)], [Bdry_S_CoorSet(i, j, 2);Bdry_E_CoorSet(i, j, 2)]);
                
            else
                %boundary = Bdry_SlopeSet(i, j) * DiagBdry_x + Bdry_Y_IntcpSet(i, j);
                DiagBdry_x = [Bdry_S_CoorSet(i, j, 1):0.01:Bdry_E_CoorSet(i, j, 1)];
                DiagBdry_y = Bdry_SlopeSet(i, j) * DiagBdry_x + Bdry_Y_IntcpSet(i, j);
                plot(DiagBdry_x, DiagBdry_y, color);
                %line([DiagBdry_min(1), DiagBdry_max(1)], [(Bdry_SlopeSet * DiagBdry_min(1) + Bdry_Y_IntcpSet), (Bdry_SlopeSet * DiagBdry_max(1) + Bdry_Y_IntcpSet)])
                
            end;
            
        end;
    end;
