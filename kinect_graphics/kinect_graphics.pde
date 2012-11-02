/*
Program to demonstrate gesture-based computing using a Microsoft Kinect
Created by Michael Kappeler and Andrew Ruether
Swarthmore College
October 2012
*/



import SimpleOpenNI.*;
SimpleOpenNI  kinect;

import rwmidi.*;

MidiOutput output;



// Mode 2 info
PImage key_blur;
PShape s;
boolean key1_was_active = false;
boolean key2_was_active = false;
boolean key3_was_active = false;
boolean key4_was_active = false;
boolean key5_was_active = false;
  
  
  
// Mode 3 info
PImage mode3_background;
PShape astro_head;
PShape astro_torso;
PShape astro_left_shoulder;
PShape astro_right_shoulder;
PShape astro_left_hand;
PShape astro_right_hand;
PShape astro_left_thigh;
PShape astro_right_thigh;
PShape astro_left_foot;
PShape astro_right_foot;


// * SETUP *
int window_size_x = 1280;
int window_size_y = 960;
float effect_button_scale = 0.2;
float mode_button_scale = 0.4;

Body body;
boolean kinect_enabled;

PShape on_button;
PShape off_button;
int sine_phase=0;

PFont font;

// Effect button
PShape effect_button1;
PShape effect_button2;
float effect_button_size;
float mode_button_size;
int time_entered_mode_button;
int time_entered_effect1_button;
boolean wasInEffect1Button;
boolean isInEffect1Button;
boolean effect1_switched;
int time_entered_effect2_button;
boolean wasInEffect2Button;
boolean isInEffect2Button;
boolean effect2_switched;
int mode = 0;
int number_of_modes = 3;
boolean isInModeButton = false;
boolean wasInModeButton = false;
boolean mode_switched = false;




// Pendulum set up
Pendulum p;
int time = 0; 
float pend_arm = 250.0f; //arm length
float mass = 1.0;
float G = 9.81;      // Arbitrary universal gravitational constant
float theta;       // Pendulum arm angle
float theta_vel;   // Angle velocity
float theta_acc;   // Angle acceleration
int yshiftpe, yshiftke;
float mpe, mke, tote, maxpe, maxke;  //variables associated with energy
int pause = 0;
float scaling = 0.05;
String typing = ""; //Variale to store text currently being typed



// SETUP //
void setup() {

  // Basic window setup
  size(window_size_x, window_size_y);
 
  // Connect to Kinect (if possible)
  // Assume Kinect is present
  // Disable Kinect if not present
  kinect_enabled  = true;
  try {
    kinect = new SimpleOpenNI(this);    
  } catch (Exception e){
    kinect_enabled  = false;
  }

  if (kinect.enableDepth() == false) {kinect_enabled=false;}

  println("Kinect status: " + kinect_enabled);
  
  if (kinect_enabled)
  {
    kinect.enableDepth();
    kinect.enableRGB();
    kinect.setMirror(true);
    kinect.alternativeViewPointDepthToImage(); // Line up RGB with depth
    
    // turn on user tracking
    kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL); 
  }


  // MIDI setup
  // creates a connection to IAC as an output
  output = RWMidi.getOutputDevices()[0].createOutput();  // talks to MIDI  



  // Mode and effect buttons
  // Images must be in the "data" directory to load correctly
  on_button = loadShape("on_button.svg");
  off_button = loadShape("off_button.svg");

  effect_button_size = on_button.width*effect_button_scale;
  mode_button_size = on_button.width*mode_button_scale;

  effect_button1 = off_button;
  effect_button2 = off_button;

  // Stuff for MODE 2
  s = loadShape("keycontrols.svg");
  key_blur = loadImage("blurred-keycontrols.png");

  astro_head = loadShape("head.svg");
  astro_torso = loadShape("torso.svg");
  astro_left_shoulder = loadShape("leftshoulder.svg");
  astro_right_shoulder = loadShape("rightshoulder.svg");
  astro_left_hand = loadShape("lefthand.svg");
  astro_right_hand = loadShape("righthand.svg");
  astro_left_thigh = loadShape("leftthigh.svg");
  astro_right_thigh = loadShape("rightthigh.svg");
  astro_left_foot = loadShape("leftfoot.svg");
  astro_right_foot = loadShape("rightfoot.svg");

  
  
  // Stuff for Mode 3 (pendulum)
  //p = new Pendulum(new PVector(width/2, 0), pend_arm); // Make a new Pendulum with an origin location and armlength
  mode3_background = loadImage("earthrise.jpg");
  
  
  // Fonts
  font = loadFont("OCRAStd-48.vlw");
  textFont(font);
  
  // Create new Body
  body = new Body();
  
  if (mode==0) {
     output.sendNoteOn(0, 2, 1);
  }
  
}









