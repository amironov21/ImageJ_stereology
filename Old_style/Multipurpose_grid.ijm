/*Makes grid based on multi-purpose grid from Gundersen & Jensen 
(J Microsc. 1987, 147:229-6) for stereological quantification as 
non-destructive overlay. 
Options include lines and crosses of different density.
Do not forget to "Set Scale" to get correct printout of grid parameters.
Parameters of the grid are reflected in the "Multipurpose grid parameters" window.

Grid constant a/l (area per line unit) is used to estimate total lenght
of a flat stucture. Total lenght equals to number of intersections (between 
linear feature and test lines) multiplied by PI/2 times the grid constant a/l.

Area per point can be used to estimate an area in 2D samples or volume density 
in isotropic uniform random sections.

Test line per point (l/p) constant is used to estimate surface density (surface
area per unit volume in isotropic uniform random sections. 

Version: 2.0
Date: 03/01/2022
Author: Aleksandr Mironov amj-box@mail.ru
*/

//help
html = "<html>"
	+"<h1><font color=navy>Multi-purpose Stereological Grid, ver. 2.0</h1>"
	+"<font color=navy>based on Gundersen & Jensen (J Microsc. 1987, 147:229-6)<br><br>"
	+"<b><font color=red>Standard (default) grid tile</b><font color=black> includes 2 segmented lines and 4"
	+" regular points (as crosses) at lines'<br> ends, one 'encircled' point (which is "
	+"included into regular points set) and 12 additional 'dense' points.<br><br>"
	+"<b><font color=purple>Grid density</b> can be set by number of tiles or by area per point<br><br>"
	+"<font color=purple><b><u>Options:</u></b><br>"
	+"<b>New Overlay</b> - removes previous overlays<br>"
	+"<b>Random Offset</b> - randomizes grid location<br>"
	+"<b>Tile density</b> - determines density of the grid <br><br>"
	+"<b>Encircled Points</b> - marks 1 sparse point per grid tile <br>"
	+"<b>Dense Points</b> - adds 16 points to regular 4 per grid tile <br><br>"
	+"<b><u>Points ratio:</u></b><br>"
	+"Encircled:Regular:Dense = 1:4:20<br><br>"
	+"<b>Default assumptions for correct calculations:</b><br>"
	+"1) Dense points include all grid points<br>"
	+"2) Regular points are at lines' ends and include encircled points<br>"
	+"3) Encircled points include only themselves<br><br>"
	+"<b><font color=green>Useful parameters:</b><br><br>"
	+"<font color=green> <i><u>Area per point</u></i> can be used to estimate an area in 2D samples<br>" 
	+"or volume density isotropic uniform random sections<br><br>"
	+"<i><u>Test line per point</u></i> constant is used to estimate surface density<br>"
	+"(surface area per unit volume) in isotropic uniform random sections<br><br>"
	+"<i><u>Grid constant a/l (area per line unit)</u></i> is used to estimate total lenght<br>"
	+"of a flat stucture. Total lenght equals to number of intersections<br>"
	+"multiplied by PI/2 times the grid constant a/l<br>"

//Check for open image
if (nImages==0) { 
	exit("No open images detected! \n\nPlease, open an image ..."); 
	} 

getDimensions(width, height, channels, slices, frames);
getPixelSize(unit, pw, ph, pd);//getting pixel size

//Check for scale
if (unit == "pixels") {
	Dialog.create("Multi-purpose Stereological Grid, ver. 2.0");
	Dialog.addMessage("This macro needs proper image scale to be set! \n\nPlease, set the scale using 'Properties...' option in pop-up window \n\nOtherwise, all calculations will show pixels ...") 
	Dialog.show();
	run("Properties...");
	}

getPixelSize(unit, pw, ph, pd);//update pixel size

//Initial dialog for image roataion and grid tile size
Dialog.create("Multi-purpose Stereological Grid, ver. 2.0"); 
Dialog.setInsets(0, 20, 0);
Dialog.addChoice("Set grid dimensions:", newArray("by tiles density", "by area per point"));
Dialog.addHelp(html);
Dialog.show();
dimensions = Dialog.getChoice();//getting grid density

