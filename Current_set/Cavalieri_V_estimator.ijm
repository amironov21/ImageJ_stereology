/* INSTRUCTIONS

Macro for object volume estimation using exhaustive serial sections 
with known thickness.
It needs an image stack, it will not work on a single image.
A grid of evenly-spaced points is displayed on cross-sections at 
a user-specified z-interval and the user counts how many points 
fall within each structure of interest. An algorithm then calculates 
an approximate volume for each structure. This macro is based on 
Cavalieri principle. 
 
Upon running the macro the user must specify several parameters in 
the [Cavalieri estimator] window, including the number of points to 
be displayed per slice, the stack slice thickness, the number of objects 
being analysed and the z-interval of slices to display. Once parameters 
are set the user then assigns each object a name associated with a specific 
counter (starting from Counter 0). The current selected counter can be 
changed by double-clicking on the [Multi-Point Tool] in the Image J menu 
and selecting from the  Counter  drop down menu. The user-assigned object
names for each counter can be viewed in the [Cavalieri estimator parameters
for stack] window.
To begin counting, the user simply clicks on each cross that falls within 
the object of interest whilst the corresponding counter is selected. 
Mistakenly placed points can be undone by Alt-clicking the point in question.
Click on each cross that falls within the objects being analysed in every 
displayed slice before pressing the [OK] button housed on the appropriately 
titled grey pop-up window. The Macro will then display the resulting volume 
information in the [Cavalieri estimator parameters for stack] window.

As a rule of thumb, the total number of points counted for each object in an 
image stack should be no more than 100-200 due to diminishing returns in 
accuracy. Set the parameters in the [Cavalieri estimator] window to reflect
this by making sure that there are an appropriate number of crosses displayed
and that there is a sufficient interval between the slices which are to be
analysed. The appearance of the displayed crosses can also be changed.

If no image stack is open when the macro is run then the user will be asked to 
open an example stack from ImageJ   mri-stack.tif. For analysis of this stack 
the default parameters should be left unchanged. A good practice exercise is to 
estimate the volume of both eyeballs. Consider not only the vitreous body (dark) 
but also the sclera (the dense outer layer of the eyeball) and the eye front 
chamber limited by the cornea. As a rough guide, the human eyeball is on average 
around 6cm3 in volume.

Many thanks to Tobias Starborg and David Smith who helped in testing and improving
this macro.
 
Version: 1.3
Date: 26/01/2026
Author: Aleksandr Mironov 
Еmail: amj-box@mail.ru

This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
If you use the material, please read the license (https://creativecommons.org/licenses/by-nc/4.0/deed.en)
and give credit appropriately.
*/ 

requires("1.54p"); 
 