void draw() {

  PShape mode_button;

  // Get updated Kinect/simulated data
  body.update();

  background(0);
  shapeMode(CORNER);


  switch(mode) {

  case 0:  
     draw_mode1(); 
    break;

  case 1:
    // Keys
    draw_mode2();
    break;

  case 2: 
    draw_mode3();
    //p.go();
    //time++;
    break;
  }

  shapeMode(CORNER);
  // -----------------------------------
  // Effect buttons
  // -----------------------------------
  
  // Handle Effect Button 1
  /*
  if ( isInEffectButton1(body.rightHand.x, body.rightHand.y)) {
    effect_button1 = on_button;
  } else {
    effect_button1 = off_button;
  }  
  // Draw on or off effect button 1:
  shape(effect_button1, window_size_x - effect_button_size - 60, window_size_y - effect_button_size - 10, effect_button_size, effect_button_size);

  
  
  // Handle Effect button 2
  if ( isInEffectButton2(body.rightHand.x, body.rightHand.y)) {
    effect_button2 = on_button;
  } else {
    effect_button2 = off_button;
  }   
  // Draw on or off effect button 2:
  shape(effect_button2, window_size_x - effect_button_size - 100, window_size_y - effect_button_size - 200, effect_button_size, effect_button_size);
*/



  // -----------------------------------
  // Effect 1 button 
  // -----------------------------------
  if ( isInEffectButton1(body.rightHand.x, body.rightHand.y))
  {
    isInEffect1Button = true;
  } 
  else {
    isInEffect1Button = false;
  }


  if (!wasInEffect1Button && isInEffect1Button)
  {
    // Start the timer -- must be in mode button for at least 0.5 seconds before switching modes
    time_entered_effect1_button = millis();
  } 
  else if (isInEffect1Button && wasInEffect1Button && !effect1_switched)
  {
    // Have been sitting in mode button -- check to see if it is long enough to switch mode
    // If so, switch modes and note switch
    if ( (millis() - time_entered_effect1_button) > 200)
    {
 
       switch(mode) {
         
         case 0: // Mode 1
           output.sendNoteOn(11, 1, 1);
           break;
           
         case 1: // Mode 2
           output.sendNoteOn(7, 1, 1);
           break;
           
         case 2:  // Mode 3
            output.sendNoteOn(15, 1, 1);
            break;
       }
      println("Switched Mode 1");
      effect1_switched = true;
      
      if (effect_button1 == off_button){
        effect_button1 = on_button;
      } else {
        effect_button1 = off_button;
      }
      
    }
  } 
  else if (wasInEffect1Button && !isInEffect1Button)
  {
    // Just exited mode button
    effect1_switched = false;
  }


  wasInEffect1Button = isInEffect1Button;

   // Draw on or off effect button 1:
  shape(effect_button1, window_size_x - effect_button_size - 200, window_size_y - effect_button_size - 160, effect_button_size, effect_button_size);



  // -----------------------------------
  // Effect 2 button 
  // -----------------------------------
  if ( isInEffectButton2(body.rightHand.x, body.rightHand.y))
  {
    isInEffect2Button = true;
  } 
  else {
    isInEffect2Button = false;
  }
   // Draw on or off effect button 1:
   
 

  if (!wasInEffect2Button && isInEffect2Button)
  {
    // Start the timer -- must be in mode button for at least 0.5 seconds before switching modes
    time_entered_effect2_button = millis();
  } 
  else if (isInEffect2Button && wasInEffect2Button && !effect2_switched)
  {
    // Have been sitting in mode button -- check to see if it is long enough to switch mode
    // If so, switch modes and note switch
    if ( (millis() - time_entered_effect2_button) > 200) {
 
       switch(mode) {
         
         case 0: // Mode 1
           output.sendNoteOn(12, 1, 1);
           break;
           
         case 1: // Mode 2
           output.sendNoteOn(8, 1, 1);
           break;
           
         case 2:  // Mode 3
            output.sendNoteOn(15, 2, 1);
            break;
       }
      println("Switched Mode 2");
      effect2_switched = true;
      
      if (effect_button2 == off_button){
        effect_button2 = on_button;
      } else {
        effect_button2 = off_button;
      }
      
    }
  } 
  else if (wasInEffect2Button && !isInEffect2Button)
  {
    // Just exited mode button
    effect2_switched = false;
  }


  wasInEffect2Button = isInEffect2Button;
 shape(effect_button2, window_size_x - effect_button_size - 100, window_size_y - effect_button_size - 200, effect_button_size, effect_button_size);



  // -----------------------------------
  // Mode button 
  // -----------------------------------
  if ( isInModeButton(body.leftHand.x, body.leftHand.y))
  {
    mode_button = on_button;
    isInModeButton = true;
  } 
  else {
    mode_button = off_button;
    isInModeButton = false;
  }
  shape(mode_button, 100, window_size_y - mode_button_size - 100, mode_button_size, mode_button_size);


  if (!wasInModeButton && isInModeButton)
  {
    // Start the timer -- must be in mode button for at least 0.5 seconds before switching modes
    time_entered_mode_button = millis();
  } 
  else if (isInModeButton && wasInModeButton && !mode_switched)
  {
    // Have been sitting in mode button -- check to see if it is long enough to switch mode
    // If so, switch modes and note switch
    if ( (millis() - time_entered_mode_button) > 500)
    {
      mode = mode + 1; 
      if (mode >= number_of_modes) {
        mode = 0;
      }
      
      // Turn off any sounds
      output.sendNoteOn(0, 1, 1); 
      
      // If entering mode 0, turn on sounds
      if (mode==0)
      {
        output.sendNoteOn(0, 2, 1);
      } else if (mode == 2) {
         output.sendNoteOn(0, 3, 1); 
      }
      
      mode_switched = true;
    }
  } 
  else if (wasInModeButton && !isInModeButton)
  {
    // Just exited mode button
    mode_switched = false;
  }




  // Draw mode inside mode button (centered)
  textAlign(CENTER, CENTER); 
  textFont(font, 46);
  fill(255);
  text(str(mode+1), 100+mode_button_size/2, window_size_y - mode_button_size/2 - 100);   


  // -----------------------------------
  // End of Mode button
  // -----------------------------------



 // If kinect is active and tracking, show status
  if (kinect_enabled && (body.userList.size() > 0) && kinect.isTrackingSkeleton(body.userId)){  
      textAlign(RIGHT, TOP); 
      textFont(font, 16);
      fill(0, 255, 0);
      text("Tracking", 1270, 10);  
  }
 







  // Sine wave
  // For now, draw beteen effect button 1 and the mouse
  //shape(sine_wave, mouseX, mouseY,window_size_x - effect_button_size/2 - 60, window_size_y - effect_button_size/2 - 10);


  // Finish up 
  wasInModeButton = isInModeButton;
}





