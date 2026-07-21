/*This macro makes a grid based on multi-purpose grid from Gundersen & Jensen 
(J Microsc. 1987, 147:229-6) as non-destructive overlay  for stereological 
quantities such as volume and surface densisty as well as total feature 
length in 2D plane.

Grid Structure
Stereological probes include evenly-spaced lines and points (crosses) of 
different density with possible random starting position.

Point Types
The macro provides three point types, allowing simultaneous use of 
three point densities with a fixed ratio of 1 : 4 : 16 for:
- Encircled points
- Regular points
- Dense points

Line Types
Two line styles are available:
- Solid lines
- Segmented lines
These allow flexible control of line density.
If both solid and segmented lines are enabled in the same orientation 
(horizontal or vertical), only the solid-line length is used in 
subsequent calculations.

Grid constants
Constant a/l (area per line unit) is used to estimate total lenght
of a flat 2D stucture. Total length equals to number of intersections between 
linear feature and test lines multiplied by PI/2 times the grid constant a/l.
Area per point can be used to estimate an area in 2D samples or volume 
density(fraction) in isotropic uniform random sections through 3D structures.
Test line per point (l/p) constant is used to estimate surface density: surface
area per unit volume in isotropic uniform random sections. 

Default Assumptions
For correct calculations, the macro assumes:
	- Dense points include only isolated points (not located at line ends).
	- Regular points occur at line intersections and include encircled points.
	- Encircled points include only themselves.
	- Segmented line length is defined as the distance between two perpendicular 
		short bars (i.e., between the centres of regular points).
Examples of all point and line types can be viewed using the default dialog options.
All grid parameters are printed to the [Multipurpose Grid Parameters] window.

Counters Setup
The Counters Setup activates the Multipoint Tool for counting probe hits under 
different scenarios. Users assign counter names manually.
For volume and surface density estimation, the last counter must be assigned 
to the reference space.
To change the active counter:
	- Double‑click the Multi‑Point Tool in the ImageJ toolbar.
	- Select the desired counter from the Counter dropdown menu.
Selecting [No Setup (grid only)] option skips the counter configuration step.

Counting Procedure
- Select the appropriate counter (the first counter is automatically selected to be Counter 0).
- Click on each test point or line intersection that falls within the object of interest.
- To remove an incorrectly placed point, Alt‑click it.
The macro converts the counted values into stereological estimates using the appropriate formulas.
All results are printed to the [Multipurpose Grid Parameters] window.
To inspect the original counter values, press Alt + Y.

Example Image
If no image is open when the macro starts, the user will be prompted to load the example 
image [Cell Diagram], which includes a cell body, nucleus, and three organelles. 
The pixel size is approximately calibrated to represent an electron microscopy image.
It is important to do about 8-10 runs for each
of stereological parameters to be estimated to achieve better precision. In real life you can never
get any decent precision if you limit yourself to only one sample. If precision is not enough 
increase the density of the probes.

Version: 4.2
Date: 08/03/2026
Author: Aleksandr Mironov 
Еmail: amj-box@mail.ru

This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
If you use the material, please read the license (https://creativecommons.org/licenses/by-nc/4.0/deed.en)
and give credit appropriately.
*/

requires("1.54p"); 

//help for different menus

html1 = "<html>"
	+"<h1><font color=navy>Cell diagram</h1>"
	+"<font color=black> You can use pre-drawn cell diagram<br>"
	+"that includes nucleus and 3 structures M.<br>"
	+"The image is calibrated to 0.01 um pixel size<br>" 
	+"and has a scale bar.<br><br>"
	
html2 = "<html>"
	+"<h1><font color=navy>Initial setup</h1>"
	+"<b><font color=red>Image Random Rotation: </b><font color=black> rotate the image at random<br>"
	+"to avoid preferential orientation with repetitive structures.<br><br>"
	+"<b><font color=red>Set gird dimensions: </b><font color=black> set by number of grid tiles<br>"
	+"per image shortest side or by specific area per grid point.<br>"
	+"The second option is convenient to have the same grid density<br>"
	+"in different images.<br><br>"
	+"<b><font color=red>Counters: </b><br><br>"
	+"<b>[No Setup (grid only)]</b> - only stereological grid is generated.<br>"
	+"Useful, if non-standard application is needed.<br><br>"
	+"<b>[for Volume Density]</b> - counting points to estimate volume density <br>"
	+"(fraction) of a class/es relative to a reference volume.<br><br>"
	+"<b>[for Surface Density]</b> - counting line intersections with surfaces <br>"
	+"to estimate surface area density related to a reference volume<br>"
	+"(estimated by point counting).<br><br>"	
	+"<b>[for 2D Total Length]</b> - counting line intersections with elongated <br>"
	+"structures to estimate its total length in 2D. Based on <br><b><i>Buffon needles</b></i> principle.<br><br>"
	+"<b><font color=red>Number of classes: </b><font color=black> total number of counted classes<br>"
	+"including a reference space (for Volume and Surface density).<br>"
	