//help 
html = "<html>" 
	+"<h1><font color=navy>Cavalieri volume estimator_ver.1.3</h1>" 
	+"<font color=navy><i>Macro for object volume estimation using exhaustive serial sections.<br>"  
	+"It needs an image stack, it will not work on a single image.<br>"
	+"A grid of evenly-spaced points is displayed on cross-sections at<br>" 
	+"a user-specified z-interval and the user counts how many points<br>" 
	+"fall within each structure of interest. An algorithm then calculates<br>" 
	+"an approximate volume for each structure. This macro is based on<br>"
	+"<b>Cavalieri principle</b>.</i><br><br>"
	+"<b>How to work with this macro</b><br><br>"
	+"1) Specify parameters in <b>[Cavalieri estimator]</b> dialog:<br>" 
	+"&nbsp&nbsp&nbsp - appearance of displayed points<br>"
	+"&nbsp&nbsp&nbsp - number of points per slice<br>"
	+"&nbsp&nbsp&nbsp - number of objects being analysed<br>" 
	+"&nbsp&nbsp&nbsp - original z-interval between slices<br>" 
	+"&nbsp&nbsp&nbsp - stack reslicing option<br><br>"
	+"2) Assign each object a name associated with a specific counter<br>"
	+"&nbsp&nbsp&nbsp(starting from <b>Counter 0</b>)<br><br>"
	+"3) To count - click on each cross within object of interest<br><br>"
	+"4) Double click on  <b>[Multi-Point Tool]</b> in the Image J menu and<br>"
	+"&nbsp&nbsp&nbsp select a counter for the next object from drop down menu<br><br>"
	+"5) After counting is done press <b>[OK]</b> on grey pop-up window<br><br>"
	+"6) Macro displays results in <br>"
	+"&nbsp&nbsp&nbsp<b>[Cavalieri estimator parameters for stack]</b> window<br><br>"
	+"<font color=black>Mistakenly placed points can be undone by Alt-clicking the point.<br>"
	+"As a rule of thumb, the total number of points counted for each object in an<br>"
	+"image stack should be no more than <b>100-200</b> due to diminishing returns in<br>"
	+"accuracy. Cavalieri estimator needs at minimum <b>7-8 slices</b> per object to be efficient.<br><br>"
	+"<font color=green>If no image stack is open when the macro is run then the user will be<br>" 
	+"asked to open an example stack from ImageJ - <b>mri-stack.tif</b>. For analysis of<br>" 
	+"this stack the default parameters should be left unchanged. A good practice<br>" 
	+"exercise is to estimate the volume of both eyeballs. Consider not only the <br>"
	+"vitreous body (dark) but also the sclera (the dense outer layer of the eyeball)<br>"
	+"and the eye front chamber limited by the cornea. As a rough guide, the<br>" 
	+"human eyeball is on average around 6cm3 in volume.<br><br>"
	+"<i>Many thanks to Tobias Starborg and David Smith who helped in testing<br>"
	+"and improving this macro.</i><br>"


//Check for opened stacks
if (nImages==0) { 
	Dialog.create("Stack for counting"); 
	Dialog.addMessage("No open stacks detected"); 
	Dialog.addChoice("Do you want to open example stack?", newArray("yes", "no")); 
	Dialog.addHelp(html); 
	Dialog.show(); 
	ImgChk = Dialog.getChoice(); 
	if (ImgChk == "yes") {  
		MRI_instr();//routine for example MRI stack instructions
		MRI_set();  //routine to open example MRI stack
	} 
} 
if (nImages==0) exit("No open stacks detected! \n\nPlease, open a stack ..."); 

//Get stack parameters 
getDimensions(width, height, channels, slices, frames); 
getVoxelSize(VxWidth, VxHeight, VxDepth, unit);
name = getTitle(); 
shortside = minOf(width, height); //determining shortest side
if (slices<2) { 
	exit("This macro needs an image stack! \n\nPlease, close all open single images..."); 
	}

//Check for scale
if (unit == "pixels") {
	Dialog.create("Cavalieri volume estimator, ver. 1.3");
	Dialog.addMessage("This macro needs proper scale to be set! \n\nPlease, set the scale using 'Properties...' option in pop-up window \n\nOtherwise, all calculations will show pixels ...") 
	Dialog.show();
	run("Properties...");
	}
getVoxelSize(VxWidth, VxHeight, VxDepth, unit);//update voxel size

