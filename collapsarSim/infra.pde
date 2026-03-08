// NeighborCallback.java (or just put it in your main .pde)
interface NeighborCallback {
    void onNeighborFound(int neighborIndex);
}

// PointHashGridSearcher3.pde

class PointHashGridSearcher3 {
    float gridSpacing;
    int resX, resY, resZ;
    
    // Using Processing's IntList array to avoid Java object boxing!
    IntList[] buckets; 

    PointHashGridSearcher3(int resolutionX, int resolutionY, int resolutionZ, float gridSpacing) {
        this.resX = resolutionX;
        this.resY = resolutionY;
        this.resZ = resolutionZ;
        this.gridSpacing = gridSpacing;

        int numBuckets = resX * resY * resZ;
        buckets = new IntList[numBuckets];
        
        // Pre-allocate everything once
        for (int i = 0; i < numBuckets; i++) {
            buckets[i] = new IntList();
        }
    }

    // Hash function: Maps a 3D (x,y,z) coordinate to a 1D array index
    int getBucketIndex(float x, float y, float z) {
        // Floor division to find the grid cell
        int gx = floor(x / gridSpacing);
        int gy = floor(y / gridSpacing);
        int gz = floor(z / gridSpacing);

        // Safe modulo for wrapping around negative coordinates (Spatial Hashing trick)
        gx = (gx % resX + resX) % resX;
        gy = (gy % resY + resY) % resY;
        gz = (gz % resZ + resZ) % resZ;

        return gx + (gy * resX) + (gz * resX * resY);
    }

    // OVERRIDE: build() from the C++ textbook
    // Call this exactly once per frame BEFORE calculating SPH forces
    void build(System data) {
        // 1. Clear all buckets (O(1) operation, NO garbage collection!)
        for (int i = 0; i < buckets.length; i++) {
            buckets[i].clear();
        }

        // 2. Assign every active particle to a bucket
        for (int i = 0; i < data.numParts; i++) {
            int bucketIdx = getBucketIndex(data.particles.get(i).pos.x, data.particles.get(i).pos.y, data.particles.get(i).pos.z);
            buckets[bucketIdx].append(i);
        }
    }

    // OVERRIDE: forEachNearbyPoint() from the C++ textbook
    // Finds all particles within 'radius' of an origin point
    void forEachNearbyPoint(float ox, float oy, float oz, float radius, System data, NeighborCallback callback) {
        
        // Find the bounding box of grid cells that the radius sphere touches
        int minX = floor((ox - radius) / gridSpacing);
        int maxX = floor((ox + radius) / gridSpacing);
        int minY = floor((oy - radius) / gridSpacing);
        int maxY = floor((oy + radius) / gridSpacing);
        int minZ = floor((oz - radius) / gridSpacing);
        int maxZ = floor((oz + radius) / gridSpacing);

        float radiusSq = radius * radius; // Optimize by skipping Math.sqrt()

        // Loop through the surrounding grid cells
        for (int k = minZ; k <= maxZ; k++) {
            for (int j = minY; j <= maxY; j++) {
                for (int i = minX; i <= maxX; i++) {
                    
                    // Wrap coordinates
                    int gx = (i % resX + resX) % resX;
                    int gy = (j % resY + resY) % resY;
                    int gz = (k % resZ + resZ) % resZ;

                    int bucketIdx = gx + (gy * resX) + (gz * resX * resY);
                    IntList bucket = buckets[bucketIdx];

                    // Check every particle in this specific cell
                    for (int p = 0; p < bucket.size(); p++) {
                        int neighborIdx = bucket.get(p);

                        // Calculate distance to verify it's inside the actual sphere, not just the grid cell box
                        float dx = data.particles.get(neighborIdx).pos.x - ox;
                        float dy = data.particles.get(neighborIdx).pos.y - oy;
                        float dz = data.particles.get(neighborIdx).pos.z - oz;
                        float distSq = (dx * dx) + (dy * dy) + (dz * dz);

                        if (distSq <= radiusSq && distSq > 0) { // distSq > 0 prevents a particle from being its own neighbor
                            callback.onNeighborFound(neighborIdx);
                        }
                    }
                }
            }
        }
    }
}
// A reusable callback to avoid memory allocation inside the physics loop
class CachingCallback implements NeighborCallback {
    int currentIndex;
    IntList[] neighborLists; // Reference to our cache

    CachingCallback(IntList[] lists) {
        this.neighborLists = lists;
    }

    public void onNeighborFound(int neighborIndex) {
        // As the textbook states, only add if it's not the particle itself (i != j)
        if (currentIndex != neighborIndex) {
            neighborLists[currentIndex].append(neighborIndex);
        }
    }
}
