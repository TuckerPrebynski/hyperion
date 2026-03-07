// ParticleData.pde
class ParticleData {
  int maxParticles;
  int activeCount; // How many are currently alive
  
  // Position
  float[] x, y, z;
  // Velocity
  float[] vx, vy, vz;
  // Physics properties
  float[] mass, density, pressure;
  // Visual properties (Frontend uses this)
  float[] temperature; // Map this to color!
  
  ParticleData(int max) {
    this.maxParticles = max;
    this.activeCount = 0;
    
    x = new float[max]; y = new float[max]; z = new float[max];
    vx = new float[max]; vy = new float[max]; vz = new float[max];
    mass = new float[max]; density = new float[max]; pressure = new float[max];
    temperature = new float[max];
  }
}