//Setting counting parameters 
Dialog.create("Cavalieri volume estimator, ver. 1.3"); 
Dialog.addNumber("\n\nNumber of objects to estimate ", 2);//number 1 
Dialog.addMessage("Counting grid parameters:"); 
Dialog.addChoice("Points color:", newArray("red", "cyan", "magenta", "blue", "yellow", "orange", "green", "black", "white"));//choice1 
Dialog.addChoice("Points type:", newArray("crosshair", "circle", "dot", "hybrid"));//choice2 
Dialog.addChoice("Points size:", newArray("tiny", "small", "medium", "large", "extra large"));//choice3 
Dialog.addNumber("Points number:", 30,0,2,"within short side");//number2 
Dialog.addCheckbox("New Grid Overlay", true);//check1 
Dialog.addCheckbox("Random Grid Offset", true);//check2 
Dialog.addMessage("Active stack can be resliced using the next line. \nPlease, make sure that "+slices+" slices in your stack \nare divisible by selected number");
Dialog.addNumber("Count points on every ", 1,0,3,"slice");//number3
Dialog.addHelp(html); 
Dialog.show(); 
 
 
//Getting grid and counting parameters 
new = Dialog.getCheckbox(); //check1 
if (new == true) Overlay.remove; 
offset = Dialog.getCheckbox(); //check2 grid offset
color = Dialog.getChoice(); //choice1 points color
type = Dialog.getChoice();//choice2 points type
size = Dialog.getChoice();///choice3 points size
ObjNmb = Dialog.getNumber();//number1 number of objects to estimate
number = Dialog.getNumber();//number2 number of points per shortest side
reslice = Dialog.getNumber();//number3 how much to reslice

tile = shortside/number; //sizing a tile of a grid
PntNmb = round(width/tile*height/tile); //number of points depending on number of grid tiles
PntArea = width*height*VxWidth*VxHeight/PntNmb; //setting area per 1 point

//reslicing if too many slices
if (reslice>1) {
	newVxSize = reslice*VxDepth;
	run("Reslice Z", "new=newVxSize");
	close(name);
	rename(name);
	setVoxelSize(VxWidth, VxHeight, newVxSize, unit);// setting new voxel size after reslicing
	getVoxelSize(VxWidth, VxHeight, VxDepth, unit);// updating voxel size 
	getDimensions(width, height, channels, slices, frames);// updating dimensions
}
run("Maximize");

//Naming counters 
Dialog.create("Names for Counters"); 
for (i=0;i<ObjNmb;i++) { 
	N = toString(i); 
	Dialog.addString("Counter "+N+" = ", "Object name");//asking for counters names
}; 
Dialog.show(); 
 
//Parameter window 
window = isOpen("Cavalieri estimator parameters for stack ["+name+"]");  
title = "[Cavalieri estimator parameters for stack ["+name+"]]";  
if (window == false){   
	run("Text Window...", "name="+ title +"width=60 height=20 menu");  
	setLocation(0, 520);  
	}; 
print(title, "\nCavalieri estimator for stack ["+name+"]"); 
print(title, "\n\nStack size ="+width+" x "+height+" pixels, "+slices+" slices");//showing stack size
print(title, "\nVoxel size = "+VxWidth+"X"+VxHeight+"X"+VxDepth+" "+unit); //showing voxel size
print(title, "\nStack volume = "+width*height*slices*VxWidth*VxHeight*VxDepth+" "+unit+"3"); //showing stack volume
print(title, "\n\nCounting grid parameters:"); 
print(title, "\nArea per point ="+PntArea+" "+unit+"2"); //showing area for 1 point
print(title, "\nVolume per point ="+PntArea*VxDepth+" "+unit+"3"); //showing volume for 1 point
 
//Counter names reminder in parameter window 
CtrName = newArray(ObjNmb);	 
print(title,"\n\nCounters' names reminder:"); 
for (i=0;i<ObjNmb;i++) { 
	N = toString(i); 
	ObjName = Dialog.getString(); //getting object names from "naming counters" part
	print(title,"\nCounter "+N+" = "+ObjName); 
	CtrName[i] = ObjName; //assign object name to specific counter
} 
print(title, "\n________________________\n"); 
 
//Creating counting grid with points 
 
//Random grid offset  
xoff = tile*random; 
yoff = tile*random;  
if (offset == false) xoff = yoff = tile/2; 
 
//Initial point coordinates  
x1 = round(tile-xoff);  
y1 = round(tile-yoff);  
x = x1; 
y = y1; 
 
//Calling systematic random points function
for (i = 1; i <= nSlices; i++) {
    setSlice(i);
	SysRdmPoints(x, y, x1, height, width, tile, color, size, type);
	}
//waitForUser;
 
