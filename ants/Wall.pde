class Wall{
  PVector pos;
  float size;
  
  Wall(float x, float y, float size_) {
    pos = new PVector(x, y);
    size = size_;
  }
  
  void show() {
    noStroke();
    fill(255, 0, 80);
    circle(pos.x, pos.y, 2*size);
  }
}
