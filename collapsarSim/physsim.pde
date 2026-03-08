

class physics_eng {
    FloatList ax = new FloatList(); 
    FloatList ay = new FloatList(); 
    FloatList az = new FloatList();
    System data;
    float dt = 0.016f; 
    float simBounds = 2000.0f; // Total width of your simulation box
    BlackHole bh = null; 
    float collapseDensityThreshold = 21.0f; // TUNE THIS: How dense before it collapses?
    BarnesHutTree gravityTree;
    // The SPH 'h' value (how far particles look for neighbors)
    float searchRadius = 20.0f; 
    
    // 1. The spatial hash grid
    
    
    // 2. The neighbor cache (Array of IntLists)
    IntList[] neighborLists;
    
    // 3. Our reusable callback
    CachingCallback cacheCallback;
    
    float smoothingRadius = 20.0f; // The 'h' in SPH math
    
    SPHKernels kernels;
    float restDensity = 5.0f; // Tuning variable: How densely packed should the star be?
    float gasConstant = 50.0f; // Tuning variable: How stiff/bouncy is the plasma?

// In your constructor: 
// Setup grid (e.g., 64x64x64 grid, cells exactly the size of your smoothing radius)
    PointHashGridSearcher3 gridSearcher = new PointHashGridSearcher3(64, 64, 64, smoothingRadius);
    
    physics_eng(System sharedData) {
        this.data = new System(sharedData); //<>//
        int max = data.maxParts; //<>//
        gravityTree = new BarnesHutTree(max);
        kernels = new SPHKernels(smoothingRadius);

        // Initialize the cache array
        neighborLists = new IntList[max];
        for (int i = 0; i < max; i++) {
            neighborLists[i] = new IntList(); 
        }
        
        // The textbook recommends setting grid spacing to 2.0 * searchRadius
        gridSearcher = new PointHashGridSearcher3(64, 64, 64, searchRadius * 2.0f);
        
        // Initialize the callback once
        cacheCallback = new CachingCallback(neighborLists);
    }

    public void update() {
        resetAccelerations();
        
        gravityTree.build(data, simBounds);
        
        // Step 1: Build the searcher grid with current particle positions
        gridSearcher.build(data);
        
        // Step 2: Build the neighbor lists cache (Translated from textbook)
        buildNeighborLists();
        
        // Step 3: Now we can calculate SPH forces using the cached lists!
        calculateDensityAndPressure();
       
       if (bh == null) {
            // Scan for a collapse
            float maxDensity = 0.0;
            for (int i = 0; i < data.particles.size(); i++) {
                Particle p = data.particles.get(i);
                if(p.density > maxDensity){
                  maxDensity = p.density;
                }
                if (p.density > collapseDensityThreshold) {
                    println("STAR COLLAPSED! Black Hole Formed!");
                    // Give it a massive starting weight and a radius based on your SPH h
                    bh = new BlackHole(p.pos, p.vel, p.mass * 100.0f, searchRadius * 3.0f);
                    p.alive = false;
                    break; 
                }
                
            }
            println("Max density: ",maxDensity);
        } else {
            // The Black Hole is alive. Eat particles and apply extreme gravity.
            bh.accrete(data, gravityTree.gravityG);
            bh.applyGravity(data, ax, ay, az, gravityTree.gravityG);
        }
        
         for (int i = 0; i < data.numParts; i++) {
             gravityTree.applyGravity(i, data, ax, ay, az);
         }
         
        //println("first point pos. x:", data.particles.get(0).pos.x, ", y:", data.particles.get(0).pos.y, ", z:", data.particles.get(0).pos.z);
        //println("first point vel. x:", data.particles.get(0).vel.x, ", y:", data.particles.get(0).vel.y, ", z:", data.particles.get(0).vel.z);
        //println("density: ",data.particles.get(0).density, "presssure:",data.particles.get(0).press);
        //println("neighbors: ", neighborLists[0]);
        integrate();
    }
    private void resetAccelerations() {

        for (int i = 0; i < data.numParts; i++){
          ax.set(i,0.0);
          ay.set(i,0.0);
          az.set(i,0.0);
        }
  }
    private void integrate() {
    for (int i = 0; i < data.numParts; i++) {
      Particle p = data.particles.get(i);
      if (!p.alive) {
                data.particles.remove(i);
                ax.remove(i);
                ay.remove(i);
                az.remove(i);
                data.numParts--;
                continue;
            }
            
      // Update Velocity FIRST (This makes it Semi-Implicit instead of Explicit)
      float friction = 0.995f;
      p.vel.x += ax.get(i) * dt;
      p.vel.y += ay.get(i) * dt;
      p.vel.z += az.get(i) * dt;
      
      p.vel.mult(friction);
      // Then Update Position using the NEW velocity
      p.pos.x += p.vel.x * dt;
      p.pos.y += p.vel.y * dt;
      p.pos.z += p.vel.z * dt;
      
      // Optional: Update temperature based on velocity/pressure 
      // so the frontend team can make fast particles glow brighter!
      // data.temperature[i] = ... 
      
    }
  }
    // Translated from the textbook's ParticleSystemData3::buildNeighborLists
    private void buildNeighborLists() {
        for (int i = 0; i < data.numParts; i++) {
            // 1. Clear the list for the current particle
            neighborLists[i].clear();
            
            // 2. Tell the callback which particle we are caching for
            cacheCallback.currentIndex = i;
            
            // 3. Run the search. The callback will populate neighborLists[i]
            gridSearcher.forEachNearbyPoint(
                data.particles.get(i).pos.x, data.particles.get(i).pos.y, data.particles.get(i).pos.z, 
                searchRadius, 
                data, 
                cacheCallback
            );
        }
    }

