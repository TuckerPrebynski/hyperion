System mySystem;
oldRender myRenderer;
physics_eng myPhys;
GUI myGUI;
SimCamera myCam;


void setup () {
    size(1920,1080,P3D);

    mySystem = new System (new PVector (0,0,0));

    mySystem.initParticles(5000, 200);

    myRenderer = new oldRender (mySystem);
    
    myRenderer = new Render (mySystem);
    myRenderer.init();

    myPhys = new physics_eng(mySystem);

    myCam = new SimCamera();

    myGUI = new GUI(myCam);
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
  box(250);

  //mandatory update stuff
  myRenderer.display(x,y,z);
  myPhys.update();

  myGUI.display();
}
