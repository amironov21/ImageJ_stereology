/*
Stereology toolset combines several macros in a convenient form. 
First Menu Tool offers grids for 2D datasets.
Second Menu Tool offers grids for 3D datasets.
Third Menu Tool selects unbiased frame grid and allows disector volume estimation.
Fourth Menu Tool gives some explanations about macros.

For the toolset to work properly it should be located in "Imagej -> macros -> toolsets"
directory. "ImageJ -> macros" directory should contain the following macros:
- Multipurpose_grid
- Cycloid_grid
- Cavalieri_V_estimator
- Spatial_grid
- HemiSpherical_probes
- Unbiased_Frame&Brick

Version: 2.0
Date: 19/08/2026
Author: Aleksandr Mironov amj-box@mail.ru
*/

 macro "Unused Tool-1 -" {}  
// leaves slot unused


var aCmds = newMenu("2D Grids Menu Tool",
	newArray("Multipurpose grid", "Cycloid grid"));

macro "2D Grids Menu Tool -C037L202f -C037L606f -C037La0af -C037Le0ef -C037L02f2 -C037L06f6 -C037L0afa -C037L0efe"
{
	cmd=getArgument();
	run(cmd);
}

macro "Multipurpose grid"
	{
	runMacro("Multipurpose_grid");
	}
macro "Cycloid grid"
	{
	runMacro("Cycloid_grid");
	}


var bCmds = newMenu("3D Grids Menu Tool",
	newArray("Cavalieri Volume Estimator","Spatial grid", "HemiSpherical probes"));
	
macro "3D Grids Menu Tool -C037L70f0 -C037Lb3f3 -C037L0777 -C037Lc7f7 -C037L0b7b -C037L0f7f -C037L0770 -C037L77f0 -C037L0b37 -C037L7bf3 -C037L0f3b -C037L7ff7"
{
	cmd=getArgument();
	run(cmd);
}
	
macro "Cavalieri Volume Estimator"
	{
	runMacro("Cavalieri_V_estimator");
	}
macro "Spatial grid"
	{
	runMacro("Spatial_grid");
	}
macro "HemiSpherical probes"
	{
	runMacro("HemiSpherical_probes");
	}


macro "Unbiased Frame & Brick Action Tool -Cf00L303c -Cf00L202c -Cf00L3bcb -Cf00L2ccc -Cf00Lcccf -Cf00Lbcbf -C037L43c3 -C037Lc3ca"
{
	runMacro("Unbiased_Frame&Brick");
	}


macro "Help Action Tool - CaffV11dd - C037O11dd -C037T7d0c?"
	{
		window = isOpen("Stereology Toolset Help"); 
		title = "[Stereology Toolset Help]"; 
		if (window == false){  
			run("Text Window...", "name="+ title +"width=90 height=30 menu"); 
			setLocation(0, 0);
			print(title, "\n1) 2D Grids Menu contains: \n\n - [Multi-purpose grid] for volume and surface density estimation \n   on isotropic uniform random sections. \n - [Cycloid grid] for surface and length density estimation \n   on vertical uniform random sections.");
			print(title, "\n\n2) 3D Grids Menu contains: \n\n - [Cavalieri Volume Estimator] for estimation of features volume in a stack. \n - [Spatial grid] for estimation of features surface area in a stack. \n - [HemiSperical probes] for estimation of features length in a stack.");			
			print(title, "\n\n3) Unbiased Frame&Brick Action Tool: \n\n - Draws unbiased frame grid and allows features number estimation in a stack");
			print(title, "\n\n4) Help Action Tool shows this window.");
			print(title, "\n\n\n\n5) All macros contain [Help] button in their dialog windows and have \nextensive theoretical and practical explanations in the main body.");			
		}
		else 
			selectWindow("Stereology Toolset Help");
}