html3 = "<html>"
	+"<h1><font color=navy>Multi-purpose Stereological Grid, ver. 4.2</h1>"
	+"<font color=navy>based on Gundersen & Jensen (J Microsc. 1987, 147:229-6)<br><br>"
	+"<b><font color=red>Stereological probes</b><font color=black> include lines and points (crosses) of different density. <br>"
	+"There are 3 types of points allowing to have 3 different point densities<br>" 
	+"at once with ratio 1:4:16 between Encircled, Regular and Dense points.<br><br>" 
	+"<h1><font color=navy>Grid parameters:</h1>"
	+"<b>New Overlay</b> - removes previous overlays.<br>"
	+"<b>Random Offset</b> - randomizes grid location.<br>"
	+"<b>Tile density</b> or <b>Area per point</b> - determines density of the grid.<br><br>"
	+"<b>Test lines</b> and <b>points</b> parameters appear depending on counting mode.<br>"
	+"<b>Encircled Points</b> - marks 1 sparse point per grid tile and are included<br> in Regular points<br>"
	+"<b>Dense Points</b> - adds 16 points to regular 4 per grid tile.<br><br>"
	+"<b>Solid and segmented lines</b> allow more flexible approach to grid<br>"
	+"lines density. If both solid and segmented lines are chosen in horizontal or <br>"
	+"vertical orientation then only solid lines' length is considered in subsequent calculations.<br><br>"
	+"<font color=purple><b>Default assumptions for correct calculations:</b><br>"
	+"1) Dense points include only isolated points (not at lines' ends).<br>"
	+"2) Regular points are at line intersections and include encircled points.<br>"
	+"3) Encircled points include only themselves.<br>"
	+"4) Segmented line length assumed to be between 2 perpendicular <br> short bars (between centres of regular points).<br><br>"
	+"<b><font color=green>Useful parameters printed out to <br> [Multipurpose grid parameters] window:</b><br><br>"
	+"<font color=green> <i><u>Area per point</u></i> can be used to estimate an area in 2D samples<br>" 
	+"or volume density isotropic uniform random sections.<br><br>"
	+"<i><u>Test line per point</u></i> constant is used to estimate surface density<br>"
	+"(surface area per volume unit) in uniform random sections.<br><br>"
	+"<i><u>Grid constant a/l (area per line unit)</u></i> is used to estimate total lenght<br>"
	+"of a flat stucture. Total lenght equals to number of intersections<br>"
	+"multiplied by PI/2 times the grid constant a/l.<br>"
	
html4 = "<html>"
	+"<h1><font color=navy>Counters for classes<br></h1>"
	+"<font color=black>1) <b>Name</b> the counters according to your <u>classes</u>.<br><br>"
	+" 2) Choose proper stereological <b>probe</b> for each class.<br><br>"
	+"  For <u>Volume or Surface Density</u> counting modes <br>"
	+"the <b><font color=red>last counter</b><font color=black> is reserved for a <b><font color=red>reference space<br>" 
	+"<font color=black></b> and should use <b>points</b> as stereological probes.<br><br>"
	+"<b>Volume density</b> is calculated as:<br>"
	+"<b>Vv = Pcls/Pref</b>, where<br>"
	+"<b>Vv</b> - volume density;<br>"
	+"<b>P</b>cls - point counts for a class;<br>"
	+"<b>P</b>ref - point counts for a reference space.<br><br>"
	+"<b>Surface density</b> is calculated as:<br>"
	+"<b>Sv = 2I/(P*l/p)</b>, where<br>"
	+"<b>Sv</b> - surface density;<br>"
	+"<b>I</b> - intersection of line probes with a class surface;<br>"
	+"<b>P</b> - point counts for a reference space;<br>"
	+"<b>l/p</b> - line length per point - grid constant.<br><br>"
	+"<b>Total length on 2D surface</b> is calculated as:<br>"
	+"<b>L = I*PI/2*aL</b>, where<br>"
	+"<b>L</b> = total length of a flat class;<br>"
	+"<b>I</b> - intersections of line probes with a flat class;<br>"
	+"<b>aL</b> = a/l - area per line length - grid constant.<br>"

