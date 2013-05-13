public class TextManager implements FilenameFilter {
  PApplet p;
  STT stt;

  //---------Program Clock------------
  long saveInterval = 5000;
  long lastSaveTime = -1;
  //delay the time the text is changed
  //long delaytext = "";

  String myStringsFilename = "myStrings.txt";
  Vector<String> myStrings = new Vector<String>(); // thread safe


  //imagesdeclared
  ArrayList<PImage> images = new ArrayList<PImage>() ;
  int lastImageNumber = -1;

  int fileWidth = 6;

  boolean imageReadyforSave = false;
  boolean transcriptionReady = false;

  public TextManager(PApplet parent) {
    p = parent;
  }

  public void setup() {
    //readimage Strings fromDisk
    File folder = new File(sketchPath("assets/images"));
    String[] filenames = folder.list(this);
    for (int i = 0; i < filenames.length; i++) {
      images.add(loadImage(sketchPath("assets/images/"+filenames[i]))); // nf() allows to generate 01, 02, etc.
      lastImageNumber = max(lastImageNumber, int(filenames[i]));
    }


    // Init STT automatically starts listening
    stt = new STT(p);
    stt.enableDebug();
    stt.setLanguage("en"); 
    stt.enableAutoRecord();

    // Some text to display the result
    textFont(createFont("Arial", 24));

    readStringsFromDisk();
  }


  public void draw() {
    float winH10 = random(height);
    float winW10 = random(width);
    
    float winH9 = random(height);
    float winW9 = random(width);

    float winH8 = random(height);
    float winW8 = random(width);

    float winH7 = random(height);
    float winW7 = random(width);

    float winH6 = random(height);
    float winW6 = random(width);

    float winH5 = random(height);
    float winW5 = random(width);

    float winH4 = random(height);
    float winW4 = random(width);

    float winH3 = random(height);
    float winW3 = random(width);

    float winH2 = random(height);
    float winW2 = random(width);

    float winH1 = random(height);
    float winW1 = random(width);

    if (!myStrings.isEmpty()) {
       textSize(1);
      text(myStrings.get(myStrings.size() - 10), winW10, winH10);
       textSize(5);
      text(myStrings.get(myStrings.size() - 9), winW9, winH9);
      textSize(10);
      text(myStrings.get(myStrings.size() - 8), winW8, winH8);
      textSize(15);
      text(myStrings.get(myStrings.size() - 7), winW7, winH7);
      textSize(20);
      text(myStrings.get(myStrings.size() - 6), winW6, winH6);
      textSize(25);
      text(myStrings.get(myStrings.size() - 5), winW5, winH5);
      textSize(30);
      text(myStrings.get(myStrings.size() - 4), winW4, winH4);
      textSize(35);
      text(myStrings.get(myStrings.size() - 3), winW3, winH3);
      textSize(40);
      text(myStrings.get(myStrings.size() - 2), winW2, winH2);
      textSize(60);
      text(myStrings.get(myStrings.size() - 1), winW1, winH1);


      imageReadyforSave = true;
    }

    long now = millis();

    if (now > lastSaveTime + saveInterval) {
      saveStringsToDisk();
      lastSaveTime = now;
    }

    if (imageReadyforSave && transcriptionReady) {
      imageSaver();
      SpreadShirtUpload(lastImageNumber, fileWidth);
      imageReadyforSave = false;
      transcriptionReady = false;
    }
  }

  boolean accept(File dir, String name) {
    return name.toLowerCase().endsWith(".png");
  }
  void saveStringsToDisk() {
    String[] myStringsArray = myStrings.toArray(new String[0]);
    saveStrings("data/" + myStringsFilename, myStringsArray);
  }

  //read all the images from the data folder into an an array
  //tile the images 
  //saveimages to images folder
  void imageSaver() {
    //delay 500ms 

    lastImageNumber++;
    String fileName = sketchPath("assets/images/"+ nf(lastImageNumber, fileWidth) + ".png");
    saveFrame(fileName);
    images.add(loadImage(fileName)); // nf() allows to generate 01, 02, etc.

    println("SAVEDFRAME!");
  }


  void readStringsFromDisk() {
    String[] myStringsArray = loadStrings(myStringsFilename);
    myStrings.clear(); //
    Collections.addAll(myStrings, myStringsArray);
  }


  // Method is called if transcription was successfull 
  void transcribe (String utterance, float confidence) {
    if (utterance.length() > 0) {
      myStrings.add(utterance);
      transcriptionReady = true;
      println("weGotIT!");
    }
  }

  //manipulate the strings saved at disk at the end of the day 
  //or for test purposes if a key is pressed
  void textProcess() {
  }
}

