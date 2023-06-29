# Qualisys PAF Theia Matlab Example

## Info

This example is a modification of the Qualisys *Open PAF Theia Markerless example*. Modifications:
* Removed Visual3D scripts
* Added Matlab scripts and resources to convert Theia pose data to QTM-like .mat and .tsv output formats.

The Theia pose data (C3D) are parsed using [ezc3d](https://github.com/pyomeca/ezc3d).

The original PAF example can be found on [Github](https://github.com/qualisys/paf-theia-markerless-example).

## Requirements

The Matlab scripts require the following toolboxes:
* QTMTools from [GitHub](https://github.com/schoondw/QTMTools).
* MarkerlessTools from [GitHub](https://github.com/schoondw/MarkerlessTools).
* Matlab Statistics and Machine Learning Toolbox from [Mathworks](https://mathworks.com/products/statistics.html) (only required for extraction of Theia processing statistics).

Copies of QTMTools and MarkerlessTools (only the necessary functions) are included with the package.

Other requirements:
* [ffmpeg](https://ffmpeg.org/download.html) (only required for extraction of video meta data)

## Preparing QTM project
There are two ways how to set up the project for QTM.
1. Simple method is to unzip the zip file and open the project from QTM (File > Open Project) or by double clicking on Settings.paf in File Explorer.
2. If you plan to create multiple projects based on this example, unzip the zip file to `C:\Program Files (x86)\Qualisys\Qualisys Track Manager\Packages`, name the folder `PAF Theia Matlab Example` and delete Settings.qtmproj. Then go to QTM > File > New Project and create new project based on `Theia Matlab Example`.

## Preparing Qualisys data for Theia3D and Matlab processing

1. Install [Theia](https://www.theiamarkerless.ca/) and accompanying engine.
2. In QTM, set Project Options > Miscellaneous > Folder Options for "Theia" to ```C:\Program Files\Theia\Theia3D\Theia3D.exe``` (adapt if Theia is installed at different location).
3. Install Matlab.
4. Set Project Options > Miscellaneous > Folder Options for "Matlab" to ```C:\Program Files\MATLAB\R2021a\bin\matlab.exe``` (adapt if Matlab is installed at different location).
5. Download data from Qualisys File Library (https://qfl.qualisys.com/#!/project/theiaexample).

   Example data includes examples for the PAF Theia Markerless Examples. Only the standard Markerless session is supported in the PAF Theia Matlab Example:
   - **John Doe** can be used with this example for Theia processing and Matlab data conversion.

## Conversion of Theia data to QTM-like export formats

1. First, you will first need to perform the Theia processing step.
2. Click on **Matlab Pose conversion**. This will convert Theia pose data to QTM-like output formats .mat and .tsv for skeleton data (see description in the QTM manual). These files will be added to the session folder. In case there are subjects in the measurement, all skeletons (poses) detected by Theia will be included in the .mat file, and there will be one .tsv file for each skeleton. In addition, a file "skeleton_export_info.xlsx" is added to the session folder containing information about the trial conversion and the extracted skeletons.
3. Optionally, you can run the **Matlab Extract Theia Processing Stats** analysis to collect meta information about the Miqus videos and Theia processing times per trial. This information will be added to the "skeleton_export_info.xlsx" file. This step requires that you have ffmpeg installed on the computer and that the ffmpeg binary folder (e.g. \ffmpeg-4.4.1-full_build\bin) is included in the system path of the computer's Environment Variables.

Example tested with:
 - Matlab 2021a
 - ezc3d 1.5.4 (compiled for Windows x64)
 - ffmpeg-4.4.1
 - QTMTools (2023-06-16)
 - MarkerlessTools (2023-06-29)

## Resources for using the Qualisys Project Automation Framework (PAF)

The purpose of the ***Project Automation Framework*** (PAF) is to streamline the motion capture process from data collection to the final report. This repository contains an example project that illustrate how PAF can be used to implement custom automated data collection in [Qualisys Track Manager (QTM)](http://www.qualisys.com/software/qualisys-track-manager/), and how QTM can be connected to a processing engine. 

### PAF Documentation

The full documentation for PAF development is available here: [PAF Documentation](https://github.com/qualisys/paf-documentation).

### PAF Examples

Our official examples for various processing engines:

- [Excel](https://github.com/qualisys/paf-excel-example)
- [Matlab](https://github.com/qualisys/paf-matlab-example)
- [OpenSim](https://github.com/qualisys/paf-opensim-example)
- [Python](https://github.com/qualisys/paf-python-example)
- [Theia Markerless](https://github.com/qualisys/paf-theia-markerless-example)
- [Theia Markerless Comparison](https://github.com/qualisys/paf-theia-markerless-comparison-example)
- [Theia Markerless True Hybrid](https://github.com/qualisys/paf-theia-markerless-true-hybrid-example)
- [Visual3D](https://github.com/qualisys/paf-visual3d-example)

_As of QTM version 2.17, the official Qualisys PAF examples can be used without any additional license. Note that some more advanced analysis types require a license for the "PAF Framework Developer kit" (Article number 150300)._
