//Sends BBC micro:bit to OSC
//By Rebecca Fiebrink: January 2016

//Sends to port 6448 using OSC message /wek/inputs
//Number of features varies according to feature selection in user drop-down (more info on screen)

import processing.serial.*;
import controlP5.*;
import java.util.*;
import oscP5.*;
import netP5.*;

//Objects for display:
ControlP5 cp5;
PFont fBig;
CColor defaultColor;

//For parsing serial data.
//Expected format: ID b1 b2 a1 a2 a3 (tab-delineated, \n at end)\
int field = 0;
int val = 0;

//I juts want a struct, mmmkay?
public class OSCData {
  public int a1 = 0;
  public int a2 = 0;
  public int a3 = 0;
  public int a1s = 1;
  public int a2s = 1;
  public int a3s = 1;
  public int b1 = 0;
  public int b2 = 0;
  public int finala1 = 0;
  public int finala2 = 0;
  public int finala3 = 0;
}

OSCData oscData1;
OSCData oscData2;

//Serial port info:
int numPorts = 0;
Serial myPort1;  // The serial port
Serial myPort2;
boolean gettingData1 = false; //True if we've selected a port to read from
boolean gettingData2 = false;

//Objects for sending OSC
OscP5 oscP5;
NetAddress dest;

//Feature mode: -1 = not set up; 0 = accelerometers only; 1 = button-segemented accelerometer; 2 = buttons & accelerometers
int featureMode = -1; 

//For buffering & downsampling in button-segment mode:
//500 is the hard-coded maximum data length here (i.e., ignore any sensor samples after 500 have been collected, even if button is still down)
int[] a1list = new int[500];
int a1len = 0;
int[] a2list = new int[500];
int[] a3list = new int[500];
int[] a1_20 = new int[20];
int[] a2_20 = new int[20];
int[] a3_20 = new int[20];

void setup() {
  size(300, 400);
  frameRate(100);

  //Set up display
  cp5 = new ControlP5(this);
  textAlign(LEFT, CENTER);
  fBig = createFont("Arial", 12);

  //Populate serial port options:
  List ls1 = Arrays.asList(Serial.list());
  numPorts = ls1.size();
  cp5.addScrollableList("PortA") //Create drop-down menu (list serial 1)
     .setPosition(10, 60)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(ls1)
     ;
     
   List ls2 = Arrays.asList(Serial.list());
   cp5.addScrollableList("PortB") //Create drop-down menu (list serial 2)
     .setPosition(10, 180)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(ls2)
     ;
  defaultColor = cp5.getColor();
  
  //Feature drop-down options:
  List l2 = Arrays.asList("Raw accelerometer values", "Button-segmented shapes", "Raw buttons & accelerometers");
  cp5.addScrollableList("Features")
     .setPosition(10, 300)
     .setSize(200, 100)
     .setBarHeight(20)
     .setItemHeight(20)
     .addItems(l2)
     ;
     
  //Set up OSC:
  oscP5 = new OscP5(this,9000);
  dest = new NetAddress("127.0.0.1",6448);
  
  //OSC Data chunks
  oscData1 = new OSCData();
  oscData2 = new OSCData();
}

//Called when new features type selected in drop-down
void Features(int n) {
  featureMode = n;
  println("Selected feature type: " + n);
  if (featureMode == 1) { //button-segmented 
    a1len = 0;
  }
}

