// SPHKernels.pde
// Precomputes the massive fractional constants for SPH math.

class SPHKernels {
    float h;
    float hSq;
    
    // Precomputed coefficients
    float poly6_coeff;
    float spiky_grad_coeff;

    SPHKernels(float smoothingRadius) {
        this.h = smoothingRadius;
        this.hSq = h * h;
        
        // Poly6 constant: 315 / (64 * PI * h^9)
        poly6_coeff = 315.0f / (64.0f * PI * pow(h, 9));
        
        // Spiky Gradient constant: -45 / (PI * h^6)
        // Note: We keep it positive here and handle the negative sign in the force vector math
        spiky_grad_coeff = 45.0f / (PI * pow(h, 6)); 
    }

    // Used for DENSITY. 
    // Optimization: Takes distance SQUARED (distSq) so we avoid the slow Math.sqrt()!
    float poly6(float distSq) {
        if (distSq >= hSq || distSq < 0) return 0.0f;
        float diff = hSq - distSq;
        return poly6_coeff * diff * diff * diff;
    }

    // Used for PRESSURE FORCES. 
    // Requires actual distance (dist), so we have to use sqrt() before calling this.
    float spikyGradient(float dist) {
        if (dist >= h || dist <= 0.0001f) return 0.0f; // Avoid divide-by-zero
        float diff = h - dist;
        return spiky_grad_coeff * diff * diff;
    }
}
