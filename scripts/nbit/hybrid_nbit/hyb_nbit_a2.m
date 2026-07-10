clear; clc; close all;

bitWidths        = [4 8 16 32];
EXHAUSTIVE_LIMIT = 8;     
numMonteCarlo    = 5e5;    % random samples used for larger bit-widths

results = table();
fprintf('using A2')
for N = bitWidths

    if N <= EXHAUSTIVE_LIMIT
        [Ag, Bg] = meshgrid(0:2^N-1, 0:2^N-1);
        A = Ag(:);
        B = Bg(:);
        methodStr = "Exhaustive";
    else
        rng(0);   % reproducibility
        A = randi([0, 2^N-1], numMonteCarlo, 1);
        B = randi([0, 2^N-1], numMonteCarlo, 1);
        methodStr = sprintf("Monte Carlo (%d samples)", numMonteCarlo);
    end

    metrics = analyzeApproxAdder(A, B, N);

    fprintf('\n===== %d-bit hybrid Adder [%s] =====\n', N, methodStr);
    fprintf('Error Rate (ER)                : %.4f %%\n', metrics.ER*100);
    fprintf('Mean Error Distance (MED)      : %.4f\n', metrics.MED);
    fprintf('Normalized MED (NMED)          : %.6f\n', metrics.NMED);
    fprintf('Mean Squared Error (MSE)       : %.4f\n', metrics.MSE);
    fprintf('Mean Relative Error Dist (MRED): %.6f\n', metrics.MRED);
    fprintf('Worst Case Error (WCE)         : %d\n', metrics.WCE);

    newRow = table(N, methodStr, metrics.ER, metrics.MED, metrics.NMED, ...
                    metrics.MSE, metrics.MRED, metrics.WCE, ...
        'VariableNames', {'BitWidth','Method','ER','MED','NMED','MSE','MRED','WCE'});
    results = [results; newRow]; %#ok<AGROW>
end

fprintf('\n\n===== Summary across bit widths =====\n');
disp(results)

%% Plot trends across bit widths
figure;
subplot(1,2,1);
bar(results.BitWidth, results.ER*100);
xlabel('Bit width'); ylabel('Error Rate (%)');
title('Error Rate vs Bit Width'); grid on;

subplot(1,2,2);
bar(results.BitWidth, results.NMED);
xlabel('Bit width'); ylabel('NMED');
title('Normalized MED vs Bit Width'); grid on;

function metrics = analyzeApproxAdder(A, B, N)
    % Ripple N approximate 1-bit adders together and compare against
    % exact integer addition.

    numSamples = numel(A);
    Abits = getBits(A, N);
    Bbits = getBits(B, N);

    Cin = zeros(numSamples, 1);
    SumApproxBits = zeros(numSamples, N);

    for i = 1:N
        if i <= N/2     % for the part to be evaluated using approximations => for lsb
            Ai = Abits(:,i);
            Bi = Bbits(:,i);
            Cout = (Ai & Bi) | (Bi & Cin) | (Ai & Cin);   
            SumApproxBits(:,i) = Cout;                    
            Cin = Cout;                                     
        elseif i > N/2  % for the part to be evaluated using exact method => for msb
            Ai = Abits(:,i);
            Bi = Bbits(:,i);
            Cout = (Ai & Bi) | (Bi & Cin) | (Ai & Cin);  
            SumApproxBits(:,i) = xor(xor(Ai, Bi), Cin);                   
            Cin = Cout;                                    
        end
    end
    CarryFinal = Cin;   % final carry-out becomes the top bit

    weights   = (2.^(0:N-1))';
    ApproxVal = SumApproxBits * weights + CarryFinal * 2^N;
    ExactVal  = double(A) + double(B);

    ED = abs(ExactVal - ApproxVal);

    metrics.ER   = mean(ED ~= 0);
    metrics.MED  = mean(ED);
    metrics.NMED = metrics.MED / (2^(N+1) - 1);   % normalize by max possible output
    metrics.MSE  = mean(ED.^2);

    nz = ExactVal ~= 0;                            % avoid divide-by-zero
    metrics.MRED = mean(ED(nz) ./ ExactVal(nz));
    metrics.WCE  = max(ED);
end

function bits = getBits(x, N)
    % LSB-first bit decomposition of a column vector of nonnegative integers
    x = double(x);
    bits = zeros(numel(x), N);
    for i = 1:N
        bits(:,i) = bitget(x, i);
    end
end