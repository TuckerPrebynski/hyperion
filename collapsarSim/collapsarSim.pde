// CollapsarSim.pde
// MAIN ENTRY POINT

// 1. The Shared Memory Contract
ParticleData sharedData;

// 2. The Team Modules
PhysicsEngine backend;
Renderer frontend;

// Global settings
int MAX_PARTICLES = 20000; 

void setup() {
  // Set up a 3D canvas. Use P3D for hardware-accelerated 3D rendering.
  size(1920, 1080, P3D);
  
  // 1. Initialize the shared memory block FIRST
  sharedData = new ParticleData(MAX_PARTICLES);
  
  // (Optional) Populate the arrays with initial star data here 
  // so the frontend team has something to look at immediately.
  initStar(sharedData); 
  
  // 2. Initialize the team modules, passing them the shared data
  backend = new PhysicsEngine(sharedData);
  frontend = new Renderer(sharedData, this); // 'this' passes the Processing context for P3D
  
  println("Simulation Initialized. Ready for collapse.");
}

void draw() {
  // --- THE GAME LOOP ---
  
  // Step 1: Backend calculates the next frame of reality
  // (Gravity, SPH pressure, Black Hole accretion)
  backend.update();
  
  // Step 2: Frontend paints reality to the screen
  // (Additive blending, camera rotation, color mapping)
  frontend.render();
  
  // Step 3: Hackathon UI/Debugging
  surface.setTitle("Collapsar Sim | FPS: " + round(frameRate) + " | Particles: " + sharedData.activeCount);
}

// Quick helper function to give both teams starting data
void initStar(ParticleData data) {
  data.activeCount = MAX_PARTICLES;
  for (int i = 0; i < MAX_PARTICLES; i++) {
    // Spawn particles in a rough sphere
    float r = random(100, 400);
    float theta = random(TWO_PI);
    float phi = acos(random(-1, 1));
    
    data.x[i] = r * sin(phi) * cos(theta);
    data.y[i] = r * sin(phi) * sin(theta);
    data.z[i] = r * cos(phi);
    
    // Give them a slight tangential velocity to start the accretion spin
    data.vx[i] = -data.y[i] * 0.05;
    data.vy[i] = data.x[i] * 0.05;
    data.vz[i] = 0;
    
    data.mass[i] = 1.0;
    data.temperature[i] = random(5000, 10000); // Kelvin
  }
}
