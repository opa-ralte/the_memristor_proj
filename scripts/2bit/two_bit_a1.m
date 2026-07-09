clear; clc;

N = 2;

%% Generate all input combinations
[Ag, Bg] = meshgrid(0:2^N-1, 0:2^N-1);
A = Ag(:);
B = Bg(:);
numSamples = numel(A);

%% Bit decomposition (LSB first)
Abits = zeros(numSamples, N);
Bbits = zeros(numSamples, N);
for i = 1:N
    Abits(:,i) = bitget(A, i);
    Bbits(:,i) = bitget(B, i);
end

%% Ripple the approximate 1-bit adders together
Cin = zeros(numSamples, 1);
SumApproxBits = zeros(numSamples, N);
for i = 1:N
    Ai = Abits(:,i);
    Bi = Bbits(:,i);
    Cout = (Ai & Bi) | (Bi & Cin) | (Ai & Cin);   
    SumApproxBits(:,i) = ~Cout;                   
    Cin = Cout;                                   
end
CarryFinal = Cin;   % final carry-out becomes the top bit

%% Combine into decimal output values
weights   = (2.^(0:N-1))';
ApproxVal = SumApproxBits * weights + CarryFinal * 2^N;
ExactVal  = A + B;

%% Error metrics
ED = abs(double(ExactVal) - double(ApproxVal));

ER   = mean(ED ~= 0);
MED  = mean(ED);
NMED = MED / (2^(N+1) - 1);
MSE  = mean(ED.^2);

nz = ExactVal ~= 0;
MRED = mean(ED(nz) ./ double(ExactVal(nz)));
WCE  = max(ED);

%% Display truth table + metrics
T = table(A, B, Abits(:,1), Abits(:,2), Bbits(:,1), Bbits(:,2), ...
          ExactVal, ApproxVal, ED, ...
    'VariableNames', {'A','B','A_b1','A_b2','B_b1','B_b2','Exact','Approx','ErrorDistance'});
disp(T)

fprintf('\nError Metrics Summary (2-bit adder) using A1\n');
fprintf('Error Rate (ER)                : %.2f %%\n', ER*100);
fprintf('Mean Error Distance (MED)      : %.4f\n', MED);
fprintf('Normalized MED (NMED)          : %.4f\n', NMED);
fprintf('Mean Squared Error (MSE)       : %.4f\n', MSE);
fprintf('Mean Relative Error Dist (MRED): %.4f\n', MRED);
fprintf('Worst Case Error (WCE)         : %d\n', WCE);