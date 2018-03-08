# G-AthArt-PrinceKopp-DeVol
Derek and Eli's DTW Project

### Goals
* The goal of this project was to train a dynamic time warping algorithm to be able to anaylyze a drummers stroke. The program uses dynamic time warping to analyze the stroke from start to finish and looks for symetry between each stroke. The model is first trained by giving it an example of a perfect stroke with both the left and right hand. It then compares all of the future strokes to these "ideal" strokes in order to tell the user weather or not their stroke pattern is the same every time. This is coupled with a beat track for the user to play along with, as the program is not analyzing the timing of the stroke, only the path and speed at which the stroke is made. After each stroke, a message is displayed indicating the quality of the stroke as well as which hand it was played with. If a series of unsymetrical strokes is played, the program adds a loud cowbell to the beat track, letting the user know they need to clean up their strokes. 

### Tools/Libraries
* Micro:Bit
* Processing.sound
* Processing.serial
* oscP5

### Feature Extraction
* We modified Rebecca Fiebrink's Micro:bit extraction Processing sketch to gather serial data from two ports and package it into OSC to be sent wherever you please. More specifically we are sending the three (x, y, z) accelerometer values from each microbit in this package to be analyzed by the Wekinator dynamic time warping algorithm. We also maintained the processing GUI and expanded it to have multiple drop-down menus, though it does not error check serial port handling.
* We also found that it was best to have our processing sketch check for the most recent OSC message multiple times a second in order to keep the output up to date. This is because the DTW algorithm only sends a message when a new gesture is recognized so without this check, the user feedback was rather unresponsive.
* The features sent over OSC were the 3-axis accelereometer values represented as floats (as that is what Wekinator is partial to). 
* We sent the values through Input helper so that we could monitor their values as well as utilize buttons to segment features. Unfortunately, this did not have as much of an effect as we had hoped so we abandoned it as it was an awkward feeling to both press a button an loosely hold the micro:bit.
* In addition to this, we tried down-sampling the data rate through Input Helper (as the micro:bit sends them at very short intervals) since Wekinator was over-fitting the inputs to the DTW model gestures and was flicking quickly between the gestures. This was not a problem that could be fixed with a threshold but wiuth better feature segmenting and definition.
* One issue we ran into was the fact that Wekinator only sends values when the gesture changes. This was only a problem because we had a timer built into our Processing code that would check how often it perceived the user as "wrong" in a given time interval. We went around this by implementing a first-order hold filter and checking the values with that of the gestures matched with "wrong." It would then increment a counter that is checked at an interval (like a reverse watchdog timer) to check the percentage of wrong to right gestures in the last interval.
* (The intervals were measured with a delay value and `millis()`)

### ML Algorithms Used/Tested
* For this project, the algorithm of dynamic time warping was used as the goal was to be able to recognize gestures, and this is the only algorithm capable of doing so.
* As touched on in the previous section, we played around with downsampling and other parameters to try to get the fit to a place where we could detect between an on stroke and a missed stroke but found that the misses were more prone to mapping to inputs when we modified the parameters and so ultimately reverted to the default settings.

### Possible Improvements
* Running two DTW models, one for each hand, in parallel then I think we could get a much bettter model for on and off strokes. This ordinarily wouldn't be an issue but the Wekinator DTW project has no way of disconnecting inputs from gestures. So the data for both hands is always linked and creates a weird training dilemma. 
* Another nice improvement to this program would be the addition of a seperate regression algorithm which can indicate to the user how in time they are playing with respect to the beat track. This would make the program more robust in being able to analyze all important aspects of a good snare role. 



### Demo Video
* [Video](https://www.youtube.com/watch?v=tAD6arDl2us)
