/*Makes isotropic grid with circles and points as non-destructive overlay.
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

Version: 1.0
Date: 04/09/2014
Author: Aleksandr Mironov amj-box@mail.ru
*/ 

requires("1.46b");

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
Dialog.addNumber("Number of tiles =", 3,0,2,"within short side"); 
Dialog.addNumber("Line thickness =", 1,0,2,"pixels"); 
Dialog.addCheckbox("Random Offset", true); 
Dialog.addCheckbox("New Overlay", true); 
Dialog.addCheckbox("Central Point", true); 
Dialog.addCheckbox("Additional Points", true); 
Dialog.addChoice("Color:", newArray("cyan", "red", "green", "magenta", "blue", "yellow", "orange", "black", "white")); 
Dialog.addHelp(html); 
Dialog.show(); 
 
name = getTitle();

//grid parameters  
nt = Dialog.getNumber(); 
t = Dialog.getNumber(); 
getDimensions(a, b, channels, slices, frames);
ss = minOf(a,b);
r = ss/(3*nt); 
d = 2*r; 
tile = 3*r; 
 
//creating random offset 
off1 = random; 
off2 = random; 
offset = Dialog.getCheckbox(); 
if (offset == false) off1 = off2 = 0; 
 
//other choices 
new = Dialog.getCheckbox(); 
if (new == true) Overlay.remove; 
point = Dialog.getCheckbox(); 
points = Dialog.getCheckbox(); 
color = Dialog.getChoice(); 
 
//initial coordinates X 
xoff = -round(d*off1); 
x1 = xoff + r; 
x2 = x1 - d/30; 
x3 = x1 + d/30; 

setColor(color);
setLineWidth(t);

//X loop; 
while (true && xoff<a) { 
 
		//initial coordinates Y 
		yoff = -round(d*off2); 
		y1 = yoff + r; 
		y2 = y1 - d/30; 
		y3 = y1 + d/30; 
 
		//Y loop 
		while (true && yoff<b) {  
		Overlay.drawEllipse(xoff, yoff, d, d); 
		Overlay.add;
		 
		//Central point 
		if (point == true){ 
			//horizontal line;	 
			Overlay.drawLine(x2,y1,x3,y1); 
			Overlay.add; 
			//vertical line; 
			Overlay.drawLine(x1,y2,x1,y3); 
			Overlay.add; 
			} 
		//Additional points 
		if (points == true){ 
			//horizontal line;	 
			Overlay.drawLine(xoff-d/30,yoff+r,xoff+d/30,yoff+r); 
			Overlay.add; 
			Overlay.drawLine(xoff+d-d/30,yoff+r,xoff+d+d/30,yoff+r); 
			Overlay.add; 
			//vertical line; 
			Overlay.drawLine(xoff+r,yoff-d/30,xoff+r,yoff+d/30); 
			Overlay.add; 
			Overlay.drawLine(xoff+r,yoff+d-d/30,xoff+r,yoff+d+d/30); 
			Overlay.add; 
			}
		Overlay.show; 
		yoff += tile; 
		y1 += tile; 
		y2 += tile; 
		y3 += tile; 
		} 
	xoff += tile; 
	x1 += tile; 
	x2 += tile; 
	x3 += tile; 
	} 

 
//  Printing the parameters of the grid 
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
print(title, "\n\nImage size = "+a+"x"+b+" pixels");
print(title, "\nPixel size = "+pw+" "+unit);
print(title, "\nScale = "+1/pw+" pixels/"+unit);
print(title, "\n\nGrid tiles per image = "+a*b/tile/tile);
print(title, "\nSingle circle perimeter ="+2*PI*r*pw+"  "+unit); 
print(title, "\nSingle circle area ="+PI*r*r*pw*ph+"  "+unit+"^2");
print(title, "\nGrid constant a/l = "+9*r*pw/PI/2+" "+unit); 
if (point || points == true) {
	print(title, "\nArea per point ="+tile*tile*pw*ph/(cp+ap)+"  "+unit+"^2");
	print(title, "\nTest line per point(l/p) ="+pw*2*PI*r/(cp+ap)+"  "+unit);
	}	
print(title, "\n_______________________\n");
