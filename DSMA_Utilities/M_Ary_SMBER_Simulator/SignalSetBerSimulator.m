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

%Compute the BER of the SymbolSet for different Eb/No for any n dimension
%and m array symbol set for equi-probable case 
function SignalSetBerSimulator(BinaryCodeSet, SymbolSet, Eb_dB_Set, No, accuracy, color)
    [NumOfSignal, dim] = size(SymbolSet);
    [NumOfSignal, NumOfBitPerSym] = size(BinaryCodeSet);
    
    NumOfBit = 100/accuracy;
    Eb_Set = 10.^(Eb_dB_Set/10);   
    NumOfEb = length(Eb_Set);
    
    %Select proper number of bit and symbols to perform the simulation
    NumOfBit_left = mod(NumOfBit, NumOfBitPerSym);
    
    if(NumOfBit_left ~= 0)
        NumOfBit = NumOfBit - NumOfBit_left + NumOfBitPerSym;
    end;

    NumOfSym = NumOfBit/NumOfBitPerSym;
    NumOfSymPerLoop = 10000;
    NumOfSym_left = mod(NumOfSym, NumOfSymPerLoop);
    
    if(NumOfSym_left ~= 0)
        NumOfSym = NumOfSym - NumOfSym_left + NumOfSymPerLoop;
        NumOfBit = NumOfSym*NumOfBitPerSym;
    end;
    
    NumOfLoop = NumOfSym/NumOfSymPerLoop;
    NumOfBit = NumOfBitPerSym * NumOfSym;
    NumOfBitPerLoop = NumOfBitPerSym*NumOfSymPerLoop;

    AWGN_SD = sqrt(No/dim);  

    %Normalize the SignalSet signals and then obtain corresponding SymbolSet set for
    %different Eb_Set
    Es_nor = mean(sum(SymbolSet.^2));        
    signal_nor = SymbolSet./sqrt(Es_nor);    
    Es_sqrt = sqrt(NumOfBitPerSym*Eb_Set);   
    SymbolSet = zeros(NumOfSignal, dim, NumOfEb);

    for i = 1:NumOfEb
        SymbolSet(:, :, i) = Es_sqrt(i)*signal_nor;
    end;

    
    %Perform BER simulation for various Eb_Set level
    BER = zeros(1, NumOfEb);
    rand('state', 11);
    randn('state', 21);
    
    for n = 1:NumOfLoop
        %Create Data Stream
        data = floor(2*rand(NumOfSymPerLoop, NumOfBitPerSym));
        
        %Create Tx Signal(Modulation)
        Tx_SignalSet = zeros(NumOfSymPerLoop, dim, NumOfEb);
        
        for i = 1:NumOfSymPerLoop
            for j = 1:NumOfSignal
                %if(sum(abs(BinaryCodeSet(:, j) - data(:, i))) == 0)
                if(sum(BinaryCodeSet(j, :) == data(i, :)) == 0)
                    for k = 1:NumOfEb
                        Tx_SignalSet(i, :, k) = SymbolSet(j, :, k);
                    end;
                end;
            end;
        end;
        
        %Create Rx Signal
        noise = AWGN_SD*randn(NumOfSymPerLoop, dim, length(Eb_dB_Set));
        Rx_SignalSet = Tx_SignalSet + noise;
     
        %De-modulate Rx Signal
        for i = 1:NumOfEb
            for j = 1:NumOfSymPerLoop
                Rx_Signal = Rx_SignalSet(j, :, i);
                Dist_min = sum((Rx_Signal - SymbolSet(1, :, i)).^2);
                SignalDemodulated_idx = 1;
                
                for k = 2:NumOfSignal
                    Dist = (Rx_Signal(1) - SymbolSet(k, 1, i))^2;
                    
                    if(Dist > Dist_min)
                        continue;
                    end;
                    
                    for m = 2:dim
                        Dist = Dist + (Rx_Signal(m) - SymbolSet(k, m, i))^2;
                        
                        if(Dist > Dist_min)
                            break;
                        end;
                    end;
                    
                    if(Dist < Dist_min)
                        Dist_min = Dist;
                        SignalDemodulated_idx = k;
                    end;
                    
                end;
                
                Err = sum(BinaryCodeSet(SignalDemodulated_idx, :) == data(j, :));
                BER(i) = BER(i) + Err;
                
            end;
        end;
    end;  
    
    BER = BER/NumOfBit;
    semilogy(Eb_dB_Set, BER, color);