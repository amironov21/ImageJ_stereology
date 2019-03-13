/*Demonstrates Buffon's needle problem interactive solution:
 
"Suppose we have a floor made of parallel strips of wood, 
each the same width, and we drop a needle onto the floor. 
What is the probability that the needle will lie across 
a line between two strips?"
								Jean Louis Leclerc, Comte de Buffon (1777).

Buffon's needle was the earliest problem in geometric probability 
to be solved.  The solution, in the case where the needle length
is not greater than the width of the strips, is used here as 
a Monte Carlo method for approximating the number Pi.
You can set the number of parallel lines per image and choose 
between preset numbers of needles thrown.

After needles and line grid are generated you will need to use [Multipoint Tool]
(already selected by macro) to click on intersections between needles and a
set of parallel lines.
Macro will wait for you to finish selection and click [OK] button.

Parameters such as probability of a needle hitting parallel line, needle length, 
distance between parallel lines and Pi value are presented in separate window 
"Buffon's needles". It allows comparing calculated and estimated values.
 
Version: 1.0
Date: 03/11/2018
Author: Aleksandr Mironov amj-box@mail.ru
*/ 

requires("1.52i");

//help
html = "<html>"
	+"<h1><font color=navy>Buffon's needle problem interactive solution, v1.0</h1>"
	+"<font color=purple><i><b>Suppose we have a floor made of parallel strips of wood,<br>" 
	+"each the same width, and we drop a needle onto the floor.<br>" 
	+"What is the probability that the needle will lie across<br>"
	+"a line between two strips?</b><br>"
	+"____________________________Jean Louis Leclerc, Comte de Buffon (1777)</i><br><br>"
	+"<font color=black>Buffon's needle was the earliest problem in geometric probability<br>" 
	+"to be solved.  The solution, in the case where the needle length<br>"
	+"is not greater than the width of the strips, is used here as<br>"
	+"a Monte Carlo method for approximating the number Pi.<br><br>"
	+"You can set the number of parallel lines per image and choose<br>"
	+"between preset numbers of needles thrown.<br><br>"
	+"<b>After needles and line grid are generated you will need to use <u>[Multipoint Tool]</u><br>"
	+"(already selected by macro) to click on intersections between needles and<br>"
	+"a set of parallel lines.<br><br>"
	+"Macro will wait for you to finish selection and click [OK] button.</b><br><br>"
	+"<font color=green>Parameters such as probability of a needle hitting parallel line, needle length,<br>"
	+"distance between parallel lines and Pi value are presented in separate window<br>"
	+"[Buffon's needles]. It allows comparing <u>calculated and estimated values.</u><br>"


Dialog.create("Buffon's needles, ver. 1.0"); 
Dialog.addNumber("Number of parallel lines", 12, 0, 4, "per image");
Dialog.addChoice("Number of needles per image", newArray(50, 1, 10, 20, 100, 200, 500, 1000));
Dialog.addHelp(html);
Dialog.show();

newImage("New", "8-bit black", 1024, 1024, 1);
getDimensions(width, height, channels, slices, frames);

//lines parameters
LinesNumber = Dialog.getNumber();;
T = height/LinesNumber;
setLineWidth(1);
setColor("green");

//Draw lines
for (y=T; y<height; y+=T) {
     Overlay.drawLine(0, y, width, y);
  }
  Overlay.show;

//Needle parameters
NdlNumber = Dialog.getChoice();
NdlColor = "red";
NdlWidth = 5;
NdlLength = T*3/4;

//Needle throw
for (i=0; i<NdlNumber; i++) {
	ThrowNeedle(width, height, T, NdlWidth, NdlColor, NdlLength);
}

//Count intersections and estimates
setTool("multipoint");
run("Point Tool...", "type=Hybrid color=Yellow size=Large label counter=0");
waitForUser("Use MultiPoint Tool (currently set) to count intersections between needles and lines."+"\nThen, click OK.");
run("Measure");
I = nResults;
ClickCheck = getResult("Area");
close("Results");
L = PI*I*T/NdlNumber/2;
Pi = 2*NdlLength*NdlNumber/T/I;
Prob = 100*2*NdlLength/PI/T;
EstProb = 100*I/NdlNumber;
EstT = 2*NdlLength*NdlNumber/PI/I;

//Display results
window = isOpen("Buffon's needles"); 
title = "[Buffon's needles]"; 
if (window == false){  
	run("Text Window...", "name="+ title +"width=80 height=16 menu"); 
	setLocation(0, 0); 
	};

if (ClickCheck==width*height) {
	print(title, "\nNo counting events detected.\n\nPlease, restart the macro and use Mutli-point Tool \nto count intersections between needles and lines.");
} else {
print(title, "\nCalculated probability of needle hitting parallel lines = "+round(Prob)+"%");
print(title, "\nEstimated probabilty of needle hitting parallel lines = "+round(EstProb)+"%");
print(title, "\nDistance set between parallel lines = "+round(T));
print(title, "\nEstimated distance between parallel lines = "+round(EstT));
print(title, "\nNeedle length setting = "+NdlLength);
print(title, "\nNeedle length estimate = "+round(L));
print(title, "\nNumber of needle intersections with lines = "+I);
print(title, "\nTotal number of needles thrown = "+NdlNumber);
print(title, "\nPi estimate = "+Pi);
print(title, "\nPi = "+PI);
print(title, "\n _______________________\n");
//}

function ThrowNeedle(width, height, T, NdlWidth, NdlColor, NdlLength) {
      	
		//Initial random coordinates
		x1 = round(random*(width-1));
		y1 = round(random*(height-1));

		//Needle random angle
		angle = 2*PI*random;

		//Needle traingle legs
		leg1 = round(NdlLength*cos(angle));
		leg2 = round(NdlLength*sin(angle));

		//Guarding against hitting image edges
		if (x1 < NdlLength){
			leg1 = abs(leg1);
		} 
		if(x1 > (width-NdlLength)) {
			leg1 = -abs(leg1);
		} 
		if(y1 < NdlLength) {
			leg2 = abs(leg2);
		} 
		if(y1 > (height-NdlLength)) {
			leg2 = -abs(leg2);
		}

		//Needle end coordinates
		x2 = x1 + leg1;
		y2 = y1 + leg2;

		//Creating a needle
		setLineWidth(NdlWidth);
		setColor(NdlColor);
		Overlay.drawLine(x1, y1, x2, y2);
		Overlay.show;
}
