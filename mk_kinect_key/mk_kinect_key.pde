int window_size_x = 1280;
int window_size_y = 960;



PShape s;
PShape topkey;
PShape topleftkey;
PShape bottomleftkey;
PShape toprightkey;
PShape bottomrightkey;

void setup() {
  size(window_size_x, window_size_y);
  s = loadShape("keycontrols.svg");
  topkey = s.getChild("top");
  topleftkey = s.getChild("topleft");
  bottomleftkey = s.getChild("bottomleft");
  toprightkey = s.getChild("topright");
  bottomrightkey = s.getChild("bottomright");

  shapeMode(CORNER);
  smooth();
}


void draw() {


  background(0);
  shape(s,40,-5,1200,622);
  //filter(BLUR,6);

  shape(topkey,20,0,600,311);
  shape(topleftkey,20,0,600,311);
  shape(bottomleftkey,20,0,600,311);
  shape(toprightkey,20,0,600,311);
  shape(bottomrightkey,20,0,600,311);

if (  (pow(float((mouseX-640))/(595), 2) + pow(float(mouseY-651)/(616),2) <= 1) && (pow(float(mouseX-640)/(465), 2) + pow(float(mouseY-651)/(484),2) >= 1))
  { 
    PVector v1 = new PVector(10 , 0);
    PVector v2 = new PVector(mouseX, mouseY); 
    float a = PVector.angleBetween(v1, v2);
    println(degrees(a));  // Prints "10.304827"
    
    
    //println(mouseX + " " +mouseY);
  } else {

  }
}



void mouseClicked(){
println (mouseX + " " +mouseY);
}




