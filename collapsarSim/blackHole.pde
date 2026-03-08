// BlackHole.pde

class BlackHole {
    PVector pos;
    PVector vel;
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
            if (dist < r_in) {
                consume(p);
                continue;
            }
            
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
        float totalMass = mass + p.mass;
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
    }
    
    // Apply massive gravity to all remaining SPH particles
    void applyGravity(System data, FloatList ax, FloatList ay, FloatList az, float gravityG) {
        for (int i = 0; i < data.particles.size(); i++) {
            Particle p = data.particles.get(i);
            if (!p.alive) continue;
            
            PVector dir = PVector.sub(pos, p.pos);
            float distSq = dir.magSq() + 10.0f; // Softening parameter
            float dist = sqrt(distSq);
            
            // a = G * M / r^2
            float forceMag = (gravityG * mass) / (distSq * dist); 
            
            ax.set(i, ax.get(i) + dir.x * forceMag);
            ay.set(i, ay.get(i) + dir.y * forceMag);
            az.set(i, az.get(i) + dir.z * forceMag);
        }
    }
}