//Called when new port (n-th) selected in drop-down
void PortA(int n) {
  println(n, cp5.get(ScrollableList.class, "PortA").getItem(n));
  CColor c = new CColor();
  c.setBackground(color(255,0,0));
  
  //Color all non-selected ports the default color in drop-down list
  for (int i = 0; i < numPorts; i++) {
      cp5.get(ScrollableList.class, "PortA").getItem(i).put("color", defaultColor);
  }
  
  //Color the selected item red in drop-down list
  cp5.get(ScrollableList.class, "PortA").getItem(n).put("color", c);
  
  //If we were previously receiving on a port, stop receiving
  if (gettingData1) {
    myPort1.stop();
  }
  
  //Finally, select new port:
  myPort1 = new Serial(this, Serial.list()[n], 115200);
  gettingData1 = true;
}
//Called when new port (n-th) selected in drop-down
void PortB(int n) {
  println(n, cp5.get(ScrollableList.class, "PortB").getItem(n));
  CColor c = new CColor();
  c.setBackground(color(255,0,0));
  
  //Color all non-selected ports the default color in drop-down list
  for (int i = 0; i < numPorts; i++) {
      cp5.get(ScrollableList.class, "PortB").getItem(i).put("color", defaultColor);
  }
  
  //Color the selected item red in drop-down list
  cp5.get(ScrollableList.class, "PortB").getItem(n).put("color", c);
  
  //If we were previously receiving on a port, stop receiving
  if (gettingData2) {
    myPort2.stop();
  }
  
  //Finally, select new port:
  myPort2 = new Serial(this, Serial.list()[n], 115200);
  gettingData2 = true;
}

//Called in a loop at frame rate (100 Hz)
void draw() {
  background(240);
  textFont(fBig);
  fill(0);
  text("micro:bit to OSC by Rebecca Fiebrink", 10, 10);
  text("(expanded by Derek Prince)", 120, 25);
  
  text("Select serial port:", 10, 40);
  text("Accelerometers: " + oscData1.finala1, 10, 100);
  text(oscData1.finala2, 150, 100);
  text(oscData1.finala3, 200, 100);
  text("Buttons: " + oscData1.b1 + " " + oscData1.b2, 10, 120);
  
  text("Select serial port:", 10, 170);
  text("Accelerometers: " + oscData2.finala1, 10, 220);
  text(oscData2.finala2, 150, 220);
  text(oscData2.finala3, 200, 220);
  text("Buttons: " + oscData2.b1 + " " + oscData2.b2, 10, 240);
  
  text("Select features:", 10, 290); 
  if (featureMode == 0) {
     text("Sending 3 values to port 6448, message /wek/inputs", 10, 340); 
  } else if (featureMode == 1) {
    text("Sending 60 values to port 6448, message /wek/inputs\nUsing button 1 to segment", 10, 340);
  } else if (featureMode == 2) {
    text("Sending 10 values to port 6448, message /wek/inputs", 10, 340); 
  }

  if (gettingData1) {
    getData(myPort1, oscData1);
  }
  if (gettingData2) {
    getData(myPort2, oscData2);
  }
}