void draw_mode1() {
  
     // Skeleton control
  PImage mask;
  
  if (kinect_enabled) {
     //body.draw_pointCloud();
     
     // Get the depth data and use as a mask -- filter out everything more than 128
     body.depth.filter(THRESHOLD, 0.7);
     body.rgbImage.mask(body.depth);
     
     image(body.rgbImage, 0, 0, 1280, 960);
  }
     
    // Cicles on hands
    fill(255,0,0); 
    ellipse(body.leftHand.x, body.leftHand.y, 20, 20);
    fill(0,0,255);
    ellipse(body.rightHand.x, body.rightHand.y, 20, 20);
    float angle  = body.angle_between_hands();
 
    // Sine wave between hands
    pushMatrix();
    strokeWeight(6);
    stroke(223, 0, 255);
    translate(body.leftHand.x, body.leftHand.y);
    rotate(radians(angle));
    
    float last_x = 0;
    float last_y1 = 0;
    float last_y2 = 0;
    float y1 = 0;
    float y2;
    for (float x=0; x<body.distance_between_hands(); x=x+6)
    {
      y1 = 50*sin(sine_phase + 12 * PI* x /  body.distance_between_hands());
      y2 = -50*sin(sine_phase + 12 * PI* x /  body.distance_between_hands());
      line(x, y1, last_x, last_y1);
      line(x, y2, last_x, last_y2);
      
      last_x = x;
      last_y1 = y1;
      last_y2 = y2;
      
    }
    popMatrix();
    
    sine_phase += 1.5;
    
    // Data to display
    textAlign(LEFT, TOP); 
    textFont(font, 16);
    fill(0, 255, 0);
    text("Size: " + body.distance_between_hands() + "\nAngle: " + angle, 10, 10);   
  
    // MIDI output
    int hands_dist = min(int(map(body.distance_between_hands(), 0, 1000, 0, 127)), 127); 
    output.sendController(9, 1, hands_dist);  
 
   int hands_angle = min(int(map(max(angle+90,0), 0, 360, 0, 127)), 127); 
   output.sendController(10, 1, hands_dist);   
      

}