    private void calculateDensityAndPressure() {
    // PASS 1: Calculate Density
    for (int i = 0; i < data.numParts; i++) {
        // A particle always has at least its own mass/density
        float density = data.particles.get(i).mass * kernels.poly6(0); 
        
        IntList neighbors = neighborLists[i];
        for (int k = 0; k < neighbors.size(); k++) {
            int j = neighbors.get(k);
            
            float dx = data.particles.get(i).pos.x - data.particles.get(j).pos.x;
            float dy = data.particles.get(i).pos.y - data.particles.get(j).pos.y;
            float dz = data.particles.get(i).pos.z - data.particles.get(j).pos.z;
            float distSq = (dx*dx) + (dy*dy) + (dz*dz);
            
            density += data.particles.get(i).mass * kernels.poly6(distSq);
        }
        
        data.particles.get(i).density = density;
        
        // Calculate Pressure using Tait Equation of State (Equation of State for fluids)
        // P = k * (density - rest_density)
        // We max(0, ...) so particles don't suck each other together when spread out
        // THE TAIT EQUATION OF STATE
      // P = k * ((rho / rho_0)^gamma - 1)
        // We use gamma = 2.0 or 3.0 for a very stiff core, avoiding slow Math.pow()
        float densityRatio = density / restDensity;
        float gammaTerm = densityRatio * densityRatio * densityRatio; // Gamma = 3

        data.particles.get(i).press = max(0.0f, gasConstant * (gammaTerm - 1.0f));
        //data.particles.get(i).press = max(0.0f, gasConstant * (density - restDensity)); 
    }

    // PASS 2: Calculate Pressure Forces (Pushing apart)
    for (int i = 0; i < data.numParts; i++) {
        float forceX = 0, forceY = 0, forceZ = 0;
        
        IntList neighbors = neighborLists[i];
        for (int k = 0; k < neighbors.size(); k++) {
            int j = neighbors.get(k);
            
            float dx = data.particles.get(i).pos.x - data.particles.get(j).pos.x;
            float dy = data.particles.get(i).pos.y - data.particles.get(j).pos.y;
            float dz = data.particles.get(i).pos.z - data.particles.get(j).pos.z;
            float distSq = (dx*dx) + (dy*dy) + (dz*dz);
            float dist = sqrt(distSq); // Unavoidable sqrt() for Spiky kernel
            
            if (dist > 0.0001f) {
                // The SPH Pressure Force Equation
                // F = -m * (Pi/rho_i^2 + Pj/rho_j^2) * Gradient(W)
                float pressureTerm = (data.particles.get(i).press/ (data.particles.get(i).density * data.particles.get(i).density)) + 
                                     (data.particles.get(j).press / (data.particles.get(j).density * data.particles.get(j).density));
                
                float gradW = kernels.spikyGradient(dist);
                
                // Direction of the force (normalized vector from j to i)
                float dirX = dx / dist;
                float dirY = dy / dist;
                float dirZ = dz / dist;
                
                // Total force magnitude from this neighbor
          
                
                // Inside PASS 2 of calculateDensityAndPressure()
//float dx = data.particles.get(i).pos.x - data.particles.get(j).pos.x;
//float dy = data.particles.get(i).pos.y - data.particles.get(j).pos.y;
//float dz = data.particles.get(i).pos.z - data.particles.get(j).pos.z;

// Calculate relative velocity
float dvx = data.particles.get(i).vel.x - data.particles.get(j).vel.x;
float dvy = data.particles.get(i).vel.y - data.particles.get(j).vel.y;
float dvz = data.particles.get(i).vel.z - data.particles.get(j).vel.z;

// Dot product of relative velocity and relative position
float dotProduct = (dx * dvx) + (dy * dvy) + (dz * dvz);

float viscosityForce = 0.0f;
float alphaVisc = 25.0f; // Tuning variable: How thick/syrupy is the shockwave?

// ONLY apply viscosity if particles are moving TOWARDS each other (dot product < 0)
if (dotProduct < 0.0f) {
    // Standard Monaghan artificial viscosity formulation (simplified)
    float mu = (smoothingRadius * dotProduct) / (distSq + 0.01f); // 0.01 prevents div by zero
    viscosityForce = -alphaVisc * mu / (data.particles.get(i).density + data.particles.get(j).density);
}

// Add the viscosity term to the pressure term!
float totalForceMag = data.particles.get(j).mass * (pressureTerm + viscosityForce) * gradW;

forceX += dirX * totalForceMag;
forceY += dirY * totalForceMag;
forceZ += dirZ * totalForceMag;
            }
        }
        
        // Convert Force to Acceleration (F = ma => a = F/m). 
        // We divide by density because this is a fluid force.
        ax.set(i,ax.get(i) + forceX/data.particles.get(i).density); 
        ay.set(i,ay.get(i) + forceY/data.particles.get(i).density);
        az.set(i,az.get(i) + forceZ/data.particles.get(i).density);
    }
}

//private void calculateForces() {
//    for (int i = 0; i < data.numParts; i++) {
        
//        // Use the grid searcher to find neighbors and calculate SPH Density
//        gridSearcher.forEachNearbyPoint(
//            data.particles.get(i).pos.x, data.particles.get(i).pos.y, data.particles.get(i).pos.z, 
//            smoothingRadius, 
//            data, 
//            new NeighborCallback() {
//                public void onNeighborFound(int neighborIndex) {
//                    // DO SPH MATH HERE!
//                    // This code runs for every neighbor found.
//                    // e.g., density[i] += calculateKernelMath(distSq);
//                }
//            }
//        );
        
//        // ... apply gravity, etc.
//    }
//}
    }