//Check for open image and calibrated image
if (nImages==0) {  
	Dialog.create("Image for counting"); 
	Dialog.addMessage("No open images detected"); 
	Dialog.addChoice("Do you want to open example cell diagram?", newArray("yes", "no")); 
	Dialog.addHelp(html1); 
	Dialog.show();
	
	ImgChk = Dialog.getChoice(); 
	if (ImgChk == "yes") Cell_diagram(); 
	};
	
getPixelSize(unit, pw, ph, pd);

//Check for scale
if (unit == "pixels") {
	Dialog.create("Multi-purpose Stereological Grid, ver. 4.2");
	Dialog.addMessage("This macro needs proper image scale to be set! \n\nPlease, set the scale using 'Properties...' option in pop-up window \n\nOtherwise, all calculations will show pixels ...") 
	Dialog.show();
	run("Properties...");
	};
	
run("Select None");
getPixelSize(unit, pw, ph, pd);
getDimensions(width, height, channels, slices, frames);

//Initial dialog for image rotation, grid tile size and counters
Dialog.create("Multi-purpose Stereological Grid, ver. 4.2"); 
Dialog.setInsets(0, 20, 0);
Dialog.addCheckbox("Image Random Rotation", false);//checkbox 1.1
Dialog.addChoice("Set grid dimensions:", newArray("by tiles density", "by area per regular point"));//choice 1.1
Dialog.addMessage("__________________________________");
Dialog.addMessage("          COUNTING MODE:");
Dialog.addChoice("Counters", newArray("No Setup (grid only)", "for Volume Density", "for Surface Density", "for 2D Total Length"));//choice 1.2
Dialog.addNumber("Number of classes", 2);//number 1.1
Dialog.addMessage("Classes should include the reference space \nif applicable, ie for Surface or Volume Density", 14, "red");
Dialog.addHelp(html2);
Dialog.show();

dimensions = Dialog.getChoice();//choice 1.1 - getting grid density
Rotation = Dialog.getCheckbox();//checkbox 1.1 - image random rotation choice
CounterType = Dialog.getChoice();//choice 1.2 - counting setup
ObjNmb = Dialog.getNumber();// number1.1 - number of classes to estimate

RRotation = random*90;
if (Rotation == true)
	run("Rotate... ", "angle=RRotation grid=0 interpolation=Bicubic enlarge");
	run("Maximize");
getDimensions(rwidth, rheight, channels, slices, frames);//image size correction after rotation

//Main dialog box for main grid parameters
Dialog.create("Grid parameters");
Dialog.addMessage("          GENERAL:");
Dialog.addCheckbox("Grid Random Offset", true);// checkbox 2.1
Dialog.addCheckbox("New Overlay", true);// checkbox 2.2
if (dimensions=="by tiles density") { // number 2.1
	Dialog.addNumber("Tile density  =", 5,0,2,"per short side"); 
	} else { 
	Dialog.addNumber("Area per point  =", 1,2,8," "+unit+"¬2"); 
	}; 
	
if (CounterType != "for 2D Total Length") {Dialog.addMessage("__________________________________");
	Dialog.addMessage("          TEST POINTS:");
	Dialog.addChoice("Points color:", newArray("red", "black", "cyan", "green", "yellow", "blue", "magenta", "orange", "white"));// choice 2.1
	Dialog.addCheckbox("Mark 'Encircled' Points (1/4 of regular points)", true);// checkbox 2.3
	Dialog.addCheckbox("Add 'Dense' Points (x4 of regular points)", true);// checkbox 2.4
	Dialog.addChoice("Dense points:", newArray("black", "red", "green", "cyan", "yellow", "blue", "magenta", "orange", "white"));// choice 2.2
	}
