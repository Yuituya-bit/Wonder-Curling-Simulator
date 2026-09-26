import processing.serial.*;
String val = "0";

//Arduino
  /*Serial myPort;
  int val, reserve = 0;
  int signal1;*/

void setup(){
  fullScreen();
  //String portName = Serial.list()[0];
  //myPort = new Serial(this, portName, 38400);
  textSize(200);
  textAlign(CENTER, CENTER);
}

void draw(){
  background(255);
  //val = myPort.read(); 
  fill(0);
  text(float(val), width/2, height/2);
}
