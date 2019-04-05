/*This macro is based on the turtle graphics code by Norbert Vischer.
It creates Merz grid with semi-circular lines and points as non-destructive overlay.
Merz grid is a linear test system with built-in 2D isotropy,
so you do not need to rotate the grid to get isotropic line orientation.
Do not forget to "Set Scale" to get correct printout of the grid parameters, 
which are reflected in the "Merz grid parameters" window.
"Central Points" makes two points in every tile.
"Line Points" makes 4 additional points per tile.
"Segmented lines" makes circular arcs  with total length
2 times shorter than solid lines.

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

var  
k57 = 180/PI, 
turtleX = newArray(2000), turtleY = newArray(2000),  
turtlePhi, tPtr, newX, newY, aa1, aa2, aa3, aa4, bb1, bb2, bb3, bb4; 
 
macro "Merz_Grid" {

//help
html = "<html>"
	+"<h1><font color=navy>Merz Grid</h1>"
	+"<font color=navy>is a linear test system with built-in 2D isotropy<font color=black><br><br>"
	+"<font color=purple><b><u>Options:</u></b><br>"
	+"<b>Tile density</b> - determines density of the grid <br>"
	+"<b>Central Points</b> - two points per grid tile <br>"
	+"<b>Line Points</b> - 4 additional points per grid tile <br><br>"
	+"<b>New Overlay</b> - removes previous overlays<br>"
	+"<b>Random Offset</b> - randomizes grid location<br>"
	+"<b>Random Phase</b> - randomizes initial arc phase<br><br>"
	+"<b>Segmented lines</b> - arcs with half of total length of solid lines<br><br>"
	+"<font color=red><b>Set Scale</b><font color=black> to get correct printout of the grid parameters,<br>" 
	+"which are reflected in the 'Merz grid parameters' window<br><br>"
	+"<font color=green><b>Useful parameters:</b><br><br>"
	+"<i><u>Area per point</u></i> can be used to estimate an area in 2D samples<br>" 
	+"or volume density isotropic uniform random sections<br><br>"
	+"<i><u>Test line per point</u></i> constant is used to estimate surface density<br>"
	+"(surface area per unit volume) in isotropic uniform random sections<br><br>"
	+"<i><u>Grid constant a/l (area per line unit)</u></i> is used to estimate total length<br>"
	+"of a flat structure. Total length equals to number of intersections<br>"
	+"multiplied by PI/2 times the grid constant a/l<br>"
	
//Creating dialog box
Dialog.create("Merz Grid, ver. 1.0"); 
Dialog.addNumber("Tile density  =", 6,0,2,"within height");    
Dialog.addCheckbox("Central Points", true); 
Dialog.addCheckbox("Line Points (x2 of central)", true);
Dialog.addMessage("\n ");
Dialog.addCheckbox("New Overlay", true);  
Dialog.addCheckbox("Random Offset", true);
Dialog.addCheckbox("Random Phase", true);
Dialog.addChoice("Line type", newArray("solid", "segmented"));
Dialog.addNumber("Line thickness =", 1,0,2,"pixels");
Dialog.addChoice("Color:", newArray("cyan", "red", "green", "magenta", "blue", "yellow", "orange", "black", "white"));
Dialog.addHelp(html); 
Dialog.show(); 

//grid parameters 
name = getTitle();
ntiles = Dialog.getNumber();  
point = Dialog.getCheckbox(); 
points = Dialog.getCheckbox();
new = Dialog.getCheckbox();
if (new == true) Overlay.remove;
getDimensions(w, h, channels, slices, frames);
tile = h/ntiles; 

//creating random offset
off1 = random; 
off2 = random; 
offset = Dialog.getCheckbox(); 
if (offset == false) off1 = off2 = 0;
xoff = -round(tile/2*off1);
yoff = -round(tile/2*off2);

//creating random phase
phase = random;
offphase = Dialog.getCheckbox();
if (offphase == false) phase = 0.1;

typeL = Dialog.getChoice(); 
t = Dialog.getNumber();
color = Dialog.getChoice(); 

setColor(color);
setLineWidth(t);

	//tile parameters
	step = tile*PI/40; //length of a step in pixels 
	nSteps = 10;// 
	dPhi = 9; //degrees between 2 steps 
	cycles = w/tile/2;
	cycless = cycles+1; 
	xx1 = xoff;
	yy1 = yoff; 

	//phase change
	if (phase<0.25){
		dPhi1=dPhi4=dPhi;
		dPhi2=dPhi3=-dPhi;
		phi=0;
		}
	else if (phase>=0.25 && phase<0.5){
		dPhi1=dPhi4=-dPhi;
		dPhi2=dPhi3=dPhi;
		phi=0;
		}
	else if (phase>=0.5 && phase<0.75){
		dPhi1=dPhi2=-dPhi;
		dPhi3=dPhi4=dPhi;
		phi=-90;
		}
	else {	dPhi1=dPhi2=dPhi;
		dPhi3=dPhi4=-dPhi;
		phi=90;
		}
		
	//main loop
	for (waves = 0; waves <= (ntiles+1); waves++){ 
		turtleInit(xx1, yy1, phi);//starting point and angle 
		for (kk =0; kk<cycless; kk++){
			 
			//first segment
			if (points == true){
				drawEndLine();
				}
			for (jj = 0; jj < nSteps; jj++){
				turtleLine (dPhi1, step ); 
				} 
				if (typeL=="segmented"){
					drawCurve();
					turtleInit(newX, newY, turtlePhi);
					}
				if (points == true){
					drawEndLine();
					}
				if (point == true) {
					x_phaseDep();
					y_phaseDep1();
					drawCentrPoint();
					}
				
			//second segment	
			for (jj = 0; jj < (nSteps); jj++){ 
				turtleLine (dPhi2, step ); 
				} 
				if (typeL=="segmented"){
					turtleInit(newX, newY, turtlePhi);
					}
					
			//third segment		
			if (points == true){
				drawEndLine ();
				}	
			for (jj = 0; jj < (nSteps); jj++){ 
				turtleLine (dPhi3, step ); 
				}
				if (typeL=="segmented"){
					drawCurve();
					turtleInit(newX, newY, turtlePhi);
					}
				if (points == true){
					drawEndLine();
					}
				if (point == true) {
					x_phaseDep();
					y_phaseDep3();
					drawCentrPoint();
					}
					
			//forth segment	
			for (jj = 0; jj < nSteps; jj++){ 
				turtleLine (dPhi4, step ); 
				} 
				if (typeL=="segmented"){
			 		turtleInit(newX, newY, turtlePhi);
					}
			}
		if (typeL=="solid"){  
			drawCurve();
			} 
		yy1 += tile; 
		} 

// Printing the parameters of the grid
getPixelSize(unit, pw, ph, pd); 
if (point == true) cp = 2; 
else	cp = 0;
if (points == true)ap = 4; 
else	ap = 0;
if (typeL == "segmented") lr = 2;
else lr = 1;
window = isOpen("Merz grid parameters"); 
title = "[Merz grid parameters]"; 
if (window == false){  
	run("Text Window...", "name="+ title +"width=60 height=16 menu"); 
	setLocation(0, 0); 
	} ;
	
print(title, "\nMerz Grid for sample ["+name+"]"); 
print(title, "\n\nImage size = "+w+"x"+h+" pixels");
print(title, "\nPixel size = "+pw+" "+unit);
print(title, "\nScale = "+1/pw+" pixels/"+unit);
print(title, "\n\nGrid tiles per image = "+ntiles*cycles);
print(title, "\nLine length per tile = "+tile*PI*pw/lr+" "+unit);
print(title, "\nGrid constant a/l = "+tile*2*lr*pw/PI+" "+unit);
if (point || points == true) {
	print(title, "\nArea per point ="+tile*tile*2*pw*ph/(cp+ap)+"  "+unit+"^2");
	print(title, "\nTest line per point(l/p) ="+pw*PI*tile/(cp+ap)/lr+"  "+unit);
	}
print(title, "\n_______________________\n");

}

//drawing segmented line
function drawCurve(){
	turtleMakeSelection("polyline");
	run("Add Selection...", "width="+t+" stroke="+color);
	run("Select None");
	}

//drawing end line (line point)
function drawEndLine(){
	if (turtlePhi == 0){a1=a2=0; b1=-tile/32; b2=tile/32;}
	else {b1=b2=0; a1=-tile/32; a2=tile/32;}
	Overlay.drawLine(turtleX[tPtr]+a1,turtleY[tPtr]+b1,turtleX[tPtr]+a2,turtleY[tPtr]+b2); 
	Overlay.add;
	Overlay.show;
	}

//drawing central point
function drawCentrPoint(){
	Overlay.drawLine(turtleX[tPtr]+aa1,turtleY[tPtr]+bb1,turtleX[tPtr]+aa2,turtleY[tPtr]+bb2);
	Overlay.add;
	Overlay.drawLine(turtleX[tPtr]+aa3,turtleY[tPtr]+bb3,turtleX[tPtr]+aa4,turtleY[tPtr]+bb4);  
	Overlay.add;
	Overlay.show;
	}

//phase dependence for x and y of central point

function x_phaseDep(){
	if (phase<0.5){
		aa1=tile/2-tile/32;
		aa2=tile/2+tile/32;
		aa3=tile/2;
		aa4=tile/2;
	}
	else 	{
		aa1=-tile/16;
		aa2=0;
		aa3=-tile/32;
		aa4=-tile/32;
	}
}

//y for segment 1
function y_phaseDep1(){
	if (phase<0.25) {
		bb1=-tile/32;
		bb2=-tile/32;
		bb3=-tile/16;
		bb4=0;
		}
	else if(phase>=0.25 && phase<0.5) {
		bb1=tile/32;
		bb2=tile/32;
		bb3=0;
		bb4=tile/16;
		}
	else if (phase>=0.5 && phase<0.75) {
		bb1=-tile/2;
		bb2=-tile/2;
		bb3=-tile/2-tile/32;
		bb4=-tile/2+tile/32;
		}
	else  {
		bb1=tile/2;
		bb2=tile/2;
		bb3=tile/2-tile/32;
		bb4=tile/2+tile/32;
		}
}

//y for segment 3
function y_phaseDep3(){

	if (phase<0.25){
		bb1=tile/32;
		bb2=tile/32;
		bb3=0;
		bb4=tile/16;
		}
	else if(phase>=0.25 && phase<0.5) {
		bb1=-tile/32;
		bb2=-tile/32;
		bb3=-tile/16;
		bb4=0;
		}
	else if (phase>=0.5 && phase<0.75){
		bb1=tile/2;
		bb2=tile/2;
		bb3=tile/2-tile/32;
		bb4=tile/2+tile/32;
		}
	else  {
		bb1=-tile/2;
		bb2=-tile/2;
		bb3=-tile/2-tile/32;
		bb4=-tile/2+tile/32;
		}	
}


/* 
Turtle routines 
=============== 
at any moment, the turtle has position turtleX[tPtr], turtleY[tPtr], 
and orientation turtlePhi. 
Turtle array is 1-based. 
Negative indices count from the back, so -1 addresses last vertex. 
turtleX[0] and turtleY[0] are not used. 
 */ 
 
//initialize
function turtleInit(xx, yy, phi){ 
	tPtr =1; 
	turtleX[1]= xx; 
	turtleY[1]= yy; 
	turtlePhi= phi; 
} 
 
//create a selection 
function turtleMakeSelection(type){ 
	xx = newArray(tPtr); 
	yy = newArray(tPtr); 
	for (jj = 1; jj<=tPtr; jj++){ 
		xx[jj-1] = turtleX[jj]; 
		yy[jj-1] = turtleY[jj]; 
	} 
	makeSelection(type, xx, yy);	 
} 
 
//create line coordinates
function turtleLine(dPhi, rad){ 
	turtlePhi -= dPhi; 
	while(turtlePhi < 0) 
		turtlePhi += 360; 
	while(turtlePhi >= 360) 
		turtlePhi -= 360; 

	dx = rad * cos(turtlePhi/k57); 
	dy = -rad * sin(turtlePhi/k57); 
	newX = turtleX[tPtr] + dx; 
	newY = turtleY[tPtr] + dy; 
	tPtr++; 
	turtleX[tPtr] = newX; 
	turtleY[tPtr] = newY; 
}

 
