System mySystem;
oldRender myRenderer;
physics_eng myPhys;
GUI myGUI;
SimCamera myCam;


void setup () {
    size(2200,1600,P3D);

    mySystem = new System (new PVector (0,0,0));

    mySystem.initParticles(5000, 200);

    myRenderer = new oldRender (mySystem);
    
    //myRenderer = new Render (mySystem);
    myRenderer.init();

    myPhys = new physics_eng(mySystem);

    myCam = new SimCamera();

    myGUI = new GUI(myCam, mySystem);
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

  //mandatory update stuff
  myRenderer.display();
  myPhys.update();


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

  myGUI.display();
}
