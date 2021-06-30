/*Makes unbiased counting frame as non-destructive overlay and calculates
 disector (2 consecuitive sections) or unbiased brick (stack of slices) volume.
 After setting up counters you can count number of objects in a volume.
"Number of frames (X & Y)" determines how many frames are drawn in one slice.
"Frames area" determines the total area of frames.
"Frame Random Offset" - randomizes frame location.
"New Frame(s) Overlay" - removes previous overlays.
"Central point" used to decide does the frame belong to the reference space.
Anything that touches "Forbidden line" should be excluded from count.
Anything that touches "Acceptance line" should be included into count.
Objects in frames that are out of reference space are counted but the area(volume)
of these frames are not included into the final estimation.

Counting objects in a volume concept:
To estimate number of objects in a volume you need to compare each slice
(starting from the first 'reference slice') in a stack with the following slice
('look-up slice').
Any object appearing on look-up slice should be counted. Then the total number of
objects counted in that way will give you a number of objects in stack volume.
To increase the efficiency you can count objects 'dissappearing' in look-up slices
as well. In this case stack volume should be duplicated because of 2-way counting mode.
Also, the last slice should be excluded as it serves as a 'reference slice' for 
"the second way" count.

Practical steps:
1) Assign counters to clearly recognizable structures in sensible way
2) Go through your stack and count object according to the rules above
3) When you finish - confirm this using panel dialog
4) Results will be given in a separate window

Parameters of the grid and results of counting are reflected in 
the "Frame(s) Parameters" window.

Version: 2.0
Date: 23/06/2021
Author: Aleksandr Mironov 
Email: amj-box@mail.ru
*/

requires("1.53j");

//help1
html1 = "<html>"
	+"<h1><font color=navy>Unbiased Counting Frame&Brick_v.2.0</h1>"
	+"<font color=navy>used to count number of objects in the area or the volume<br>"
	+"based on:<br><br>" 
	+"Gundersen HJG (J.Microsc. 1977, 111:219-223) and<br>"
	+"Sterio DC (J Microsc. 1984 May;134(Pt 2):127-36).<br>"
	+"Howard V et al (J Microsc. 1985 May;138(Pt 2):203-212).<br><br>"
	+"<font color=purple><b><u>Options:</u></b><br><br>"
	+"<b>Number of frames (X & Y)</b> - determines how many frames are drawn<br>"
	+"<b>Frames area</b> - determines the total area of frames<br>"
	+"<b>Frame Random Offset</b> - randomizes frame location<br>"
	+"<b>New Frame(s) Overlay</b> - removes previous overlays<br>"
	+"<b>Central point</b> - to decide does a frame belong to a reference space<br><br>"
	+"<b><font color=red>Set Scale</b><font color=black> to get correct printout of the grid parameters,<br>" 
	+"which are reflected in the 'Frame(s) Parameters' window<br><br>"
	+"<font color=green><b><u>Counting rules:</u></b><br><br>"
	+"Anything that touches <b>Forbidden line</b> should be excluded from count<br>"
	+"Anything that touches <b>Acceptance line</b> should be included into count<br><br>"
	+"Objects in frames that are out of reference space are counted but the area(volume)<br>"	
	+"of these frames are not included into the final estimation.<br><br>"

//help2
html2 = "<html>"
	+"<font color=green><b><u>Frame counting rules:</u></b><br><br>"
	+"Objects in frames that are out of reference space<br>"
	+"(i.e. frame's <b>Central Point</b> does not hit a reference space)<br>"	
	+"are <b>counted</b><br><br>"
	+"but the area(volume) of these frames are<br>"
	+"<b>not included</b> into the final estimation.<br><br>"
	
//help3
html3 = "<html>"
	+"<h1><font color=navy>Unbiased Counting Frame&Brick_v.2.0</h1>"
	+"<font color=navy>used to count number of objects in a volume<br>"
	+"based on:<br><br>" 
	+"Sterio DC (J Microsc. 1984 May;134(Pt 2):127-36).<br>"
	+"Howard V et al (J Microsc. 1985 May;138(Pt 2):203-212).<br><br>"
	+"<font color=green><b><u>Counting concept:</u></b><br><br>"
	+"To estimate number of objects in a volume you need to compare each slice<br>"
	+"(starting from the first 'reference slice') in a stack with the following slice <br>"
	+"('look-up slice'). <br>"
	+"Any object appearing on look-up slice should be counted. Then the total number of<br>"
	+"objects counted in that way will give you a number of objects in stack volume. <br>"
	+"To increase the efficiency you can count objects 'dissappearing' in look-up slices as well.<br>"
	+"In this case stack volume should be duplicated because of 2-way counting mode.<br>"
	+"Also, the last slice should be excluded as it serves as a 'reference slice'<br>"
	+"for 'the second way' count.<br><br>"
	+"<font color=purple><b><u>Practical steps:</u></b><br>"
	+"1) Assign counters to clearly recognizable structures in sensible way<br>"
	+"2) Go through your stack and count object according to the rules above<br>"
	+"3) When you finish - confirm this using panel dialog<br>"
	+"4) Results will be given in a separate window<br><br>"