void draw_mode2()
{
  
  boolean key1_active = false;
  boolean key2_active = false;
  boolean key3_active = false;
  boolean key4_active = false;
  boolean key5_active = false;

 // If kinect is active, draw 3D image
  if (kinect_enabled) {
    
    if ((body.userList.size() <= 0) || !kinect.isTrackingSkeleton(body.userId)){   
       // Draw RGB image until calibrated
       image(body.rgbImage, 0,0,1280,960); 
    } else {
     //background 
      background(0);
  
  
  // Draw keys and blurred background
  //image(key_blur, -10, -40, 1300, 750);  // Blurred keys background
  shape(s,40,-5,1200,622);    // Keys
  
  // Draw hand location
  stroke(255, 0, 0);
  fill(255, 0, 0);
  ellipse(body.rightHand.x, body.rightHand.y, 20, 20);
  fill(0, 0, 255);
  ellipse(body.leftHand.x, body.leftHand.y, 20, 20);
  
  // Draw hand location info
  textAlign(LEFT, TOP); 
  textFont(font, 16);
  text("X: " + body.rightHand.x + "\nY: " + body.rightHand.y, 10, 10);   
  
   // Draw Skeleton
    strokeWeight(2);
    stroke(255,0,0);
    line(body.left_hand.x, body.left_hand.y, body.left_elbow.x, body.left_elbow.y);
    line(body.left_elbow.x, body.left_elbow.y, body.left_shoulder.x, body.left_shoulder.y);
    line(body.left_shoulder.x, body.left_shoulder.y, body.left_hip.x, body.left_hip.y);
    line(body.left_hip.x, body.left_hip.y, body.left_knee.x, body.left_knee.y);
    line(body.left_knee.x, body.left_knee.y, body.left_foot.x, body.left_foot.y);
    
    line(body.right_hand.x, body.right_hand.y, body.right_elbow.x, body.right_elbow.y);
    line(body.right_elbow.x, body.right_elbow.y, body.right_shoulder.x, body.right_shoulder.y);
    line(body.right_shoulder.x, body.right_shoulder.y, body.right_hip.x, body.right_hip.y);
    line(body.right_hip.x, body.right_hip.y, body.right_knee.x, body.right_knee.y);
    line(body.right_knee.x, body.right_knee.y, body.right_foot.x, body.right_foot.y);
    
    line(body.left_hip.x, body.left_hip.y, body.right_hip.x, body.right_hip.y);
    line(body.left_shoulder.x, body.left_shoulder.y,body.right_shoulder.x, body.right_shoulder.y);
    line(body.right_shoulder.x, body.right_shoulder.y, body.torso.x, body.torso.y);
    line(body.left_shoulder.x, body.left_shoulder.y, body.torso.x, body.torso.y);
    line(body.right_hip.x, body.right_hip.y, body.torso.x, body.torso.y);
    line(body.left_hip.x, body.left_hip.y, body.torso.x, body.torso.y);
    line(body.neck.x, body.neck.y, body.head.x, body.head.y);
 
 
   // Left ahnd
     // First make sure mouse is in top half of screen, then check to see if it overlaps with a key
   if (  (body.leftHand.y <=651) && (pow(((body.leftHand.x-640))/(595), 2) + pow((body.leftHand.y-651)/(616),2) <= 1) && (pow((body.leftHand.x-640)/(465), 2) + pow((body.leftHand.y-651)/(484),2) >= 1))
  { 
    PVector v1 = new PVector(10 , 0);
    PVector v2 = new PVector(body.leftHand.x-640, body.leftHand.y-651); 
    float a = degrees(PI - PVector.angleBetween(v2, v1));
     
    if (a > 0 && a < 35) {
      key1_active=true;
      println("Key 1 active");
    } else if (a>35 && a < 70)
    {  key2_active=true;
       println("Key 2 active");
    } else if(a>70 && a < 105)
    {  key3_active=true;
       println("Key 3 active");
    } else if (a>105 && a < 140)
    {  key4_active=true;
       println("Key 4 active");
    } else if (a>145 && a < 180)
    {  key5_active=true;
       println("Key 5 active");
    } 
  }
 
 
   // Right hand
     // First make sure mouse is in top half of screen, then check to see if it overlaps with a key
   if (  (body.rightHand.y <=651) && (pow(((body.rightHand.x-640))/(595), 2) + pow((body.rightHand.y-651)/(616),2) <= 1) && (pow((body.rightHand.x-640)/(465), 2) + pow((body.rightHand.y-651)/(484),2) >= 1))
  { 
    PVector v1 = new PVector(10 , 0);
    PVector v2 = new PVector(body.rightHand.x-640, body.rightHand.y-651); 
    float a = degrees(PI - PVector.angleBetween(v2, v1));
     
    if (a > 0 && a < 35) {
      key1_active=true;
      println("Key 1 active");
    } else if (a>35 && a < 70)
    {  key2_active=true;
       println("Key 2 active");
    } else if(a>70 && a < 105)
    {  key3_active=true;
       println("Key 3 active");
    } else if (a>105 && a < 140)
    {  key4_active=true;
       println("Key 4 active");
    } else if (a>145 && a < 180)
    {  key5_active=true;
       println("Key 5 active");
    } 
  }
 
   // Now check to see if we should send a note
   if (key1_active && !key1_was_active) {
      output.sendNoteOn(2, 1, 1); 
      println("Send note on: 2, 1, 1");
   } else if (!key1_active && key1_was_active) {
     output.sendNoteOff(2, 1, 1);
   } else if (key2_active && !key2_was_active) {
      output.sendNoteOn(2, 2, 1); 
   } else if (!key2_active && key2_was_active) {
     output.sendNoteOff(2, 2, 1);
   } else if (key3_active && !key3_was_active) {
      output.sendNoteOn(2, 3, 1); 
   } else if (!key3_active && key3_was_active) {
     output.sendNoteOff(2, 3, 1);
   }else if (key4_active && !key4_was_active) {
      output.sendNoteOn(2, 4, 1); 
   } else if (!key4_active && key4_was_active) {
     output.sendNoteOff(2, 4, 1);
   } else if (key5_active && !key5_was_active) {
      output.sendNoteOn(2, 5, 1); 
   } else if (!key5_active && key5_was_active) {
     output.sendNoteOff(2, 5, 1);
   }

  key1_was_active = key1_active;
  key2_was_active = key2_active;
  key3_was_active = key3_active;
  key4_was_active = key4_active;
  key5_was_active = key5_active;
 
    
}

  }
}