//Parses serial data to get button & accel values, also buffers accels if we're in button-segmented mode
void getData(Serial myPort, OSCData oscData) {
  while (myPort.available() > 0 ) {
    char inByte = (char)myPort.read();
    if ((int)inByte <= 57 && (int)inByte >= 48){
       if (field == 1) { //BUTTON 1
         int oldB1 = oscData.b1;
         oscData.b1 = (int)inByte - 48;
         
         //Are we in button-segmented mode, and have we started or stopped a segment?
         if (featureMode == 1 && oldB1 != oscData.b1) {
            if (oscData.b1 == 1) {
               //Button down
               startSegment(); 
            } else {
               //Button up
               endSegment(); 
            }
         }
         
       } else if (field == 2) { // BUTTON 2
         oscData.b2 = (int)inByte - 48;
       } else if (field == 3) { // ACCELEROMETER 1
         oscData.a1 = 10 * oscData.a1 + ((int)inByte - 48);
       } else if (field == 4) { // ACCELEROMETER 2
          oscData.a2 = 10 * oscData.a2 + ((int)inByte - 48);
       } else if (field == 5) { //ACCELEROMETER 3
          oscData.a3 = 10 * oscData.a3 + ((int)inByte - 48);
       } 
    }else if (inByte == '\n') { //End of line: do something with this data
       oscData.a3 = oscData.a3s * oscData.a3;
       oscData.finala1 = oscData.a1;
       oscData.finala2 = oscData.a2;
       oscData.finala3 = oscData.a3;
      //println("Last a1=" + a1 + ", last a2=" + a2 + ", last a3=" + a3);
      if (featureMode == 0 || featureMode == 2) {
        sendOsc();
      } else if (featureMode == 1) {
         addVals(oscData.finala1, oscData.finala2, oscData.finala3); 
      }
      field = 0;
      val = 0;
      oscData.a1 = 0;
      oscData.a2 = 0; 
      oscData.a3 = 0;
      oscData.a1s = 1;
      oscData.a2s = 1;
      oscData.a3s = 1;
    } else if (inByte == '\t') {
      if (field == 3) {
         oscData.a1 = oscData.a1s * oscData.a1; 
      } else if (field == 4) {
        oscData.a2 = oscData.a2s * oscData.a2;
      }
      field++;
      val = 0;
    } else if (inByte == '-') {
      if (field == 3) {
        oscData.a1s = -1;
      } else if (field == 4) {
        oscData.a2s = -1;
      } else if (field == 5) {
        oscData.a3s = -1;
      }
    } 
  }
}

void sendOsc() {
  OscMessage msg = new OscMessage("/wek/inputs");
  //println("FeatureMode = " + featureMode);
  if (featureMode == 0) { //Accelerometers only
    msg.add(float(oscData1.finala1)); 
    msg.add(float(oscData1.finala2)); 
    msg.add(float(oscData1.finala3)); 
    msg.add(float(oscData2.finala1)); 
    msg.add(float(oscData2.finala2)); 
    msg.add(float(oscData2.finala3)); 
    oscP5.send(msg, dest);
  } else if (featureMode == 2) { //Buttons & accelerometers
    msg.add(float(oscData1.b1));
    msg.add(float(oscData1.b2));
    msg.add(float(oscData1.finala1)); 
    msg.add(float(oscData1.finala2)); 
    msg.add(float(oscData1.finala3)); 
    msg.add(float(oscData2.b1));
    msg.add(float(oscData2.b2));
    msg.add(float(oscData2.finala1)); 
    msg.add(float(oscData2.finala2)); 
    msg.add(float(oscData2.finala3)); 
    oscP5.send(msg, dest);
    //println("Sent");
  }
}

void startSegment() {
  a1len = 0;
}

void endSegment() {  
  if (a1len == 0) {
    return;
  }
  
  if (a1len <= 20) {
     int i = 0; 
     while (i < a1len) {
         a1_20[i] = a1list[i];
         a2_20[i] = a2list[i];
         a3_20[i] = a3list[i];
         i++;
     } 
     while (i < 20) {
         a1_20[i] = a1list[a1len-1];
         a2_20[i] = a2list[a1len-1];
         a3_20[i] = a3list[a1len-1];

         i++;
     }
  } else {
      int factor = a1len/20;
      for (int i = 0; i < 20; i++) {
         a1_20[i] = a1list[i*factor]; 
         a2_20[i] = a2list[i*factor]; 
         a3_20[i] = a3list[i*factor]; 

      }
      OscMessage msg = new OscMessage("/wek/inputs");
      for (int i = 0; i < 20; i++) {
         msg.add(float(a1_20[i]));  
      }
       for (int i = 0; i < 20; i++) {
         msg.add(float(a2_20[i]));  
      }
             for (int i = 0; i < 20; i++) {
         msg.add(float(a3_20[i]));  
      }
      
      oscP5.send(msg, dest);

  }
}

void addVals(int finala1, int finala2, int finala3) {
    if (a1len < 500) {
       a1list[a1len] = finala1;
       a2list[a1len] = finala2;
       a3list[a1len] = finala3; 
       a1len++;
    }
} 