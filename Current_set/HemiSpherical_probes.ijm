/* INSTRUCTIONS

This macro is for object length (or length density) estimation 
using serial sections with known thickness. It requires an 
image stack and will not work on a single image.

I. Theoretical background

For length estimation, intersections must be counted between 
an isotropically oriented surface probe, such as a plane or section, 
and linear features within a reference volume.

A spherical probe has an inherently isotropic orientation in 
relation to linear structures within a volume stack. Each orientation 
of a surface element on the sphere is represented twice, at opposite 
antipodes. As a consequence, the probe need only consist of a hemisphere, 
since all orientations of the surface are present on the surface of a
hemisphere.

A series of circles, representing the continuous surface of 
a hemispherical probe, is generated across the slices of an image stack.
Intersections between linear features and the hemispherical probe 
surface are counted to estimate the total length, or length density,
of features within the stack volume.
The user determines the density and size of the  hemispherical probes. 


II. Practical assumptions

1) It is impossible to physically place a 3D probe into histological 
or electron microscopy material.
However, this can be done virtually by superimposing an image of 
the probe surface, which appears as a circle of a given size,
at specific depths within a thick section or image stack.

2) All physical or virtual slices through a volume have some thickness, 
because it is impossible to make a strictly 2D surface cut.
In addition, all microscopy systems have finite z-axis resolution, 
meaning that apparently 2D slices or virtual planes through stack 
slabs represent projections of features within the slab onto a 2D 
plane. 
Therefore, a 2D circle placed on the midplane of the slice can 
serve as a useful approximation of the full slice hit by 
hemispherical probe.

3) In serial sections, a hemispherical probe is represented by concentric 
circles with decreasing diameters, starting from the maximum diameter
at the probe mid-section. Because the probe itself is a 2D spherical 
surface, the last, smallest concentric circles represent the surface in 
the shape of a cap.
Any structures whose length is being estimated and that remain present 
through this virtual cap should be counted as probe hits.

4) Most elongated features have not one dimension but at least two, 
forming a kind of tube. If the tube diameter is comparable to the 
spherical probe diameter, a degree of length-estimation bias will 
arise. To keep this bias negligible, below 1%, use hemispherical probes 
with a diameter at least 10 times larger than the diameter of the 
structural feature.

5) Please, adjust hemispherical probe size, so that you have at least
one layer of full probes (with 'caps'). Otherwise probe surface will not 
be isotropic and length estimation will be biased againt lost probe 
orientation. 


III. Practical implementation

1) Event counting

A grid of evenly spaced hemispherical probes is placed across a stack 
of serial sections.
This produces a series of concentric circles, with diameters 
calculated using the formula for a spherical segment, on the sections 
of the stack. Linear-feature intersections with the hemispherical probe 
surface must be counted. In addition, elongated structures that pass 
through the invisible hemispherical probe caps should also be counted.
These caps are displayed in a different colour from the main circles 
to remind the user of the special counting rule in this case.
This rule can be demonstrated as follows:
	a) A structure that is inside the last concentric circle, 
representing a cap with a different colour, and remains in roughly 
the same location on the next section without a circle should be 
counted as a hit.
	b) A structure that is present in a section without a probe 
circle and then appears inside a probe circle, representing a cap 
with a different colour, on the following section should be counted 
as a hit.

It is important to define the classes of counted structures in advance.
A pilot experiment is strongly recommended.


2) Estimator calculations

After counting is completed, the algorithm calculates the approximate 
total length and length density for each structure according to 
the following formulas:

Ltot = 2xQ × (v/a), where [Ltot] is the total length of a feature, 
[Q] is the sum of intersections between the feature and the 
probe surface, [v] is the tissue volume associated with each probe, 
and [a] is the probe surface area, [v/a] is tile volume per one probe
surface area.

Lv = Ltot/Vst, where [Lv] is the length density of a feature, 
[Ltot] is the total length of the feature, and [Vst] is the volume
of the stack.


3) User Interface
 
When the macro is run, the user must specify several parameters 
in the [HemiSpherical probes estimator] window, including the number 
of probes along the shortest side of the stack, the stack slice 
thickness if the stack is not calibrated, and the number of 
classes being analysed.

Once the parameters are set, the user assigns each class a name 
associated with a specific counter, starting from Counter 0.
The currently selected counter can be changed by double-clicking 
the [Multi-Point Tool] in the ImageJ menu and selecting the 
required option from the [Counter] drop-down menu. The user-assigned 
class names for each counter can be viewed in the [HemiSpherical 
probes estimator parameters for stack] window.

To begin counting, click each intersection between a test circle 
and the elongated object of interest while the corresponding counter 
is selected.
For probe caps, count events when a linear feature remains in 
roughly the same position on two sequential sections and passes 
into or out of the smallest probe circle, which has a different 
colour from the rest of the probe and represents the probe cap.

Mistakenly placed points can be removed by Alt-clicking the point 
in question.
Complete the count of all test-line intersections before pressing 
the OK button in the grey pop-up window.
The macro will then display the resulting length and volume 
information in the [HemiSpherical probes estimator parameters for 
stack] window.

4) Practical counting considerations

As a rule of thumb, the total number of intersections counted for 
each class in an image stack should be no more than 100–200
because of diminishing returns in accuracy. 


This macro is based on the following publications:
 
Mouton PR, Gokhale AM, Ward NL, West MJ. Stereological length 
estimation using spherical probes. J Microsc. 2002 
Apr;206(Pt 1):54-64. (doi: 10.1046/j.1365-2818.2002.01006.x.)

West MJ. Space balls revisited: stereological estimates of 
length with virtual isotropic surface probes. Front Neuroanat. 
2018 Jun 12;12:49. (doi: 10.3389/fnana.2018.00049)


Version: 1.0
Date: 07/08/2026
Author: Aleksandr Mironov 
Еmail: amj-box@mail.ru

This work is licensed under a Creative Commons Attribution-NonCommercial 
4.0 International License.
If you use this material, please read the licence and give appropriate 
credit: https://creativecommons.org/licenses/by-nc/4.0/deed.en
 */

