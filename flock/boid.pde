
// Boid Class - flocking boids obey 3 rules:
  // cohesion: steer to avoid crowding local flockmates
  // separation: steer towards the average heading of local flockmates
  // alignment: steer to move toward the average position (center of mass) of local flockmates
class Boid {
  PVector loc;
  PVector vel;
  PVector acc;
  int mass;
  int max_force = 4; // determines how much effect the different forces have on the acceleration. 6
  int max_velocity = 3;//5
  int[] state = {0,0,0};

  Boid(PVector location) {
    loc = location; // Boids start with given location and no vel or acc.
    vel = new PVector();
    acc = new PVector();
    mass = int(random(5, 10));  
  }

  void flock(ArrayList<Boid> boids) {
    separate(boids);
    cohere(boids);
    align(boids);
  }

  void update() {
    vel.add(acc);
    loc.add(vel);
    acc.mult(0); // reset boid acceleration each frame
    vel.limit(max_velocity);

    //wrap edges
    if (loc.x<=0) { loc.x = width; }
    if (loc.x>width) { loc.x = 0; }
    if (loc.y<=0) { loc.y = height; }
    if (loc.y>height) { loc.y = 0; }
  }

  void display() {
    update();
    fill(0, 0);
    //stroke(0);
    stroke(state[0],state[1],state[2]);
    // represent boids as a vector proportional to velocity
    line(loc.x, loc.y, loc.x + 3*vel.x, loc.y + 3*vel.y);
  }

  // f=ma
  void apply_force(PVector force) {
    force.div(mass);
    acc.add(force);
  }

  // computer average location or 
  PVector compute_com(ArrayList<Boid> boids, int view_rad, boolean v) {
    float count = 0; // Keep track of how many boids are too close.
    PVector vec_sum = new PVector();

    for (Boid other: boids) {
      int separation = mass + view_rad;
      PVector dist = PVector.sub(other.getLoc(), loc); // distance to other boid.
      float d = dist.mag();

      if (d != 0 && d<separation) { // If closer than desired, and not self.
        PVector other_vec = new PVector();
        if(v) { other_vec = other.getVel(); } // if we want to average the velocities vs. locations
        else { other_vec = other.getLoc(); }
        vec_sum.add(other_vec); // All locs from closeby boids are added.
        count ++;
      }
    }
    vec_sum.div(count);
    if(count > 0) {
      return vec_sum;
    } else {
      return null;
    }
  }

  void separate (ArrayList<Boid> boids) {
    PVector com = compute_com(boids, 20, false);
    if(com != null) {
      state[2]+=2;
      PVector avoidVec = PVector.sub(loc, com);
      avoidVec.limit(max_force*2.5); // Weigh by factor arbitrary factor 2.5.
      apply_force(avoidVec);    
    }
  }

  void cohere(ArrayList<Boid> boids) {
    PVector com = compute_com(boids, 60, false);
    if(com != null) {
      state[1]+=2;
      PVector approachVec = PVector.sub(com, loc);
      approachVec.limit(max_force);
      apply_force(approachVec);
    }
  }

  void align(ArrayList<Boid> boids) {
    PVector com = compute_com(boids, 100, true);
    if(com != null) {
      state[1]+=2;
      PVector alignVec = PVector.sub(com, loc);
      alignVec.limit(max_force);
      apply_force(alignVec);
    }
  }

  void repelForce(PVector obstacle, float radius) {
    // Force that drives boid away from an object.
    PVector futPos = PVector.add(loc, vel); // Calculate future position for more effective behavior.
    PVector dist = PVector.sub(obstacle, futPos);
    float d = dist.mag();

    if (d<=radius) {
      PVector repelVec = PVector.sub(loc, obstacle);
      repelVec.normalize();
      state[1]=0;
      state[2]=0;
      state[0]+=20;
      if (d != 0) { // Don't divide by zero.
        float scale = 1.0/d; // scale force up as distance decreases
        repelVec.normalize();
        repelVec.mult(max_force*7);
      }
      apply_force(repelVec);
    }
  }

  void colorState() {

  }

  PVector getLoc() {
    return loc;
  }
  PVector getVel() {
    return vel;
  }
}

// Predator
class Predator extends Boid { // Predators are just boids with some extra characteristics.
  int max_force = 8; // predators are agile and fast 10
  int max_velocity = 4;//6
  Predator(PVector location, int scope) {
    super(location);
    mass = int(random(8, 15));
  }

  void display() {
    update();
    fill(255, 10, 10);
    noStroke();
    ellipse(loc.x, loc.y, mass, mass);
  }

  void chase(ArrayList<Boid> boids) {
    PVector com = super.compute_com(boids, 260, false);
    if(com != null) {
      PVector approachVec = PVector.sub(com, loc);
      approachVec.limit(max_force);
      apply_force(approachVec);
    }
  }
}
