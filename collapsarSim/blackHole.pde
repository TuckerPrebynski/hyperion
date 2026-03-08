// BlackHole.pde

class BlackHole {
    public PVector pos;
    PVector vel;
    PVector spinAxis;
    float mass;
    float r_acc; // Outer accretion radius (Event horizon + violent magnetic zone)
    float r_in;  // Inner accretion radius (Absolute point of no return)
    
    BlackHole(PVector initPos, PVector initVel, float initMass, float r_accretion) {
        pos = initPos.copy();
        vel = initVel.copy();
        mass = initMass;
        r_acc = r_accretion;
        
        // The paper suggests an inner radius 10-100x smaller than the outer radius
        r_in = r_accretion * 0.1f; 
    }
    
    // The Accretion Logic based on Bate, Bonnell, and Price (1995)
    void accrete(System data, float gravityG) {
        for (int i = 0; i < data.particles.size(); i++) {
            Particle p = data.particles.get(i);
            if (!p.alive) continue; // Skip already dead particles
            
            PVector relPos = PVector.sub(p.pos, pos);
            PVector relVel = PVector.sub(p.vel, vel);
            float distSq = relPos.magSq();
            float dist = sqrt(distSq);
            
            // 1. Inner Radius Test: Unconditional consumption
            if (dist < r_in * 2.0) { // Just outside the absolute point of no return
                
                // 5% chance a particle gets caught in the magnetic jet instead of eaten
                if (random(1) < 0.005) {
                    
                    // Shoot it out the Y-axis (Up if above equator, Down if below)
                    float jetDirection = (p.pos.y > pos.y) ? 1.0 : -1.0;
                    
                    // Kill horizontal speed, apply massive vertical acceleration
                    p.vel.x *= 0.1; 
                    p.vel.z *= 0.1;
                    p.vel.y = jetDirection * 500.0; // BOOM.
                    
                    // Make it super hot (Bright blue/white in your renderer)
                    p.temp = 20000; 
                    
                } else if (dist < r_in) {
                    consume(p); // Eat everything else that crosses the boundary
                }
                
                continue;
            }
            /*if (dist < r_in) {
                consume(p);
                continue;
            }*/
            
            // 2. Outer Radius Test: Angular Momentum and Bound Checks
            if (dist < r_acc) {
                
                // Test A: Is the particle gravitationally bound to the black hole?
                // Kinetic Energy + Potential Energy < 0
                float vSq = relVel.magSq();
                boolean isBound = (0.5f * vSq) < (gravityG * mass / dist);
                
                // Test B: Specific Angular Momentum (Crucial for Accretion Disks!)
                // j = r x v. We need the momentum to be less than a circular orbit.
                PVector jVec = relPos.cross(relVel); 
                float jSq = jVec.magSq();
                
                // j_circ^2 = G * M * r_acc
                float jCircSq = gravityG * mass * r_acc;
                boolean lowAngularMomentum = jSq < jCircSq;
                
                // If it's bound and NOT spinning fast enough to orbit, it falls in!
                if (isBound && lowAngularMomentum) {
                    consume(p);
                }
            }
        }
    }
    
    private void consume(Particle p) {
        // Conservation of momentum: m1v1 + m2v2 = (m1+m2)vf
        float totalMass = mass*1.001 + p.mass;
        PVector momBH = PVector.mult(vel, mass);
        PVector momP = PVector.mult(p.vel, p.mass);
        
        vel = PVector.add(momBH, momP).div(totalMass);
        
        // Move BH slightly towards the center of mass of the eaten particle
        PVector posBH = PVector.mult(pos, mass);
        PVector posP = PVector.mult(p.pos, p.mass);
        pos = PVector.add(posBH, posP).div(totalMass);
        
        mass = totalMass; // Increase Black Hole mass
        
        // Flag for deletion (We don't remove it from the array yet to prevent crashing)
        p.alive = false; 
        r_acc += 0.1f;
        r_in = r_acc * 0.1f;
    }
    
    // Apply massive gravity to all remaining SPH particles
    void applyGravity(float[] ax, float[] ay, float[] az, float gravityG) {
        spinAxis = new PVector(0, 1, 0); // The axis the black hole spins around (Up)    
        for (int i = 0; i < mySystem.particles.size(); i++) {
            Particle p = mySystem.particles.get(i);
            if (!p.alive) continue;
            
            // --- 1. SHARED MATH ---
            PVector dir = PVector.sub(pos, p.pos); // Vector pointing to BH
            
            float distSq = dir.magSq() + 10.0f;    // Softened distance squared
            //if(distSq > 2000){distSq = 2000;}
            float dist = sqrt(distSq);             // Actual distance
            
            dir.normalize(); // We need the normalized direction for both forces
            float away = dir.copy().mult(-1).dot(p.vel);
            // --- 2. GRAVITY FORCE ---
            // Newton's Law: a = G * M / r^2
            float gravMag = ((gravityG * mass) / distSq); 
            
            // --- 3. SPIN FORCE ---
            // Tangent vector perpendicular to gravity and the Y-axis
            PVector tangent = spinAxis.cross(dir).normalize();
            // Spin gets stronger as it gets closer
            float spinMag = 900.0f / dist; 
            
            // --- 4. FLATTENING DRAG (Accretion Disk) ---
            // Slowly dampen the Y-velocity so particles settle into the X/Z equator
            p.vel.y *= 0.98f; 
            
            // --- 5. COMBINE AND APPLY ---
            // Add the gravity pull and the spin push together
            float totalAx = (dir.x * gravMag) + (tangent.x * spinMag);
            float totalAy = (dir.y * gravMag) + (tangent.y * spinMag);
            float totalAz = (dir.z * gravMag) + (tangent.z * spinMag);
            
            // Update the acceleration arrays exactly ONCE per particle
            float scale = 5;
            float negscale = min(.8f,(1/away));
            ax[i] = ax[i]* negscale+ totalAx*scale;
            ay[i] = ay[i]*negscale + totalAy*scale;
            az[i] = az[i]*negscale + totalAz*scale;
            if(stepsleft > 0){
              p.vel = p.vel.mult(stepsscale);
            }
        }
    }
}
