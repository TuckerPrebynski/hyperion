float dt = 0.016f;
float simBounds = 2000.0f; // Total width of your simulation box
float collapseDensityThreshold = 10.0f; // TUNE THIS: How dense before it collapses?


//sph params
float smoothingRadius = 14.0f; // The 'h' in SPH math
float restDensity = 8.0f; // Tuning variable: How densely packed should the star be?
float gasConstant = 35.0f; // Tuning variable: How stiff/bouncy is the plasma?

float friction = 0.995f;

//Viscosity of mongahan in pressure calc
float alphaVisc = 25.0f; // Tuning variable: How thick/syrupy is the shockwave?


//BarnesHut params (GRAVITY)
float gravityG = 20.0f;    // Gravitational Constant (Tuned for the simulation)
float softeningSq = 10.0f; // Prevents infinite forces when particles overlap
float theta = 0.5f;       // Accuracy vs Speed threshold. 0.5 is standard.

int stepsleft = 5;
float stepsscale = .7;
class physics_eng {
  float[] ax;
  float[] ay;
  float[] az;

  int hitThreshold = 0;

  public BlackHole bh = null;

  BarnesHutTree gravityTree;
  // The SPH 'h' value (how far particles look for neighbors)
  float searchRadius = 20.0f;
  float maxDensity = 0.0;

  // 1. The spatial hash grid
  //<>//

  // 2. The neighbor cache (Array of IntLists)
  IntList[] neighborLists;

  // 3. Our reusable callback
  CachingCallback cacheCallback;



  SPHKernels kernels;


  // In your constructor:
  // Setup grid (e.g., 64x64x64 grid, cells exactly the size of your smoothing radius)
  PointHashGridSearcher3 gridSearcher = new PointHashGridSearcher3(64, 64, 64, smoothingRadius);

  physics_eng() {
    int max = mySystem.maxParts;
    gravityTree = new BarnesHutTree(max);
    kernels = new SPHKernels(smoothingRadius);

    ax = new float[max];
    ay = new float[max];
    az = new float[max];

    // Initialize the cache array
    neighborLists = new IntList[max];
    for (int i = 0; i < max; i++) {
      neighborLists[i] = new IntList();
      ax[i] = 0.0f;
      ay[i] = 0.0f;
      az[i] = 0.0f;
    }

    // The textbook recommends setting grid spacing to 2.0 * searchRadius
    gridSearcher = new PointHashGridSearcher3(64, 64, 64, searchRadius * 2.0f);

    // Initialize the callback once
    cacheCallback = new CachingCallback(neighborLists);
  }

