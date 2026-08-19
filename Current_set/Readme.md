# ImageJ_stereology
Stereological macros for ImageJ/Fiji.
Contains macros for ImageJ/Fiji software package to use stereological methods to estimate total parameters 
as volume, surface, length and number of structures of interest from 2D slices and 3D image stacks. 
All current versions are located in "Current_set" folder. 
"Old_2_grids" folder has historical versions of some grids without counters. 
You can "Buffon_needles" macro to demonstrate the principles behind probabilistic geometry, 
which is the foundation of Stereology.

# Credits
These macros were written by Aleksandr Mironov MD, PhD, University of Manchester, UK. 
This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
If you use the material, please read [the license](https://creativecommons.org/licenses/by-nc/4.0/deed.en) 
and give credit appropriately.

# Installation
Macros can be used separately or as a collection that is managed by Stereology_Toolset in ImageJ/Fiji menu.

I. If you want to use macros separately then you can:
1) Open Fiji/ImageJ, File > Open, select the macro to open it.
2) Or simply drug the macro into ImageJ/Fiji panel.
3) Then click Run (or Ctrl-R).

II. If you want to use macros as a collection selectable from ImagJ/Fiji menu:
1) Move the following macroa into "macros" folder in ImageJ/Fiji directory:
     -  Multipurpose_grid
     -  Cycloid_grid
     -  Cavalieri_V_estimator
     -  Spatial_grid
     -  HemiSpherical_probes
     -  Unbiased_Frame&Brick
2) Move Stereology_Toolset into "Imagej/Fiji -> macros -> toolsets" directory
3) Restart ImageJ/Fiji
4) Now you can use Sterelogy_Toolset from the menu (click double chevron bracket menu button - most right one). 

Every macro contains "Help" button in dialog that will show the instructions on how to use the macro. 
Each macro has extensive theoretical and practical explanations in their main body.
