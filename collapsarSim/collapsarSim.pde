System mySystem;
Render myRenderer;
physics_eng myPhys;
SimCamera myCam;


void setup () {
    size(1920,1080,P3D);

    mySystem = new System (new PVector (0,0,0));

    mySystem.initParticles(5000, 200);

    myRenderer = new Render (mySystem);
    myRenderer.init();

    myPhys = new physics_eng(mySystem);

    myCam = new SimCamera();
}

float x = 1;
float y = 1;
float z = 1;

void draw () {
  //sets background to black, can be changed to images.
  //this is what "clears" the screen
  background(0);

  float camDist = 600;
  float angle = frameCount * 0.01;
  camera(
    cos(angle) * camDist, 200, sin(angle) * camDist,  // eye
    0, 0, 0,                                            // look at origin
    0, 1, 0                                             // up
  );

  //mandatory update stuff
  myRenderer.display();
  myPhys.update();
}