  public void update() {
    resetAccelerations();

    gravityTree.build(mySystem, simBounds);

    //step 0 - zero acceleration

    // Step 1: Build the searcher grid with current particle positions
    gridSearcher.build(mySystem);

    // Step 2: Build the neighbor lists cache (Translated from textbook)
    buildNeighborLists();

    // Step 3: Now we can calculate SPH forces using the cached lists!
    calculateDensityAndPressure();

    if (bh == null) {
      // Scan for a collapse

      float frameMaxDensity = 0.0f;
      Particle densestParticle = null;

      for (int i = 0; i < mySystem.particles.size(); i++) {
        Particle p = mySystem.particles.get(i);
        if (p.density > maxDensity) {
          maxDensity = p.density;
        }
        if (p.density > frameMaxDensity) {
          frameMaxDensity = p.density;
          densestParticle = p;
        }
      }

      if (frameMaxDensity > collapseDensityThreshold && densestParticle != null) {
        hitThreshold++;
        if (hitThreshold > 3) {
          println("STAR COLLAPSED! Black Hole Formed!");
          bh = new BlackHole(new PVector(0,0,0), densestParticle.vel, densestParticle.mass * 120.0f * densestParticle.density, searchRadius * 3.0f);
          densestParticle.alive = false;
          hitThreshold = 0;
        }
      } else {
        hitThreshold = 0;
      }

      println("Max density: ", maxDensity);
    } else {
      // The Black Hole is alive. Eat particles and apply extreme gravity.
      bh.accrete(mySystem, gravityG);
      bh.applyGravity(ax, ay, az, gravityG);
      if (stepsleft > 0) {
        stepsleft --;
      }
    }

    for (int i = 0; i < mySystem.numParts; i++) {
      gravityTree.applyGravity(i, mySystem, ax, ay, az);
    }

    // println("first point pos. x:", mySystem.particles.get(0).pos.x, ", y:", mySystem.particles.get(0).pos.y, ", z:", mySystem.particles.get(0).pos.z);
    // println("first point vel. x:", mySystem.particles.get(0).vel.x, ", y:", mySystem.particles.get(0).vel.y, ", z:", mySystem.particles.get(0).vel.z);
    // println("density: ",mySystem.particles.get(0).density, "presssure:",mySystem.particles.get(0).press);
    // println("neighbors: ", neighborLists[0]);
    integrate();
  }
  private void resetAccelerations() {

    for (int i = 0; i < mySystem.numParts; i++) {
      ax[i] = 0.0;
      ay[i] = 0.0;
      az[i] = 0.0;
    }
  }
  private void integrate() {
    for (int i = mySystem.numParts - 1; i >= 0; i--) {
      Particle p = mySystem.particles.get(i);
      if (!p.alive) {
        mySystem.particles.remove(i);
        //ax.remove(i);
        //ay.remove(i);
        //az.remove(i);
        mySystem.numParts--;
        continue;
      }

      // Update Velocity FIRST (This makes it Semi-Implicit instead of Explicit)

      p.vel.x += ax[i] * dt;
      p.vel.y += ay[i] * dt;
      p.vel.z += az[i] * dt;

      //p.vel.limit(150.0f);

      p.vel.mult(friction);
      // Then Update Position using the NEW velocity
      p.pos.x += p.vel.x * dt;
      p.pos.y += p.vel.y * dt;
      p.pos.z += p.vel.z * dt;

      // Optional: Update temperature based on velocity/pressure
      // so the frontend team can make fast particles glow brighter!
      // mySystem.temperature[i] = ...
    }
  }
  // Translated from the textbook's ParticleSystemmySystem3::buildNeighborLists
  private void buildNeighborLists() {
    for (int i = 0; i < mySystem.numParts; i++) {
      // 1. Clear the list for the current particle
      neighborLists[i].clear();

      // 2. Tell the callback which particle we are caching for
      cacheCallback.currentIndex = i;

      // 3. Run the search. The callback will populate neighborLists[i]
      gridSearcher.forEachNearbyPoint(
        mySystem.particles.get(i).pos.x, mySystem.particles.get(i).pos.y, mySystem.particles.get(i).pos.z,
        searchRadius,
        mySystem,
        cacheCallback
        );
    }
  }

