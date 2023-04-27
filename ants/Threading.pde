class Threading extends Thread {
  int start;
  int stop;
  int colonyNb;

  Threading(int start_, int stop_, int colonyNb_) {
    start = start_;
    stop = stop_;
    colonyNb = colonyNb_;
  }

  @Override
    void run() {
    for (int i = start; i < stop; i++) {
      colonies.get(colonyNb).get(i).update();
    }
  }
}
