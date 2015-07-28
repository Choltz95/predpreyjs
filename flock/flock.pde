// A flocking simulation based on Daniel Shiffman's The Nature of Code

ArrayList<Boid> boids = new ArrayList<Boid>();
ArrayList<Predator> preds = new ArrayList<Predator>();
int num_boids = 20;
int num_preds = 1;
PVector mouse_loc; // Mouse-vector
float obstRad = 60; // Radius of boid sight.

boolean STATS;
boolean HELP;
boolean FRATE;
boolean FLOCKING = true;
boolean PREDATOR= true;
boolean MOUSE_OBST;
boolean COHERE;
boolean SEPARATE;
boolean ALIGN;

void setup() {
  HELP = false;
  STATS = false;
  FRATE = false;
  COHERE = true;
  SEPARATE = true;
  ALIGN = true;
  MOUSE_OBST = false;

  FLOCKING = true;
  PREDATOR = true;

  num_boids = 20;
  num_preds = 2;
  obstRad = 60;

  size(800, 400);
  smooth();
  frameRate(60); 
  noStroke();

  for (int i=0; i<num_boids; i++) {
    boids.add(new Boid(new PVector(random(0, width), random(0, height))));
  }
  for (int j=0; j<num_preds; j++) {
    preds.add(new Predator(new PVector(random(0, width), random(0, height)), 50));
  }
}

void draw() {
  fill(255, 255, 255, 50);
  rect(0, 0, width, height);

    if (STATS) { stats(); }
    if (HELP) { help(); }
    if (FRATE) { showFrameRate(); }
    init_run();
}

void showFrameRate() {
  int fps = int(frameRate);
  fill(0, 0, 0);
  text("frames / sec:", 10, 98);
  text(fps, 85, 98);
}

void help() {
  String legend = "Predator: p \nObstacle: o \nAdd Boids: click \nStats: s \nDisplay Framerate: f";
  fill(0, 0, 0);
  text(legend, 10, 10, 150, 120);
}

void stats() {
  fill(0, 0, 0);
  text("Boids:", 10, 85);
  text(boids.size(), 50, 85);
}

void init_run() {
  if (mousePressed) { // Add boid by clicking.
    mouse_loc = new PVector(mouseX,mouseY);
    boids.add(new Boid(mouse_loc));
  }
  for (Boid boid: boids) {
    if (PREDATOR) { // Flee from each predator.
      for (Predator pred: preds) {
        PVector predBoid = pred.getLoc();
        boid.repelForce(predBoid, obstRad);
      }
    }
    if (MOUSE_OBST) { // Flee from mouse.
      mouse_loc = new PVector(mouseX,mouseY);
      boid.repelForce(mouse_loc, obstRad);
    }
    if (FLOCKING) { // Execute flocking rules.
      boid.flock(boids);
    }
    boid.display();
  }
  for (Predator pred: preds) { // Predator flocking mechanic
    if (FLOCKING) {
      pred.flock(boids);
      pred.chase(boids);
      for (Predator otherpred: preds){ // Predators should not run into other predators.
        if (otherpred.getLoc() != pred.getLoc()){
          pred.repelForce(otherpred.getLoc(), 30.0);
        }
      }
    }
    if(PREDATOR) {
      pred.display();
    }
  }
}

void keyPressed() {
  switch (key) {
    case 'p':
      PREDATOR = !PREDATOR;
      break;
    case 'o':
      MOUSE_OBST = !MOUSE_OBST;
      break; 
    case 's':
      STATS = !STATS;
      break;
    case 'h':
      HELP = !HELP;
      break;
    case 'f':
      FRATE = !FRATE;     
    default:  
      break;
  }
}