  private void calculateDensityAndPressure() {
    // PASS 1: Calculate Density
    for (int i = 0; i < mySystem.numParts; i++) {
      // A particle always has at least its own mass/density
      float density = mySystem.particles.get(i).mass * kernels.poly6(0);

      IntList neighbors = neighborLists[i];
      for (int k = 0; k < neighbors.size(); k++) {
        int j = neighbors.get(k);

        float dx = mySystem.particles.get(i).pos.x - mySystem.particles.get(j).pos.x;
        float dy = mySystem.particles.get(i).pos.y - mySystem.particles.get(j).pos.y;
        float dz = mySystem.particles.get(i).pos.z - mySystem.particles.get(j).pos.z;
        float distSq = (dx*dx) + (dy*dy) + (dz*dz);

        density += mySystem.particles.get(j).mass * kernels.poly6(distSq);
      }

      mySystem.particles.get(i).density = density;

      // Calculate Pressure using Tait Equation of State (Equation of State for fluids)
      // P = k * (density - rest_density)
      // We max(0, ...) so particles don't suck each other together when spread out
      // THE TAIT EQUATION OF STATE
      // P = k * ((rho / rho_0)^gamma - 1)
      // We use gamma = 2.0 or 3.0 for a very stiff core, avoiding slow Math.pow()
      float densityRatio = density / restDensity;
      float gammaTerm = densityRatio * densityRatio * densityRatio; // Gamma = 3

      mySystem.particles.get(i).press = max(0.0f, gasConstant * (gammaTerm - 1.0f));
      //mySystem.particles.get(i).press = max(0.0f, gasConstant * (density - restDensity));
    }

    // PASS 2: Calculate Pressure Forces (Pushing apart)
    for (int i = 0; i < mySystem.numParts; i++) {
      float forceX = 0, forceY = 0, forceZ = 0;

      IntList neighbors = neighborLists[i];
      for (int k = 0; k < neighbors.size(); k++) {
        int j = neighbors.get(k);

        float dx = mySystem.particles.get(i).pos.x - mySystem.particles.get(j).pos.x;
        float dy = mySystem.particles.get(i).pos.y - mySystem.particles.get(j).pos.y;
        float dz = mySystem.particles.get(i).pos.z - mySystem.particles.get(j).pos.z;
        float distSq = (dx*dx) + (dy*dy) + (dz*dz);
        float dist = sqrt(distSq); // Unavoidable sqrt() for Spiky kernel

        if (dist > 0.0001f) {
          // The SPH Pressure Force Equation
          // F = -m * (Pi/rho_i^2 + Pj/rho_j^2) * Gradient(W)
          float pressureTerm = (mySystem.particles.get(i).press/ (mySystem.particles.get(i).density * mySystem.particles.get(i).density)) +
            (mySystem.particles.get(j).press / (mySystem.particles.get(j).density * mySystem.particles.get(j).density));

          float gradW = kernels.spikyGradient(dist);

          // Direction of the force (normalized vector from j to i)
          float dirX = dx / dist;
          float dirY = dy / dist;
          float dirZ = dz / dist;

          // Total force magnitude from this neighbor


          // Inside PASS 2 of calculateDensityAndPressure()

          // Calculate relative velocity
          float dvx = mySystem.particles.get(i).vel.x - mySystem.particles.get(j).vel.x;
          float dvy = mySystem.particles.get(i).vel.y - mySystem.particles.get(j).vel.y;
          float dvz = mySystem.particles.get(i).vel.z - mySystem.particles.get(j).vel.z;

          // Dot product of relative velocity and relative position
          float dotProduct = (dx * dvx) + (dy * dvy) + (dz * dvz);

          float viscosityForce = 0.0f;


          // ONLY apply viscosity if particles are moving TOWARDS each other (dot product < 0)
          if (dotProduct < 0.0f) {
            // Standard Monaghan artificial viscosity formulation (simplified)
            float mu = (smoothingRadius * dotProduct) / (distSq + 0.01f); // 0.01 prevents div by zero
            viscosityForce = -alphaVisc * mu / (mySystem.particles.get(i).density + mySystem.particles.get(j).density);
          }

          // Add the viscosity term to the pressure term!
          float totalForceMag = mySystem.particles.get(j).mass * (pressureTerm + viscosityForce) * gradW;

          forceX += dirX * totalForceMag;
          forceY += dirY * totalForceMag;
          forceZ += dirZ * totalForceMag;
        }
      }

      // Convert Force to Acceleration (F = ma => a = F/m).
      // We divide by density because this is a fluid force.
      ax[i] = (ax[i] + forceX/mySystem.particles.get(i).density);
      ay[i] = (ay[i] + forceY/mySystem.particles.get(i).density);
      az[i] = (az[i] + forceZ/mySystem.particles.get(i).density);
    }
  }
}
