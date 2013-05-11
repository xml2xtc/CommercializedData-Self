//javalib
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.*;
import java.io.File;
import java.io.FilenameFilter;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.*;
import java.net.HttpURLConnection;
//processinglib
import com.getflourish.stt.*;
import processing.video.*;

private static final Logger log = LoggerFactory.getLogger(PApplet.class);

public static final String API_KEY = "4bc0b0a1-6586-443c-b69b-f0d598924a6d";
public static final String SECRET = "16e5f296-f7b5-4a66-916f-c18a14324d1a";

public String UPLOAD_URL = null;
public String UPLOAD_XML = null;
public String UPLOAD_IMAGE = null;
public String CREATION_URL = null;
public String PRODUCT_XML = null;


VideoManager videoManager;
TextManager textManager;


void setup ()
{
  size(1280, 720);
  background(0);

  textManager = new TextManager2(this);
  textManager.setup();

  videoManager = new VideoManager(this);
  videoManager.setup();
}

void draw () {
  videoManager.draw();
  textManager.draw();
}

// Method is called if transcription was successfull 
void transcribe (String utterance, float confidence) {
  textManager.transcribe(utterance, confidence);
}






