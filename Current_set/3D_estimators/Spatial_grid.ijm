/* INSTRUCTIONS

Macro for object surface estimation using exhaustive serial sections 
with known thickness.
It needs an image stack, it will not work on a single image.
A grid of evenly-spaced and mutually perpendicular lines is displayed on 
cross-sections and the user counts X and Y test-line intersections
with a boundary of a structure of interest. 
For Z-lines points are considered as the "end on" view of a line travelling
in the z direction. Therefore when any grid point moves from "outside" 
a transect of the object to "inside" or vice versa, while moving from 
one section to the next, then that particular line in the z direction 
must have penetrated the surface of the object. So, total count of z lines 
intersection with the object can be tracked as points move either 
from "in" to "out" or from "out" to "in". 

Then an  algorithm then calculates an approximate surface for 
each structure according to the formula:

S = 2*(Ix+Iy+Iz)/(l/v), where

S - object surface area;
I,x Iy, Iz - number of intersections of an object boundary with test lines 
				(in all three orientations);
l/v - grid constant of test line lenght per volume unit.

This macro is based on spatial grid principle and modification by 
Kubínová L, Janácek J., J Microsc. 1998, 191:201-211 (doi: 10.1046/j.1365-2818.1998.00356.x).
 
Upon running the macro the user must specify several parameters in 
the [Spatial grid estimator] window, including the number of lines to 
be displayed per slice, the stack slice thickness (if it is not calibrated), 
the number of objects being analysed and the z-interval of slices to display. 

Once parameters are set the user then assigns each object a name associated 
with a specific counter (starting from Counter 0). The current selected 
counter can be changed by double-clicking on the [Multi-Point Tool] in the 
Image J menu and selecting from the  Counter  drop down menu. The user-assigned 
object names for each counter can be viewed in the [Spatial grid estimator parameters
for stack] window.

To begin counting, the user simply clicks on each test line intersection 
(for X and Y directions) with the boundary of object of interest whilst the 
corresponding counter is selected. For Z-lines the user counts events when vertical
Z-line projections (shown as corsses) goes "in" or "out" of the object boundary.

Mistakenly placed points can be undone by Alt-clicking the point in question.
Complete to count all test line intersections before pressing the [OK] button 
housed on the appropriately titled grey pop-up window. The Macro will then 
display the resulting surface information in the [Spatial grid estimator 
parameters for stack] window.

Sample stack should meet the following requirements:
1) to have isotropic orientation;
2) to have empty (no object) first and last slices in Z axis;
3) Slice thickness must match the complexity of the surface of the object being analysed.
	The estimator needs at minimum 7-8 slices per object to be efficient.

As a rule of thumb, the total number of intesections counted for each object in an 
image stack should be no more than 100-200 due to diminishing returns in 
accuracy. Set the parameters in the [Spatial grid estimator] window to reflect
this by making sure that there are an appropriate number of lines displayed
and that there is a sufficient interval between the slices which are to be
analysed.

If no image stack is open when the macro is run then the user will be asked to 
open an example stack from ImageJ mri-stack.tif. For analysis of this stack 
the default parameters should be left unchanged. A good practice exercise is to 
estimate the surface of both eyeballs. Consider not only the vitreous body (dark) 
but also the sclera (the dense outer layer of the eyeball) and the eye front 
chamber limited by the cornea. As a rough guide, the human eyeball has on average 
of around 17cm2 of surface area.
 
Version: 1.0
Date: 19/03/2026
Author: Aleksandr Mironov 
Еmail: amj-box@mail.ru

This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
If you use the material, please read the license (https://creativecommons.org/licenses/by-nc/4.0/deed.en)
and give credit appropriately.
*/ 


//help 

html1 = "<html>" 
	+"<font color=navy>Macro for object surface area estimation using exhaustive<br>" 
	+"serial sections with known thickness.<br>"  
	+"It needs an image stack, it will not work on a single image.<br><br>"
	+"<font color=black>If no image stack is open then the user will be<br>" 
	+"asked to open an example stack from ImageJ - <b>mri-stack.tif</b>.<br>" 
	+"For analysis leave the default grid parameters unchanged.<br><br>"
	+"The stack is calibrated for voxel size <b>0.8x0.8x4mm</b><br><br>"
	+"A good practice exercise is to estimate the volume of both eyeballs.<br>" 
	+"Consider not only the vitreous body (dark) but also the sclera<br>"
	+"(the dense outer layer of the eyeball) and the eye front chamber<br>"
	+"limited by the cornea.<br><br>" 
	+"As a rough guide, the human eyeball has on average of<br>" 
	+"around <b>17cm2</b> of surface area.<br><br>"
	