//spreadshirtUploadfunction
void SpreadShirtUpload(int lastImageNumber, int fileWidth) { 
  UPLOAD_URL = "http://api.spreadshirt.com/api/v1/shops/392894/designs";
  UPLOAD_XML = sketchPath("data/design.xml");
  UPLOAD_IMAGE = sketchPath("assets/images/"+ nf(lastImageNumber, fileWidth) + ".png");
  CREATION_URL = "http://api.spreadshirt.com/api/v1/shops/392894/products";
  PRODUCT_XML = sketchPath("data/product.xml");
  ARTICLE_URL
  ARTICLE_XML = sketchPath("data/article.xml");

  try {

    HttpUrlConnectionFactory urlConnectionFactory =
      new HttpUrlConnectionFactory(API_KEY, SECRET, null);
    HttpCallCommandFactory commandFactory =
      new HttpCallCommandFactory(urlConnectionFactory);

    // create design data using xml
    HttpCallCommand createDesignCommand =
      commandFactory.createPlainHttpCallCommand(UPLOAD_URL, HttpMethod.POST, null);
    createDesignCommand.setInput(getXMLData(UPLOAD_XML));
    createDesignCommand.setApiKeyProtected(true);
    createDesignCommand.execute();
    if (createDesignCommand.getStatus() >= 400) {
      throw new Exception("Could not create design xml!");
    }
    println(nf(lastImageNumber, fileWidth));
    println("XML location is: " + createDesignCommand.getUrl());
    
    // get created design xml
    HttpCallCommand getDesignCommand =
      commandFactory.createPlainHttpCallCommand(createDesignCommand.getLocation(), HttpMethod.GET, null);
    getDesignCommand.execute();
    if (createDesignCommand.getStatus() >= 400) {
      throw new Exception("Could not retrieve design xml from " + createDesignCommand.getLocation() + "!");
    }
    String message = (String) getDesignCommand.getOutput();

    // determine upload location
    String searchString = "resource mediaType=\"png\" type=\"montage\" xlink:href=\"";
    int index = message.indexOf(searchString);
    String uploadUrl = message.substring(index + searchString.length(), 
    message.indexOf("\"", index + searchString.length() + 1));
    println("Upload location is: " + uploadUrl);

    // upload image
    HttpCallCommand uploadDesignCommand =
      commandFactory.createFileHttpCallCommand(uploadUrl, HttpMethod.PUT, null, new File(UPLOAD_IMAGE), null);
    uploadDesignCommand.setApiKeyProtected(true);
    uploadDesignCommand.execute();
    if (uploadDesignCommand.getStatus() >= 400) {
      println(uploadDesignCommand.getErrorMessage());
      throw new Exception("Status above 400 expected but status was " + uploadDesignCommand.getStatus() + "!");
    }

    //    catch (Exception exc) {
    //      exc.printStackTrace();
    //    }
    //  }
    // println("productData!" + productData);

    //---------------PROBLEM IS IN HERE---------- is it the order of the URL ie API CALL
    // create product data using xml
    HttpCallCommand createProductCommand =
      commandFactory.createPlainHttpCallCommand(CREATION_URL, HttpMethod.POST, null);
    println("DESIGNID" + uploadUrl.substring(uploadUrl.lastIndexOf('/')+1));
    String productData = getXMLData(PRODUCT_XML);

    // use id from fetched design xml here -> my solution is only a hack
    productData = productData.replace("THE_DESIGN_ID", "u" + uploadUrl.substring(uploadUrl.lastIndexOf('/') + 1));
    createProductCommand.setInput(productData);
    createProductCommand.setApiKeyProtected(true);
    println("productdataVARIABLE HERE" + productData);
    //--could happen after excute? 
    createProductCommand.execute();
    if (createProductCommand.getStatus() >= 400) {
      throw new Exception("Could not create product xml!");
    }
    println("XML location is: " + createProductCommand.getLocation());
  }
  
  //create modify ARTICLEXML and Post XML to spreadshirt  
      // create product data using xml
    HttpCallCommand createArticleCommand =
      commandFactory.createPlainHttpCallCommand(CREATION_URL, HttpMethod.POST, null);
    println("DESIGNID" + uploadUrl.substring(uploadUrl.lastIndexOf('/')+1));
    String articleData = getXMLData(ARTICLE_XML);

    // use id from fetched design xml here -> my solution is only a hack
    productData = productData.replace("THE_PRODUCT_ID", "u" + uploadUrl.substring(uploadUrl.lastIndexOf('/') + 1));
    createProductCommand.setInput(productData);
    createProductCommand.setApiKeyProtected(true);
    println("productdataVARIABLE HERE" + productData);
    //--could happen after excute? 
    createProductCommand.execute();
    if (createProductCommand.getStatus() >= 400) {
      throw new Exception("Could not create product xml!");
    }
    println("XML location is: " + createProductCommand.getLocation());
  }
  
  
  
  catch (Exception exc) {
    exc.printStackTrace();
  }
}
private static String getXMLData(String fileName)

throws IOException {
  ByteArrayOutputStream os = null;
  InputStream is = null;
  try {
    os = new ByteArrayOutputStream();
    is = new FileInputStream(new File(fileName));
    int length = 0;
    byte[] data = new byte[4096];
    while ( (length = is.read (data)) != -1) {
      os.write(data, 0, length);
    }
    return os.toString();
  } 
  finally {
    if (os != null)
      os.close();
    if (is != null)
      is.close();
  }
}
