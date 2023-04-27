class Marker {
  Type type;
  int i, j;
  int lifespan;
  int time_away;
  int from;
  PVector pos;
  Marker(int i_, int j_, int lifespan_, Type type_, int time_away_, int from_) {
    i = i_;
    j = j_;
    pos = new PVector(i, j);
    lifespan = lifespan_;
    type = type_;
    time_away = time_away_;
    from = from_;
  }
}