if (CounterType != "for Volume Density") {Dialog.addMessage("__________________________________");
	Dialog.addMessage("          TEST LINES:");
	Dialog.addNumber("Line thickness =", 1,0,2,"pixels");// number 2.2
	Dialog.addChoice("Lines color:", newArray("blue", "yellow", "cyan", "red", "green", "magenta", "orange", "black", "white"));// choice 2.3
	Dialog.addCheckbox("Horizontal segmented", false);// checkbox 2.5
	Dialog.addCheckbox("Vertical segmented", false);// checkbox 2.6
	Dialog.addCheckbox("Horizontal solid (x2 of segmented)", true);// checkbox 2.7
	Dialog.addCheckbox("Vertical solid (x2 of segmented)", true);// checkbox 2.8
	Dialog.addMessage("At least one line type should be choosen!", 14, "red");
	}
Dialog.addHelp(html3);
Dialog.show(); 

//grid parameters 
offset = Dialog.getCheckbox();// checkbox 2.1 - grid offset
new = Dialog.getCheckbox();// checkbox 2.2 - new overlay
number = Dialog.getNumber();// number 2.1 - probe density

if (CounterType != "for 2D Total Length"){
colorP = Dialog.getChoice();// choice 2.1 - regular and encircled points color
circP = Dialog.getCheckbox();// checkbox 2.3 - choice for encircled points
denseP = Dialog.getCheckbox();// checkbox 2.4 -choice for dense points
colorDP = Dialog.getChoice();// choice 2.2 - dense points color
}

if (CounterType != "for Volume Density") {
color = Dialog.getChoice();// choice 2.3 - lines color
Lthick = Dialog.getNumber();// number 2.2 - line thickness
H_segm_Line = Dialog.getCheckbox();// checkbox 2.5 - choice for horizontal segmented lines
V_segm_Line = Dialog.getCheckbox();// checkbox 2.6 - choice for vertical segemented lines
H_solid_Line = Dialog.getCheckbox();// checkbox 2.7 -choice for horizontal segmented lines
V_solid_Line= Dialog.getCheckbox();// checkbox 2.8 - choice for vertical segmented lines
}

//check overlay
if (new == true) Overlay.remove;

//initial settings for l/p calculation
vsg=hsg=vsl=hsl=0;

//grid tile size
name = getTitle();
shortside = minOf(width, height); //determining shortest side

if (dimensions=="by tiles density") {
	tile = shortside/number;//side of tile square
	}else {
	tile = sqrt(4*number/ph/pw);//4 regular points in 1 tile, sqrt - to get a side of tile square 
	}
pointd = tile/4;//distance between dense points
pointr = tile/2;//distance between regular points

//creating random offset 
off1 = random; 
off2 = random; 
if (offset == false) off1 = off2 =0.5;//no offset 
xoff = -round(pointr*off1);
yoff = -round(pointr*off2);


//Drawing lines
if (CounterType != "for Volume Density") {
	setColor(color);
	setLineWidth(Lthick);
	//Horizonal solid lines
	if (H_solid_Line == true){
	hsl = 2;
	Draw_H_solid_Line();
	}

	//Vertical solid lines
	if (V_solid_Line == true){
	vsl = 2;
	Draw_V_solid_Line();
	}

	//Horizonal segmented lines
	if (H_segm_Line == true){
	hsg = 1;
	Draw_H_segm_Line();
	}

	//Vertical segmented lines
	if (V_segm_Line == true){
	vsg = 1;
	Draw_V_segm_Line();
	}
}

//Drawing points
if (CounterType != "for 2D Total Length") {
		Draw_Regular_Points();
	if (denseP == true) 
		Draw_Dense_Points();
	if (circP == true) 
		Mark_Encircled_Points();
}

// Printing the parameters of the grid
window = isOpen("Multipurpose grid parameters"); 
title = "[Multipurpose grid parameters]"; 
if (window == false){  
	run("Text Window...", "name="+ title +"width=60 height=40 menu"); 
	setLocation(0, 0); 
	};

//Size and areas
print(title, "\n\nMultipurpose Grid for image ["+name+"]");
print(title, "\n\nImage size = "+width+"x"+height+" pixels");
print(title, "\nImage size after rotation= "+rwidth+"x"+rheight+" pixels");//image size after rotation
print(title, "\nPixel width = "+pw+" "+unit);
print(title, "\nScale = "+1/pw+" pixels/"+unit);