//Main dialog box for grid parameters
Dialog.create("Grid parameters");
Dialog.addMessage("          GENERAL:");
Dialog.addCheckbox("Grid Random Offset", true);// checkbox1
Dialog.addCheckbox("New Overlay", true);// checkbox2
Dialog.addChoice("Grid color:", newArray("cyan", "red", "yellow", "green", "blue", "magenta", "orange", "black", "white"));// choice1
Dialog.addNumber("Line thickness =", 1,0,2,"pixels");// number1
if (dimensions=="by tiles density") { // number2
	Dialog.addNumber("Tile density  =", 1,0,2,"per short side"); 
	} else { 
	Dialog.addNumber("Area per point  =", 10000,2,8," "+unit+"^2"); 
	};  
Dialog.addMessage("__________________________________");
Dialog.addMessage("          TEST POINTS:");
Dialog.addCheckbox("Mark 'Encircled' Points (1/4 of regular points)", true);// checkbox3
Dialog.addCheckbox("Add 'Dense' Points (x4 of regular points)", true);// checkbox4
Dialog.addMessage("__________________________________");
Dialog.addMessage("          TEST LINES:");
Dialog.addCheckbox("Horizontal segmented", true);// checkbox5
Dialog.addCheckbox("Vertical segmented", false);// checkbox6
Dialog.addCheckbox("Horizontal solid (x3 of segmented)", false);// checkbox7
Dialog.addCheckbox("Vertical solid (x3 of segmented)", false);// checkbox8
Dialog.addHelp(html);
Dialog.show(); 

name = getTitle();

//grid parameters 
offset = Dialog.getCheckbox();// checkbox1
new = Dialog.getCheckbox();// checkbox2
Lthick = Dialog.getNumber();// number1
dimens = Dialog.getNumber();// number2
circP = Dialog.getCheckbox();// checkbox3
denseP = Dialog.getCheckbox();// checkbox4
color = Dialog.getChoice();// choice1
H_segm_Line = Dialog.getCheckbox();// checkbox5
V_segm_Line = Dialog.getCheckbox();// checkbox6
H_solid_Line = Dialog.getCheckbox();// checkbox7
V_solid_Line= Dialog.getCheckbox();// checkbox8

//initial settings for l/p
vsg=hsg=vsl=hsl=0;//setting counters for lines lenght

//tile size
if (dimensions=="by tiles density") {
	if (width>=height) { //finding shortest side for tile calculations
	ss = height; 
	} else { 
	ss = width; 
	} 
	tileside = ss/dimens;
	}else {
	tileside = sqrt(4*dimens/ph/pw);
	}
pointd = tileside/4;//distance between dense points
pointr = tileside/2;//distance between regular points

//check overlay
if (new == true) Overlay.remove;

//creating random offset 
off1 = random; 
off2 = random; 
if (offset == false) off1 = off2 = 1;//no offset 
xoff = round(pointd*off1);
yoff = round(pointd*off2);

setColor(color);
setLineWidth(Lthick);

//Horizonal solid lines
if (H_solid_Line == true){	
	y = yoff;
	while (true && y<height) { 
		Overlay.drawLine(0, y, width, y);
		Overlay.add;
		y += pointr;
		}
	Overlay.show;
	hsl = 2;
	}

//Vertical solid lines
if (V_solid_Line == true){
	x = xoff;
	while (true && x<width) { 
		Overlay.drawLine(x, 0, x, height);
		Overlay.add;
		x += pointr;
		}
	Overlay.show;
	vsl = 2;
	}

//Horizonal segmented lines
if (H_segm_Line == true){
hsg = 1;

//Y loop1
y1 = yoff;
while (y1<height) { 
		
		//X loop1
		x1 = xoff; 
		while (x1<width) {   
			Overlay.drawLine(x1, y1, x1+pointr, y1);
			Overlay.add;
			x1 += tileside;  
		}
	Overlay.show;	 
	y1 += tileside;  
	}
	
//Y loop2
y1 = yoff+pointr;
while (y1<height) { 
 
		//X loop2 
		x2 = xoff;
		x1 = 0;	
		while (x1<width) {   
			Overlay.drawLine(x1, y1, x2, y1);
			Overlay.add;
			x1 = x2 + pointr;
			x2 += tileside;
		}
	Overlay.show; 
	y1 += tileside;  
	}
}

//Vertical segmented lines
if (V_segm_Line == true){
vsg = 1;

//X loop1
x1 = xoff;
while (x1<width) { 
		
		//Y loop1
		y1 = yoff; 
		while (y1<height) {   
			Overlay.drawLine(x1, y1, x1, y1+pointr);
			Overlay.add;
			y1 += tileside;  
		} 
	Overlay.show;
	x1 += tileside;  
	}
	
//X loop2
x1 = xoff+pointr;
while (x1<width) { 
 
		//Y loop2 
		y2 = yoff;
		y1 = 0;	
		while (y1<height) {   
			Overlay.drawLine(x1, y1, x1, y2);
			Overlay.add;
			y1 = y2 + pointr;
			y2 += tileside;
		} 
	Overlay.show;
	x1 += tileside;  
	}
}
	
 //Regular points

