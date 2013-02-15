import SimpleOpenNI.*;
import hypermedia.video.*;
import java.awt.Rectangle;
import java.awt.Point;
import org.processing.wiki.triangulate.*;
 


SimpleOpenNI  kinectLib;
OpenCV opencv;
PGraphics pg;
int w = 640;
int h = 480;
int threshold = 130;
ArrayList triangles = new ArrayList();

void setup() {

  kinectLib = new SimpleOpenNI(this); 
  opencv = new OpenCV(this);
   
  if(kinectLib.enableRGB() == false) { 
    println(" can't open RGB ");
    exit();
    return;    
  }

  if(kinectLib.enableDepth() == false) { 
    println(" can't open depth ");
    exit();
    return;    
  }
  
    size( w, h );

    opencv = new OpenCV( this );
    opencv.capture(w,h);
    
    pg = createGraphics(w,h);

    println( "Drag mouse inside sketch window to change threshold" );
}



void draw() {

   kinectLib.update();
   PImage depth = kinectLib.depthImage(); 
  
   opencv.copy(depth, 0, 0, 640, 480, 0, 0, 640, 480);
  
   opencv.absDiff();
   opencv.threshold(threshold);
   opencv.flip( OpenCV.FLIP_HORIZONTAL );

    // working with blobs
    Blob[] blobs = opencv.blobs( 1000, w*h/2, 1, false );

    pg.beginDraw();
    pg.background(0);
  
    // Draw points around edge
    Point[] points = blobs[0].points;
    pg.noFill();
    pg.stroke(255,0,0);
    pg.strokeWeight(3); 
        
    ArrayList pointList = new ArrayList();
    if ( points.length>0 ) {
      pg.beginShape();
      for( int j=0; j<points.length; j=j+10 ) {
        pg.vertex( points[j].x, points[j].y );
        pointList.add(new PVector(points[j].x, points[j].y)); //, depth.get(points[j].x, points[j].y)));
      }
      pg.endShape();
    }
        
    triangles = Triangulate.triangulate(pointList);
    // draw the mesh of triangles
    pg.stroke(0,255,0);
    pg.fill(0, 100, 0);
    pg.beginShape(TRIANGLES);
 
    for (int tri = 0; tri < triangles.size(); tri++) {
      Triangle t = (Triangle)triangles.get(tri);
      pg.vertex(t.p1.x, t.p1.y);
      pg.vertex(t.p2.x, t.p2.y);
      pg.vertex(t.p3.x, t.p3.y);
    }
    pg.endShape();
     
  pg.endDraw();
    

    background(pg); 
    
    opencv.copy(depth, 0, 0, 640, 480, 0, 0, 640, 480);  
    opencv.threshold(threshold);
    opencv.flip( OpenCV.FLIP_HORIZONTAL );
    //image( opencv.image(), 0,0 );
    blend(opencv.image(),0,0,w,h,0,0,w,h,DARKEST);
}

void keyPressed() {
    if ( key==' ' ) {
      
      opencv.copy(kinectLib.depthImage(), 0, 0, 640, 480, 0, 0, 640, 480);
      opencv.threshold(threshold);
      opencv.remember(OpenCV.SOURCE);
    }
}

void mouseDragged() {
    threshold = int( map(mouseX,0,width,0,255) );
}

public void stop() {
    opencv.stop();
    super.stop();
}
