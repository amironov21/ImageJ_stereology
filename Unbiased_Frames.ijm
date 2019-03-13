/*Makes unbiased counting frame as non-destructive overlay and calculates disector volume.
"Number of frames" determines how many frames are drawn.
"Frames area" determines the size of frames.
"Central point" used to decide does the frame belong to the reference space.
"Disector volume" calculates the volume of disector probe when scale 
and distance between sections are set.
Anything that touches "Forbidden line" should be excluded from count.
Anything that touches "Acceptance line" should be included into count.
Objects in frames that are out of reference space are counted but the area(volume)
of these frames are not included into the final estimation.
Parameters of the grid are reflected in the "Frame(s) Parameters" window.

Version: 1.0
Date: 04/09/2014
Author: Aleksandr Mironov amj-box@mail.ru

*/

requires("1.46b");

//help
html = "<html>"
	+"<h1><font color=navy>Unbiased Counting Frame(s)</h1>"
	+"<font color=navy>used to count number of objects in the area or the volume<br><br>"
	+"based on Gundersen HJG (J.Microsc. 1977, 111:219-223)<br><br>"
	+"<font color=purple><b><u>Options:</u></b><br><br>"
	+"<b>Number of frames</b> - determines how many frames are drawn<br>"
	+"<b>Random Offset</b> - randomizes frame location<br>"
	+"<b>New Overlay</b> - removes previous overlays<br>"
	+"<b>Central point</b> - used to decide does the frame belong to the reference space<br>"
	+"<b>Calculate Disector Volume</b> - calculates the volume of disector probe when scale<br>"
	+"and distance between sections are set<br><br>"
	+"<b><font color=red>Set Scale</b><font color=black> to get correct printout of the grid parameters,<br>" 
	+"which are reflected in the 'Frame(s) Parameters' window<br><br>"
	+"<font color=green><b><u>Counting rules:</u></b><br><br>"
	+"Anything that touches <b>Forbidden line</b> should be excluded from count<br>"
	+"Anything that touches <b>Acceptance line</b> should be included into count<br><br>"
	+"Objects in frames that are out of reference space are counted but the area(volume)<br>"	
	+"of these frames are not included into the final estimation.<br><br>"

//Creating dialog box
Dialog.create("Unbiased Counting Frame(s), ver. 1.0");
Dialog.addNumber("Number of frames in X =", 1);
Dialog.addNumber("Number of frames in Y =", 1);
Dialog.addNumber("Frame(s) area =", 50,0,2,"% of image area");
Dialog.addNumber("Line width =", 2,0,2,"pixels");
Dialog.addCheckbox("Random Offset", true);
Dialog.addCheckbox("New Overlay", true);
Dialog.addCheckbox("Central Point", true);
Dialog.addCheckbox("Calculate Disector Volume", false);
Dialog.addChoice("Forbidden line:", newArray("red", "green", "cyan", "magenta", "blue", "yellow", "orange", "black", "white"));
Dialog.addChoice("Acceptance line:", newArray("green", "red",  "cyan", "magenta", "blue", "yellow", "orange", "black", "white"));
Dialog.addHelp(html);
Dialog.show();

//frame dimensions
name = getTitle();
nx = Dialog.getNumber();
ny = Dialog.getNumber();
pct = Dialog.getNumber();
t = Dialog.getNumber();
t1 = t/2;
a = getWidth();
b = getHeight();
a1 = a*sqrt(pct/100);
b1 = b*sqrt(pct/100);
a2 = a1/nx;
b2 = b1/ny;

//creating random offset
r1 = random;
r2 = random;
offset = Dialog.getCheckbox();
if (offset == false) r1 = r2 = 0.5;
x = (a - a1)/(nx+1);
y = (b - b1)/(ny+1);
xr = x*r1;
yr = y*r2;

new = Dialog.getCheckbox();
if (new == true) run("Remove Overlay");

point = Dialog.getCheckbox();

//getting colour
c1 = Dialog.getChoice();
c2 = Dialog.getChoice();

//initial coordinates X;
x1 = xr+x/2;
x2 = a2+x1;
x4 = x1+a2/2;
x5 = x4 - a2/30;
x6 = x4 + a2/30;

//X loop;
for (i=0; i<nx; i++) {

	//initial coordinates Y;
	y1 = yr+y/2-1/3*y;
	y2 = b2+y1+1/3*y;
	y3 = y2+1/3*y;
	y4 = y1+ 1/3*y + b2/2;
	y5 = y4 - a2/30;
	y6 = y4 + a2/30;

	//Y loop;
	for (j=0; j<ny; j++) {
		//first line of unbiased frame;	
		makeLine(x1,y1,x1,y2,x2,y2,x2,y3);
		//first overlay;
		run("Add Selection...", "width="+t+" stroke="+c1);
		//second line of unbiased frame;
		makeLine(x1+t,y1+1/3*y,x2,y1+1/3*y,x2,y2-t);
		//second overlay;
		run("Add Selection...", "width="+t+" stroke="+c2);

		//Adding central point;
		if (point == true){
			//horizontal line;	
			makeLine(x5,y4,x6,y4);
			run("Add Selection...", "width="+t1+" stroke="+c1);
			//vertical line;
			makeLine(x4,y5,x4,y6);
			run("Add Selection...", "width="+t1+" stroke="+c1);
	
		}

		//Y increment;
		y1 = y1+b2+y;
		y2 = y2+b2+y;
		y3 = y3+b2+y;
		y4 = y4+b2+y;
		y5 = y5+b2+y;
		y6 = y6+b2+y;
		}
	//X increment;
	x1 = x1 + a2+ x;
	x2 = x2 + a2 +x;
	x4 = x4 + a2 +x;
	x5 = x5 + a2 +x;
	x6 = x6 + a2 +x;
	}

run("Select None");

//Frame parameters
disector = Dialog.getCheckbox();

getPixelSize(unit, pw, ph, pd);
S1 = a1*pw*b1*ph;
S2 = a*b*pw*ph;
window = isOpen("Frame(s) Parameters");

	//Creating dialog box;
	Dialog.create("Frame(s) Parameters");
	Dialog.addNumber("Frames outside reference space", 0);
	if (disector == true) {
		Dialog.addNumber("Distance between sections, "+unit+"=", 1);
	}
	Dialog.addHelp(html);
	Dialog.show();

	fn = Dialog.getNumber();
	S3 = S1 - S1*fn/(nx*ny);
	if (disector == true){
		h =  Dialog.getNumber();
		V = S3*h;
	}
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
	if (disector == true) {
		print(title, "\nDisector volume ="+V+" "+unit+"^3");
	}
	print(title, "\n_______________________\n");
	
