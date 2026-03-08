// BarnesHutTree.pde
// BACKEND: $O(N \log N)$ spatial partitioning for self-gravity

class BarnesHutNode {
    float x, y, z, width;         // Bounding box center and size
    float mass, comX, comY, comZ; // Center of Mass data
    
    int particleIndex;            // Which particle is here? (-1 if empty or internal node)
    boolean isLeaf;               // Is this a branch or an endpoint?
    int[] children;               // Pointers to the 8 sub-octants in the memory pool
    
    BarnesHutNode() {
        children = new int[8];
        reset();
    }
    
    void reset() {
        mass = 0; comX = 0; comY = 0; comZ = 0;
        particleIndex = -1;
        isLeaf = true;
        for (int i = 0; i < 8; i++) children[i] = -1;
    }
}

class BarnesHutTree {
    BarnesHutNode[] pool;
    int nextAvailableNode = 0;
    
    float theta = 0.5f;       // Accuracy vs Speed threshold. 0.5 is standard.
    float gravityG = 5.0f;    // Gravitational Constant (Tuned for the simulation)
    float softeningSq = 10.0f; // Prevents infinite forces when particles overlap

    BarnesHutTree(int maxParticles) {
        // An Octree typically needs up to 8x the number of particles in nodes
        int poolSize = maxParticles * 8; 
        pool = new BarnesHutNode[poolSize];
        for (int i = 0; i < poolSize; i++) {
            pool[i] = new BarnesHutNode();
        }
    }

    // --- STEP 1: BUILD THE TREE ---
    void build(ParticleData data, float boundsSize) {
        nextAvailableNode = 0; // Reset the memory pool! Zero GC!
        
        // Initialize the root node (Node 0)
        int rootIndex = allocateNode();
        BarnesHutNode root = pool[rootIndex];
        root.x = 0; root.y = 0; root.z = 0;
        root.width = boundsSize;
        
        // Insert all active particles into the tree
        for (int i = 0; i < data.activeCount; i++) {
            insert(rootIndex, i, data);
        }
    }

    private int allocateNode() {
        if (nextAvailableNode >= pool.length) {
            println("ERROR: Barnes-Hut Tree Memory Pool Exhausted!");
            return 0; // Prevent crash, but physics will glitch this frame
        }
        int idx = nextAvailableNode;
        pool[idx].reset();
        nextAvailableNode++;
        return idx;
    }

    private void insert(int nodeIdx, int particleIdx, ParticleData data) {
        BarnesHutNode node = pool[nodeIdx];
        
        // 1. Update this node's Center of Mass
        float pMass = data.mass[particleIdx];
        float pX = data.x[particleIdx];
        float pY = data.y[particleIdx];
        float pZ = data.z[particleIdx];
        
        // Center of mass formula: (m1*x1 + m2*x2) / (m1 + m2)
        float newMass = node.mass + pMass;
        node.comX = ((node.comX * node.mass) + (pX * pMass)) / newMass;
        node.comY = ((node.comY * node.mass) + (pY * pMass)) / newMass;
        node.comZ = ((node.comZ * node.mass) + (pZ * pMass)) / newMass;
        node.mass = newMass;

        // 2. Base Case: If node is empty, put the particle here
        if (node.isLeaf && node.particleIndex == -1) {
            node.particleIndex = particleIdx;
            return;
        }

        // 3. Collision Case: If it's a leaf but already has a particle, 
        // we must split it, push the old particle down, then push the new one down.
        if (node.isLeaf) {
            node.isLeaf = false;
            int oldParticleIdx = node.particleIndex;
            node.particleIndex = -1; // It is now an internal branch
            
            subdivideAndInsert(nodeIdx, oldParticleIdx, data);
        }

        // 4. Recursive Case: If it's an internal node, push the new particle down
        subdivideAndInsert(nodeIdx, particleIdx, data);
    }

    private void subdivideAndInsert(int nodeIdx, int pIdx, ParticleData data) {
        BarnesHutNode node = pool[nodeIdx];
        
        // Find which of the 8 sub-quadrants the particle belongs in
        int octant = getOctant(node.x, node.y, node.z, data.x[pIdx], data.y[pIdx], data.z[pIdx]);
        
        // If the child doesn't exist yet, allocate it
        if (node.children[octant] == -1) {
            int childIdx = allocateNode();
            node.children[octant] = childIdx;
            
            // Set the bounding box for the new child
            BarnesHutNode child = pool[childIdx];
            child.width = node.width / 2.0f;
            float quarter = child.width / 2.0f;
            
            // Offset the center based on the octant
            child.x = node.x + ((octant & 1) != 0 ? quarter : -quarter);
            child.y = node.y + ((octant & 2) != 0 ? quarter : -quarter);
            child.z = node.z + ((octant & 4) != 0 ? quarter : -quarter);
        }
        
        insert(node.children[octant], pIdx, data);
    }

    // Bitwise magic to find the correct 3D quadrant (0 to 7)
    private int getOctant(float nx, float ny, float nz, float px, float py, float pz) {
        int oct = 0;
        if (px >= nx) oct |= 1;
        if (py >= ny) oct |= 2;
        if (pz >= nz) oct |= 4;
        return oct;
    }
}
