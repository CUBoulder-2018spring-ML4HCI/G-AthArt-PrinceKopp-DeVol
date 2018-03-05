// This demo triggers a text display with each new message
// Works with DTW
// Set number of DTW gestures and their namesBelow

//Necessary for OSC communication with Wekinator:
import oscP5.*;
import netP5.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import processing.sound.*;
SoundFile file;
SoundFile file2;
OscP5 oscP5;
NetAddress dest;

String[] messageNames = {"/on_left", "/on_right", "/missed_left", "/missed_right" }; //message names for each DTW gesture type
//String[] messageNames = {"/outputs_1", "/outputs_2", "/outputs_3", "/outputs_4" }; //message names for each DTW gesture type

//No need to edit:
PFont myFont, myBigFont;
final int myHeight = 400;
final int myWidth = 400;
int frameNum = 0;
int[] hues;
int[] textHues;
int numClasses;
int currentHue = 100;
int currentTextHue = 255;
String currentMessage = "Waiting...";
float amp = 0.0;
int misses;
int now, delay, delayCounter;
int lastMessage;
boolean grabbedMessage;

Minim       minim;
AudioOutput out;
Oscil       wave;

void setup() {
  colorMode(HSB);
  size(400,400, P3D);
  smooth();
  numClasses = messageNames.length;
  hues = new int[numClasses];
  textHues = new int[numClasses];
  for (int i = 0; i < numClasses; i++) {
     hues[i] = (int)generateColor(i); 
     textHues[i] = (int)generateColor(i+1);
  }
  file = new SoundFile(this, "20 Minute Backing Track - Hard Rock Drum Beat 90 BPM.mp3");
  file2 = new SoundFile(this, "cowbell.wav");
  file.play();
  
  now = millis();
  delay = 100;
  lastMessage = -1;
  grabbedMessage = false;
  
  //Initialize OSC communication
  oscP5 = new OscP5(this,12000); //listen for OSC messages on port 12000 (Wekinator default)
  dest = new NetAddress("127.0.0.1",6448); //send messages back to Wekinator on port 6448, localhost (this machine) (default)
  
  
  String typeTag = "f";
  for (int i = 1; i < numClasses; i++) {
    typeTag += "f";
  }
  //myFont = loadFont("SansSerif-14.vlw");
  myFont = createFont("Arial", 14);
  myBigFont = createFont("Arial", 60);
}

void draw() {
  frameRate(30);
  background(currentHue, 255, 255);
  drawText();
  
  if(millis() - now > delay){
    if (delayCounter > 49){ 
      if (misses>4) {
 
      file2.play();
      }
      
      misses = 0;
      delayCounter = 0;
    
    }
    if (lastMessage > 1 && !grabbedMessage){
      misses++;
    }
    grabbedMessage = false;
    delayCounter++;
  }

}

//This is called automatically when OSC message is received
void oscEvent(OscMessage theOscMessage) {
 for (int i = 0; i < numClasses; i++) {
    if (theOscMessage.checkAddrPattern(messageNames[i]) == true) {
     // println("received1");
       showMessage(i);
       grabbedMessage = true;
       lastMessage = i;
       if (i > 1) {
         println(i);
         misses++;
       }
    }
 }
}

void showMessage(int i) {
    currentHue = hues[i];
    currentTextHue = textHues[i];
    currentMessage = messageNames[i];
    
}

//Write instructions to screen.
void drawText() {
    stroke(0);
    textFont(myFont);
    textAlign(LEFT, TOP); 
    fill(currentTextHue, 255, 255);

    text("Receives DTW messages from wekinator", 10, 10);
    text("Listening for " + numClasses + " DTW triggers:", 10, 30);
    for (int i= 0; i < messageNames.length; i++) {
       text("     " + messageNames[i], 10, 47+17*i); 
    }
    textFont(myBigFont);
    text(currentMessage, 20, 180);
}


float generateColor(int which) {
  int i = which;
  if (i <= 0) {
     return 100;
  } 
  else {
     return (generateColor(which-1) + 1.61*255) %255; 
  }
}