void draw_mode3() {
  
     // Skeleton control
     
     
  if (kinect_enabled) {
    
    if ((body.userList.size() <= 0) || !kinect.isTrackingSkeleton(body.userId)){   
       // Draw RGB image until calibrated
       image(body.rgbImage, 0,0,1280,960); 
    } else {
     //background 
     image(mode3_background,0 ,0, 1280,960);
       
     shapeMode(CENTER);

     pushMatrix();
       float torso_scaling = 1.7*sqrt(pow(body.neck.y - body.right_hip.y, 2)) / astro_torso.height;
       translate( body.torso.x, body.torso.y);
       scale(torso_scaling);
       shape(astro_torso, 0,0);
      popMatrix();
     
     pushMatrix();
       float head_scaling =  2*sqrt(pow(body.head.x - body.neck.x, 2) + pow(body.head.y - body.neck.y, 2)) / astro_head.height ;
       
       PVector neck_to_head = new PVector(body.neck.x, body.neck.y);
       neck_to_head.sub(body.head);
       neck_to_head.normalize();
       PVector orientation = new PVector(0,1,0);
       float angle = acos(orientation.dot(neck_to_head));
       if (body.head.x < body.neck.x) { angle = -angle;}
  
       translate( body.head.x, body.head.y);
       scale(head_scaling);
       rotate(angle);
       
       
       shape(astro_head, 0,0);
      popMatrix();
  

     
  
    // Left thigh
    pushMatrix();
       float left_thigh_scaling = 1.2*sqrt(pow(body.left_hip.x - body.left_knee.x, 2) + pow(body.left_hip.y - body.left_knee.y, 2)) / sqrt(pow(astro_left_thigh.height,2) + pow(astro_left_thigh.width,2)) ;
       angle = -degrees(atan((body.left_hip.x - body.left_knee.x)/(body.left_hip.y - body.left_knee.y)));        
       translate( (body.left_hip.x + body.left_knee.x)/2 , (body.left_hip.y + body.left_knee.y)/2 );
       scale(left_thigh_scaling);      
       rotate(radians(angle-10));
       shape(astro_left_thigh, 0, 0);
     popMatrix();
     
    // right thigh
    pushMatrix();
       float right_thigh_scaling = 1.2*sqrt(pow(body.right_hip.x - body.right_knee.x, 2) + pow(body.right_hip.y - body.right_knee.y, 2)) / sqrt(pow(astro_right_thigh.height,2) + pow(astro_right_thigh.width,2)) ;
       angle = -degrees(atan((body.right_hip.x - body.right_knee.x)/(body.right_hip.y - body.right_knee.y)));       
       translate( (body.right_hip.x + body.right_knee.x)/2 , (body.right_hip.y + body.right_knee.y)/2 );
       scale(right_thigh_scaling);      
       rotate(radians(angle+10));
       shape(astro_right_thigh, 0, 0);
     popMatrix();

 
    // Left foot
    pushMatrix();
       float left_foot_scaling = 2*sqrt(pow(body.left_knee.x - body.left_foot.x, 2) + pow(body.left_knee.y - body.left_foot.y, 2)) / sqrt(pow(astro_left_foot.height,2) + pow(astro_left_foot.width,2)) ;
       angle = -degrees(atan((body.left_knee.x - body.left_foot.x)/(body.left_knee.y - body.left_foot.y)))-5;        
       translate( (body.left_knee.x + body.left_foot.x)/2 , (body.left_knee.y + body.left_foot.y)/2 );
       scale(left_foot_scaling);      
       rotate(radians(angle));
       shape(astro_left_foot, 0, 0);
     popMatrix();

    // right foot
    pushMatrix();
       float right_foot_scaling = 1.7*sqrt(pow(body.right_knee.x - body.right_foot.x, 2) + pow(body.right_knee.y - body.right_foot.y, 2)) / sqrt(pow(astro_right_foot.height,2) + pow(astro_right_foot.width,2)) ;
       angle = -degrees(atan((body.right_knee.x - body.right_foot.x)/(body.right_knee.y - body.right_foot.y)))+5 ;    
       translate( (body.right_knee.x + body.right_foot.x)/2 , (body.right_knee.y + body.right_foot.y)/2 );
       scale(right_foot_scaling);      
       rotate(radians(angle));
       shape(astro_right_foot, 0, 0);
     popMatrix();

     // Left shoulder
     pushMatrix();
       float left_shoulder_scaling = 1.8*sqrt(pow(body.left_shoulder.x - body.left_elbow.x, 2) + pow(body.left_shoulder.y - body.left_elbow.y, 2)) / sqrt(pow(astro_left_shoulder.height,2) + pow(astro_left_shoulder.width,2));
       angle = degrees(atan((body.left_shoulder.y - body.left_elbow.y)/(body.left_shoulder.x - body.left_elbow.x)));      
       if (body.left_elbow.x > body.left_shoulder.x) {angle = angle - 180;} // To account for atan      
       translate( (body.left_shoulder.x + body.left_elbow.x)/2 , (body.left_shoulder.y + body.left_elbow.y)/2 );
       scale(left_shoulder_scaling);        
       rotate(radians(angle+80));
       shape(astro_left_shoulder, 0,0);
     popMatrix();
   

     // Right shoulder
     pushMatrix();
       float right_shoulder_scaling = 1.8*sqrt(pow(body.right_shoulder.x - body.right_elbow.x, 2) + pow(body.right_shoulder.y - body.right_elbow.y, 2)) / sqrt(pow(astro_right_shoulder.height,2) + pow(astro_right_shoulder.width,2));
       angle = degrees(atan((body.right_shoulder.y - body.right_elbow.y)/(body.right_shoulder.x - body.right_elbow.x))); 
       if (body.right_elbow.x < body.right_shoulder.x) {angle = angle - 180;} // To account for atan       
       translate( (body.right_shoulder.x + body.right_elbow.x)/2 , (body.right_shoulder.y + body.right_elbow.y)/2 );
       scale(right_shoulder_scaling);        
       rotate(radians(angle-80));
       shape(astro_right_shoulder, 0,0);
     popMatrix();
   
   
   
   
    // Left hand
    pushMatrix();
       float left_hand_scaling = 1.8*sqrt(pow(body.left_hand.x - body.left_elbow.x, 2) + pow(body.left_hand.y - body.left_elbow.y, 2)) / sqrt(pow(astro_left_hand.height,2) + pow(astro_left_hand.width,2)) ;
       angle = degrees(atan((body.left_hand.y - body.left_elbow.y)/(body.left_hand.x - body.left_elbow.x)));   
       if (body.left_elbow.x < body.left_hand.x) {angle = angle - 180;} // To account for atan
       translate( (body.left_hand.x + body.left_elbow.x)/2 , (body.left_hand.y + body.left_elbow.y)/2 );
       scale(left_hand_scaling);      
       rotate(radians(angle+60)); // To account for the angle of the svg
       shape(astro_left_hand, 0, 0);
     popMatrix();
  
  
    // Right hand
    pushMatrix();
       float right_hand_scaling = 1.8*sqrt(pow(body.right_hand.x - body.right_elbow.x, 2) + pow(body.right_hand.y - body.right_elbow.y, 2)) / sqrt(pow(astro_right_hand.height,2) + pow(astro_right_hand.width,2)) ;
       angle = -60 + degrees(atan((body.right_hand.y - body.right_elbow.y)/(body.right_hand.x - body.right_elbow.x)));
       if (body.right_elbow.x > body.right_hand.x) {angle = angle - 180;} // To account for atan
       text("Right Hand angle: " + angle, 10, 40);    
       translate( (body.right_hand.x + body.right_elbow.x)/2 , (body.right_hand.y + body.right_elbow.y)/2 );
       scale(right_hand_scaling);      
       rotate(radians(angle));
       shape(astro_right_hand, 0, 0);
     popMatrix();

     int left_hand_height = min(int(map(max(0,body.left_hand.y), 0, 960, 0, 127)), 127); 
     output.sendController(13, 1, left_hand_height);  
    
     int right_hand_height = min(int(map(max(0,body.right_hand.y), 0, 960, 0, 127)), 127); 
     output.sendController(14, 1, right_hand_height);        
  }
        
  }  
  
}




