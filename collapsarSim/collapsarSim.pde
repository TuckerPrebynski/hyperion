float x = 0;
float y = 0;
float z = 0;

void setup () {
    size (1920,1080,P3D);
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
  point(mouseX,mouseY,50);
  stroke(255);
  point(x,y,z);
  x++;
  y++;
  z++;
  
}
