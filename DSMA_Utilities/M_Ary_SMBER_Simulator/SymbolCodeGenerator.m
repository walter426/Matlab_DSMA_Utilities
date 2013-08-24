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

%compute the binary and gray code set of the input symbol set
function [BinaryCodeSet, GrayCodeSet] = SymbolCodeGenerator(SymbolSet)
    [NumOfSignal, dim] = size(SymbolSet);
    
    %Calculate distance between each symbol pairs
    DistSet = zeros(NumOfSignal, NumOfSignal);

    for i = 1:NumOfSignal;
        for j = 1:NumOfSignal
            DistSet(i, j) = sqrt(sum(SymbolSet(i, :).^2- SymbolSet(j, :).^2));
        end;
    end;

    %Calculate number of bits for coding this symbol set
    NumOfBit = 0;
    NumOfSignal_t = 0;
    
    while(NumOfSignal_t < NumOfSignal)
        NumOfBit = NumOfBit + 1;
        NumOfSignal_t = 2^NumOfBit;
    end;

    
    %Store max distance among symbol pair of each signl into pair, (i, i) for later reference. as it is an invalid pair
    for i = 1:NumOfSignal
        DistSet(i, i) = max(DistSet(i, :)) + 1;
    end;
    
    %Sort the symbol set according to the distance between S0 and S1, and  S1 and S2, ... and so on
    DecimalCodeSet = zeros(NumOfSignal, 1);
    Symbol_selected = zeros(NumOfSignal);
    
    %Generate Decimal Code of the symbol set
    Sym_idx = 1;
    
    for i = 1:NumOfSignal
        Symbol_selected(Sym_idx) = 1;
        DecimalCodeSet(Sym_idx) = i - 1;
        Dist_min = max(DistSet(Sym_idx, :));
        Sym_idx_min = Sym_idx;

        for j = 1:NumOfSignal
            if(i == j)
               continue 
            end;
            
            if(DistSet(Sym_idx, j) >= Dist_min)
                continue
            end
            
            if (Symbol_selected(j) == 1)
                continue
            end
            
            
            Dist_min = DistSet(Sym_idx, j);
            Sym_idx_min = j;
            
        end;
        
        if(Sym_idx == Sym_idx_min)
            break;
        else
            Sym_idx = Sym_idx_min;
        end;
        
    end;

    
    %Obtain the Binary Code of the symbol set 
    BinaryCodeSet = zeros(NumOfSignal, NumOfBit);
    
    for i = 1:NumOfSignal
        DecimalCode_t = DecimalCodeSet(i);
        
        for j = 0:NumOfBit - 1
        %for j = 1:NumOfBit
            if(DecimalCode_t >= (2^(NumOfBit - j - 1)))
                BinaryCodeSet(i, NumOfBit - j) = 1;
                DecimalCode_t = DecimalCode_t - (2^(NumOfBit - j - 1));
            end;
        end;
    end;

    
    %Obtain the Gray Code of the symbol set 
    GrayCodeSet = zeros(NumOfSignal, NumOfBit);
    
    for i = 1:NumOfSignal
        GrayCodeSet(i, NumOfBit) = BinaryCodeSet(i, NumOfBit);
        
        for j = 1:NumOfBit - 1
            GrayCodeSet(i, j) = xor(BinaryCodeSet(i, j + 1), BinaryCodeSet(i, j));
        end;
    end;
