/*
	ImageJ Multi Measurement
	Copyright (C) 2017-2018 Anfrew Ying.

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
var channels = 1;
var samples = 1;
var c = 0;
var count = 0;
var mode = "Manual";
var area = newArray(3);
var mean = newArray(3);

macro "Initiate Multi Measurement Tool [o]" {
	Stack.getDimensions(w, h, channels, s, f);
	
	Dialog.create("Multi Measurement Tool");
	Dialog.addMessage("This tool automatically creates an oval of a fixed\n"
		+ "size to the center of the selection.\nTo stop this tool, "
		+ "press [e]\n \n(c) Andrew Ying 2017.");
	Dialog.addNumber("Oval Diameter (px):", 15);
	Dialog.addChoice("Mode of Measurement:", newArray("Manual", "Automated"),
		"Manual");
	Dialog.addNumber("Number of Samples:", 1);
	Dialog.addMessage("Number of Channels:\t" + channels)
	Dialog.show();
	
	radius = Dialog.getNumber();
	mode = Dialog.getChoice();
	samples = Dialog.getNumber();
	
	area = newArray(samples * channels + 1);
	mean = newArray(samples * channels + 1);
	
	if (mode == "Manual") {
		waitForUser("Multi Measurement Tool", 
			"Now, make your first set of selection using the " 
			+ "selection tool,\nholding [shift] in between. Select " 
			+ "the objects first, then\nthe background. Press [m] to"
			+ " measure.");
	}
	
	if (mode == "Automated") {
		waitForUser("Multi Measurement Tool", 
			"Now, make your selection using the selection tool. Select the" 
			+ " objects\nfirst, then the background. Measurement will be made" + " for every " + (samples + 1) + " selections. \n"
			+ "If you made a mistake, press [r] to reset. Press [E] when you "
			+ "are done.");
			
		c = 1;
		count = 1;
		waitForUser("Multi Measurement Tool", "Please select the "
			+ "first point.");
		run("Text Window...", "name=[Selection] width=15 height=4");
		print("[Selection]", "Object\nReset - [r]");
		
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
					
				for (channel = 1; channel <= channels; channel++) {
					Stack.setChannel(channel);
					getStatistics(area[(count - 1) * (samples - 1) + channel], mean[(count - 1) * (samples - 1) + channel]);
				}
				Stack.setChannel(1);
				
				getSelectionCoordinates(x, y);
				xLog = x[0];
				yLog = y[0];
				count++;
				
				if ((count - 1) % (samples + 1) == 0) {
					for (channel = 1; channel <= channels; channel++) {
						row = nResults;
						setResult("Slice", row, slice);
						setResult("Channel", row, channel);
						for (object = 1; object < samples, object++) {
							setResult("Object " + object + " Signal", row, mean[(object - 1) * (samples - 1) + channel] - mean[(samples - 1) * (samples - 1) + channel]);
						}
						setResult("Background", row, mean[(samples - 1) * (samples - 1) + channel]);
						updateResults();
					}
					
					count = 1;
					print("[Selection]", "\\Update:Object\nReset - [r]");
				}
				else {
					if (count == (samples + 1)) {
						print("[Selection]", "\\Update:Background\nReset -"
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
	
	while (x.length < 2) {
		waitForUser("Multi Measurement Tool",
			"You must select at least 2 points before this tool can calculate\n"
			+ "the object signal(s).");
		getSelectionCoordinates(x, y);
	}
	
	area = newArray(x.length * channels + 1);
	mean = newArray(x.length * channels + 1);
	
	for (i = 0; i < x.length; i++) {
		run("Specify...", "width=" + radius + " height=" + radius + " x=" 
			+ x[i] + " y=" + y[i] + " slice=" 
			+ slice + " oval centered constrain");
			
		for (channel = 1; channel < channels; channel++) {
			Stack.setChannel(channel);
			getStatistics(area[i * (x.length - 1) + channel], mean[i * (x.length - 1) + channel]);
		}
		Stack.setChannel(1);
	}
	
	for (channel = 1; channel <= channels; channel++) {
		row = nResults;
		setResult("Slice", row, slice);
		setResult("Channel", row, channel);
		for (object = 1; object < x.length; object++) {
			setResult("Object " + object + " Signal", row, mean[(object - 1) * (x.length - 1) + channel] - mean[(x.length - 1) * (x.length - 1) + channel]);
		}
		setResult("Background", row, mean[(x.length - 1) * (x.length - 1) + channel]);
		updateResults();
	}
}

macro "Clear Counter [r]" {
	count = 1;
	print("[Selection]", "\\Update:Background\nReset - [r]");
}

macro "Stop Macro [E]" {
	c = 0;
}
