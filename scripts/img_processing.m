% Algorithms used (bit-level full adder, inputs A, B, Cin):
%   A1: Cout = MAJ(A,B,C)   , Sum = Cout'
%   A2: Cout = MAJ(A,B,C)   , Sum = Cout
%   A3: Cout = A.B          , Sum = A xor B
%   A4: Cout = A.B + B.C    , Sum = Cout'

clear; clc; close all;

% first we have to load test images

% i will simply use the builtin image in matlab
% this one is a grayscale, 256x256
img1 = imread('cameraman.tif');
% this one is a color image that needs a resize/grayscaling maw
img2rgb = imread('peppers.png');


% this will convert img2rgb into grayscale image of same size as to img1  
img2 = im2uint8(rgb2gray(imresize(img2rgb, size(img1))));

figure('Name', 'Input Images');
subplot(1,2,1); imshow(img1); title('image A aw, thla la tu thlalak');
subplot(1,2,2); imshow(img2); title('image B aw')

algos = [1 2 3 4];
algoNames = {'A1 (Sum=Cout'')', 'A2 (Sum=Cout)','A3 (ignores Cin)', 'A4 (AB+BC, Sum=Cout'')'};

% tunah image addition - now we begin image addition
exactAdd = imadd(img1, img2);   % tah hi chuan matlab-in a chhawm sa image addition kan hmanga, exact result atan kan la a ni e

figure('Name', 'Approximate Addition');
subplot(2,3,1); imshow(exactAdd); title('Exact Addition');

% tunah chuan image subtraction - this is image subtraction
exactSub = imsubtract(img1, img2); % tah pawh matlab subtraction kan hmang phawt, exact subtraction kan duh vangin  

figure('Name', 'Approximate Subtraction');
subplot(2,3,1); imshow(exactSub); title('Exact Subtraction');

% tunah chuan greyscale filter
rgbImg = imresize(img2rgb, [256 256]);
exactGray = rgb2gray(rgbImg);

figure('Name', 'Apporximate Greyscale');
subplot(2,3,1); imshow(exactGray); title('Exact Greyscale');