var x,y,h,diam,slice,ProbeLayersN;

requires("1.54p");

macro "HemiSpherical_Probes" {
//help 

html = "<html>" 
	+"<h1><font color=navy>HemiSpherical probes length estimator, ver.1.0</h1>" 
	+"<font color=navy>A grid of circles, representing the continuous surface of hemispherical<br>"
 	+"probes, is generated across the slices of an image stack.<br>"
	+"Intersections between linear features and the hemispherical probe<br>"
 	+"surface represented by concentric circles are counted to estimate the<br>" 
 	+"total length, or length density, of features within the stack volume.<br>"
 	+"In addition, elongated structures that pass through the invisible <br>"
 	+"hemispherical probe caps should also be counted. These caps are<br>" 
 	+"displayed in a different colour from the main circles to remind <br>"
 	+"the user of the special counting rule in this case.<br><br>"
	+"This macro is based on <b>Spherical probes</b> principle with the modification by<br>" 
	+"Mouton PR et al., J Microsc. 2002 Apr;206(Pt 1):54-64. <br>"
	+"(doi: 10.1046/j.1365-2818.2002.01006.x.).</i><br><br>"
	+"The <b>Total Length</b> and <b>Length Density</b> for classes is calculated with<br>" 
	+"the following <u>formulas:</u><br><br>"
	+"<b>Formula 1:</b><br>"
	+"<b>Ltot = 2xQ × (v/a)</b>, where<br>"
	+"<b>Ltot</b> - the total length of a feature in the volume;<br>"
	+"<b>Q</b> - the sum of intersections between the feature and the probe surface;<br>"
	+"<b>v/a</b> - grid constant of tile volume per one probe surface area.<br><br>"
	+"<b>Formula 2:</b><br>"
	+"<b>Lv = Ltot/Vst</b>, where<br>"
	+"<b>Lv</b> - the total length of the feature;<br>"
	+"<b>Vst</b> - the volume of the stack<br><br>" 
	+"<font color=black><b>How to work with this macro</b><br><br>"
	+"1) Specify parameters in <b>[HemiSpherical probes length estimator]</b> dialog:<br><br>"
	+"&nbsp&nbsp&nbsp - new overlay removes previous overlays<br>"
	+"&nbsp&nbsp&nbsp - random offest randomizes grid location<br>"
	+"&nbsp&nbsp&nbsp - number of probes per the shortest stack side<br>"
	+"&nbsp&nbsp&nbsp - main probe colour<br>"
	+"&nbsp&nbsp&nbsp - probe 'cap' colour<br>"
	+"&nbsp&nbsp&nbsp - probe line thickness<br>"
	+"&nbsp&nbsp&nbsp - number of classes being analysed<br><br>" 
	+"2) To keep bias negligible, use hemispherical probes diameter at least<br>" 
	+"10 times larger than the diameter of the structural feature,<br>"
	+"which length is being estimated.<br><br>"
	+"3) Adjust hemispherical probe size, so that you have at least<br>"
	+"one layer of full probes (with 'caps') covering all orientations.<br><br>"
	+"4) Assign each class a name associated with a specific counter<br>"
	+"&nbsp&nbsp&nbsp(starting from <b>Counter 0</b>).<br><br>"
	+"5) To count - click on probe circle intersection with the feature<br>"
	+"of interest.<br><br>"
	+"6) Double click on  <b>[Multi-Point Tool]</b> in the Image J menu and<br>"
	+"&nbsp&nbsp&nbsp select a counter for the next class from drop down menu.<br><br>"
	+"7) After counting is done press <b>[OK]</b> within grey pop-up window.<br><br>"
	+"8) Macro displays results in <br>"
	+"&nbsp&nbsp&nbsp<b>[HemiSpherical probes length estimator parameters for stack]</b> window.<br><br>"
	+"9) Mistakenly placed counts can be undone by Alt-clicking the point.<br><br>"
	+"As a rule of thumb, the total number of intersections counted<br>"
	+"for each class in an image stack should be no more than<br>"
	+"<b>100-200</b> due to diminishing returns in accuracy.<br><br>"

//Image check
if (nImages==0) exit ("No image is open! \n\nPlease, open a stack ...");  
if (nSlices<2) exit("Active image is not a stack! \n\nPlease, select (or open) a stack ..."); 

//Check for scale
getVoxelSize(VxWidth, VxHeight, VxDepth, unit);
	if (unit == "pixels") {
		Dialog.create("HemiSpherical probes length estimator, ver.1.0");
		Dialog.addMessage("This macro needs proper scale to be set! \n\nPlease, set the scale using 'Properties...' option in pop-up window \n\nOtherwise, all calculations will show pixels ...") 
		Dialog.show();
		run("Properties...");
		getVoxelSize(VxWidth, VxHeight, VxDepth, unit);//update voxel size
	}

getDimensions(width, height, channels, slices, frames);
ZtoXY = VxDepth/VxWidth;//pixel size normalization factor for spherical segments calculations
name = getTitle();
shortside = minOf(width, height); 		//shortest XY side of image

//Setting counting parameters 
Dialog.create("HemiSpherical probes length estimator, ver.1.0");
Dialog.addCheckbox("New Grid Overlay", true);					//check1 
Dialog.addCheckbox("Random Grid Offset", true);					//check2
Dialog.addMessage("Probes parameters:", 14, "blue"); 
Dialog.addNumber("Probes number:", 3,0,2,"within short side");	//number 1
Dialog.addChoice("Main color:", newArray("red", "green", "magenta", "blue", "yellow", "cyan", "orange", "pink"));//choice1 
Dialog.addChoice("Probe 'cap' color:", newArray("green", "red", "magenta", "blue", "yellow", "cyan", "orange", "pink"));//choice2
Dialog.addNumber("Probe line thickness:", 1);					//number2
Dialog.addMessage("Counter Setup:", 14, "blue"); 
Dialog.addNumber("Number of classes", 1,0,2,"for length estimation");//number 3
Dialog.addHelp(html); 
Dialog.show(); 

new = Dialog.getCheckbox(); 			//check1 new overlay
if (new == true) Overlay.remove; 
offset = Dialog.getCheckbox(); 			//check2 grid offset
number = Dialog.getNumber();			//number 1 number of probes per shortest side
color1 = Dialog.getChoice(); 			//choice1 probe main color
color2 = Dialog.getChoice(); 			//choice2 probe 'cap' color
Lwidth = Dialog.getNumber();			//number 2 line thickness
ClassNmb = Dialog.getNumber();			//number 3 number of classes to estimate

//Probe size calculation
tile = shortside/number;				//XY size of a grid tile
SphPrbRad = tile/2.5;					//optimal spherical probe radius for chosen probe density of a grid
SphSegm = 2*SphPrbRad/ZtoXY;			//number of spherical segments of a spherical probe of certain radius

//2D virtual planes represent sperical segments through a spherical probe
SphSect = Math.ceil(SphSegm);//number of 2D virtual planes equals to 'ceiling' number of segments
if (Math.ceil(SphSegm)%2 == 0) SphSect = floor(SphSegm);//even segments number results in odd number of 2D virtual planes
if (SphSegm%2 == 0) SphSect = SphSegm+1;//exact even number (with no height remainder) of segments results in odd number of 2D virtual planes

hsegm = 2*SphPrbRad/SphSect;//height of spherical segment normalized to XY pixels

//Naming counters 
Dialog.create("Names for Counters"); 
	for (i=0;i<ClassNmb;i++) { 
		N = toString(i); 
		Dialog.addString("Counter "+N+" = ", "Class name");//asking for counters names
	}
Dialog.addHelp(html);
Dialog.show();

//random offset
off1 = -random*2*SphPrbRad+SphPrbRad/2; 
off2 = -random*2*SphPrbRad+SphPrbRad/2; 
if (offset == false) off1 = off2 = SphPrbRad/4;//no offset 
InitX = off1;
InitY = off2;

InitSlice = 2;
ProbeSlices = Math.ceil(SphSect/2);//number of slices thorugh a hemispherical probe
ProbeLayersN = Math.ceil(slices/(ProbeSlices+1));//number of full probe (not cut) layers in a volume

//Drawing probes (circles) in a stack volume
	for (i=0; i<ProbeLayersN; i++){
		z = 1;
		Init_Layer();
		SphProbes();
			InitSlice +=ProbeSlices + 1;//moving to the next complete probe layer
	}


//Parameter window 
window = isOpen("HemiSpherical probes estimator parameters for stack ["+name+"]");  
title = "[HemiSpherical probes estimator parameters for stack ["+name+"]]";  
	if (window == false){   
		run("Text Window...", "name="+ title +"width=70 height=50 menu");  
		setLocation(0, 20);  
	}

SphSurf = 2*PI*SphPrbRad*VxWidth*SphPrbRad*VxWidth;//surface area of a probe
tileVol = tile*tile*VxWidth*VxWidth*(ProbeSlices+1)*VxDepth;//estimator tile volume
VolSurf = tileVol/SphSurf;//Tile volume per probe surface area
StckVol = width*height*VxWidth*VxWidth*VxDepth*slices;//volume of a stack

print(title, "\nHemiSpherical probes estimator for stack ["+name+"]"); 
print(title, "\n\nStack size = "+width+" x "+height+" pixels, "+slices+" slices");//showing stack size
print(title, "\nVoxel size = "+VxWidth+" x "+VxHeight+" x "+VxDepth+unit); //showing voxel size
print(title, "\nZ-to-XY resolution ratio = "+ZtoXY);// pixel size normalization factor for spherical segments calculations
print(title, "\n\nStack volume = "+StckVol+unit+"3"); //showing stack volume 
print(title, "\n\nGrid parameters:");
print(title, "\nProbe diameter = "+2*SphPrbRad+"px = "+2*SphPrbRad*VxWidth+unit);//probe diameter
print(title, "\nProbe surface = "+SphSurf+unit+"¬2");//probe surface area
print(title, "\nNumber of slices(circles) in one probe = "+ProbeSlices);
print(title, "\nTile Volume = "+tileVol+unit+"¬3");//estimator tile volume
print(title, "\nTile volume per probe surface area = "+VolSurf+unit+" (or nm¬3/nm¬2)");//Tile volume per probe surface ratio

//Counter names reminder in parameter window 
CtrName = newArray(ClassNmb);	 
print(title,"\n\nCounters' names reminder:"); 
	for (i=0;i<ClassNmb;i++) { 
		N = toString(i); 
		ClassName = Dialog.getString(); //getting class names from "naming counters" part
		print(title,"\n   Counter "+N+" = "+ClassName); 
		CtrName[i] = ClassName; //assign class name to specific counter
	} 
print(title, "\n________________________"); 

//Counting intersections
Classes = toString(ClassNmb);
setSlice(1);
setTool("multipoint"); 
run("Point Tool...", "type=Circle color=Yellow size=Large label counter=0"); //setting multipoint tool active
waitForUser("Click [OK] button after counting finished!", "Use MultiPoint Tool (currently set) to count intersections."+"\n  "+"\nFor each of your "+Classes+" classes change the Counter by double clicking on \nMulti-point Tool button in ImageJ Menu"+"\n  "+"\nClick OK when you finish counting."); //wait for user to finish clicking
setKeyDown("alt"); 
run("Properties... "); //showing statistics of counting

//Length estimation 
print(title, "\n\nClasses counts, total length and length density:"); 
ClassLngh = newArray(ClassNmb); //new array for length related to counted points
headers = split(Table.headings,"\t"); 
 	 
	for (i=1; i<headers.length; i++) { 
		ClassLngh[i-1] = Table.get(headers[i],Table.size-1)*2*VolSurf; //length calculation according to counts
		print(title,"\n\nClass "+CtrName[i-1]+" has "+Table.get(headers[i],Table.size-1)+" intersections"+", which equals to \n    total length = "+ClassLngh[i-1]+unit+"\n    length density = "+ClassLngh[i-1]/StckVol+unit+"¬-2 (or nm/nm¬3)"); 
  	}; //displaying counting and length results
print(title,"\n==========================================\n"); 
close("Counts_"+name); //closing results table


	function Init_Layer(){		//Initialize coordinates for new layer of probes
		diam = 2*SphPrbRad;		//Diameter of a probe
		h = hsegm;				//Height of a spherical segment
		slice = InitSlice;		//start slice
		setColor(color1); 
		run("Line Width...", "line="+Lwidth);
	}

	function SphProbes(){		//Draw probe crossections on serial slices
		for (i=0; i<=floor(SphSect/2); i++) {
 			NewDiam = 2*sqrt(SphPrbRad*SphPrbRad - Math.sqr(h));//next probe crossection diameter
 			if (i==floor(SphSect/2) || NewDiam == 0) setColor(color2); //coloring probe cap
			drawCircles();
 				InitX = x + (diam - NewDiam)/2;		//new X for sequential probe circle diameter
 				InitY = y + (diam - NewDiam)/2;		//new Y for sequential probe circle diameter
  				diam = NewDiam;						//sequential probe circle diameter
  				h += hsegm;							//distance from probe centre
				slice += z;							//slice counter
			}
	
	}

	function drawCircles(){			//Draw multiple circles in a plane
		x = InitX;					//setting initial X
		y = InitY;					//seting initial Y
		while (y<(height)) { 
			while (x<(width)) {
				Overlay.drawEllipse(x,y,diam,diam);
	//			Overlay.drawRect(x, y, diam, diam);//checking the probe centering - need to uncomment (remove front slashes)
				Overlay.setPosition(slice);
				Overlay.show;
				x += tile;			//move to next position in X
				}
			y += tile;				// move to next position in Y
			x = InitX;				//reset a row 
			}
		y = InitY;					//reset a column
	}
}
