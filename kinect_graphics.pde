int window_size_x = 640;
int window_size_y = 480;
float effect_button_scale = 0.2;
float mode_button_scale = 0.4;

PShape on_button;
PShape off_button;
PShape sine_wave;


PShape key_pad;
float key_pad_scale = 0.5;

PFont font;

float effect_button_size;
float mode_button_size;
int time_entered_mode_button;
int mode = 1;
int number_of_modes = 3;
boolean isInModeButton = false;
boolean wasInModeButton = false;
boolean mode_switched = false;

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




void setup() {

  size(window_size_x, window_size_y);

  // Images must be in the "data" directory to load correctly
  on_button = loadShape("on_button.svg");
  off_button = loadShape("off_button.svg");

  effect_button_size = on_button.width*effect_button_scale;
  mode_button_size = on_button.width*mode_button_scale;

  // Sine wave
  sine_wave = loadShape("sine_wave.svg");


  // Keys
  key_pad = loadShape("key.svg");

  // Pendulum
  p = new Pendulum(new PVector(width/2, 0), pend_arm); // Make a new Pendulum with an origin location and armlength



  font = loadFont("OCRAStd-48.vlw");
  textFont(font);
}

void draw() {

  PShape effect_button1;
  PShape effect_button2;
  PShape mode_button;

  background(0);
  shapeMode(CORNER);

  // Effect 1
  if ( isInEffectButton1(mouseX, mouseY))
  {
    effect_button1 = on_button;
  } 
  else {
    effect_button1 = off_button;
  }  
  shape(effect_button1, window_size_x - effect_button_size - 60, window_size_y - effect_button_size - 10, effect_button_size, effect_button_size);

  // Effect 2
  if ( isInEffectButton2(mouseX, mouseY))
  {
    effect_button2 = on_button;
  } 
  else {
    effect_button2 = off_button;
  }   
  shape(effect_button2, window_size_x - effect_button_size - 10, window_size_y - effect_button_size - 60, effect_button_size, effect_button_size);




  // -----------------------------------
  // Mode button 
  // -----------------------------------
  if ( isInModeButton(mouseX, mouseY))
  {
    mode_button = on_button;
    isInModeButton = true;
  } 
  else {
    mode_button = off_button;
    isInModeButton = false;
  }
  shape(mode_button, 10, window_size_y - mode_button_size - 10, mode_button_size, mode_button_size);


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
  text(str(mode+1), 10+mode_button_size/2, window_size_y - mode_button_size/2 - 10);   


  // -----------------------------------
  // End of Mode button
  // -----------------------------------





  // Print out status
  float hands_apart_distance = mouseX;
  float angle = mouseY;


  switch(mode) {

  case 0:  
    // Skeleton control
    textAlign(LEFT, TOP); 
    textFont(font, 16);
    fill(0, 255, 0);
    text("Size: " + hands_apart_distance + "\nAngle: " + angle, 10, 10);   
    break;

  case 1:
    // Keys
    drawKeys();
    break;

  case 2: 
    // Pendulum
    p.go();
    time++;
    break;
  }






  // Sine wave
  // For now, draw beteen effect button 1 and the mouse
  //shape(sine_wave, mouseX, mouseY,window_size_x - effect_button_size/2 - 60, window_size_y - effect_button_size/2 - 10);


  // Finish up 
  wasInModeButton = isInModeButton;
}









void drawKeys()
{
  
  boolean key1_active = false;
  boolean key2_active = false;
  boolean key3_active = false;
  boolean key4_active = false;
  boolean key5_active = false;

  stroke(0);
  fill(205, 255, 255);

  // Key 1
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(191), radians(221));

  // Key 2
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(223), radians(253));

  // Key 3 
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(255), radians(285));

  // Key 4

  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(287), radians(317));

  // Key 5
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(319), radians(349));

  // Remove fill from center
  fill(0);
  ellipse(window_size_x/2, window_size_y/2, window_size_x - 120, window_size_y - 120);

  // Check to see if in ellipse zone  
  if (  (pow(float((mouseX-window_size_x/2))/(window_size_x/2 - 5), 2) + pow(float(mouseY-window_size_y/2)/(window_size_y/2 -5),2) <= 1) && (pow(float(mouseX-window_size_x/2)/(window_size_x/2 - 60), 2) + pow(float(mouseY-window_size_y/2)/(window_size_y/2 - 60),2) >= 1))
  {

     
     // If so, determine if in a key pad by getting angle
     float angle = 270 - degrees(atan( float((mouseX-window_size_x/2)) / float((mouseY-window_size_y/2))));
     

     
     // First make sure mouse is in top half of screen, then check to see if it overlaps with a key
     if (mouseY < window_size_y/2)
     {
        if ( angle >= 191 && angle <= 221)
        {
           key1_active = true; 
        } else if ( angle >= 223 && angle <= 253)
        {
          key2_active = true; 
        } else if ( angle >= 255 && angle <= 285)
        {
          key3_active = true; 
        } else if ( angle >= 287 && angle <= 317)
        {
          key4_active = true; 
        } else if ( angle >= 319 && angle <= 349)
        {
          key5_active = true; 
        }   
     }


  // Key 1
  if (key1_active) { fill (0, 0, 255); } else { fill(205, 255, 255); }
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(191), radians(221));

  // Key 2
  if (key2_active) { fill (0, 0, 255); } else { fill(205, 255, 255); }
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(223), radians(253));

  // Key 3 
  if (key3_active) {fill (0, 0, 255); } else {  fill(205, 255, 255); }
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(255), radians(285));

  // Key 4
  if (key4_active) { fill (0, 0, 255); } else {  fill(205, 255, 255); }
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(287), radians(317));

  // Key 5
  if (key5_active) { fill(0, 0, 255); } else { fill(205, 255, 255); }
  arc(window_size_x/2, window_size_y/2, window_size_x - 10, window_size_y - 10, radians(319), radians(349));

  // Remove fill from center
  fill(0);
  ellipse(window_size_x/2, window_size_y/2, window_size_x - 120, window_size_y - 120);

      println("in zone " + angle + " " + key1_active);   
    
  }
}






void keyPressed() {

  if (key== 'm') {
    mass = float(typing);
    typing = "";
  }
  else if (key== 'g') {
    G = float(typing);
    typing = "";
  }
  else if (key==' ') {
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
boolean isInEffectButton1(int x, int y)
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
boolean isInEffectButton2(int x, int y)
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
boolean isInModeButton(int x, int y)
{
  // Get distance from the center of the button
  float distance = sqrt(pow(10 + mode_button_size/2 - x, 2) + pow(window_size_y - mode_button_size/2 - 10 - y, 2));

  if (distance < mode_button_size/2)
  {
    return true;
  } 
  else {
    return false;
  }
}


