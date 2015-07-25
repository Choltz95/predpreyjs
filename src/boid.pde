
class Boid {
  PVector loc;
  PVector vel;
  PVector acc;
  int mass; //to calculate acceleration and radius of sphere.
  int maxForce = 6; //determines how much effect the different forces have on the acceleration.

  Boid(PVector location) {
    loc = location; //Boids start with given location and no vel or acc.
    vel = new PVector();
    acc = new PVector();
    mass = int(random(5, 10));
  }

  void flockForce(ArrayList<Boid> boids) {
    //The three behaviours that result in flocking; Defined below.
    avoidForce(boids);
    approachForce(boids);
    alignForce(boids);
  }

  void update() {
    //Calculate the next position of the boid.
    vel.add(acc);
    loc.add(vel);
    acc.mult(0); //Reset acc every time update() is called.
    vel.limit(5); //Arbitrary limit on speed.

    if (loc.x<=0) {
      loc.x = width;
    }
    if (loc.x>width) {
      loc.x = 0;
    }
    if (loc.y<=0) {
      loc.y = height;
    }
    if (loc.y>height) {
      loc.y = 0;
    }
  }

  void applyF(PVector force) {
    //F=ma
    force.div(mass);
    acc.add(force);
  }

  void display() {
    update();
    fill(0, 0);
    stroke(0);
    //Draw vel-vector, scaled by arbitrary factor.
    line(loc.x, loc.y, loc.x + 3*vel.x, loc.y + 3*vel.y);
  }

  void avoidForce(ArrayList<Boid> boids) {
    //Applies a force in the opposite direction of other boids average position
    float count = 0; //Keep track of how many boids are too close.
    PVector locSum = new PVector(); //To store positions of the ones that are too close.

    for (Boid other: boids) {
      int separation = mass + 20; //Desired separation from other boids. Arbitrarily linked to mass.

      PVector dist = PVector.sub(other.getLoc(), loc); //distance to other boid.
      float d = dist.mag();

      if (d != 0 && d<separation) { //If closer than desired, and not self.
        PVector otherLoc = other.getLoc();
        locSum.add(otherLoc); //All locs from closeby boids are added.
        count ++;
      }
    }
    if (count>0) { //Don't divide by zero.
      locSum.div(count); //Divide by number of positions that were added (to create average).
      PVector avoidVec = PVector.sub(loc, locSum); //AvoidVec connects loc and average loc.
      avoidVec.limit(maxForce*2.5); //Weigh by factor arbitrary factor 2.5.
      applyF(avoidVec);
    }
  }

  void approachForce(ArrayList<Boid> boids) {
    float count = 0; //Keep track of how many boids are within sight.
    PVector locSum = new PVector(); //To store locations of boids in sight.

    //Algorhithm analogous to avoidForce().
    for (Boid other: boids) {
      int approachRadius = mass + 60; //Radius in which to look for other boids.
      PVector dist = PVector.sub(other.getLoc(), loc);
      float d = dist.mag();

      if (d != 0 && d<approachRadius) {
        PVector otherLoc = other.getLoc();
        locSum.add(otherLoc);
        count ++;
      }
    }
    if (count>0) {
      locSum.div(count);
      PVector approachVec = PVector.sub(locSum, loc);
      approachVec.limit(maxForce);
      applyF(approachVec);
    }
  }

  void alignForce(ArrayList<Boid> boids) {
    float count = 0; //Keep track of how many boids are in sight.
    PVector velSum = new PVector(); //To store vels of boids in sight.

    //Algorhithm analogous to approach- and avoidForce.
    for (Boid other: boids) {
      int alignRadius = mass + 100;
      PVector dist = PVector.sub(other.getLoc(), loc);
      float d = dist.mag();

      if (d != 0 && d<alignRadius) {
        PVector otherVel = other.getVel();
        velSum.add(otherVel);
        count ++;
      }
    }
    if (count>0) {
      velSum.div(count);
      PVector alignVec = velSum;
      alignVec.limit(maxForce);
      applyF(alignVec);
    }
  }

  void repelForce(PVector obstacle, float radius) {
    //Force that drives boid away from obstacle.
    PVector futPos = PVector.add(loc, vel); //Calculate future position for more effective behavior.
    PVector dist = PVector.sub(obstacle, futPos);
    float d = dist.mag();

    if (d<=radius) {
      PVector repelVec = PVector.sub(loc, obstacle);
      repelVec.normalize();
      if (d != 0) { //Don't divide by zero.
        float scale = 1.0/d; //The closer to the obstacle, the stronger the force.
        repelVec.normalize();
        repelVec.mult(maxForce*7);
        if (repelVec.mag()<0) { //Don't let the boids turn around to avoid the obstacle.
          repelVec.y = 0;
        }
      }
      applyF(repelVec);
    }
  }

  PVector getLoc() {
    return loc;
  }
  PVector getVel() {
    return vel;
  }
}

class Predator extends Boid { //Predators are just boids with some extra characteristics.
  float maxForce = 10; //Predators are better at steering.
  Predator(PVector location, int scope) {
    super(location);
    mass = int(random(8, 15)); //Predators are bigger and have more mass.
  }

  void display() {
    update();
    fill(255, 140, 130);
    noStroke();
    ellipse(loc.x, loc.y, mass, mass);
  }

  void update() { //Same as for boid, but with different vel.limit().
    //Calculate the next position of the boid.
    vel.add(acc);
    loc.add(vel);
    acc.mult(0); //Reset acc every time update() is called.
    vel.limit(6); //Arbitrary limit on speed, hihger for a predator.

    if (loc.x<=0) {
      loc.x = width;
    }
    if (loc.x>width) {
      loc.x = 0;
    }
    if (loc.y<=0) {
      loc.y = height;
    }
    if (loc.y>height) {
      loc.y = 0;
    }
  }

  void approachForce(ArrayList<Boid> boids) { //Same as for boid, but with bigger approachRadius.
    float count = 0;
    PVector locSum = new PVector();

    for (Boid other: boids) {
      int approachRadius = mass + 260;
      PVector dist = PVector.sub(other.getLoc(), loc);
      float d = dist.mag();

      if (d != 0 && d<approachRadius) {
        PVector otherLoc = other.getLoc();
        locSum.add(otherLoc);
        count ++;
      }
    }
    if (count>0) {
      locSum.div(count);
      PVector approachVec = PVector.sub(locSum, loc);
      approachVec.limit(maxForce);
      applyF(approachVec);
    }
  }
}
