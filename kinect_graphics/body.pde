
class Body  {
 
  PVector leftHand;      
  PVector rightHand;  
  boolean dataValid = false;  
  float distance_between_hands = 0;   
  PImage depth;
  PImage rgbImage;
  int userId;
  IntVector userList;
  PVector head;
  PVector torso;
  PVector left_shoulder;
  PVector right_shoulder;
  PVector left_elbow;
  PVector right_elbow;
  PVector left_hand;
  PVector right_hand;
  PVector left_knee;
  PVector right_knee;
  PVector left_foot;
  PVector right_foot;
  PVector left_hip;
  PVector right_hip;
  PVector neck;


  
  // This constructor could be improved to allow a greater variety of pendulums
Body() {

    leftHand = new PVector(0,0);
    rightHand = new PVector(0,0);
    head = new PVector(0,0);
    torso = new PVector(0,0);
    left_shoulder = new PVector(0,0);
    right_shoulder = new PVector(0,0);
    left_elbow = new PVector(0,0);
    right_elbow = new PVector(0,0);
    left_hand = new PVector(0,0);
    right_hand = new PVector(0,0);
    left_hip = new PVector(0,0);
    right_hip = new PVector(0,0);
    left_knee = new PVector(0,0);
    right_knee = new PVector(0,0);
    left_foot = new PVector(0,0);
    right_foot = new PVector(0,0);   
    neck = new PVector(0,0); 
}
 
 
 void update()
 {
   
   dataValid = false;
   PVector convertedRightHand = new PVector();
   PVector convertedLeftHand = new PVector();
   PVector convertedHead = new PVector();
   PVector convertedTorso = new PVector();
   
    // Kinect processing
  if (!kinect_enabled) {
    leftHand = new PVector(window_size_x/2, window_size_y/2);
    rightHand =  new PVector(mouseX, mouseY);
    dataValid = true;
  }  else {
    
  // Kinect is present -- use it.
  
    kinect.update();
    depth = kinect.depthImage();
    rgbImage = kinect.rgbImage();
    
    //image(depth, 0, 0);
    ArrayList kinect_data = new ArrayList();
    kinect_data.add(false); // First element is whether the data is present (assume false for now)
  
    // make a vector of ints to store the list of users
    userList = new IntVector();
    // write the list of detected users
    // into our vector
    kinect.getUsers(userList);

    // if we found any users
    if (userList.size() > 0) {
      // get the first user
      userId = userList.get(0);
    
      // if we're successfully calibrated
      if ( kinect.isTrackingSkeleton(userId)) {
      
        //println("Tracking skeleton");
        kinect_data.set(0, true); // First element is whether the data is present
      
        // make a vector to store the left hand
        leftHand = new PVector();
        // put the position of the left hand into that vector
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);

        // convert the detected hand position
        // to "projective" coordinates
        // that will match the depth image
        kinect.convertRealWorldToProjective(leftHand, convertedLeftHand);
  
        // make a vector to store the left hand
        rightHand = new PVector();
        // put the position of the left hand into that vector
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);

        // convert the detected hand position
        // to "projective" coordinates
        // that will match the depth image
        kinect.convertRealWorldToProjective(rightHand, convertedRightHand); 
  
        // Head
        head = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, head);
        kinect.convertRealWorldToProjective(head, convertedHead); 
  
        // Torso
        torso = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, torso);
        kinect.convertRealWorldToProjective(torso, convertedTorso);
        