void keyPressed() {

  if (key==' ') {
    mass= 1.0;
    G= 9.81;
    theta= 0.0;
    theta_vel = 0.0;  
    theta_acc = 0.0;
    mpe = 0.0;
    mke = 0.0;
    tote = 0.0;
  }

  else if (key=='p') {
    pause = 1-pause;
  }


  else {
    typing = typing + key;
  }
}//end keyPressed


void mousePressed() {
 // p.clicked(mouseX, mouseY);
}

void mouseReleased() {
  //p.stopDragging();
}









// Is pointer inside effect Button 1?
boolean isInEffectButton1(float x, float y)
{
  // Get distance from the center of the button
  float distance = sqrt(pow(window_size_x - effect_button_size/2 - 200 - x, 2) + pow(window_size_y - effect_button_size/2 - 160 - y, 2));

  if (distance < effect_button_size/2)
  {
    return true;
  } 
  else {
    return false;
  }
}


// Is pointer inside effect Button 2?
boolean isInEffectButton2(float x, float y)
{
  // Get distance from the center of the button
  float distance = sqrt(pow(window_size_x - effect_button_size/2 - 100 - x, 2) + pow(window_size_y - effect_button_size/2 - 200 - y, 2));

  if (distance < effect_button_size/2)
  {
    return true;
  } 
  else {
    return false;
  }
}



