/*Stereology toolset
Compiles stereological macros and plugins in a convenient form. 
First Menu Tool used to set an image scale in proper measurement units.
Second Menu Tool chooses one of 4 different grids.
Third Menu Tool selects unbiased frame grid and allows disector volume estimation.
Forth Menu Tool calls for Multi-point Tool to count events.
Fifth Menu Tool gives some explanations.

Version: 1.1
Date: 08/06/2016
Author: Aleksandr Mironov amj-box@mail.ru
*/

 macro "Unused Tool-1 -" {}  
// leaves slot unused


var aCmds = newMenu("Set Scale Menu Tool",
	newArray("Instructions", "Measure", "Set Scale..."));

macro "Set Scale Menu Tool - C037F02f2 - C037L0c0f -C037T0d0cu -C037T7d0cm"
{
	cmd=getArgument();
	run(cmd);
}

macro "Instructions"
	{
		window = isOpen("Instructions"); 
		title = "[Instructions]"; 
		if (window == false){  
			run("Text Window...", "name="+ title +"width=90 height=17 menu"); 
			setLocation(0, 0);
			print(title, "\n If your image magnification is not calibrated: \n\n- Select the Straight Line tool \n\n - Overlay the line above the scale bar \n\n - Use Measure command \n\n - Bring up Set Scale dialog \n\n - Fill in Known Distance and Unit of Length \n\n - Check Global if all the images have the same scale");
			}
		else 
			selectWindow("Instructions");
	}
// asks for performing magnification calibration



var bCmds = newMenu("Select Grid Menu Tool",
	newArray("Multipurpose grid", "Cycloid grid", "Merz grid", "Multiple Circles grid", "Remove Overlay"));

macro "Select Grid Menu Tool -C037L202f -C037L606f -C037La0af -C037Le0ef -C037L02f2 -C037L06f6 -C037L0afa -C037L0efe"
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
macro "Merz grid"
	{
	runMacro("Merz_grid");
	}
macro "Multiple Circles grid"
	{
	runMacro("Multiple_Circles_grid");
	}
macro "Remove Overlay"
	{
	run("Select None");
	run("Remove Overlay");
	}

// allows to select appropriate stereological grid


var cCmds = newMenu("Disector Menu Tool",
	newArray("Unbiased Frame(s)", "Remove Overlay"));

macro "Disector Menu Tool -Cf00L303c -Cf00L202c -Cf00L3bcb -Cf00L2ccc -Cf00Lcccf -Cf00Lbcbf -C037L33c3 -C037Lc3cb"
{
	cmd=getArgument();
	run(cmd);
}

macro "Unbiased Frame(s)"
	{
	runMacro("Unbiased_Frames");
	}
// allows to perform disector method

macro "Remove Overlay"
	{
	run("Select None");
	run("Remove Overlay");
	}



var dCmds = newMenu("Counting Tool Menu Tool",
	newArray("Counting Tool","Counting Help"));
	
macro "Counting Tool Menu Tool -C037T0e0c1 -C037T6e0c2 -C037Tce0c3"
{
	cmd=getArgument();
	run(cmd);
}
	
macro "Counting Tool"
{
	setTool("multipoint");
	run("Point Tool...", "type=Circle color=Magenta size=Medium label show counter=0");
}
// calls for Multi-point Tool to count objects

macro "Counting Help"
	{
		window = isOpen("Counting Help"); 
		title = "[Counting Help]"; 
		if (window == false){  
			run("Text Window...", "name="+ title +"width=90 height=17 menu"); 
			setLocation(0, 0);
			print(title, "\n - Double click on Multi-point Tool for options and more counters \n\n- Click on a feature to count a point event \n\n- Alt-click, or control-click, on a point to delete it \n\n - Press 'y' to display the counts in a results table \n\n - Press 'm' to display the point stack positions in the results table \n\n - Use File>Save As>Tiff or File>Save As>Selection to save the points and counts \n\n - Hold the shift key down and points will be constrained to a horizontal or vertical line");
			}
		else 
			selectWindow("Counting Help");
	}


macro "Help Action Tool - Caffo11dd - C037O11dd -C037T5c0c?"
	{
		window = isOpen("Stereology Toolset Help"); 
		title = "[Stereology Toolset Help]"; 
		if (window == false){  
			run("Text Window...", "name="+ title +"width=90 height=13 menu"); 
			setLocation(0, 0);
			print(title, "\n - Set Scale Tool is used to set an image scale in proper measurement units \n\n - Select Grid Tool chooses one of 4 stereological grids \n\n - Disector Tool selects unbiased frame grid and allows disector volume estimation \n\n - Counting Tool calls for Multi-point Tool to count events \n\n - All macros contain Help button in their dialog windows");
			}
		else 
			selectWindow("Stereology Toolset Help");
}
