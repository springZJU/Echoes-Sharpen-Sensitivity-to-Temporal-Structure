# Code Repository for "Echoes Sharpen Sensitivity to Temporal Structure"

This repository contains the MATLAB code and resources required to reproduce the main figures presented in the paper "Echoes Sharpen Sensitivity to Temporal Structure".

## System Requirements
- MATLAB (The code has been tested on [Insert Your MATLAB Version, e.g., R2024a])
- No specific operating system constraints (Windows, macOS, Linux compatible).

## Directory Structure

### 1. Main Scripts
- **configInitialization.m**: 
  This script initializes the environment. It adds all necessary paths, including the `add-on` toolboxes and `utils` folder, to the MATLAB search path. **Run this file first before executing any figure scripts.**

- **FigureN_Direct.m** (e.g., `Figure2_Direct.m`, `Figure3_Direct.m`, ...): 
  These scripts correspond to the main figures in the paper. Once the data is downloaded and placed correctly, running these scripts will directly generate the corresponding panels shown in the publication.

### 2. Dependencies & Helpers
- **add-on/**: 
  Contains necessary custom and third-party open-source toolboxes required for plotting and analysis.
  
- **utils/**: 
  Contains specific helper functions and subroutines called by the main analysis scripts.

## Usage Instructions

1. **Data Preparation**:
   - Download the dataset from [Insert Link or DOI here].
   - Place the data in the root directory (or specify the folder if different, e.g., `./Data/`).

2. **Initialization**:
   - Open MATLAB and navigate to this folder.
   - Run `configInitialization.m` to set up the workspace and paths.

3. **Reproducing Figures**:
   - Run the specific figure script (e.g., `Figure2_Direct.m`) to generate the plot.

## License
MIT License, CC-BY

## Contact
For any questions regarding the code or data, please contact:
[Dr. Peirun Song/Email:11815013@zju.edu.cn]