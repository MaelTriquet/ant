int pop = 300;
int[] scores;
float max_food = 30;
float[] food_radius;
ArrayList<PVector> foods = new ArrayList<PVector>();
float home_radius = 50;
ArrayList<PVector> homes = new ArrayList<PVector>();
Marker[][] markerMap;
int max_it = 1;
int marker_lifespan = width * width * width;
ArrayList<ArrayList<Ant>> colonies = new ArrayList<ArrayList<Ant>>();
boolean started = false;
ArrayList<Wall> walls = new ArrayList<Wall>();
float size_wall = 30;
boolean building = false;
boolean destroying = false;
boolean fooding = false;
boolean homing = false;
int[] colors;
boolean can_eat = false;
Threading[] threads = new Threading[8];
boolean showMark = false;

enum Type {
  toFood, toHome, toEnnemy
};

void setup() {
  size(800, 800);
  markerMap = new Marker[width][height];
  colorMode(HSB);
}

void draw() {
  background(0);
  if (mousePressed) {
    create_map();
  }
  noStroke();
  for (Wall w : walls) {
    w.show();
  }
  if (!started) {
    fill(95, 0, 255);
    for (int i = 0; i < foods.size(); i++) {
      circle(foods.get(i).x, foods.get(i).y, 30);
    }
    for (int i = 0; i < homes.size(); i++) {
      fill(0, 0, 255);
      circle(homes.get(i).x, homes.get(i).y, home_radius);
    }
  }
  if (started) {
    for (int i = 0; i < homes.size(); i++) {
      fill(colors[i], 255, 255);
      circle(homes.get(i).x, homes.get(i).y, home_radius);
    }
    fill(95, 0, 255);
    for (int i = 0; i < foods.size(); i++) {
      circle(foods.get(i).x, foods.get(i).y, food_radius[i]);
    }
    noStroke();
    for (int i = 0; i < homes.size(); i++) {
      if (scores[i] == 5) {
        colonies.get(i).add(new Ant(homes.get(i).x, homes.get(i).y, 1, i, true));
        //if (colonies.get(i).size() % 25 == 0) {
        //  colonies.get(i).add(new Ant(homes.get(i).x, homes.get(i).y, 0.6, i, false));
        //}
        scores[i] -= 5;
      }
    }
    for (int k = 0; k < max_it; k++) {
      for (int j = 0; j < homes.size(); j++) {
        int step = colonies.get(j).size() / threads.length;
        for (int i = 0; i < threads.length-1; i++) {
          threads[i] = new Threading(i * step, (i+1) * step - 1, j);
        }
        threads[threads.length - 1] = new Threading((threads.length-1) * step, colonies.get(j).size(), j);
        for (int i = 0; i < threads.length; i++) {
          threads[i].start();
        }
        try {
          for (int i = 0; i < threads.length; i++) {
            threads[i].join();
          }
        }
        catch (InterruptedException e) {
        }
      }
    }
    for (ArrayList<Ant> colony : colonies) {
      for (Ant a : colony) {
        a.show();
      }
    }

    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        if (markerMap[i][j] != null) {
          if (showMark) {
            stroke(colors[markerMap[i][j].from], 255, 255, map(pow(float(markerMap[i][j].lifespan)/float(marker_lifespan), 25), 0, 1, 0, 200));
            point(i, j);
          }
          markerMap[i][j].lifespan -= max_it;
          if (markerMap[i][j].lifespan < 1) {
            markerMap[i][j] = null;
          }
        }
      }
    }
  }
}

void keyPressed() {
  if ( key == 's') {
    showMark = !showMark;
  }
  if (key == '+') {
    max_it++;
  }
  if (key == '-') {
    if (max_it > 0) {
      max_it--;
    }
  }
  if (key == 'b') {
    building = !building;
  }
  if (key == 'd') {
    destroying = !destroying;
  }
  if (key == 'f') {
    fooding = !fooding;
  }
  if (key == 'h') {
    homing = !homing;
  }
  if (keyCode == ENTER) {
    started = true;
    scores = new int[homes.size()];
    for (int i = 0; i < scores.length; i++) {
      scores[i] = 0;
    }
    food_radius = new float[foods.size()];
    for (int i = 0; i < food_radius.length; i++) {
      food_radius[i] = max_food;
    }
    colors = new int[homes.size()];
    for (int i = 0; i < colors.length; i++) {
      colors[i] = floor(map(i, 0, colors.length, 0, 255));
    }
  }
}

void create_map() {
  if (building) {
    for (Wall w : walls) {
      if (dist(mouseX, mouseY, w.pos.x, w.pos.y) < size_wall) {
        return;
      }
    }
    walls.add(new Wall(mouseX, mouseY, size_wall));
  }
  if (destroying) {
    for (int i = 0; i < walls.size(); i++) {
      Wall w = walls.get(i);
      if (dist(mouseX, mouseY, w.pos.x, w.pos.y) < size_wall) {
        walls.remove(i);
        return;
      }
    }
  }
  if (!started) {
    if (fooding) {
      foods.add(new PVector(mouseX, mouseY));
    }
    if (homing) {
      homes.add(new PVector(mouseX, mouseY));
      colonies.add(new ArrayList<Ant>());
      for (int i = 0; i < pop; i++) {
        colonies.get(colonies.size()-1).add(new Ant(mouseX, mouseY, 1, colonies.size()-1, true));
        //if (i%10 == 0) {
        //  colonies.get(colonies.size()-1).add(new Ant(mouseX, mouseY, .6, colonies.size()-1, false));
        //}
      }
      homing = false;
    }
  }
}
