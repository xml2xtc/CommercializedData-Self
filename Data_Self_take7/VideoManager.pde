public class VideoManager {
  Capture cam;
  PApplet p;

  public VideoManager(PApplet parent) {
    p = parent;
  }

  public void draw() {
    if (cam != null && cam.available()) {
      cam.read(); 
      set(0, 0, cam);
    }
  }

  public void setup() {
    String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } 
    else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }

      // The camera can be initialized directly using an 
      // element from the array returned by list():
      cam = new Capture(p, cameras[0]);
      cam.start();
    }
  }
}