html2 = "<html>" 
	+"<h1><font color=navy>Spatial grid surface area estimator_ver.1.0</h1>" 
	+"<font color=navy>A grid of evenly-spaced and mutually perpendicular lines along x,y and z axes<br>"
	+"is displayed on stack slices.<br>"
	+"The user counts X and Y test-line intersections with a boundary of the structure<br>"
	+"of interest. For Z-lines crosses are considered as the 'end on' view of a line<br>"
	+"travelling in the z direction. So, the total count of z lines intersections with<br>" 
	+"the object can be tracked as crosses move either from 'in' to 'out' or from 'out'<br>" 
	+"to 'in' the object of interest.<br><br>" 
	+"This macro is based on <b>Spatial grid</b> principle with the modification by<br>" 
	+"Kubínová L, Janácek J., J Microsc. 1998, 191:201-211 <br>"
	+"(doi: 10.1046/j.1365-2818.1998.00356.x).</i><br><br>"
	+"The <b>Surface Area</b> for objects of interest is calculated with<br>" 
	+"the following <u>formula:</u><br>"
	+"<b>S = 2*(Ix+Iy+Iz)/(l/v)</b>, where<br>"
	+"<b>S</b> - object surface area;<br>"
	+"<b>I,x Iy, Iz</b> - number of intersections of an object boundary with test lines<br>"
	+"&nbsp&nbsp&nbsp (in all three orientations);<br>"
	+"<b>l/v</b> - grid constant of test line lenght per volume unit.<br><br>"
	+"<font color=black><b>How to work with this macro</b><br><br>"
	+"1) Specify parameters in <b>[Spatial grid surface area estimator]</b> dialog:<br><br>"
	+"&nbsp&nbsp&nbsp - new overlay removes previous overlays<br>"
	+"&nbsp&nbsp&nbsp - random offest randomizes grid location<br>"
	+"&nbsp&nbsp&nbsp - test lines colour<br>"
	+"&nbsp&nbsp&nbsp - number of lines per slice<br>"
	+"&nbsp&nbsp&nbsp - number of objects being analysed<br>" 
	+"&nbsp&nbsp&nbsp - stack reslicing option<br><br>"
	+"2) Assign each object a name associated with a specific counter<br>"
	+"&nbsp&nbsp&nbsp(starting from <b>Counter 0</b>)<br><br>"
	+"3) To count - click on test-line intersection with the boundary of  object of interest<br><br>"
	+"4) Double click on  <b>[Multi-Point Tool]</b> in the Image J menu and<br>"
	+"&nbsp&nbsp&nbsp select a counter for the next object from drop down menu<br><br>"
	+"5) After counting is done press <b>[OK]</b> on grey pop-up window<br><br>"
	+"6) Macro displays results in <br>"
	+"&nbsp&nbsp&nbsp<b>[Spatial grid estimator parameters for stack]</b> window<br><br>"

html3 = "<html>" 
	+"Mistakenly placed counts can be undone by Alt-clicking the point.<br><br>"
	+"As a rule of thumb, the total number of intersections counted for each object in an<br>"
	+"image stack should be no more than <b>100-200</b> due to diminishing returns in<br>"
	+"accuracy. Spatial grid estimator needs at minimum <b>7-8 slices</b> per object to be efficient.<br><br>"
	+"Image stack should meet the following <b>requirements:</b><br>"
	+"&nbsp&nbsp&nbsp 1) Have isotropic orientation;<br>"
	+"&nbsp&nbsp&nbsp 2) Have empty (no object) first and last slices in Z axis;<br>"
	+"&nbsp&nbsp&nbsp 3) Slice thickness must match the complexity of the surface of<br>" 
	+"&nbsp&nbsp&nbsp  the object being analysed.<br>"
	
requires("1.54p");

//Check for opened stacks
if (nImages==0) { 
	Dialog.create("Stack for counting"); 
	Dialog.addMessage("No open stacks detected"); 
	Dialog.addChoice("Do you want to open example stack?", newArray("yes", "no")); 
	Dialog.addHelp(html1); 
	Dialog.show(); 
	ImgChk = Dialog.getChoice(); 
	if (ImgChk == "yes") {  
		MRI_instr();//routine for example MRI stack instructions
	} 
} 
if (nSlices<2) exit("Active image is not a stack! \n\nPlease, select (or open) a stack ..."); 

getDimensions(iwidth, iheight, channels, slices, frames);
shortside = minOf(iwidth, iheight);
getVoxelSize(VxWidth, VxHeight, VxDepth, unit);
name = getTitle();

//Check for scale
if (unit == "pixels") {
	Dialog.create("Spatial grid surface area estimator, ver.1.0");
	Dialog.addMessage("This macro needs proper scale to be set! \n\nPlease, set the scale using 'Properties...' option in pop-up window \n\nOtherwise, all calculations will show pixels ...") 
	Dialog.show();
	run("Properties...");
	}
