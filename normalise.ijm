/*
	ImageJ Normalise
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

var radius = 40;
var x = 0;
var y = 0;

macro "Set-up tool [b]" {
    getSelectionCoordinates(xSe, ySe);
    
    while (xSe.length != 1) {
		waitForUser("Normalisation Tool",
			"You must select 1 point for the basis of normalisation only.");
        getSelectionCoordinates(xSe, ySe);
	}
    
    x = xSe[0];
    y = ySe[0];
    
    waitForUser("Normalisation Tool", "Set up successful.");
}

macro "Normalise [n]" {
    title = getTitle();
    run("Duplicate...", "title=" + title + "-norm duplicate");
    for (i = 1; i <= nSlices; i++) {
        setSlice(i);
        run("Specify...", "width=" + radius + " height=" + radius + " x=" 
			+ x + " y=" + y + " slice=" 
			+ i + " oval centered constrain");
        getStatistics(area, mean);
        run("Divide...", "value=" + mean + " slice");
    }
    setSlice(1);
    run("Enhance Contrast", "saturated=0.35");
}