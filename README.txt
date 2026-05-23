SMART-Fuse: Semantic-Aware Multimodal Medical Image Fusion
==========================================================

SMART-Fuse is a MATLAB-based multimodal medical image fusion method designed to fuse two registered medical images such as MRI, CT, PET, and SPECT images. The method performs semantic-aware adaptive fusion using local image activity cues, foreground masking, adaptive source-contribution maps, base-detail decomposition, and edge-aware detail fusion.

This repository contains the proposed SMART-Fuse method only. Comparative baseline methods, metric evaluation codes, and parameter comparison scripts are intentionally removed to keep the repository clean and focused on the proposed approach.

Main Features
-------------
1. Supports grayscale and color medical images.
2. Converts grayscale inputs to three-channel images automatically.
3. Uses grayscale guidance maps for semantic activity computation.
4. Generates a foreground mask to suppress non-informative background.
5. Computes semantic activity maps using edge strength, local variance, Laplacian response, and local entropy.
6. Produces adaptive weight maps W1 and W2 for source contribution analysis.
7. Performs luminance-channel fusion using YCbCr color representation.
8. Applies base-detail decomposition using a guided/rolling-guidance-inspired filtering step.
9. Uses edge-aware hybrid detail fusion.
10. Generates visual interpretability outputs: SMART-Fuse output, W1/W2 maps, foreground mask, weight histogram, decision-strength map, dominance map, and ROI-level visualization.

Repository Files
----------------
SMART_Fuse_Proposed_Method_Visual_Analysis.m
    Main MATLAB file containing the proposed SMART-Fuse method and visual analysis.

README.txt
    General repository description and usage overview.

USAGE.txt
    Step-by-step instructions to run the MATLAB code.

REQUIREMENTS.txt
    MATLAB version and toolbox requirements.

METHOD_OVERVIEW.txt
    Short description of the SMART-Fuse methodology.

OUTPUT_FILES.txt
    Description of the figures and image files generated after execution.

INTERPRETABILITY_ANALYSIS.txt
    Explanation of W1, W2, foreground mask, histogram, decision map, and dominance map.

CITATION.txt
    Suggested citation format.

LICENSE.txt
    Simple academic-use license text.

Input
-----
The code requires two registered source images:

I1: Source image 1
I2: Source image 2

Both images are resized to 256 x 256 inside the code. If any input image is grayscale, it is automatically converted to a three-channel image.

Output
------
The code generates the fused image and several visual interpretation figures. The main output is:

SMART_Fuse_Output_Color.png

Other saved outputs include weight maps, foreground mask, decision-strength map, dominance map, and high-resolution figures.

Important Note
--------------
The code is intended for academic and research use. The input medical images should be spatially registered before fusion. The code does not perform image registration.