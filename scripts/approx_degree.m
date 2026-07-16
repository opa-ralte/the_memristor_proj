% what I have to do in this script...
% basically there are 2^16=65536 (which is < 1000000) permutations of a 16-bit binary number
% so I'll do the approximation degree run-through for a 32-bit number only
% 
% approximation degree is denoted by k
% so, for n=32 I will take k=2,4,6,8,10,...,32
% for each value of k I need to perform addition and subtraction using the
% approximation-algorithms given, here I'll go with A1 which is described
% as
% A1: Cout=MAJ(A, B, C) and Sum=Cout'
%
% so I'll pick one random 32-bit number and another random 32-bit number,
% then perform addition and subtraction with the approximation-degree set
% to 2 initially, 
% then I'll increase the approximation-degree to 4, 6, 8, ...
% then increase the approximation-degree again till 32 (which is exact)
%
% then I'll go to the next two generated random 32-bit numbers, then perform the same thing
% and do this iteration for 1000000 times (which means I'll take two random
% 32-bit numbers and perform the thing in first iteration and go on till
% the 1000000th iteration.
%
% then I'll find the error metrics (error_distance, error_rate,
% mean_error_distance, normalized_mean_error_distance, mean_squared_error,
% mean_squared_error_distance, worst_case_error
%
% also for the comparison I'll simply use the last case where k = n (which is the exact
% adder_case where every bit is evaluated in exact manner using built-in
% adder)

%% so summary of the program
% n = 32-bit operands
% k = approximation degree
% for each k we generate N random pairs of 32-bit numbers
% do approx addition and subtraction and compare against the exact result
% to compute the following
% error_rate
% mean_error_distance
% normalized_mean_error_distance
% mean_squared_error
% worst_case_error


clear; clc;


n = 32;     % number-a bit awm zat
N = 1000000;    % test nan, kan iterate zat tur
ks = 2:2:n;      % 2, 4, 6, 8, ..., 32

A = randi([0, 2^n-1], N, 1);       % array of 1000000 randomly generated 32-bit binary numbers
B = randi([0, 2^n-1], N, 1);        % same 👆

exactSum = mod(A + B, 2^n);         
exactDiff = mod(A - B, 2^n);

for k = ks
    approxSum = approxAdd(A, B, 0, k, n);
    approxDiff = approxAdd(A, (2^n-1) - B, 1, k, n); % using two's complement

    [ER1, MED1, NMED1, MSE1, WCE1] = errMetrics(exactSum, approxSum, n);
    [ER2, MED2, NMED2, MSE2, WCE2] = errMetrics(exactDiff, approxDiff, n);

    fprintf('k=%2d | ADD: ER=%.4f MED=%.2f NMED=%.5f MSE=%.2e WCE=%d | SUB: ER=%.4f MED=%.2f NMED=%.5f MSE=%.2e WCE=%d\n', ...
        k, ER1, MED1, NMED1, MSE1, WCE1, ER2, MED2, NMED2, MSE2, WCE2);
end




%% functions

function S = approxAdd(A, B, cin, k, n)
    approxBits = n-k;
    carry = cin * ones(size(A));
    S = zeros(size(A));
    for i = 0:n-1
        a = bitget(A, i+1);
        b = bitget(B, i+1);
        cout = (a & b) | (carry & (a | b));
        if i < approxBits
            s = ~cout & 1;
        else
            s = xor(xor(a, b), carry);
        end
        S = S + s * 2^i;
        carry = cout;
    end
end

function [ER,MED,NMED,MSE,WCE] = errMetrics(exact, approx, n)
    ED = abs(exact - approx);
    ER = mean(ED ~= 0);
    MED = mean(ED);
    NMED = MED / (2^n - 1);
    MSE = mean(ED.^2);
    WCE = max(ED);
end

