// ParticleData.java
public class ParticleData {
    public int maxParticles;
    public int activeCount; // How many are currently alive
    
    // Position
    public float[] x, y, z;
    // Velocity
    public float[] vx, vy, vz;
    // Physics properties
    public float[] mass, density, pressure;
    // Visual properties (Frontend uses this)
    public float[] temperature; // Map this to color!
    
    public ParticleData(int max) {
        this.maxParticles = max;
        this.activeCount = 0;
        
        x = new float[max]; y = new float[max]; z = new float[max];
        vx = new float[max]; vy = new float[max]; vz = new float[max];
        mass = new float[max]; density = new float[max]; pressure = new float[max];
        temperature = new float[max];
    }
}