// Is pointer inside mode button?
boolean isInModeButton(float x, float y)
{
  // Get distance from the center of the button
  float distance = sqrt(pow(100 + mode_button_size/2 - x, 2) + pow(window_size_y - mode_button_size/2 - 100 - y, 2));

  if (distance < mode_button_size/2)
  {
    return true;
  } 
  else {
    return false;
  }
}





// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.startPoseDetection("Psi", userId);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } else { 
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
}



ArrayList kinect_draw()
{
  
  kinect.update();
  PImage depth = kinect.depthImage();
  image(depth, 0, 0);
  ArrayList kinect_data = new ArrayList();
  kinect_data.add(false); // First element is whether the data is present (assume false for now)
  
  // make a vector of ints to store the list of users
  IntVector userList = new IntVector();
  // write the list of detected users
  // into our vector
  kinect.getUsers(userList);

  // if we found any users
  if (userList.size() > 0) {
    // get the first user
    int userId = userList.get(0);
    
    // if we're successfully calibrated
    if ( kinect.isTrackingSkeleton(userId)) {
      
      kinect_data.set(0, true); // First element is whether the data is present
      
      // make a vector to store the left hand
      PVector leftHand = new PVector();
      // put the position of the left hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);

      // convert the detected hand position
      // to "projective" coordinates
      // that will match the depth image
      PVector convertedLeftHand = new PVector();
      kinect.convertRealWorldToProjective(leftHand, convertedLeftHand);
  
       // make a vector to store the left hand
      PVector rightHand = new PVector();
      // put the position of the left hand into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);

      // convert the detected hand position
      // to "projective" coordinates
      // that will match the depth image
      PVector convertedRightHand = new PVector();
      kinect.convertRealWorldToProjective(rightHand, convertedRightHand); 
  
      //float distance_between_hands = sqrt(    pow(convertedRightHand.x - convertedLeftHand.x, 2) + pow(convertedRightHand.y - convertedLeftHand.y,2));
      
      kinect_data.add(convertedLeftHand);
      kinect_data.add(convertedRightHand);
      //kinect_data.add(distance_between_hands);
    } 

  }      
  
   
return kinect_data;
    
}



// Stop function
void stop() {
  // Turn off any sounds before quitting
  output.sendNoteOn(0, 1, 1); 
  super.stop();
} 

