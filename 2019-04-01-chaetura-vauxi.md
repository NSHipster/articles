---
title: Swift
author: Mattt
category: Swift
excerpt: >-
  Vaux's swifts (_Chaetura vauxi_) is a species of swift
  native to the American Pacific Northwest and South America.
  Like others in its genus,
  vaux's swifts are impressive aerialists,
  capable of high-precision maneuvers at speeds in excess of 100 km/h.
  On the other hand, they are often described as
  _"small, dark, fast-flying cigars with wings"_,
  which isn't a particularly majestic designation.
status:
  swift: n/a
retired: true
published: false
---

> Since the progress of civilization in our country
> has furnished thousands of convenient places for this Swallow to breed in,
> safe from storms, snakes, or quadrupeds,
> it has abandoned, with a judgment worthy of remark,
> its former abodes in the hollows of trees,
> and taken possession of the chimneys which emit no smoke in the summer season.
> For this reason, no doubt,
> it has obtained the name by which it is generally known.
>
> <cite>John J Audubon, _Birds of America_, Plate 158: "American Swift"</cite>

{% asset chaetura-hipsterus.png width="350" class="chaetura-hipsterus" alt="Chaetura hipsterus" %}

Vaux's swifts (_Chaetura vauxi_) is a species of swift
native to the American Pacific Northwest and South America.
Like others in its genus,
vaux's swifts are impressive aerialists,
capable of high-precision maneuvers at speeds in excess of 100 km/h.
On the other hand, they are frequently described as
_"small, dark, fast-flying cigars with wings"_,
which isn't a particularly majestic characterization.

In the Alphabet District of Portland Oregon
_(a short walk from NSHipster headquarters, as it were)_,
Chapman Elementary School
is host to North America's largest concentration of Vaux's swifts.

{% info %}
Appropriately enough,
Portland is also the home of Chris Lattner's
[alma mater](upcs).
{% endinfo %}

Every evening, from late summer through October,
thousands of swifts can be seen just before sunset
as they fly into the school's old smokestack to roost for the night.
At dawn, they emerge once again
and continue their migration to Central and South America.

Vaux's are among the more gregarious species of swifts,
observed to flock in the dozens.
Moving together as a group,
the whirling mass of birds flying in and out of their roost  
creates a phantasmal silhouette against the twilight sky .

