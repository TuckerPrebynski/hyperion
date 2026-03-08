System mySystem;
Render myRenderer;


void setup () {
    size (2500,2000,P3D);
    mySystem = new System (new PVector (0,0,0));

    mySystem.initParticles(5000);

    myRenderer = new Render (mySystem);
}

float x = 1;
float y = 1;
float z = 1;

float cameraX = 0;
float cameraY = 0;
float cameraZ = (height/2) / tan(PI/6);

void draw () {
  background(0);
  
  
  strokeWeight(2);
  //stroke(random(0,255));
  camera(cameraX, cameraY, cameraZ, width/2, height/2, 0, 0, 1, 0);
  cameraX+=(5);
  cameraY+=(5);
  cameraZ+=(5);
  translate(width/2, height/2, -100);
  noFill();
  box(250);
  
  strokeWeight(10);
  stroke(250,20,10);
  //point(mouseX,mouseY,50);
  x+=(random(-10,10));
  y+=(random(-10,10));
  z+=(random(-10,10));
  point(x,y,z);

  myRenderer.display(x, y, z);
}
