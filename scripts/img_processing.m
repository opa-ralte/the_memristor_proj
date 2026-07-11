% Algorithms used (bit-level full adder, inputs A, B, Cin):
%   A1: Cout = MAJ(A,B,C)   , Sum = Cout'
%   A2: Cout = MAJ(A,B,C)   , Sum = Cout
%   A3: Cout = A.B          , Sum = A xor B
%   A4: Cout = A.B + B.C    , Sum = Cout'

clear; clc; close all;

% first we have to load test images

% image of mona_lisa
pickachiu = imread('src/pickachiu.jpg');
%image of supar_man
supar_man = imread('src/perman.png');

% conversion to greyscale
img1 = im2uint8(rgb2gray(supar_man));
img2 = im2uint8(rgb2gray(pickachiu));

figure('Name', 'Input Images');
subplot(1,2,1); imshow(img1); title('image A aw');
subplot(1,2,2); imshow(img2); title('image B aw')

algos = [1 2 3 4 5];
algoNames = {'A1 (Sum=Cout'')', 'A2 (Sum=Cout)','A3 (ignores Cin)', 'A4 (AB+BC, Sum=Cout'')', 'A5 (Hybrid: approx low 4b, exact high 4b)'};

% tunah image addition - now we begin image addition
exactAdd = imadd(img1, img2);   % tah hi chuan matlab-in a chhawm sa image addition kan hmanga, exact result atan kan la a ni e

figure('Name', 'Approximate Addition');
subplot(2,3,1); imshow(exactAdd); title('Exact Addition');

fprintf('\n results of addition\n');
for k = 1:numel(algos)
    algo = algos(k);
    approx = approxAddImage(img1, img2, algo, true);
    [mse_val, psnr_val]  = imageError(exactAdd, approx);
    mssim_val = ssim(exactAdd, approx);
    fprintf('%-22s MSE = %8.3f  PSNR = %6.2f dB MSSIM = %6.2f dB\n', algoNames{k}, mse_val, psnr_val, mssim_val);

    subplot(2,3,k+1); imshow(approx);
    title(sprintf('%s\nPSNR=%.2fdB', algoNames{k}, psnr_val));
end

% tunah chuan image subtraction - this is image subtraction
exactSub = imsubtract(img1, img2); % tah pawh matlab subtraction kan hmang phawt, exact subtraction kan duh vangin  

figure('Name', 'Approximate Subtraction');
subplot(2,3,1); imshow(exactSub); title('Exact Subtraction');

fprintf('\n results of subtraction\n');
for k = 1:numel(algos)
    algo = algos(k);
    approx = approxSubImage(img1, img2, algo, true);
    mssim_val = ssim(exactAdd, approx);
    fprintf('%-22s MSE = %8.3f  PSNR = %6.2f dB MSSIM = %6.2f dB\n', algoNames{k}, mse_val, psnr_val, mssim_val);

    subplot(2,3,k+1); imshow(approx);
    title(sprintf('%s\nPSNR=%.2fdB', algoNames{k}, psnr_val));
end

% tunah chuan greyscale filter
rgbImg = imresize(pickachiu, [256 256]);
exactGray = rgb2gray(rgbImg);

figure('Name', 'Apporximate Greyscale');
subplot(2,3,1); imshow(exactGray); title('Exact Greyscale');

fprintf('\n results of greyscale\n');
for k = 1:numel(algos)
    algo = algos(k);
    approx = approxGreyscale(rgbImg, algo);
    mssim_val = ssim(exactAdd, approx);
    fprintf('%-22s MSE = %8.3f  PSNR = %6.2f dB MSSIM = %6.2f dB\n', algoNames{k}, mse_val, psnr_val, mssim_val);

    subplot(2,3,k+1); imshow(approx);
    title(sprintf('%s\nPSNR=%.2fdB', algoNames{k}, psnr_val));
end

fprintf('\nDone. Figures show Exact vs each approximate algorithm.\n');


% local functions

function [S, Cout] = approxAdderImage(A, B, algo, Cin0)
    A = uint8(A);
    B = uint8(B);
    sz = size(A);

    Cin = false(sz) | logical(Cin0);
    Sbits = false([sz, 8]);

    for bitpos = 1:8
        a = logical(bitget(A, bitpos));
        b = logical(bitget(B, bitpos));

        maj = (a & b) | (b & Cin) | (a & Cin);

        switch algo
            case 1
                c = maj;
                s = ~c;
            case 2
                c = maj;
                s = c;
            case 3
                c = a & b;
                s = xor(a, b);
            case 4
                c = (a & b) | (b & Cin);
                s = ~c;
            case 5
                if bitpos <= 4
                    c = maj;
                    s = ~c;
                else
                    c = maj;
                    s = xor(xor(a, b), Cin);
                end
            otherwise
                error('Algo number a dik lo... %d', algo);
        end

        Sbits(:,:,bitpos) = s;
        Cin = c;
    end

    Cout = Cin;

    % reconstructing the 8 bit value  
    S = zeros(sz, 'uint16');
    for bitpos = 1:8
        S = S + uint16(Sbits(:,:,bitpos)) * uint16(2^(bitpos-1));
    end
    S = uint8(mod(double(S), 256));
end

function out = approxAddImage(A, B, algo, doSaturate)
    if nargin < 4, doSaturate = true; end
    [S, Cout] = approxAdderImage(A, B, algo, 0);
    if doSaturate
        S(Cout) = 255;
    end
    out = S;
end

function out = approxSubImage(A, B, algo, doClamp)
    if nargin < 4, doClamp = true; end
    Bcomp = bitcmp(uint8(B));
    [S, Cout] = approxAdderImage(A, Bcomp, algo, 1);
    if doClamp
        S(~Cout) = 0;
    end
    out = S;
end

function Gray = approxGreyscale(rgbImg, algo)
    R = rgbImg(:,:,1);
    G = rgbImg(:,:,2);
    B = rgbImg(:,:,3);

    Rt = bitshift(R, -2);
    Gt = bitshift(G, -1);
    Bt = bitshift(B, -3);

    temp = approxAdderImage(Rt, Gt, algo, 0);
    Gray = approxAdderImage(temp, Bt, algo, 0);
end

function [mse_val, psnr_val] = imageError(exactImg, approxImg)
    exactImg = double(exactImg);
    approxImg = double(approxImg);
    mse_val = mean((exactImg(:) - approxImg(:)).^2);
    if mse_val == 0
        psnr_val = Inf;
    else
        psnr_val = 10 * log10(255^2 / mse_val);
    end
end