if (CounterType != "for 2D Total Length") {
	print(title, "\n\nArea per regular point ="+tile*tile*pw*ph/4+"  "+unit+"¬2");
	if (circP == true)
		print(title, "\nArea per encircled point ="+tile*tile*pw*ph+"  "+unit+"¬2"); 
	if (denseP == true)
		print(title, "\nArea per dense point ="+tile*tile*pw*ph/16+"  "+unit+"¬2");	
}

if (CounterType != "for Volume Density"){
	if (V_segm_Line && V_solid_Line == true)
		vsg = 0; 
	if (H_segm_Line && H_solid_Line == true)
		hsg = 0; 
}

RL = vsg+hsg+vsl+hsl;//relative line lenght in tile
LL = pw*tile*RL;//total line lenght in tile
aL = pw*pw*tile*tile/LL;//a/l constant

//grid constants per line length
if (CounterType != "for Volume Density"){
		print(title, "\nGrid constant a/l = "+aL+" "+unit+"¬2/"+unit);//area per line unit - to estimate total length in 2D
		if (CounterType != "for 2D Total Length") {
			print(title, "\nTest line per regular point(l/p) ="+LL/4+"  "+unit);//test line per point - for surface density estimation
			if (circP == true)
				print(title, "\nTest line per encircled point(l/p) ="+LL+"  "+unit);		
			if (denseP == true)
				print(title, "\nTest line per dense point(l/p) ="+LL/16+"  "+unit);
		}
print(title, "\n_______________________");
}

