System mySystem;
oldRender myRenderer;
physics_eng myPhys;
GUI myGUI;
SimCamera myCam;

// --- 1. MULTITHREADING VARIABLES ---
class RenderParticle {
    float x, y, z, temp;
    PVector vel;
    boolean alive;
    float mass;
}

RenderParticle[] renderBuffer;
int renderCount = 0;

// Thread-safe Black Hole Data
boolean renderBhExists = false;
float renderBhX, renderBhY, renderBhZ, renderBhRIn;

// Threading locks and flags
Object threadLock = new Object();
boolean isCalculating = false;
boolean isPaused = false;

void resetSimulation() {
    // 1. Throw away the old system and make a new one
    mySystem = new System(new PVector(0, 0, 0));
    
     //mySystem.initParticles(6000, 200);
    mySystem.addStar(5000,200,new PVector(0,0,0));
    //mySystem.addStar(6000,50,new PVector(-300,300,0));
   

    // --- 2. INITIALIZE THE RENDER BUFFER ---
    renderBuffer = new RenderParticle[mySystem.maxParts];
    for (int i = 0; i < renderBuffer.length; i++) {
        renderBuffer[i] = new RenderParticle();
    }

    // 3. Re-initialize the renderer
    myRenderer = new oldRender(mySystem); 
    myRenderer.init();

    // 4. Create a fresh physics engine
    myPhys = new physics_eng();

    // 5. Reset camera and GUI
    myCam = new SimCamera();
    myGUI = new GUI(); 
    
    isCalculating = false;
}

void setup() {
    size(2500, 1100, P3D); // Note: this is a massive resolution!
    resetSimulation();
}

float x = 1;
float y = 1;
float z = 1;

void draw() {
    background(0);
    myCam.apply();

    // Box display for testing
    pushMatrix();
    strokeWeight(2);
    translate(0, 0, 0);
    noFill();
    stroke(250, 30, 30);
    box(350);
    popMatrix();

    // --- 3. THREAD-SAFE RENDERING ---
    // We lock the thread briefly while drawing to prevent tearing/crashing
    synchronized(threadLock) {
        
        // Render Black Hole from BUFFER
        if (renderBhExists) {
            pushMatrix();
            translate(renderBhX, renderBhY, renderBhZ);

            // Event horizon
            fill(0); 
            noStroke();
            sphere(renderBhRIn * 3.5f); 

            // Magnetic zone
            noFill();
            strokeWeight(2);
            float time = millis() * 0.001f;
            int numRings = 8; 
            for (int i = 0; i < numRings; i++) {
                pushMatrix();
                rotateX(time + (PI / numRings) * i);
                rotateY(time * 0.7f + (PI / numRings) * i);
                stroke(70, 20, 70, 150);
                ellipse(0, 0, renderBhRIn * 15, renderBhRIn * 15);
                popMatrix();
            }
            popMatrix();
        }

        // RENDER PARTICLES
        myRenderer.display(); 
    }

    //myGUI.display();

    // --- 4. TRIGGER BACKGROUND PHYSICS ---
    if (!isPaused && !isCalculating) {
        isCalculating = true;
        thread("runPhysics"); 
    }
}

// --- 5. THE BACKGROUND THREAD ---
// This runs on a separate CPU core
void runPhysics() {
    myPhys.update(); 
    
    // The math is done! Briefly lock the thread to copy data safely
    synchronized(threadLock) {
        renderCount = mySystem.particles.size();
        
        // Copy particle data
        for (int i = 0; i < renderCount; i++) {
            Particle p = mySystem.particles.get(i);
            renderBuffer[i].x = p.pos.x;
            renderBuffer[i].y = p.pos.y;
            renderBuffer[i].z = p.pos.z;
            renderBuffer[i].temp = p.temp;
            renderBuffer[i].vel = p.vel;
            renderBuffer[i].alive = p.alive;
            renderBuffer[i].mass = p.mass;
        }
        
        // Copy Black Hole data
        if (myPhys.bh != null) {
            renderBhExists = true;
            renderBhX = myPhys.bh.pos.x;
            renderBhY = myPhys.bh.pos.y;
            renderBhZ = myPhys.bh.pos.z;
            renderBhRIn = myPhys.bh.r_in;
        } else {
            renderBhExists = false;
        }
    }
    
    isCalculating = false;
}

// --- CONTROLS ---
void keyPressed() {
    if (key == ' ') isPaused = !isPaused;
    if (key == 'r' || key == 'R') resetSimulation();
    
    // Add any other manual override keys here!
}
