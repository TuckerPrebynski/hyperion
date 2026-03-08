System mySystem;
Render myRenderer;
physics_eng myPhys;
GUI myGUI;
SimCamera myCam;


void setup () {
    size(800,800,P3D);

    mySystem = new System (new PVector (0,0,0));

    mySystem.initParticles(5000, 200);

    myRenderer = new Render (mySystem);
    
    //myRenderer = new Render (mySystem);
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
  //box(250);

  //randomizer for point cloud, delete at some point
  x+=(random(-10,10));
  y+=(random(-10,10));
  z+=(random(-10,10));
  //random point, can be deleted whenever
  strokeWeight(10);
  stroke(250,20,10);
  point(mouseX,mouseY,50);
  //random point 2
  point(x,y,z);

  //mandatory update stuff
  myRenderer.display();
  myPhys.update();

  myGUI.display();
}
