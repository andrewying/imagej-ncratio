/*
ImageJ N:C Ratio Calculator
Copyright (C) 2017 Anfrew Ying.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

requires("1.30k");

var radius = 15;
var c = 0;
var count = 0;
var mode = "Manual";
var area = newArray(3);
var mean = newArray(3);

macro "Initiate N:C Measurement Tool [o]" {
	Dialog.create("N:C Ratio Measurement Tool");
	Dialog.addMessage("This tool automatically creates an oval of a fixed\n"
		+ "size to the center of the selection.\nTo stop this tool, "
		+ "press [e]\n \n(c) Andrew Ying 2017.");
	Dialog.addNumber("Oval Diameter (px):", 15);
	Dialog.addChoice("Mode of Measurement:", newArray("Manual", "Automated"),
		"Manual");
	Dialog.show();
	
	radius = Dialog.getNumber();
	mode = Dialog.getChoice();
	
	if (mode == "Manual") {
		waitForUser("N:C Ratio Measurement Tool", 
			"Now, make your first set of selection using the selection "
			+ "tool,\nholding [shift] in between. Select the background" 
			+ " first, then\nthe cytoplasm and finally the nucleus. Press"
			+ " [m] to measure.");
	}
	
	if (mode == "Automated") {
		waitForUser("N:C Ratio Measurement Tool", 
			"Now, make your selection using the selection tool. Select the" 
			+ " background\nfirst, then the cytoplasm and finally the nucleus. Measurement will be made for every 3 selections. \n"
			+ "If you made a mistake, press [r] to reset. Press [E] when you are done.");
			
		c = 1;
		count = 0;
		waitForUser("N:C Ratio Measurement Tool", "Please select the "
			+ "first point.");
		run("Text Window...", "name=[Selection] width=15 height=4");
		print("[Selection]", "Background\nReset - [r]");
		
		xLog = 0;
		yLog = 0;
		sliceLog = 0;
		
		while (c == 1) {
			getSelectionCoordinates(x, y);
			
			slice = getSliceNumber();
			
			if (xLog != x[0] || yLog != y[0]) {
				run("Specify...", "width=" + radius + " height=" + radius 
					+ " x=" + x[0] + " y=" + y[0] + " slice=" + slice 
					+ " oval centered constrain");
				getStatistics(area[count], mean[count]);
				
				getSelectionCoordinates(x, y);
				xLog = x[0];
				yLog = y[0];
				count++;
				
				if (count % 3 == 0) {
					row = nResults;
					setResult("Slice", row, slice);
					setResult("Cytoplasmic Signal", row, mean[1] - mean[0]);
					setResult("Nuclear Signal", row, mean[2] - mean[0]);
					setResult("N:C Ratio", row, (mean[2] - mean[0]) / (mean[1] - mean[0]));
					updateResults();
					
					count = 0;
					print("[Selection]", "\\Update:Background\nReset - [r]");
				}
				else {
					if (count == 1) {
						print("[Selection]", "\\Update:Cytoplasm\nReset -"
						+ " [r]");
					}
					if (count == 2) {
						print("[Selection]", "\\Update:Nucleus\nReset -"
						+ " [r]");
					}
				}
			}
			
			wait(100);
		}
	}
}

macro "Make Measurement [m]" {
	getSelectionCoordinates(x, y);
	slice = getSliceNumber();
	
	while (x.length != 3) {
		waitForUser("N:C Ratio Measurement Tool",
			"You must select three points before this tool can calculate\n"
			+ "the cytoplasmic to nuclear ratio.");
	}
	
	for (i = 0; i < 3; i++) {
		run("Specify...", "width=" + radius + " height=" + radius + " x=" 
			+ x[i] + " y=" + y[i] + " slice=" 
			+ slice + " oval centered constrain");
		getStatistics(area[i], mean[i]);
	}
	
	row = nResults;
	setResult("Slice", row, slice);
	setResult("Cytoplasmic Signal", row, mean[1] - mean[0]);
	setResult("Nuclear Signal", row, mean[2] - mean[0]);
	setResult("N:C Ratio", row, (mean[2] - mean[0]) / (mean[1] - mean[0]));
	updateResults();
}

macro "Clear Counter [r]" {
	count = 0;
	print("[Selection]", "\\Update:Background\nReset - [r]");
}

macro "Stop Macro [E]" {
	c = 0;
}
