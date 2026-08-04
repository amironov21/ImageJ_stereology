/*Makes a grid based on cycloid grid from Baddeley, A.J., 
H.J.G. Gundersen, and L.M. Cruz-Orive, J. of Microsc. 1986, 
142:259-276. for stereological quantification on vertical uniform 
random sections as non-destructive overlay.

Image vertical axis should be aligned with the grid vertical axis
(placed on the left side). 

Do not forget to "Set Scale" to get correct printout of the grid parameters, 
which are reflected in the "Cycloid grid parameters" window.

"Central Points" makes two points in every tile.
"Line Points" makes 4 additional points per tile.
"Segmented lines" makes circular arcs  with total length
2 times shorter than solid lines.

Test line per point (l/p) constant is used to estimate surface density (surface
area per unit volume) in uniform random sections. 

Version: 1.1
Date: 04/09/2014
Author: Aleksandr Mironov amj-box@mail.ru
*/

requires("1.49g");

var
x0, y0, tmax, newStart = newArray(2);

macro "Cycloid_Grid" {

//help
html = "<html>"
	+"<h1><font color=navy>Cycloid Grid</h1>"
	+"<font color=navy>is a linear test system for vertical uniform random sections<font color=black><br><br>"
	+"<font color=navy>based on Baddeley, Gundersen, Cruz-Orive (J. of Microsc. 1986, 142:259-276)<font color=black><br><br>"
	+"<font color=purple><b><u>Options:</u></b><br>"
	+"<b>Tile density</b> - determines density of the grid <br>"
	+"<b>Central Points</b> - two points per grid tile <br>"
	+"<b>Line Points</b> - 4 additional points per grid tile <br><br>"
	+"<b>New Overlay</b> - removes previous overlays<br>"
	+"<b>Random Offset</b> - randomizes grid location<br>"
	+"<b>Segmented lines</b> - arcs with half of total length of solid lines<br><br>"
	+"<font color=red><b>Set Scale</b><font color=black> to get correct printout of the grid parameters,<br>" 
	+"which are reflected in the 'Cycloid grid parameters' window<br><br>"
	+"<font color=green><b>Useful parameters:</b><br><br>"
	+"<i><u>Area per point</u></i> can be used to estimate an area in 2D samples<br>" 
	+"or volume density in uniform random sections<br><br>"
	+"<i><u>Test line per point</u></i> constant is used to estimate surface density<br>"
	+"(surface area per unit volume) in vertical uniform random sections<br><br>"
	
// Cycloid settings
tmax = 3.251;
nPoints = 30;
getDimensions(w, h, channels, slices, frames);
name = getTitle();
stSegm = random;

//Creating dialog box
Dialog.create("Cycloid Grid, ver. 1.1"); 
Dialog.addNumber("Tile density  =", 6,0,2,"within height");    
Dialog.addCheckbox("Central Points", true); 
Dialog.addCheckbox("Line Points (x2 of central)", true);
Dialog.addMessage("\n ");
Dialog.addChoice("Line type", newArray("segmented", "solid"));
Dialog.addNumber("Line thickness =", 1,0,2,"pixels");
Dialog.addChoice("Line color:", newArray("cyan", "red", "green", "magenta", "blue", "yellow", "orange", "black", "white"));
Dialog.addChoice("Central Point color:", newArray("green", "cyan", "red", "magenta", "blue", "yellow", "orange", "black", "white"));
Dialog.addCheckbox("New Overlay", true);  
Dialog.addCheckbox("Random Offset", true);
Dialog.addCheckbox("Show Vertical Axis", true); 
Dialog.addHelp(html); 
Dialog.show(); 

//grid parameters
ntiles = Dialog.getNumber();;
tile = h/ntiles;
rad = tile/4;
cycles = w/PI/4/rad;
point = Dialog.getCheckbox();;
points = Dialog.getCheckbox();;
typeCycloid = Dialog.getChoice();
th = Dialog.getNumber();
color = Dialog.getChoice();
colorC = Dialog.getChoice();
new = Dialog.getCheckbox();
if (new == true) Overlay.remove;

//Creating offset
off1 = random;
off2 = random;
offset = Dialog.getCheckbox(); 
if (offset == false) off1 = off2 = 0;
xoff = -round(off1*PI*tile);
yoff = -round(off2*tile);
newStart[0] = xoff;
newStart[1] = yoff;

//vertical axis
arrow = Dialog.getCheckbox();

//Filling image with grid tiles
for (i = 0; i <= ntiles+1; i++){
	for (j = 0; j <= cycles+1; j++){
		startSegm = stSegm;
		drawCurve(typeCycloid, startSegm);
		run("Select None");
		}
	newStart[0] = xoff;
	newStart[1] = newStart[1] + tile;
	i=i++;
	for (j = 0; j <= cycles+1; j++){
		startSegm = 1-stSegm;
		drawCurve(typeCycloid, startSegm);
		run("Select None");
		}
	newStart[0] = xoff;
	newStart[1] = newStart[1] + tile;
}

if (arrow == true){
	makeArrow(th*2, h, th*2, 0, "notched large outline");
	Roi.setStrokeWidth(th*2);
	Roi.setStrokeColor(colorC);
	run("Add Selection...");
}

//Drawing one segment of cycloid
function makeSegm(x, y, rad, tmax, k1, k2, type){
		xArr = newArray(nPoints);
		yArr = newArray(nPoints);
		
		for (pt = 0; pt < nPoints; pt++){
		t = pt/nPoints * tmax; 
		xArr[pt] = newStart[0] + rad * (t+k1*sin(t));
		yArr[pt] = newStart[1] + k2*rad * (1-cos(t));
		}
		if (type == "solid"){
		makeSelection("polyline", xArr, yArr);
		run("Add Selection...", "width="+th+" stroke="+color);
		}
		//last segment coordinates
		newStart[0] = xArr[pt-1];
		newStart[1] = yArr[pt-1];
		return newStart;
		}

//Drawing cycloid from segments
function drawCurve(typeCycloid, startSegm){

		//First segment
		if (typeCycloid == "segmented" && startSegm <= 0.5){
			type = "empty";
			} else {
			type = "solid";
			}
		k1 = k2 = -1;
		makeSegm(x0, y0, rad, tmax, k1, k2, type);
		if (points == true){
			orient = "V";
			drawEndLine(orient);
			}
		if (point == true){
			kk = 1;
			drawCentralPoint(kk);
			}

		//Second segment
		if (typeCycloid == "segmented" && startSegm > 0.5){
			type = "empty";
			} else {
			type = "solid";
			}
		k1 = k2 = 1;
		makeSegm(x0, y0, rad, tmax, k1, k2, type);
		if (points == true){
			orient = "H";
			drawEndLine(orient);
			}

		//Third segment
		if (typeCycloid == "segmented" && startSegm <= 0.5){
			type = "empty";
			} else {
			type = "solid";
			}
		k1 = -1;
		makeSegm(x0, y0, rad, tmax, k1, k2, type);
		if (points == true){
			orient = "V";
			drawEndLine(orient);
			}
		if (point == true){
			kk = -1;
			drawCentralPoint(kk);
			}

		//Fourth segment
		if (typeCycloid == "segmented" && startSegm > 0.5){
			type = "empty";
			} else {
			type = "solid";
			}
		k1 = 1;
		k2 = -1;
		makeSegm(x0, y0, rad, tmax, k1, k2, type);
		if (points == true){
			orient = "H";
			drawEndLine(orient);
			}
		}

//End Points
function drawEndLine(orient){
		setColor(color);
		setLineWidth(th);
		y1 = newStart[1] - tile/24;
		y2 = newStart[1] + tile/24;
		y = newStart[1];
		x = newStart[0];
		x1 = newStart[0] - tile/24;
		x2 = newStart[0] + tile/24;
		if (orient == "V"){
		Overlay.drawLine(x,y1,x,y2);
		Overlay.add;
		Overlay.show;
		} else {
		Overlay.drawLine(x1,y,x2,y);
		Overlay.add;
		Overlay.show;
		} 
	}


//Central Points
function drawCentralPoint(kk){
		setColor(colorC);
		setLineWidth(th);
		x1 = newStart[0] - tile/24;
		x2 = newStart[0] + tile/24;
		y = newStart[1] + kk*tile/2;
		x = newStart[0];
		y1 = newStart[1] + kk*tile/2 - tile/24;
		y2 = newStart[1] + kk*tile/2 + tile/24;
		Overlay.drawLine(x,y1,x,y2); 
		Overlay.add;
		Overlay.drawLine(x1,y,x2,y); 
		Overlay.add;
		Overlay.show;
		}

// Printing the parameters of the grid
getPixelSize(unit, pw, ph, pd); 
window = isOpen("Cycloid grid parameters"); 
title = "[Cycloid grid parameters]"; 
if (window == false){  
	run("Text Window...", "name="+ title +"width=60 height=16 menu"); 
	setLocation(0, 0); 
	}
if (point == true) cp = 2; 
else	cp = 0;
if (points == true)ep = 4; 
else	ap = 0;
if (typeCycloid == "segmented") lr = 2;
else lr = 1;

print(title, "\nCycloid Grid for sample ["+name+"]"); 
print(title, "\n\nImage size = "+w+"x"+h+" pixels");
print(title, "\nPixel size = "+pw+" "+unit);
print(title, "\nScale = "+1/pw+" pixels/"+unit);
print(title, "\n\nGrid tiles per image = "+ntiles*w/PI/tile);
print(title, "\nLine length per tile = "+tile*4*pw/lr+" "+unit);
if (point || points == true) {
	print(title, "\nArea per point ="+tile*tile*2*PI*pw*ph/(cp+ep)+"  "+unit+"^2");
	print(title, "\nTest line per point(l/p) ="+pw*PI*tile/(cp+ep)/lr+"  "+unit);
	}
print(title, "\n_______________________\n");

}
