%% A4: Cout= AB + BC and Sum=Cout'

clear; clc;

inputs = dec2bin(0:7,3) - '0';   % 8x3 matrix, each row = [A B C]
A = inputs(:,1);
B = inputs(:,2);
C = inputs(:,3);
N = size(inputs,1);

% Exact full adder outputs
Sum_exact  = xor(xor(A,B),C);
Cout_exact = (A & B) | (B & C) | (A & C);

% Approximate adder outputs
Cout_approx = (A & B) + (B & C);
Sum_approx  = double(~Cout_approx);

% Combine Cout,Sum into a single 2-bit decimal output (0-3)
Out_exact_dec  = Cout_exact*2  + Sum_exact;
Out_approx_dec = Cout_approx*2 + Sum_approx;

% Error metrics

% Error Distance (ED) per input pattern = |exact - approx|
ED = abs(Out_exact_dec - Out_approx_dec);

% Error Rate (ER): fraction of input patterns that produce a wrong output
ER = sum(ED ~= 0) / N;

% Mean Error Distance (MED)
MED = mean(ED);

% Normalized Mean Error Distance (NMED): MED / max possible output value
NMED = MED / max(Out_exact_dec);

% Mean Squared Error (MSE)
MSE = mean(ED.^2);

% Mean Relative Error Distance (MRED) — skip patterns where exact output = 0
RED = zeros(N,1);
nz = Out_exact_dec ~= 0;
RED(nz) = ED(nz) ./ Out_exact_dec(nz);
MRED = mean(RED);

% Worst-Case Error (WCE)
WCE = max(ED);

% Display truth table + metrics
T = table(A,B,C,Sum_exact,Cout_exact,Sum_approx,Cout_approx, ...
          Out_exact_dec,Out_approx_dec,ED, ...
    'VariableNames',{'A','B','C','Sum_exact','Cout_exact', ...
                      'Sum_approx','Cout_approx','Out_exact','Out_approx','ErrorDistance'});
disp(T)

fprintf('\n--- Error Metrics Summary ---\n');
fprintf('Error Rate (ER)                : %.2f %%\n', ER*100);
fprintf('Mean Error Distance (MED)      : %.4f\n', MED);
fprintf('Normalized MED (NMED)          : %.4f\n', NMED);
fprintf('Mean Squared Error (MSE)       : %.4f\n', MSE);
fprintf('Mean Relative Error Dist (MRED): %.4f\n', MRED);
fprintf('Worst Case Error (WCE)         : %d\n', WCE);