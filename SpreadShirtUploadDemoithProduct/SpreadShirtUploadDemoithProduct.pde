
//import net.sprd.tutorials.common.http.HttpCallCommand;
//import net.sprd.tutorials.common.http.HttpCallCommandFactory;
//import net.sprd.tutorials.common.http.HttpMethod;
//import net.sprd.tutorials.common.http.HttpUrlConnectionFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.File;
import java.io.*;

import java.net.HttpURLConnection;

private static final Logger log = LoggerFactory.getLogger(PApplet.class);

public static final String API_KEY = "...";
public static final String SECRET = "...";

public String UPLOAD_URL = null;
public String UPLOAD_XML = null;
public String UPLOAD_IMAGE = null;
public String CREATION_URL = null;
public String PRODUCT_XML = null;




void setup() {

  UPLOAD_URL = "http://api.spreadshirt.com/api/v1/shops/392894/designs";
  UPLOAD_XML = sketchPath("data/design.xml");
  UPLOAD_IMAGE = sketchPath("data/design.png");
  CREATION_URL = "http://api.spreadshirt.com/api/v1/shops/392894/products";
  PRODUCT_XML = sketchPath("data/product.xml");

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


//---------------PROBLEM IS IN HERE-----------
         // create product data using xml
         HttpCallCommand createProductCommand =
                 commandFactory.createPlainHttpCallCommand(CREATION_URL, HttpMethod.POST, null);
                 println("DESIGNID" + uploadUrl.substring(uploadUrl.lastIndexOf('/')+1));
         String productData = getXMLData(PRODUCT_XML);
         // use id from fetched design xml here -> my solution is only a hack
         productData = productData.replace("THE_DESIGN_ID", "u" + uploadUrl.substring(uploadUrl.lastIndexOf('/') + 1));
         createProductCommand.setInput(productData);
         println("productData!" + productData);
         createProductCommand.setApiKeyProtected(true);
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
//------problem could be in here 2-------
        private static String getXMLData(String fileName)
        
              throws IOException {
          ByteArrayOutputStream os = null;
          InputStream is = null;
          try {
              os = new ByteArrayOutputStream();
              is = new FileInputStream(new File(fileName));
              int length = 0;
              byte[] data = new byte[4096];
              while ((length = is.read(data)) != -1) {
                  os.write(data, 0, length);
              }
              return os.toString();
          } finally {
              if (os != null)
                  os.close();
              if (is != null)
                  is.close();
          }
      }
      




  void loop() {
  }

