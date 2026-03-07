// ParticleData.pde
// Shared data structure for particles accessed by both physics and frontend

class ParticleData {
  int maxParticles;
  int activeCount;
  
  // Position
  float[] x, y, z;
  // Velocity
  float[] vx, vy, vz;
  // Temperature (for rendering)
  float[] temperature;
  
  ParticleData(int maxParticles) {
    this.maxParticles = maxParticles;
    this.activeCount = 0;
    
    x = new float[maxParticles];
    y = new float[maxParticles];
    z = new float[maxParticles];
    vx = new float[maxParticles];
    vy = new float[maxParticles];
    vz = new float[maxParticles];
    temperature = new float[maxParticles];
  }
}

// PhysicsEngine.pde
// BACKEND: Handles all math, forces, and integration.

class PhysicsEngine {
  ParticleData data;
  
  // Time step per frame. Keep this fixed for stable physics!
  // Do not tie this to actual frame rate (dt = 1/60th of a second)
  float dt = 0.016f; 
  
  // Internal physics arrays (Frontend doesn't need these)
  float[] ax, ay, az; 
  
  // Central entity (the Black Hole / Collapsing Core)

  PhysicsEngine(ParticleData sharedData) {
    this.data = sharedData;
    
    // Allocate acceleration arrays to match the shared data size
    int max = data.maxParticles;
    ax = new float[max];
    ay = new float[max];
    az = new float[max];
    
    // Initialize the central mass
  }

  // --- THE MAIN PHYSICS LOOP ---
  // Called once per frame by CollapsarSim.pde
  void update() {
    
    // Step 1: Zero out accelerations from the previous frame
    resetAccelerations();
    
    // Step 2: Build spatial partition tree (Barnes-Hut)
    // TODO: Instantiate and populate Octree here later
    // Octree tree = new Octree(boundary);
    // for (int i = 0; i < data.activeCount; i++) { tree.insert(i); }
    
    // Step 3: Calculate all forces applying to particles
    calculateForces();
    
    // Step 4: Move the particles based on the forces
    integrate();
  }

  // --- PIPELINE METHODS ---

  private void resetAccelerations() {
    for (int i = 0; i < data.activeCount; i++) {
      ax[i] = 0.0f;
      ay[i] = 0.0f;
      az[i] = 0.0f;
    }
  }

  private void calculateForces() {
    for (int i = 0; i < data.activeCount; i++) {
      // 1. GRAVITY (Pull towards center)
      // TODO: Math goes here. Calculate vector to 'core', apply 1/r^2 law, add to ax, ay, az.
      
      // 2. SPH PRESSURE (Push away from neighbors)
      // TODO: Math goes here. Use Octree to find neighbors, apply SPH kernel, add to ax, ay, az.
      
      // Dummy test force: Just pull everything slightly towards the origin (0,0,0)
      ax[i] += -data.x[i] * 0.001f;
      ay[i] += -data.y[i] * 0.001f;
      az[i] += -data.z[i] * 0.001f;
    }
  }

  // --- INTEGRATION (The Secret Sauce) ---
  // This uses Semi-Implicit Euler. It is vastly more stable for orbits 
  // than standard explicit Euler, but just as cheap to calculate.
  private void integrate() {
    for (int i = 0; i < data.activeCount; i++) {
      // Update Velocity FIRST (This makes it Semi-Implicit instead of Explicit)
      data.vx[i] += ax[i] * dt;
      data.vy[i] += ay[i] * dt;
      data.vz[i] += az[i] * dt;
      
      // Then Update Position using the NEW velocity
      data.x[i] += data.vx[i] * dt;
      data.y[i] += data.vy[i] * dt;
      data.z[i] += data.vz[i] * dt;
      
      // Optional: Update temperature based on velocity/pressure 
      // so the frontend team can make fast particles glow brighter!
      // data.temperature[i] = ... 
    }
  }
}