//Counting classes
if (CounterType != "No Setup (grid only)") {Dialog.create("Names for Counters"); //Naming Counters
	for (i=0;i<ObjNmb;i++) {N = toString(i); 
		Dialog.addString("Counter "+N+" = ", "Class name");//asking for counters names
		if (CounterType != "for 2D Total Length") Dialog.addToSameRow();//putting the next line in the same row
		if (CounterType == "for Volume Density") Dialog.addChoice("Probes", newArray("Regular Points", "Dense Points", "Encircled Points"));//probe choice
		if (CounterType == "for Surface Density") Dialog.addChoice("Probes", newArray("Lines", "Regular Points", "Dense Points", "Encircled Points"));//probe choice
		};
	if (CounterType == "for Volume Density"||CounterType == "for Surface Density") Dialog.addMessage("The last counter is for the reference space! \nChoose points as probes for it.", 14, "red");
	Dialog.addHelp(html4);
	Dialog.show();

	//Assigning counters to classes and stereological probes 
	CtrName = newArray(ObjNmb);
	PrbChoice = newArray(ObjNmb);
	print(title,"\n\nCounters' names reminder:\n"); 
	for (i=0;i<ObjNmb;i++) { 
		N = toString(i); 
		ObjName = Dialog.getString(); //getting class names
		if (CounterType != "for 2D Total Length") 
			PrbType = Dialog.getChoice();
		else 
			PrbType = "Lines";
		print(title,"\nCounter "+N+" = "+ObjName+", Probes = "+PrbType); 
		CtrName[i] = ObjName; //assign class name to specific counter
		PrbChoice[i] = PrbType;//assign stereological probe to specific counter
		} 
	print(title, "\n________________________"); 
		
	//Multipoint Tool setup
	Objects = toString(ObjNmb); 
	setTool("multipoint"); 
	run("Point Tool...", "type=Circle color=red size=Large label counter=0"); //setting multipoint tool active
	waitForUser("Click [OK] button after counting is finished!", "Use MultiPoint Tool (currently set) to count classes."+"\n  "+"\nFor each of your "+Objects+" classes change the Counter by double clicking on \nMulti-point Tool button in ImageJ Menu. \nPress 'alt+y' to inspect the counts in a results table. \nCalculated results will be printed to [Multipurpose grid parameters] window"+"\n  "+"\nClick OK when you finish counting."); //wait for user to finish clicking
	setKeyDown("alt"); 
	run("Properties... "); //showing statistics of counting

//Calculating 2D feature length with intersection counts
if (CounterType == "for 2D Total Length") {
	print(title, "\nCounts and total length for classes:\n");
	headers = split(Table.headings,"\t");
		for (i=1; i<headers.length; i++) {
		Length = Table.get(headers[i],Table.size-1)*PI/2*aL;//total length calculation
		print(title, "\n "+CtrName[i-1]+"="+headers[i]+" = "+Table.get(headers[i],Table.size-1)+" counts, "+Length+" "+unit+" of total length");
		}
	print(title, "\n\nPress 'alt+y' to display the counts in a results table.");
	print(title, "\n============================"); 
	}

//Calculating Volume Density with point counts
if (CounterType == "for Volume Density") {
	print(title, "\n\nVolume density is calculated in relation to \na reference space\n");
	headers = split(Table.headings,"\t");
	j = headers.length-1;
	RefCnt = Table.get(headers[j],Table.size-1);//reference space counts
	if (PrbChoice[j-1] =="Encircled Points") 
		RefSpc = RefCnt*4;//normalization for encircled points
	else if (PrbChoice[j-1] =="Dense Points")
		RefSpc = RefCnt/4;//normalization for dense points
	else
		RefSpc = RefCnt;
	ClassCnt = newArray(j);
		for (i=1; i<j; i++) {
			ClassCnt[i] = Table.get(headers[i],Table.size-1);//class counts
			print(title, "\nClass ["+CtrName[i-1]+"] = "+ClassCnt[i]+" counts, "+PrbChoice[i-1]);//print counts for class
			if (PrbChoice[i-1] =="Encircled Points") 
				ClassNrm = ClassCnt[i]*4;//normalization for encircled points
			else if (PrbChoice[i-1] =="Dense Points")
				ClassNrm = ClassCnt[i]/4;//normalization for dense points
			else
				ClassNrm = ClassCnt[i];
			print(title, "\nVolume fraction of ["+CtrName[i-1]+"] = "+ClassNrm/RefSpc);//print volume density for class
		}
	print(title, "\n\nClass ["+CtrName[j-1]+"] = "+RefSpc+" counts, "+PrbChoice[j-1]+"\nClass ["+CtrName[j-1]+"] is the reference space");//print counts for reference space
	print(title, "\n\nPress 'alt+y' to display the counts in a results table.");
	print(title, "\n============================"); 
	}

//Calculating Surface Density with line intersection and point counts
if (CounterType == "for Surface Density") {
	print(title, "\n\nSurface density is calculated \nin relation to a reference space\n");
	headers = split(Table.headings,"\t");
	j = headers.length-1;
	RefSpc = Table.get(headers[j],Table.size-1);//reference space counts	
	if (PrbChoice[j-1] =="Regular Points") 
		lP = LL/4;//l/p constant for regular points
	else if (PrbChoice[j-1] =="Dense Points")
		lP = LL/16;//l/p constant for dense points
	else
		lP = LL;//l/p constant for encircled points
	ClassCnt = newArray(j);
	for (i=1; i<j; i++) {
		ClassCnt[i] = Table.get(headers[i],Table.size-1);//class counts
		print(title, "\nClass ["+CtrName[i-1]+"] = "+ClassCnt[i] +" counts, "+PrbChoice[i-1]);//print counts for class		
		print(title, "\nSurface density of ["+CtrName[i-1]+"] = "+2*ClassCnt[i]/RefSpc/lP+" "+unit+"-1");//print surface density for class
		}
	print(title, "\n\nClass ["+CtrName[j-1]+"] = "+RefSpc+" counts, "+PrbChoice[j-1]+"\nClass ["+CtrName[j-1]+"] is the reference space");//print counts for reference space
	print(title, "\n\nPress 'alt+y' to display the counts in a results table.");
	print(title, "\n============================"); 
	}
};
	
close("Counts_"+name); //closing results table

//Drawing functions

function Draw_H_solid_Line() {
y = yoff;
	while (y<rheight) {
		Overlay.drawLine(0, y, rwidth, y);
		Overlay.add;
		y += pointr;
		}
	Overlay.show;
};

function Draw_V_solid_Line() {
x = xoff;
	while (x<rwidth) { 
		Overlay.drawLine(x, 0, x, rheight);
		Overlay.add;
		x += pointr;
		}
	Overlay.show;
};

function Draw_H_segm_Line() {

//Y loop1
y1 = yoff;
	while (y1<rheight) { 
		
		//X loop1
		x1 = xoff; 
		while (x1<rwidth) {   
			Overlay.drawLine(x1, y1, x1+pointr, y1);
			Overlay.add;
			x1 += tile;  
			}
		Overlay.show;	 
		y1 += tile;  
		}
	
//Y loop2
y1 = yoff+pointr;
	while (y1<rheight) { 
 
		//X loop2 
		x2 = xoff;
		x1 = 0;	
		while (x1<rwidth) {   
			Overlay.drawLine(x1, y1, x2, y1);
			Overlay.add;
			x1 = x2 + pointr;
			x2 += tile;
			}
		Overlay.show; 
		y1 += tile;  
		}
};