getVoxelSize(VxWidth, VxHeight, VxDepth, unit);//update voxel size

//Setting counting parameters 
Dialog.create("Spatial grid surface area estimator, ver.1.0");
Dialog.addCheckbox("New Grid Overlay", true);//check1 
Dialog.addCheckbox("Random Grid Offset", true);//check2 
Dialog.addMessage("Counting grid:"); 
Dialog.addChoice("Lines color:", newArray("red", "cyan", "magenta", "blue", "yellow", "orange", "green", "black", "white"));//choice1 
Dialog.addNumber("Lines number:", 10,0,2,"within short side");//number 1
Dialog.addMessage("Counter Setup:"); 
Dialog.addNumber("Number of objects", 2);//number 2
Dialog.addMessage("Active stack can be resliced to have less slices. \nSlices will be removed using interval set by a user. \nPlease, make sure that "+slices+" slices in your stack \nare divisible by selected number");
Dialog.addNumber("Count points on every ", 1,0,3,"slice");//number 3 
Dialog.addHelp(html2); 
Dialog.show(); 
 
 
//Getting grid and counting parameters from dialog
new = Dialog.getCheckbox(); //check1 
if (new == true) Overlay.remove; 
offset = Dialog.getCheckbox(); //check2 grid offset
color = Dialog.getChoice(); //choice1 lines color
nLines = Dialog.getNumber();//number 1 number of lines per shortest side
ObjNmb = Dialog.getNumber();//number 2 number of objects to estimate
reslice = Dialog.getNumber();//number 3 how much to reslice


Lwidth = 1;
size = "tiny";
type = "crosshair";
tile = shortside/nLines;//side of tile square
x1 = 0.75*tile;
y1 = 0.75*tile;

//reslicing if too many slices
if (reslice>1) {
	newVxSize = reslice*VxDepth;
	run("Reslice Z", "new=newVxSize");
	close(name);
	rename(name);
	setVoxelSize(VxWidth, VxHeight, newVxSize, unit);// setting new voxel size after reslicing
	getVoxelSize(VxWidth, VxHeight, VxDepth, unit);// updating voxel size 
	getDimensions(iwidth, iheight, channels, slices, frames);// updating dimensions
}
setLocation(400, 0);

// line length per volume unit. Volume unit consists of tile area with double section thickness
LV = (tile*VxWidth + tile*VxHeight + 2*VxDepth)/(tile*VxWidth*tile*VxHeight*2*VxDepth);

//Naming counters 
Dialog.create("Names for Counters"); 
for (i=0;i<ObjNmb;i++) { 
	N = toString(i); 
	Dialog.addString("Counter "+N+" = ", "Object name");//asking for counters names
};
Dialog.addHelp(html3);
Dialog.show(); 

//Parameter window 
window = isOpen("Spatial grid parameters for stack ["+name+"]");  
title = "[Spatial grid parameters for stack ["+name+"]]";  
if (window == false){   
	run("Text Window...", "name="+ title +"width=60 height=30 menu");  
	setLocation(0, 520);  
	}; 
setLocation(0, 520);

VolumeTile = tile*tile*2*VxWidth*VxHeight*VxDepth;
print(title, "\nSpatial grid for stack ["+name+"]"); 
print(title, "\n\nStack size = "+iwidth+" x "+iheight+" pixels, "+slices+" slices");//showing stack size
print(title, "\nVoxel size = "+VxWidth+" x "+VxHeight+" x "+VxDepth+unit); //showing voxel size
print(title, "\nStack volume = "+iwidth*iheight*slices*VxWidth*VxHeight*VxDepth+unit+"3"); //showing stack volume
print(title, "\n\nGrid parameters:"); 
print(title, "\n   Tile Size ="+tile+"x"+tile+"x"+2+"px");
print(title, "\n   Volume unit [3D tile] ="+tile+"x"+tile+"x"+2+"px = \n"); // 3D tile includes 2 slices and contains 3 mutually perpendicular test lines in X, Y and Z orientation
print(title, "             ="+tile*VxWidth+"x"+tile*VxHeight+"x"+2*VxDepth+unit+" = "+VolumeTile+unit+"3");
print(title, "\n   Line length per volume unit = "+LV+unit+"-2"); //line length per volume unit (3D tile)

//Counter names reminder in parameter window 
CtrName = newArray(ObjNmb);	 
print(title,"\n\nCounters' names reminder:"); 
for (i=0;i<ObjNmb;i++) { 
	N = toString(i); 
	ObjName = Dialog.getString(); //getting object names from "naming counters" part
	print(title,"\n   Counter "+N+" = "+ObjName); 
	CtrName[i] = ObjName; //assign object name to specific counter
} 
print(title, "\n________________________\n"); 