Among the first computer simulations of this flocking behavior
was a program called [Boids](https://en.wikipedia.org/wiki/Boids),
created by Craig Reynolds in 1986.
It remains one of the most striking examples of <dfn>emergent behavior</dfn>,
with complex --- seemingly chaotic --- interactions
arising from a small set of simple rules:

- **separation**:
  steer to avoid crowding local flockmates
- **alignment**:
  steer towards the average heading of local flockmates
- **cohesion**:
  steer to move towards the average position
  (center of mass) of local flockmates

The [following simulation][flocking]
is an implementation of Craig Reynold's "Boids" program,
created by Daniel Shiffman using [Processing.js](http://processingjs.org).

<figure id="boids">

<figcaption>Click or tap to add a new bird.</figcaption>

{% asset processing.min.js %}

<script type="application/processing">
Flock flock;
void setup() {
  size(860,400);
  colorMode(RGB,255,255,255,100);
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 20; i++) {
    flock.addBoid(new Boid(new Vector3D(width/2,height/2),2.0f,0.05f));
  }
  smooth();
}
void draw() {
  background(100);
  flock.run();
}
// Add a new boid into the System
void mousePressed() {
  flock.addBoid(new Boid(new Vector3D(mouseX,mouseY),2.0f,0.05f));
}
class Flock {
  ArrayList boids; // An arraylist for all the boids
  Flock() {
    boids = new ArrayList(); // Initialize the arraylist
  }
  void run() {
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }
  void addBoid(Boid b) {
    boids.add(b);
  }
}
class Boid {
  Vector3D loc;
  Vector3D vel;
  Vector3D acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  Boid(Vector3D l, float ms, float mf) {
    acc = new Vector3D(0,0);
    vel = new Vector3D(random(-1,1),random(-1,1));
    loc = l.copy();
    r = 2.0f;
    maxspeed = ms;
    maxforce = mf;
  }
  
  void run(ArrayList boids) {
    flock(boids);
    update();
    borders();
    render();
  }
  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList boids) {
    Vector3D sep = separate(boids);   // Separation
    Vector3D ali = align(boids);      // Alignment
    Vector3D coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(2.0f);
    ali.mult(1.0f);
    coh.mult(1.0f);
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
  }
  
  // Method to update location
  void update() {
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    loc.add(vel);
    // Reset accelertion to 0 each cycle
    acc.setXYZ(0,0,0);
  }
  void seek(Vector3D target) {
    acc.add(steer(target,false));
  }
 
  void arrive(Vector3D target) {
    acc.add(steer(target,true));
  }
  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  Vector3D steer(Vector3D target, boolean slowdown) {
    Vector3D steer;  // The steering vector
    Vector3D desired = target.sub(target,loc);  // A vector pointing from the location to the target
    float d = desired.magnitude(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < 100.0f)) desired.mult(maxspeed*(d/100.0f)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = target.sub(desired,vel);
      steer.limit(maxforce);  // Limit to maximum steering force
    } else {
      steer = new Vector3D(0,0);
    }
    return steer;
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = vel.heading2D() + radians(90);
    fill(200);
    stroke(255);
    pushMatrix();
    translate(loc.x,loc.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }
  
  // Wraparound
  void borders() {
    if (loc.x < -r) loc.x = width+r;
    if (loc.y < -r) loc.y = height+r;
    if (loc.x > width+r) loc.x = -r;
    if (loc.y > height+r) loc.y = -r;
  }
  // Separation
  // Method checks for nearby boids and steers away
  Vector3D separate (ArrayList boids) {
    float desiredseparation = 25.0f;
    Vector3D sum = new Vector3D(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.distance(loc,other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        Vector3D diff = loc.sub(loc,other.loc);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      sum.div((float)count);
    }
    return sum;
  }
  
  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  Vector3D align (ArrayList boids) {
    float neighbordist = 50.0f;
    Vector3D sum = new Vector3D(0,0,0);
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.distance(loc,other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.limit(maxforce);
    }
    return sum;
  }
  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  Vector3D cohesion (ArrayList boids) {
    float neighbordist = 50.0f;
    Vector3D sum = new Vector3D(0,0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.distance(loc,other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.loc); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      return steer(sum,false);  // Steer towards the location
    }
    return sum;
  }
}
// Simple Vector3D Class 
static class Vector3D {
  float x;
  float y;
  float z;
  Vector3D(float x_, float y_, float z_) {
    x = x_; y = y_; z = z_;
  }
  Vector3D(float x_, float y_) {
    x = x_; y = y_; z = 0f;
  }
  
  Vector3D() {
    x = 0f; y = 0f; z = 0f;
  }
  void setX(float x_) {
    x = x_;
  }
  void setY(float y_) {
    y = y_;
  }
  void setZ(float z_) {
    z = z_;
  }
  
  void setXY(float x_, float y_) {
    x = x_;
    y = y_;
  }
  
  void setXYZ(float x_, float y_, float z_) {
    x = x_;
    y = y_;
    z = z_;
  }
  void setXYZ(Vector3D v) {
    x = v.x;
    y = v.y;
    z = v.z;
  }
  
  float magnitude() {
    return (float) Math.sqrt(x*x + y*y + z*z);
  }
  Vector3D copy() {
    return new Vector3D(x,y,z);
  }
  Vector3D copy(Vector3D v) {
    return new Vector3D(v.x, v.y,v.z);
  }
  
  void add(Vector3D v) {
    x += v.x;
    y += v.y;
    z += v.z;
  }
  void sub(Vector3D v) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
  }
  void mult(float n) {
    x *= n;
    y *= n;
    z *= n;
  }
  void div(float n) {
    x /= n;
    y /= n;
    z /= n;
  }
  void normalize() {
    float m = magnitude();
    if (m > 0) {
       div(m);
    }
  }
  void limit(float max) {
    if (magnitude() > max) {
      normalize();
      mult(max);
    }
  }
  float heading2D() {
    float angle = (float) Math.atan2(-y, x);
    return -1*angle;
  }
  Vector3D add(Vector3D v1, Vector3D v2) {
    Vector3D v = new Vector3D(v1.x + v2.x,v1.y + v2.y, v1.z + v2.z);
    return v;
  }
  Vector3D sub(Vector3D v1, Vector3D v2) {
    Vector3D v = new Vector3D(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z);
    return v;
  }
  Vector3D div(Vector3D v1, float n) {
    Vector3D v = new Vector3D(v1.x/n,v1.y/n,v1.z/n);
    return v;
  }
  Vector3D mult(Vector3D v1, float n) {
    Vector3D v = new Vector3D(v1.x*n,v1.y*n,v1.z*n);
    return v;
  }
  float distance (Vector3D v1, Vector3D v2) {
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    float dz = v1.z - v2.z;
    return (float) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }
}

</script>

<canvas width="860" height="400" tabindex="0" id="__processing0" class="processing-sketch" style="image-rendering: optimizeQuality !important;"></canvas>

</figure>

As you gaze upon this computational approximation of flocking swifts,
consider, for a moment, the emergent nature of your own behavior.

_What separates you from others?
How often is your direction more a consequence of your surroundings
than a reasoned, conscious choice?
And when you are, indeed, making such a decision,
how is your choice shaped by the consensus of your peers?_

...or don't.
Such philosophical introspection is but a fool's errand.

[flocking]: http://processingjs.org/learning/topic/flocking/
[upcs]: https://engineering.up.edu/abet-accredited-undergraduate-programs/computer-science.html
