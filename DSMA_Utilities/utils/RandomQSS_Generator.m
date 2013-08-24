
%Random Quadrature Signal Symbol Generator
function SymbolsSet = RandomQSS_Generator(seed, NumOfSymbol, Cand)
    rand('seed', seed);

    SymbolsSet = zeros(NumOfSymbol, 2);

    for n = 1:NumOfSymbol
        SymbolsSet(n, :) = [(-1).^(floor((n - 1)/2))*randsrc(1, 1, Cand), (-1).^(floor((n)/2))*randsrc(1, 1, Cand)];
    end