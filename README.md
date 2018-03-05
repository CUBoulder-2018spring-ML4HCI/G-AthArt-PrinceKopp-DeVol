# G-AthArt-PrinceKopp-DeVol
Derek and Eli's DTW Project

### Goals
* The goal of this project was to train a dynamic time warping algorithm to be able to anaylyze a drummers stroke. The program uses dynamic time warping to analyze the stroke from start to finish and looks for symetry between each stroke. The model is first trained by giving it an example of a perfect stroke with both the left and right hand. It then compares all of the future strokes to these "ideal" strokes in order to tell the user weather or not their stroke pattern is the same every time. This is coupled with a beat track for the user to play along with, as the program is not analyzing the timing of the stroke, only the path and speed at which the stroke is made. After each stroke, a message is displayed indicating the quality of the stroke as well as which hand it was played with. If a series of unsymetrical strokes is played, the program adds a loud cowbell to the beat track, letting the user know they need to clean up their strokes. 

### Tools/Libraries
* Micro Bit
* Processing.sound
* 

### Feature Extraction
* 

### ML Algorithms Used/Tested

* For this project, the algorithm of dynamic time warping was used as the goal was to be able to recognize gestures, and this is the only algorithm is capable of doing so.




### Possible Improvements
* A nice improvement to this program would be the addition of a seperate regression algorithm which can indicate to the user how in time they are playing with respect to the beat track. This would make the program more robust in being able to analyze all important aspects of a good snare role. 


### Demo Video
* [Video](https://www.youtube.com/watch?v=tAD6arDl2us)