//Check for opened images or stacks
if (nImages==0) { 
	exit("No open images or stacks detected! \n\nThis macro needs open image or stack ..."); 
	} 

//Get image or stack parameters 
getDimensions(width, height, channels, slices, frames);
getVoxelSize(VxWidth, VxHeight, VxDepth, unit);

//Check for scale
if (unit == "pixels") {
	Dialog.create("Unbiased Counting Frame&Brick_v.2.0");
	Dialog.addMessage("This macro needs proper image or stack scale to be set! \n\nPlease, set the scale using 'Properties...' option in pop-up window \n\nOtherwise, all calculations will show pixels ...") 
	Dialog.show();
	run("Properties...");
	}
getVoxelSize(VxWidth, VxHeight, VxDepth, unit);//update voxel size

//dialog box for frame parameters
Dialog.create("Unbiased Counting Frame&Brick_v.2.0");
Dialog.addNumber("Number of frames in X =", 1);//number1
Dialog.addNumber("Number of frames in Y =", 1);//number2
Dialog.addNumber("Frame(s) area =", 50,0,2,"% of image area");//number3
Dialog.addNumber("Line width =", 2,0,2,"pixels");//number4
Dialog.addChoice("Forbidden line:", newArray("red", "green", "cyan", "magenta", "blue", "yellow", "orange", "black", "white"));//choice1
Dialog.addChoice("Acceptance line:", newArray("green", "red",  "cyan", "magenta", "blue", "yellow", "orange", "black", "white"));//choice2
Dialog.addCheckbox("Frame Random Offset", true);//check1
Dialog.addCheckbox("New Frame(s) Overlay", true);//check2
Dialog.addMessage("__________________________________");
Dialog.addCheckbox("Central Point", true);//check3
Dialog.addChoice("Central Point Size", newArray("large", "tiny", "small", "medium", "extra large", "xxl", "xxxl"));//choice3
Dialog.addChoice("Central Point Color", newArray("yellow","green","red", "cyan", "magenta", "blue", "orange", "black", "white"));//choice4
Dialog.addMessage("__________________________________");
Dialog.addCheckbox("Setup object(s) for counting", true);//check4
Dialog.addHelp(html1);
Dialog.show();

//Frame/s parameters from dialog
name = getTitle();//getting name of image file
nx = Dialog.getNumber();//number1, frames in X
ny = Dialog.getNumber();//number2, frames in Y
fArea = Dialog.getNumber();//number3, frame/s area
t = Dialog.getNumber();//number4, line thickness
color1 = Dialog.getChoice();//choice1, forbidden line color
color2 = Dialog.getChoice();//choice2, acceptance line color
CPsize = Dialog.getChoice();//choice3, central point size
CPcolor = Dialog.getChoice();//choice4, central point color
offset = Dialog.getCheckbox();//check1, random offset
new = Dialog.getCheckbox();//check2, new overlay
point = Dialog.getCheckbox();//check3, central point
count = Dialog.getCheckbox();//check4, counting objects

if (new == true) run("Remove Overlay");

//frame size
a1 = width*sqrt(fArea/100);//frames total width
b1 = height*sqrt(fArea/100);//frames total lentgh
a2 = a1/nx;//width of single frame
b2 = b1/ny;//length of single frame

//random offset
r1 = random;
r2 = random;
if (offset == false) r1 = r2 = 0.5;
x = (width - a1)/(nx+1);//distance between frames
y = (height - b1)/(ny+1);//distance between frames
xr = x*r1;//random shift
yr = y*r2;//random shift

//Frame/s creation

//Initial frame coordinates X
x1 = xr+x/2;
x2 = a2+x1;
x4 = x1+a2/2;

	//X loop;
	for (i=0; i<nx; i++) {
		//initial coordinates Y;
		y1 = yr+y/2-1/3*y;
		y2 = b2+y1+1/3*y;
		y3 = y2+1/3*y;
		y4 = y1+ 1/3*y + b2/2;

			//Y loop;
			for (j=0; j<ny; j++) {
				DrawFrame(x1,x2,x4,y,y1,y2,y3,y4,t,CPsize,CPcolor,color1,color2);
			
				//Y increment;
				y1 = y1+b2+y;
				y2 = y2+b2+y;
				y3 = y3+b2+y;
				y4 = y4+b2+y;
				}
		//X increment;
		x1 = x1 + a2+ x;
		x2 = x2 + a2 +x;
		x4 = x4 + a2 +x;
		}	
