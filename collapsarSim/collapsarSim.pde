float x = 1;
float y = 1;
float z = 1;

System mySystem;
Render myRenderer;


void setup () {
    size (1920,1080,P3D);
    mySystem = new System (new PVector (0,0,0));

    mySystem.initParticles(5000);

    myRenderer = new Render (mySystem);
}

void draw () {
  background(0);
  
  
  strokeWeight(2);
  stroke(random(0,255));
  camera(mouseX, height/2, (height/2) / tan(PI/6), width/2, height/2, 0, 0, 1, 0);
  translate(width/2, height/2, -100);
  noFill();
  box(200);
  
  strokeWeight(10);
  stroke(255);
  point(x,y,z);
  point(mouseX,mouseY,50);
  x+=(random(-5,5));
  y+=(random(-5,5));
  z+=(random(-5,5));

  myRenderer.display(x, y, z);
}
