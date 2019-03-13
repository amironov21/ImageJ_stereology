/*
Makes isotropic grid with circles and points as non-destructive overlay.
You do not need to rotate the grid to get isotropic line orientation.
Do not forget to "Set Scale" to get correct printout of grid parameters.
Parameters of the grid are reflected in the "Multiple Circles grid parameters" window.
"Number of circles within short side" determines number and size of grid circles.
"Central Point" makes one point in every circle.
"Additional Points" makes 4 additional points per circle.

Grid constant a/l (area per line unit) is used to estimate total length
of a flat structure. Total length equals to number of intersections (between 
linear feature and test lines) multiplied by PI/2 times the grid constant a/l.

Area per point can be used to estimate an area in 2D samples or volume density 
in isotropic uniform random sections.

Test line per point (l/p) constant is used to estimate surface density (surface
area per unit volume) in isotropic uniform random sections. 

Version: 1.1
Date: 12/11/2018
Author: Aleksandr Mironov amj-box@mail.ru
*/ 

requires("1.52i");

//help
html = "<html>"
	+"<h1><font color=navy>Multiple Circles Grid</h1>"
	+"<font color=navy>is a linear test system with built-in 2D isotropy<br><br>"
	+"<font color=purple><b><u>Options:</u></b><br><br>"
	+"<b>Number of tiles</b> - determines how many tiles are drawn<br>"
	+"<b>Random Offset</b> - randomizes grid location<br>"
	+"<b>New Overlay</b> - removes previous overlays<br>"
	+"<b>Central point</b> - point in the middle of circles<br>"
	+"<b>Additional Points</b> - 4 additional points per circle<br><br>"
	+"<b><font color=red>Set Scale</b><font color=black> to get correct printout of the grid parameters,<br>" 
	+"which are reflected in the 'Multiple Circles grid parameters' window<br><br>"
	+"<font color=green><b><u>Useful parameters:</u></b><br><br>"
	+"<i><u>Area per point</u></i> can be used to estimate an area in 2D samples<br>" 
	+"or volume density isotropic uniform random sections<br><br>"
	+"<i><u>Test line per point</u></i> constant is used to estimate surface density<br>"
	+"(surface area per unit volume) in isotropic uniform random sections<br><br>"
	+"<i><u>Grid constant a/l (area per line unit)</u></i> is used to estimate total lenght<br>"
	+"of a flat stucture. Total length equals to number of intersections<br>"
	+"multiplied by PI/2 times the grid constant a/l<br>"
	
//Creating dialog box
Dialog.create("Multiple Circles Grid, ver. 1.0"); 
Dialog.addNumber("Number of tiles =", 3,0,2,"within short side"); //number1
Dialog.addNumber("Line thickness =", 1,0,2,"pixels"); //number2
Dialog.addCheckbox("Random Offset", false); //checkbox1
Dialog.addCheckbox("New Overlay", true); //checkbox2
Dialog.addCheckbox("Central Point", true); //checkbox3
Dialog.addCheckbox("Additional Points", true); //checkbox4
Dialog.addChoice("Color:", newArray("cyan", "red", "green", "magenta", "blue", "yellow", "orange", "black", "white")); 
Dialog.addHelp(html); 
Dialog.show(); 
 
name = getTitle();

//grid parameters  
ntiles = Dialog.getNumber();//number1 
t = Dialog.getNumber(); //number2
getDimensions(width, height, channels, slices, frames);
shortside = minOf(width, height);
r = shortside/(3*ntiles); 
tile = 3*r;
tileArea = r*r*9*sqrt(3)/2; 
offset = Dialog.getCheckbox(); //checkbox1
new = Dialog.getCheckbox(); //checkbox2
if (new == true) Overlay.remove; 
point = Dialog.getCheckbox(); //checkbox3
points = Dialog.getCheckbox(); //checkbox4
color = Dialog.getChoice(); 

setColor(color);
setLineWidth(t);

//Random offset 
xoff = random*2*r;
yoff = random*2*r; 
if (offset == false) xoff = yoff = 0;

//Initial coordinates 
x1 = round(r/2-xoff); 
y1 = round(r/2-yoff); 
x = x1;
y = y1;

//Main Loop (cricles hexagonal pattern and points)
while (y<height-1) { 
		GridRow(x, y, tile, r, color, point, points, width);
		x = x1-1.5*r;
		y += round(r*sqrt(6.75));
		GridRow(x, y, tile, r, color, point, points, width);
		x = x1;
		y+= round(r*sqrt(6.75));
	} 

 
//Printing the parameters of the grid 
getPixelSize(unit, pw, ph, pd); 
if (point == true) cp = 1; 
else cp = 0 ;
if (points == true) ap = 4; 
else ap = 0 ;
window = isOpen("Multiple Circles grid parameters"); 
title = "[Multiple Circles grid parameters]"; 
if (window == false){  
	run("Text Window...", "name="+ title +"width=60 height=16 menu"); 
	setLocation(0, 0); 
	}
print(title, "\nMultiple Circles Grid for sample ["+name+"]");  
print(title, "\n\nImage size = "+width+"x"+height+" pixels");
print(title, "\nPixel size = "+pw+" "+unit);
print(title, "\nScale = "+1/pw+" pixels/"+unit);
print(title, "\n\nGrid tiles per image = "+width*height/tileArea);
print(title, "\nSingle circle perimeter ="+2*PI*r*pw+"  "+unit); 
print(title, "\nSingle circle area ="+PI*r*r*pw*ph+"  "+unit+"2");
print(title, "\nGrid constant a/l = "+tileArea*pw/2/PI/r+" "+unit);
if (point || points == true) {
	print(title, "\nArea per point ="+tileArea*pw*ph/(cp+ap)+"  "+unit+"2");
	print(title, "\nTest line per point(l/p) ="+pw*2*PI*r/(cp+ap)+"  "+unit);
	}	
print(title, "\n_______________________\n");


//Making circles and points in one row
function GridRow(x, y, tile, r, color, point, points, width) {
	while (x<width-1) {
			if (point == true){ 
			makePoint(x+r, y+r, "large "+color+"cross add");
			Overlay.setPosition(0);
			} 
			if (points== true) {
			makePoint(x+r, y, "large "+color+"cross add");
			Overlay.setPosition(0);
			makePoint(x+2*r, y+r, "large "+color+"cross add");
			Overlay.setPosition(0);
			makePoint(x+r, y+2*r, "large "+color+"cross add");
			Overlay.setPosition(0);
			makePoint(x, y+r, "large "+color+"cross add");
			Overlay.setPosition(0);
			}
		
			Overlay.drawEllipse(x, y, 2*r, 2*r); 
			Overlay.show; 
			x += tile;
		} 
}