run("Select None");

//Frames area estimation
S1 = a1*VxWidth*b1*VxHeight;//total area of frames
S2 = width*height*VxWidth*VxHeight;//area of image (stack)

//Out of reference space frames;
Dialog.create("Frames out");
Dialog.addNumber("Frames outside reference space", 0);//number5	
Dialog.addHelp(html2);
Dialog.show();

FramesOut = Dialog.getNumber();//number5 - how many frames are out of reference space
S3 = S1 - S1*FramesOut/(nx*ny);//area of frames in reference space
if (slices>1){
	V = S3*VxDepth*slices;//volume of frames in stack
	}

//Displaying frame(s) parameters window
window = isOpen("Frame(s) Parameters");
title = "[Frame(s) Parameters]";
if (window == false){ 
	run("Text Window...", "name="+ title +"width=60 height=16 menu");
	setLocation(0, 0);
	}

print(title, "\nFrame(s) parameters for sample ["+name+"]");
print(title, "\n\nImage area ="+S2+" "+unit+"^2");
print(title, "\nTotal frame number ="+nx*ny);
print(title, "\nTotal frame area ="+S1+" "+unit+"^2");
print(title, "\nFrame area in reference space ="+S3+" "+unit+"^2");
if (slices>1) {
	print(title, "\nProbe volume ="+V+" "+unit+"^3");
	}
print(title, "\n_______________________\n");

//Setting up counter(s)
if (count==true){
	
	Dialog.create("Number estimator");
	Dialog.addNumber("Number of objects to count ", 2);//number6
	Dialog.addCheckbox("Two-way counting for stack", true);//check5
	Dialog.addHelp(html3);
	Dialog.show();
	
	ObjNmb = Dialog.getNumber();//number6 number of objects to esitmate
	TwoWay = Dialog.getCheckbox();//check5 two-way counting mode
//Naming counters 
	Dialog.create("Names for Counters"); 
	for (i=0;i<ObjNmb;i++) { 
		N = toString(i); 
		Dialog.addString("Counter "+N+" = ", "Object name");//asking for counters names
	}; 
	Dialog.show();
//Counter names reminder in parameter window 
	CtrName = newArray(ObjNmb);	 
	print(title,"Counters' names reminder:"); 
		for (i=0;i<ObjNmb;i++) { 
			N = toString(i); 
			ObjName = Dialog.getString(); //getting object names from "naming counters" part
			print(title,"\nCounter "+N+" = "+ObjName); 
			CtrName[i] = ObjName; //assign object name to specific counter
	}
//Counting 
	Objects = toString(ObjNmb); 
	setTool("multipoint"); 
	run("Point Tool...", "type=Circle color=Yellow size=Large label counter=0"); //setting multipoint tool active
	waitForUser("Click [OK] button after counting finished!", "Use MultiPoint Tool (currently set) to count events."+"\n  "+"\nFor each of your "+Objects+" objects change the Counter by double clicking on \nMulti-point Tool button in ImageJ Menu"+"\n  "+"\nClick OK when you finish counting."); //wait for user to finish clicking
	setKeyDown("alt"); 
	run("Properties... "); //showing statistics of counting
//printing counting results
	if (slices>1){
		if (TwoWay == true) V = 2*V;
		print(title, "\n\nCounts for objects in probe volume \nof "+V+" "+unit+"^3:\n");//printing resulst for stack
		}else {
		print(title, "\n\nCounts for objects in probe area \nof "+S3+" "+unit+"^2:\n");//printing result for single image
		};
	headers = split(Table.headings,"\t");//getting header names from table
	for (i=1; i<headers.length; i++) {
		print(title, "\n "+CtrName[i-1]+" = "+Table.get(headers[i],Table.size-1)+" counts");//printing results into window
  		};
	close("Counts_"+name);
}

//function for drawing unbiased frame
function DrawFrame(x1,x2,x4,y,y1,y2,y3,y4,t,CPsize,CPcolor,color1,color2){
	
	//forbidden line
	makeLine(x1,y1,x1,y2,x2,y2,x2,y3);
	//set overlay
	run("Add Selection...", "width="+t+" stroke="+color1);
	Overlay.setPosition(0);//display on all slices
	//acceptance line
	makeLine(x1+t/2,y1+1/3*y,x2,y1+1/3*y,x2,y2-t/2);
	//set overlay
	run("Add Selection...", "width="+t+" stroke="+color2);
	Overlay.setPosition(0);//display on all slices

	//central point
	if (point == true){
	makePoint(x4, y4,CPcolor+CPsize+"cross add"); 
	Overlay.setPosition(0);//display on all slices
	}
}
