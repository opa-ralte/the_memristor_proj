# the_memristor_proj
Development of matlab environment for approximated computing using memristive-based majority gate.  

**Objectives:**  
1. To create a working environment on MATLAB for the following:  
    a. To find the error metrics for Algorithms 1, 2, 3, and 4 for 1-bit, 2-bit, 8-bit, 16-bit, and 32-bit RCA  
    b. To perform image processing (Addition, Subtraction, grey-scale filter) using Algorithms 1, 2, 3, and 4  
    c. To find the PSNR, SSIM and MSSIM for the above  
2. To compare results with existing SOA  

**Algorithms/Approximations to use**  
Algorithm:  
1-bit adder is realized using MAJORITY gate and approximated as:  
A1: Cout = MAJ(A,B,C) and Sum = Cout'  
A2: Cout = MAJ(A,B,C) and Sum = Cout  
A3: Cout = AB and Sum = A XOR B  
A4: Cout = AB+BC and Sum = Cout’  

**Note**  
While processing the image, use a hybrid adder: use the approximated value for lower k bits and the  
exact MAJ-based full adder for the higher bits.  
Example:  
for an 8-bit adder  
    Bit 0-3: approximate  
    Bit 4-7: exact
for a 16-bit adder  
    Bit 0-7: approximate  
    Bit 8-15: exact  
for a 32-bit adder
    Bit 0-15: approximate
    Bit 16-31: exact

**My Progress**
Right now I have done finding the error metrics for A1-A4 for 1 bit number additions