function Draw_V_segm_Line() {

//X loop1
x1 = xoff;
	while (x1<rwidth) { 
		
		//Y loop1
		y1 = yoff; 
		while (y1<rheight) {   
			Overlay.drawLine(x1, y1, x1, y1+pointr);
			Overlay.add;
			y1 += tile;  
			} 
		Overlay.show;
		x1 += tile;  
		}
	
//X loop2
x1 = xoff+pointr;
	while (x1<rwidth) { 
 
		//Y loop2 
		y2 = yoff;
		y1 = 0;	
		while (y1<rheight) {   
			Overlay.drawLine(x1, y1, x1, y2);
			Overlay.add;
			y1 = y2 + pointr;
			y2 += tile;
			} 
		Overlay.show;
		x1 += tile;  
		}
};

function Draw_Regular_Points() {
	type = "crosshair";
	size = "small";
	//Initial point coordinates  
	x1 = xoff;  
	y1 = yoff;  
	x = x1; 
	y = y1; 
	while (y<(rheight)) { 
		while (x<(rwidth)) {
			makePoint(x, y, size+colorP+type+" add"); 
			Overlay.setPosition(0,0,0); 
			x += pointr; 
			} 
		y += pointr; 
		x = x1; 
		} 
}; 

function Draw_Dense_Points() {
	type = "crosshair";
	size = "small";
	//Initial point coordinates  
	x1 = round(xoff-pointd/2);  
	y1 = round(yoff-pointd/2);  
	x = x1; 
	y = y1; 
	while (y<(rheight)) { 
		while (x<(rwidth)) {
			makePoint(x, y, size+colorDP+type+" add"); 
			Overlay.setPosition(0,0,0); 
			x += pointd; 
			} 
		y += pointd; 
		x = x1; 
		} 
};


function Mark_Encircled_Points() {
	type = "circle";
	size = "extra large";
	RfactorX = random;//additional random X shift for encircled points
	RfactorY = random;//additional random Y shift for encircled points
	//Initial point coordinates  
	if (RfactorX<0.5000) {x1 = xoff;
	}else{x1 = xoff+pointr;}
	if (RfactorY<0.5000) {y1 = yoff;
	}else{y1 = yoff+pointr;}
	x = x1; 
	y = y1; 
	while (y<(rheight)) { 
		while (x<(rwidth)) {
			makePoint(x, y, size+colorP+type+" add"); 
			Overlay.setPosition(0,0,0); 
			x += tile; 
			} 
		y += tile; 
		x = x1; 
		} 
};

function Cell_diagram() {
	newImage("Cell diagram", "RGB white", 1000, 1000, 1);//new image
	setForegroundColor(0, 0, 0);
	setLocation(300, 80);
	
	//drawing a cell
	makeEllipse(98, 89, 896, 904, 0.60);
	setColor(255, 201, 185);
	run("Fill", "slice");
	run("Draw", "slice");

	makeOval(193, 232, 466, 340);
	setColor(0, 198, 255);
	run("Fill", "slice");
	run("Draw", "slice");

	makeEllipse(718, 544, 902, 610, 0.60);
	setColor(205, 255, 185);
	run("Fill", "slice");
	run("Draw", "slice");

	makeEllipse(594, 784, 802, 696, 0.32);
	setColor(205, 255, 185);
	run("Fill", "slice");
	run("Draw", "slice");

	makeEllipse(437, 834, 568, 596, 0.32);
	setColor(205, 255, 185);
	run("Fill", "slice");
	run("Draw", "slice");
	
	//marking organelles
	setFont("SansSerif", 24, "bold antialiased");
	setColor("black");
	drawString("Nucleus", 384, 406);
	drawString("M1", 798, 593);
	drawString("M2", 485, 729);
	drawString("M3", 682, 753);

	run("Select None");
	
	//Setting scale and scale bar
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=0.01 pixel_height=0.01 voxel_depth=0.01");
	run("Scale Bar...", "width=1 height=0 color=Black horizontal bold");
};
