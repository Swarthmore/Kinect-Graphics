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

if (  (mouseY <=651) && (pow(float((mouseX-640))/(595), 2) + pow(float(mouseY-651)/(616),2) <= 1) && (pow(float(mouseX-640)/(465), 2) + pow(float(mouseY-651)/(484),2) >= 1))
  { 
    PVector v1 = new PVector(10 , 0);
    PVector v2 = new PVector(mouseX-640, mouseY-651); 
    float a = degrees(PI - PVector.angleBetween(v2, v1));
    println(a);  // Prints "10.304827"
    
    if (a > 0 && a < 35) {
      println("Key 1");
    } else if (a>35 && a < 70)
    { println("Key 2");
    } else if(a>70 && a < 105)
    { println("Key 3");
    } else if (a>105 && a < 140)
    { println("Key 4");
    } else if (a>145 && a < 180)
    { println("Key 5");
    } 
  }
}



void mouseClicked(){
println (mouseX + " " +mouseY);
}




