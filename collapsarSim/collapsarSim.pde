void setup () {
    size (1920,1080,P3D);
}

void draw () {
    background(0,0,0);

    translate(100,100,0);

    noStroke();
    sphere(50);
    
    directionalLight(0,255,0,0,-1,0);
}