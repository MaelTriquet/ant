class Ant {
  PVector pos, vel;
  float vel_max = 2.5;
  float freedom;
  Type objective;
  Type dropping;
  Marker nose;
  int sent_last = marker_lifespan;
  float perif_vision = 0.3;
  int time_away = 0;
  boolean dropped = false;
  int home;
  boolean isWorker;
  Ant(float x, float y, float freedom_, int home_, boolean isWorker_) {
    pos = new PVector(x, y);
    isWorker = isWorker_;
    objective = Type.toFood;
    if (!isWorker) {
      vel_max = 3;
      objective = null;
    }
    vel = (new PVector(random(-1, 1), random(-1, 1)).normalize()).mult(vel_max);
    dropping = Type.toHome;
    freedom = freedom_;
    home = home_;
  }

  void show() {
    noStroke();
    fill(colors[home], 255, 255);
    if (isWorker) {
      circle(pos.x, pos.y, 10);
      if (dropping == Type.toFood) {
        fill(95, 0, 255);
        circle(pos.x, pos.y, 5);
      }
    } else {
      rectMode(CENTER);
      rect(pos.x, pos.y, 15, 15);
    }
  }

  void update() {
    if (isWorker) {
      if (time_away % 3 == 0 && !dropped) {
        drop();
        dropped = true;
      } else {
        dropped = false;
      }
      int x = floor(pos.x);
      int y = floor(pos.y);
      for (int i = -20; i < 20; i++) {
        for (int j = -20; j < 20; j++) {
          PVector vect_ij = new PVector(i, j);
          if (x+i > -1 && x+i < width && y+j > -1 && y+j < height && normed_dot(vect_ij, vel) > perif_vision && vect_ij.mag() < 20) {
            if (markerMap[x + i][y + j] != null) {
              if (markerMap[x + i][y + j].from == home) {
                if (markerMap[x + i][y + j].type == objective && markerMap[x + i][y + j].lifespan > 0) {
                  if (nose == null) {
                    nose = markerMap[x + i][y + j];
                  } else if (nose.time_away > markerMap[x + i][y + j].time_away) {
                    nose = markerMap[x + i][y + j];
                  }
                }
              } //else {
              //  nose = null;
              //  vel.mult(-1);
              //  objective = Type.toHome;
              //  dropping = Type.toEnnemy;
              //}
            }
          }
        }
      }
      if (nose != null) {
        vel = (new PVector(nose.i-pos.x, nose.j-pos.y)).normalize().mult(vel_max);
      }
      nose = null;
      applyFreedom();
      pos.add(vel);
      for (Wall w : walls) {
        if (dist(pos.x, pos.y, w.pos.x, w.pos.y) < w.size) {
          vel.mult(-1);
          PVector temp = ((pos.copy().sub(w.pos)).normalize()).mult(w.size);
          pos = w.pos.copy().add(temp);
        }
      }
      if (pos.x < 0) {
        pos.x = 0;
        vel.x *= -1;
      }
      if (pos.x > width-1) {
        pos.x = width-1;
        vel.x *= -1;
      }
      if (pos.y < 0) {
        pos.y = 0;
        vel.y *= -1;
      }
      if (pos.y > height-1) {
        pos.y = height-1;
        vel.y *= -1;
      }
      time_away++;
      getFood();
      dropFood();
    } else {
      if (dist(homes.get(home).x, homes.get(home).y, pos.x, pos.y) > width / 5 && objective == null) {
        objective = Type.toHome;
      }
      int x = floor(pos.x);
      int y = floor(pos.y);
      for (int i = -20; i < 20; i++) {
        for (int j = -20; j < 20; j++) {
          PVector vect_ij = new PVector(i, j);
          if (x+i > -1 && x+i < width && y+j > -1 && y+j < height && normed_dot(vect_ij, vel) > perif_vision && vect_ij.mag() < 20) {
            if (markerMap[x + i][y + j] != null) {
              if (markerMap[x + i][y + j].from == home && markerMap[x + i][y + j].type == Type.toEnnemy && markerMap[x + i][y + j].lifespan > 0) {
                objective = Type.toEnnemy;
                nose = null;
              }
              if (markerMap[x + i][y + j].type == objective && markerMap[x + i][y + j].lifespan > 0 && markerMap[x + i][y + j].from == home) {
                if (nose == null) {
                  nose = markerMap[x + i][y + j];
                } else if (nose.time_away > markerMap[x + i][y + j].time_away) {
                  nose = markerMap[x + i][y + j];
                }
              }
              for (int k = 0; i < colonies.size(); i++) {
                if (k != home) {
                  for (int l = colonies.get(k).size() - 1; l > -1; l--) {
                    if (dist(colonies.get(k).get(l).pos.x, colonies.get(k).get(l).pos.y, pos.x, pos.y) < 30) {
                      markerMap[floor(colonies.get(k).get(l).pos.x)][floor(colonies.get(k).get(l).pos.y)] = new Marker(floor(colonies.get(k).get(l).pos.x), floor(colonies.get(k).get(l).pos.y), sent_last, Type.toEnnemy, time_away, home);
                      nose = markerMap[floor(colonies.get(k).get(l).pos.x)][floor(colonies.get(k).get(l).pos.y)];
                    }
                    if (dist(colonies.get(k).get(l).pos.x, colonies.get(k).get(l).pos.y, pos.x, pos.y) < 7) {
                      colonies.get(k).remove(l);
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (nose != null) {
        vel = (new PVector(nose.i-pos.x, nose.j-pos.y)).normalize().mult(vel_max);
      }
      nose = null;
      applyFreedom();
      pos.add(vel);
      for (Wall w : walls) {
        if (dist(pos.x, pos.y, w.pos.x, w.pos.y) < w.size) {
          vel.mult(-1);
          PVector temp = ((pos.copy().sub(w.pos)).normalize()).mult(w.size);
          pos = w.pos.copy().add(temp);
        }
      }
      if (pos.x < 0) {
        pos.x = 0;
        vel.x *= -1;
      }
      if (pos.x > width-1) {
        pos.x = width-1;
        vel.x *= -1;
      }
      if (pos.y < 0) {
        pos.y = 0;
        vel.y *= -1;
      }
      if (pos.y > height-1) {
        pos.y = height-1;
        vel.y *= -1;
      }
      dropFood();
    }
  }
  void drop() {
    markerMap[floor(pos.x)][floor(pos.y)] = new Marker(floor(pos.x), floor(pos.y), sent_last, dropping, time_away, home);
  }

  void applyFreedom() {
    PVector freedom_vec = (new PVector(-vel.y, vel.x).normalize()).mult(random(-freedom, freedom));
    vel.add(freedom_vec);
    vel.normalize().mult(vel_max);
  }

  void getFood() {
    if (objective == Type.toFood) {
      for (int i = 0; i < foods.size(); i++) {
        if (dist(foods.get(i).x, foods.get(i).y, pos.x, pos.y) < food_radius[i] / 2) {
          objective = Type.toHome;
          vel.mult(-1);
          dropping = Type.toFood;
          if (food_radius[i] > 0 && can_eat) {
            food_radius[i] -= max_food/100;
          }
          time_away = 0;
        }
      }
    }
  }

  void dropFood() {
    if (dist(homes.get(home).x, homes.get(home).y, pos.x, pos.y) < home_radius / 2) {
      if (isWorker) {
        time_away = 0;
        if (dropping == Type.toFood) {
          scores[home]++;
        }
        if (objective == Type.toHome) {
          objective = Type.toFood;
          vel.mult(-1);
          dropping = Type.toHome;
        }
      } else {
        if (objective ==Type.toHome) {
          objective = null;
          vel.mult(-1);
        }
      }
    }
  }
}

float normed_dot(PVector p1, PVector p2) {
  float n1 = p1.mag();
  float n2 = p2.mag();
  return (p1.x * p2.x + p1.y * p2.y) / (n1*n2);
}
