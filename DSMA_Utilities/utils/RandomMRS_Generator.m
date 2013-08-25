%{
/***************************************************************************
         Random Multi-Regions Symbol Generator
        
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

%Random Multi-Regions Symbol Generator
%Make sure each infinite region of the given number of dimensions includes a Symbol
function SymbolsSet = RandomMRS_Generator(seed, NumOfSymbol, dim, Cand)
    rand('seed', seed);

    SymbolsSet = zeros(NumOfSymbol, dim);

    for n = 0:NumOfSymbol - 1
        for d = 0:dim - 1
            SymbolsSet(n + 1, d + 1) = (-1).^(floor((n + d)/dim))*randsrc(1, 1, Cand);
        end
    end