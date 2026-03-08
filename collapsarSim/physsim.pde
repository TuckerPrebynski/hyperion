

class physics_eng {

    System data;
    float dt = 0.016f; 
    
    // The SPH 'h' value (how far particles look for neighbors)
    float searchRadius = 20.0f; 
    
    // 1. The spatial hash grid
    
    
    // 2. The neighbor cache (Array of IntLists)
    IntList[] neighborLists;
    
    // 3. Our reusable callback
    CachingCallback cacheCallback;
    
    float smoothingRadius = 20.0f; // The 'h' in SPH math
    
    SPHKernels kernels;
    float restDensity = 1000.0f; // Tuning variable: How densely packed should the star be?
    float gasConstant = 2000.0f; // Tuning variable: How stiff/bouncy is the plasma?

// In your constructor: 
// Setup grid (e.g., 64x64x64 grid, cells exactly the size of your smoothing radius)
    PointHashGridSearcher3 gridSearcher = new PointHashGridSearcher3(64, 64, 64, smoothingRadius);
    
    physics_eng(System sharedData) {
        this.data = sharedData;
        int max = data.maxParts;
        
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
        // Step 1: Build the searcher grid with current particle positions
        gridSearcher.build(data);
        
        // Step 2: Build the neighbor lists cache (Translated from textbook)
        buildNeighborLists();
        
        // Step 3: Now we can calculate SPH forces using the cached lists!
        calculateDensityAndPressure();
        calculateForces();
        
        // ... (Black hole logic and integration)
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
        data.particles.get(i).press = max(0.0f, gasConstant * (density - restDensity)); 
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
                float forceMag = data.particles.get(j).mass * pressureTerm * gradW;
                
                forceX += dirX * forceMag;
                forceY += dirY * forceMag;
                forceZ += dirZ * forceMag;
            }
        }
        
        // Convert Force to Acceleration (F = ma => a = F/m). 
        // We divide by density because this is a fluid force.
        data.particles.get(i).acc.x += forceX/data.particles.get(i).density; 
        data.particles.get(i).acc.y += forceY/data.particles.get(i).density;
        data.particles.get(i).acc.z += forceZ/data.particles.get(i).density;
    }
}

private void calculateForces() {
    for (int i = 0; i < data.numParts; i++) {
        
        // Use the grid searcher to find neighbors and calculate SPH Density
        gridSearcher.forEachNearbyPoint(
            data.particles.get(i).pos.x, data.particles.get(i).pos.y, data.particles.get(i).pos.z, 
            smoothingRadius, 
            data, 
            new NeighborCallback() {
                public void onNeighborFound(int neighborIndex) {
                    // DO SPH MATH HERE!
                    // This code runs for every neighbor found.
                    // e.g., density[i] += calculateKernelMath(distSq);
                }
            }
        );
        
        // ... apply gravity, etc.
    }
}
    }
