import SimpleOpenNI.*;
SimpleOpenNI  kinect;

import rwmidi.*;

MidiOutput output;


// variables for note generation from keystrike
// variables for note generation from keystrike
int aChannel,  sChannel,  dChannel,  fChannel;
int aNote,     sNote,     dNote,     fNote;
int aVelocity, sVelocity, dVelocity, fVelocity;
int aSuccess,  sSuccess,  dSuccess,  fSuccess;

boolean isClapping = false;
boolean wasClapping = false;
boolean beatOn = false;
boolean wasInEffectBox = false;

// Mode 2 info
PImage key_blur;
PShape s;

// Mode 3 info
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
float effect_button_size;
float mode_button_size;
int time_entered_mode_button;
int mode = 2;
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
  p = new Pendulum(new PVector(width/2, 0), pend_arm); // Make a new Pendulum with an origin location and armlength

  // Fonts
  font = loadFont("OCRAStd-48.vlw");
  textFont(font);
  
  // Create new Body
  body = new Body();
  
}









void draw() {
 

  
  PShape effect_button1;
  PShape effect_button2;
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
    // Pendulum
    draw_mode3();
    p.go();
    time++;
    break;
  }

  shapeMode(CORNER);
  // -----------------------------------
  // Effect buttons
  // -----------------------------------
  
  // Handle Effect Button 1
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
  shape(effect_button2, window_size_x - effect_button_size - 10, window_size_y - effect_button_size - 60, effect_button_size, effect_button_size);




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
     
  if (kinect_enabled) {
     //body.draw_pointCloud();
     image(body.depth, 0, 0, 1280, 960);
  }
     
    // Cicles on hands
    fill(255,0,0); 
    ellipse(body.leftHand.x, body.leftHand.y, 20, 20);
    fill(0,0,255);
    ellipse(body.rightHand.x, body.rightHand.y, 20, 20);
    
    // Sine wave between hands
    pushMatrix();
    strokeWeight(3);
    stroke(223, 0, 255);
    translate(body.rightHand.x, body.rightHand.y);
    rotate(radians(body.angle_between_hands()));
    for (float x=0; x<body.distance_between_hands(); x=x+3)
    {
      point(x, 50*sin(sine_phase + 12 * PI* x /  body.distance_between_hands()));
      point(x, -50*sin(sine_phase + 12 * PI* x /  body.distance_between_hands()));
      
    }
    popMatrix();
    
    sine_phase += 2;
    
    // Data to display
    textAlign(LEFT, TOP); 
    textFont(font, 16);
    fill(0, 255, 0);
    text("Size: " + body.distance_between_hands() + "\nAngle: " + body.angle_between_hands(), 10, 10);   
  
    // MIDI output
    int hands_dist = min(int(map(body.distance_between_hands(), 0, 1000, 0, 127)), 127); 
    output.sendController(1, 1, hands_dist);    

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
     //body.draw_pointCloud();
     image(body.depth, 0, 0, 1280, 960);
  }

  
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
  
 
  
     // First make sure mouse is in top half of screen, then check to see if it overlaps with a key
   if (  (body.rightHand.y <=651) && (pow(((body.rightHand.x-640))/(595), 2) + pow((body.rightHand.y-651)/(616),2) <= 1) && (pow((body.rightHand.x-640)/(465), 2) + pow((body.rightHand.y-651)/(484),2) >= 1))
  { 
    PVector v1 = new PVector(10 , 0);
    PVector v2 = new PVector(body.rightHand.x-640, body.rightHand.y-651); 
    float a = degrees(PI - PVector.angleBetween(v2, v1));
     
    if (a > 0 && a < 35) {
      key1_active=true;
      output.sendNoteOn(2, 1, 1);
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
    
}




void draw_mode3() {
  
     // Skeleton control
  if (kinect_enabled && (body.userList.size() > 0) && kinect.isTrackingSkeleton(body.userId)){   
     image(body.depth, 0,0,1280,960); 
       
     shapeMode(CENTER);
     
     shape(astro_head, body.head.x, body.head.y);
     
     shape(astro_torso, body.torso.x, body.torso.y);
     
     shape(astro_left_shoulder, body.left_shoulder.x, body.left_shoulder.y);
     
     shape(astro_right_shoulder, body.right_shoulder.x, body.right_shoulder.y);
   
     shape(astro_left_hand, body.left_hand.x, body.left_hand.y);
     
     shape(astro_right_hand, body.right_hand.x, body.right_hand.y);   
     
     shape(astro_right_thigh, body.right_hip.x, body.right_hip.y);
     
     shape(astro_left_thigh, body.left_hip.x, body.left_hip.y);

     shape(astro_right_foot, body.right_foot.x, body.right_foot.y);
     
     shape(astro_left_foot, body.left_foot.x, body.left_foot.y);

    strokeWeight(3);
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

     println( body.head.x + " " + body.head.y);
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
  p.clicked(mouseX, mouseY);
}

void mouseReleased() {
  p.stopDragging();
}









// Is pointer inside effect Button 1?
boolean isInEffectButton1(float x, float y)
{
  // Get distance from the center of the button
  float distance = sqrt(pow(window_size_x - effect_button_size/2 - 60 - x, 2) + pow(window_size_y - effect_button_size/2 - 10 - y, 2));

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
  float distance = sqrt(pow(window_size_x - effect_button_size/2 - 10 - x, 2) + pow(window_size_y - effect_button_size/2 - 60 - y, 2));

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

