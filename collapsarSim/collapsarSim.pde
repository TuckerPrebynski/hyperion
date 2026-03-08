System mySystem;
Render myRenderer;
physics_eng myPhys;
GUI myGUI;
SimCamera myCam;

void resetSimulation() {
    // 1. Throw away the old system and make a new one
    mySystem = new System(new PVector(0, 0, 0));
    mySystem.initParticles(6000, 200);

    // 2. Re-initialize the renderer with the new system
    myRenderer = new oldRender(mySystem);
    // myRenderer = new Render(mySystem); // Use this if you switched to your shader renderer!
    myRenderer.init();

    // 3. Create a fresh physics engine
    myPhys = new physics_eng(mySystem);

    // 4. Reset the camera to its starting position
    myCam = new SimCamera();

    // 5. Hook the GUI back up to the new camera and new system
    myGUI = new GUI(myCam, mySystem); 
}


void setup () {
    size(3000,1900,P3D);

    resetSimulation();
}

float x = 1;
float y = 1;
float z = 1;

void draw () {
  //sets background to black, can be changed to images.
  //this is what "clears" the screen
  background(0);

  myCam.apply();

  //box display for testing, delete in prod
  strokeWeight(2);
  translate(width/2, height/2, -100);
  noFill();
  stroke(250,30,30);
  box(350);

  //BLACK HOLE
  if (myPhys.bh != null) {
    pushMatrix();
    translate(myPhys.bh.pos.x, myPhys.bh.pos.y, myPhys.bh.pos.z);

    //event horizon
    fill(0); // Pure black
    noStroke();
    sphere(myPhys.bh.r_in*3.5); // Draw it at the exact point of no return!

    //magnetic zone
    noFill();
    strokeWeight(2);

    float time = millis()*0.001f;

    int numRings = 8; //number of rings
    for (int i = 0; i< numRings; i++) {
      pushMatrix();

      //rotation angle math
      rotateX(time+(PI/numRings)*i);
      rotateY(time*0.7f + (PI / numRings) * i);

      //outer boundary
      stroke (70,20,70,150);
      ellipse(0,0,myPhys.bh.r_acc*2.5,myPhys.bh.r_acc*2.5);

      //draw inner photon ring
      stroke(0,12,186,120);
      ellipse(0,0,myPhys.bh.r_acc*3.5,myPhys.bh.r_acc*3.5);

      popMatrix();
    }
    popMatrix();
  }

  //mandatory update stuff
  myRenderer.display();

  if (!myCam.simPaused) {
    myPhys.update();
  }

  myGUI.display();
}

void keyPressed() {
    // If the user presses 'N' or 'n', completely reset the simulation!
    if (key == 'c' || key == 'C') {
        resetSimulation();
    }
}