         // Left shoulder
        PVector left_shoulder_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, left_shoulder_raw);
        kinect.convertRealWorldToProjective(left_shoulder_raw, left_shoulder);       
        left_shoulder.mult(2);
  
        // Right shoulder
        PVector right_shoulder_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, right_shoulder_raw);
        kinect.convertRealWorldToProjective(right_shoulder_raw, right_shoulder);       
        right_shoulder.mult(2);      
 
         // Left hand
        PVector left_hand_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, left_hand_raw);
        kinect.convertRealWorldToProjective(left_hand_raw, left_hand);       
        left_hand.mult(2);       
        
          // Right hand
        PVector right_hand_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, right_hand_raw);
        kinect.convertRealWorldToProjective(right_hand_raw, right_hand);       
        right_hand.mult(2);
        
        // Left elbow
        PVector left_elbow_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, left_elbow_raw);
        kinect.convertRealWorldToProjective(left_elbow_raw, left_elbow);       
        left_elbow.mult(2);           
        
        // Right elbow
        PVector right_elbow_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, right_elbow_raw);
        kinect.convertRealWorldToProjective(right_elbow_raw, right_elbow);       
        right_elbow.mult(2);      


        // Left hip
        PVector left_hip_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HIP, left_hip_raw);
        kinect.convertRealWorldToProjective(left_hip_raw, left_hip);       
        left_hip.mult(2);    
        
        
        // Right hip
        PVector right_hip_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, right_hip_raw);
        kinect.convertRealWorldToProjective(right_hip_raw, right_hip);       
        right_hip.mult(2);   
 
        // Left knee
        PVector left_knee_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_KNEE, left_knee_raw);
        kinect.convertRealWorldToProjective(left_knee_raw, left_knee);       
        left_knee.mult(2);     
        
        // Right knee
        PVector right_knee_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, right_knee_raw);
        kinect.convertRealWorldToProjective(right_knee_raw, right_knee);       
        right_knee.mult(2);  
 
         // Left foot
        PVector left_foot_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_FOOT, left_foot_raw);
        kinect.convertRealWorldToProjective(left_foot_raw, left_foot);       
        left_foot.mult(2);       
        
        // Right foot
        PVector right_foot_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, right_foot_raw);
        kinect.convertRealWorldToProjective(right_foot_raw, right_foot);       
        right_foot.mult(2);  

        // Neck
        PVector neck_raw = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_NECK, neck_raw);
        kinect.convertRealWorldToProjective(neck_raw, neck);       
        neck.mult(2);  
        
        dataValid = true;
        
        // Scale coordinates to screen
        convertedRightHand.mult(2);
        convertedLeftHand.mult(2);
        leftHand = new PVector(convertedLeftHand.x, convertedLeftHand.y);
        rightHand =  new PVector(convertedRightHand.x, convertedRightHand.y);
        
        convertedHead.mult(2);
        head = new PVector(convertedHead.x, convertedHead.y);
        
        convertedTorso.mult(2);
        torso = new PVector(convertedTorso.x, convertedTorso.y);
      } 

  }  
  }
}

float distance_between_hands() {  
    return PVector.dist(rightHand, leftHand); //sqrt(    pow(convertedRightHand.x - convertedLeftHand.x, 2) + pow(convertedRightHand.y - convertedLeftHand.y,2));    
}

float angle_between_hands() {
    PVector hand_to_hand = new PVector(leftHand.x, leftHand.y);
    hand_to_hand.sub(rightHand);
    hand_to_hand.normalize();
    PVector handOrientation = new PVector(1,0,0);
    float angle = degrees(acos(handOrientation.dot(hand_to_hand)));
    
    if (leftHand.y < rightHand.y)
    {
       angle = -angle; 
    }
    
    //println("Angle: " + angle);  
    return angle; 
}


void draw_pointCloud()
{
  
  hint(ENABLE_DEPTH_TEST);
  pushMatrix();
  translate(window_size_x/2, window_size_y/2, -250);
  rotateX(radians(180));
  translate(0, 0, 1000);

  PVector[] depthPoints = kinect.depthMapRealWorld();
  // don't skip any depth points
  for (int i = 0; i < depthPoints.length; i+=5) {
    PVector currentPoint = depthPoints[i];
    if (currentPoint.z < 1500)
    {
      // set the stroke color based on the color pixel
      stroke(rgbImage.pixels[i]);
      point(currentPoint.x*2, currentPoint.y*2, currentPoint.z*2);
    }
  } 
  
  popMatrix();
  hint(DISABLE_DEPTH_TEST);
}



}