//Initial coordinates X
x1 = xoff;
x2 = x1 - pointd/16; 
x3 = x1 + pointd/16;

//X loop 
while (x1<width) { 
 
		//initial coordinates Y 
		y1 = yoff; 
		y2 = y1 - pointd/16; 
		y3 = y1 + pointd/16; 

		//Y loop 
		while (y1<height) {  
		 
			//horizontal line	 
			Overlay.drawLine(x2,y1,x3,y1); 
			Overlay.add; 
			//vertical line 
			Overlay.drawLine(x1,y2,x1,y3); 
			Overlay.add; 	
		y1 += pointr; 
		y2 += pointr; 
		y3 += pointr; 
		} 
	Overlay.show;
	x1 += pointr; 
	x2 += pointr; 
	x3 += pointr; 
	} 

//Dense points 
if (denseP == true){
	//Initial coordinates X;
	x1 = xoff - pointd/2;
	x2 = x1 - pointd/16; 
	x3 = x1 + pointd/16;
	
	//X loop 
	while (x1<width) { 
 
		//initial coordinates Y 
		y1 = yoff - pointd/2; 
		y2 = y1 - pointd/16; 
		y3 = y1 + pointd/16;
		 
		//Y loop 
		while (y1<height) {  
			//horizontal line	 
			Overlay.drawLine(x2,y1,x3,y1); 
			Overlay.add; 
			//vertical line 
			Overlay.drawLine(x1,y2,x1,y3); 
			Overlay.add; 
		y1 += pointd; 
		y2 += pointd; 
		y3 += pointd; 
		} 
	Overlay.show;
	x1 += pointd; 
	x2 += pointd; 
	x3 += pointd; 
	} 
}

//Encircled points
if (circP == true){
	
	//Initial coordinates X
	x1 = xoff;
	x2 = x1 - pointd/16;
	
	//X loop 
	while (x2<width) { 
 
		//Initial coordinates Y 
		y1 = yoff; 
		y2 = y1 - pointd/16; 
		 
		//Y loop 
		while (y2<height) {  
			Overlay.drawEllipse(x2, y2, pointd/8, pointd/8);
			Overlay.add; 
		y2 += tileside;  
		}
	Overlay.show;
	x2 += tileside;  
	} 
}

//  Printing the parameters of the grid

window = isOpen("Multipurpose grid parameters"); 
title = "[Multipurpose grid parameters]"; 
if (window == false){  
	run("Text Window...", "name="+ title +"width=60 height=16 menu"); 
	setLocation(0, 0); 
	};
	
print(title, "\nMultipurpose Grid for sample ["+name+"]");
print(title, "\n\nOriginal Image size = "+width+"x"+height+" pixels");
print(title, "\nPixel size = "+pw+" "+unit);
print(title, "\nScale = "+1/pw+" pixels/"+unit);
print(title, "\n\nArea per regular point ="+tileside*tileside*pw*ph/4+"  "+unit+"^2");
if (denseP == true){ 
	n = 16;
	}else{
	n = 0;
	};
if (circP == true){ 
	print(title, "\nArea per encircled point ="+tileside*tileside*pw*ph+"  "+unit+"^2"); 
	};
print(title, "\nArea per any point ="+tileside*tileside*pw*ph/(4+n)+"  "+unit+"^2");
	
if (V_segm_Line && V_solid_Line == true)
vsg = 0; 
if (H_segm_Line && H_solid_Line == true)
hsg = 0; 
z = vsg+hsg+vsl+hsl;
lp = pw*tileside*z;
if (H_segm_Line || V_segm_Line ||H_solid_Line || H_solid_Line == true){
	print(title, "\nTest line per any point(l/p) ="+lp/(4+n)+"  "+unit);
		if (circP == true){
		print(title, "\nTest line per encircled point(l/p) ="+lp+"  "+unit);
		}
		if (H_segm_Line || V_segm_Line ||H_solid_Line || H_solid_Line == true){
		print(title, "\nTest line per regular point(l/p) ="+lp/4+"  "+unit);
		}
	print(title, "\nGrid constant a/l = "+2*pw*tileside/z+" "+unit);
	}
print(title, "\n _______________________\n");