//Setting line color and width
run("Overlay Options...", "stroke="+color+" width="+Lwidth+" set");

//creating grid random offset 
xoff = tile*random;
yoff = tile*random;
if (offset == "false") { //no offset 
	xoff = 0; 
	yoff = 0;
	}

slice = 1;
setSlice(1);
// Drawing 3D grid
while (slice<=slices){
		Draw_H_solid_Line();
		zLines();
		run("Next Slice [>]");
		if(slice<slices){
   			Draw_V_solid_Line();
   			zLines();
   			run("Next Slice [>]"); 
		}
   		slice +=2;
   }
run("Select None");
setSlice(1);

//Counting 
Objects = toString(ObjNmb);
setSlice(1);
setTool("multipoint"); 
run("Point Tool...", "type=Circle color=Yellow size=Large label counter=0"); //setting multipoint tool active
waitForUser("Click [OK] button after counting finished!", "Use MultiPoint Tool (currently set) to count events."+"\n  "+"\nFor each of your "+Objects+" objects change the Counter by double clicking on \nMulti-point Tool button in ImageJ Menu"+"\n  "+"\nClick OK when you finish counting."); //wait for user to finish clicking
setKeyDown("alt"); 
run("Properties... "); //showing statistics of counting

//Surface area estimation 
print(title, "\n\nCounts and Surface Area for objects:\n"); 
ObjSrfc = newArray(ObjNmb); //new array for surface area related to counted points
headers = split(Table.headings,"\t"); 
 	 
for (i=1; i<headers.length; i++) { 
	ObjSrfc[i-1] = Table.get(headers[i],Table.size-1)*2/LV; //surface area calculation according to counts
	print(title,"\n "+CtrName[i-1]+" = "+Table.get(headers[i],Table.size-1)+" counts"+" equals to Volume = "+ObjSrfc[i-1]+unit+"2"); 
  	}; //displaying counting and surface area results
print(title,"\n==========================================\n"); 
close("Counts_"+name); //closing results table


//X lines
function Draw_H_solid_Line() {
	y = y1-yoff;
		while (y<iheight) {
      		makeLine(0, y, iwidth, y);
      		run("Add Selection...");
			y += tile;
			}
		Overlay.show;
	}

//Y lines
function Draw_V_solid_Line() {
	x = x1-xoff;
		while (x<iwidth) { 
      		makeLine(x, 0, x, iheight);
      		run("Add Selection...");
			x += tile;
			}
		Overlay.show;
	}

//Z-lines with point-like projections
function zLines() {
	a = x1/3-xoff;
	b = y1/3-yoff;
	while (b<(iheight)) { 
		while (a<(iwidth)) {
			makePoint(a, b, size+color+type+" add");
			a += tile; 
			} 
		b += tile; 
		a = x1/3-xoff; 
		} 
	}

//Example set instructions
function MRI_instr() {
	//Extracting one slice
	run("MRI Stack (528K)");
	run("Make Substack...", "  slices=4");
	run("Size...", "width=372 height=452 constrain average interpolation=Bicubic");
	screen = screenHeight;
	if (screen>1500) run("In [+]");
	rename("Instructions for mri-stack");

	//Printing instructions
	run("RGB Color");
	setLocation(0, 0);
	setColor("green");
	setFont("SansSerif", 20, "antialiased");
	drawString("Instructions for MRI stack example:", 5, 150);
	setFont("SansSerif", 14, "antialiased");
	setColor("cyan");
	drawString("- Use default counting parameters;", 5, 190);
	drawString("- Name 2 counters for eyeballs;", 5, 220);
	drawString("- Count line intersections with eyeball boundaries", 5, 250);
	drawString("    on relevant slices;", 5, 265);
	drawString("- Change counters by double click on [Multipoint Tool]", 5, 295);
	drawString("    in ImageJ Menu;", 5, 310);
	drawString("- Eyeball structures are shown in red circle;", 5, 340);
	drawString("- Eyeball surface area should be about 17cm2.", 5, 370);
	setColor("yellow");
	drawString("Use 'Help' button in dialog to see full instructions.", 5, 430);

	//Identifying eyeball
	setColor("red");
	drawOval(220, 47, 65, 65);
	run("Select None");

	//Preparing MRI-stack
	selectWindow("mri-stack.tif");
	setLocation(400, 0);
	Stack.setXUnit("cm");
	run("Properties...", "channels=1 slices=27 frames=1 pixel_width=0.08 pixel_height=0.08 voxel_depth=0.4");
	run("Maximize");
	}
