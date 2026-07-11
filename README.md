# The Memristor Project

A MATLAB environment for **approximate computing using memristive-based majority (MAJ) gates**. The project builds and evaluates several MAJ-gate approximate adder designs, then applies them to real image processing tasks to see how the approximation trades off accuracy for efficiency.

## Overview

A memristor-based 1-bit full adder can be realized using a majority (MAJ) gate. This project implements four such realizations — exact and approximate — and studies their behavior at the bit level (ripple-carry adders of varying width) and at the application level (image arithmetic).

## Algorithms

The 1-bit adder is built around `MAJ(A, B, C)`, with four variants:

| Algorithm | Carry-out | Sum |
|-----------|-----------|-----|
| **A1** | `MAJ(A, B, C)` | `Cout'` |
| **A2** | `MAJ(A, B, C)` | `Cout` |
| **A3** | `AB` | `A XOR B` |
| **A4** | `AB + BC` | `Cout'` |

## Objectives

1. Build a working MATLAB environment to:
   - Compute error metrics (MAE, MSE, PSNR) for A1–A4 across 1-bit, 2-bit, 8-bit, 16-bit, and 32-bit ripple-carry adders (RCA).
   - Perform image processing operations (addition, subtraction, greyscale filtering) using A1–A4.
   - Compute PSNR, SSIM, and MSSIM for the resulting images.
2. Compare results against existing state-of-the-art approximate adder designs.

## Hybrid Adder Design

For image processing, a **hybrid adder** is used: lower-order bits use the approximate MAJ-based adder, while higher-order bits use the exact MAJ-based full adder — preserving precision where it matters most (MSBs) while saving cost on the LSBs.

| Adder width | Approximate bits | Exact bits |
|-------------|------------------|------------|
| 8-bit  | 0–3  | 4–7   |
| 16-bit | 0–7  | 8–15  |
| 32-bit | 0–15 | 16–31 |

## Repository Structure

```
the_memristor_proj/
├── src/                     # MATLAB source (adder implementations, error metrics, image pipeline)
├── scripts/                 # Run/analysis scripts
├── docs/                    # the docs (deuh tawp)
├── resources/project/       # Project resources and supporting files
├── TheMemristorProject.prj  # MATLAB project file
├── .gitattributes
└── .gitignore
```

## Getting Started

### Requirements
- MATLAB (Image Processing Toolbox recommended for PSNR/SSIM/MSSIM computations)

### Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/opa-ralte/the_memristor_proj.git
   ```
2. Open `TheMemristorProject.prj` in MATLAB to load the project environment.
3. Run the scripts in `scripts/` to reproduce the n-bit error metric analysis or the image processing pipeline.

## Progress

- [x] N-bit error metric calculation for A1–A4 (1-bit through 32-bit RCA)
- [x] Hybrid adder image processing pipeline (addition, subtraction, greyscale)
- [x] PSNR / SSIM / MSSIM evaluation on processed images
- [ ] Comparison against existing state-of-the-art approximate adders

## License

No license specified yet.