//Counting 
Objects = toString(ObjNmb);
setSlice(1);
setTool("multipoint"); 
run("Point Tool...", "type=Circle color=Yellow size=Large label counter=0"); //setting multipoint tool active
waitForUser("Click [OK] button after counting finished!", "Use MultiPoint Tool (currently set) to count events."+"\n  "+"\nFor each of your "+Objects+" objects change the Counter by double clicking on \nMulti-point Tool button in ImageJ Menu"+"\n  "+"\nClick OK when you finish counting."); //wait for user to finish clicking
setKeyDown("alt"); 
run("Properties... "); //showing statistics of counting
 
//Volume estimation 
print(title, "\n\nCounts and Volumes for objects:\n"); 
ObjVol = newArray(ObjNmb); //new array for volume related to counted points
headers = split(Table.headings,"\t"); 
 	 
for (i=1; i<headers.length; i++) { 
	ObjVol[i-1] = Table.get(headers[i],Table.size-1)*PntArea*VxDepth; //volume calculation according to counts
	print(title,"\n "+CtrName[i-1]+" = "+Table.get(headers[i],Table.size-1)+" counts"+" / Volume = "+ObjVol[i-1]+unit+"3"); 
  	}; //displaying counting and volume results
print(title,"\n==========================================\n"); 
close("Counts_"+name); //closing results table

//Systematic random points 
function SysRdmPoints(x, y, x1, height, width, tile, color, size, type) {
run("Point Tool...", "label show");
while (y<(height-1)) { 
	while (x<(width-1)) {
		makePoint(x, y, size+color+type+" add"); 
		Overlay.setPosition(0,0,0); 
		x += tile; 
		} 
	y += tile; 
	x = x1; 
	} 
} 
 
//Opening example set 
function MRI_set() {  
		selectWindow("mri-stack.tif");
		setLocation(400, 0);
		Stack.setXUnit("cm");
		run("Properties...", "channels=1 slices=27 frames=1 pixel_width=0.08 pixel_height=0.08 voxel_depth=0.4");
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
	drawString("- Use default counting parameters", 5, 190);
	drawString("- Name 2 counters for eyeballs", 5, 220);
	drawString("- Count points hitting eyeballs on relevant slices", 5, 250);
	drawString("- Change counters by double click on", 5, 280);
	drawString("   [Multipoint Tool] in ImageJ Menu", 5, 310);
	drawString("- Eyeball structures are shown in red circle", 5, 340);
	drawString("- Eyeball volume should be about 6cm3", 5, 370);
	setColor("yellow");
	drawString("Use 'Help' button in dialog to see full instructions", 5, 420);

	//Identifying eyeball
	setColor("red");
	drawOval(220, 47, 65, 65);
	
	//Making Multipoint Tool Icon
	setColor("white");
	drawRect(278,258,30,30);
	setColor("black");
	drawRect(279,259,28,28);
	setColor(180, 180, 180);
	fillRect(280, 260, 26, 26);
	xcross = newArray(286,286,284,288,287,287,285,289,294,294,292,296,295,295,293,297,300,300,298,302);
	ycross = newArray(266,270,268,268,275,279,277,277,264,268,266,266,274,278,276,276,268,272,270,270);
	xpoints = newArray(286,294,287,295,300);
	ypoints = newArray(268,266,277,276,270);
	xarrow = newArray(300,304,301,303,302,302);
	yarrow = newArray(280,280,281,281,282,282);

	setColor("black");
	for (i=0; i<20; i++) {
		j=i+1;
		drawLine(xcross[i], ycross[i], xcross[j], ycross[j]);
		i=i+1;
	}
	setColor("yellow");
	for (i=0; i<5; i++) {
		drawLine(xpoints[i], ypoints[i], xpoints[i], ypoints[i]);
	}
	setColor(150, 0, 0);
	for (i=0; i<6; i++) {
		j=i+1;
		drawLine(xarrow[i], yarrow[i], xarrow[j], yarrow[j]);
		i=i+1;
	}
	run("Select None");
}
