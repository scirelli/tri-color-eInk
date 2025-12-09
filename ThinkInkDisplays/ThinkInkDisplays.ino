// Adafruit_ImageReader test for Adafruit E-Ink Breakouts.
// Demonstrates loading images from SD card or flash memory to the screen,
// to RAM, and how to query image file dimensions.
// Requires BMP file in root directory of QSPI Flash:

#include <Adafruit_GFX.h>         // Core graphics library
#include "Adafruit_ThinkInk.h"
#include <SdFat_Adafruit_Fork.h>  // SD card & FAT filesystem library
#include <Adafruit_SPIFlash.h>    // SPI / QSPI flash library
#include <Adafruit_ImageReader_EPD.h> // Image-reading functions

#define MIN_REFRESH_DELAY (3 * 60 * 1000)

// Comment out the next line to load from SPI/QSPI flash instead of SD card:
#define USE_SD_CARD
#define SD_CS       13  // SD card chip select
#define EPD_DC      6
#define EPD_CS      5
#define EPD_BUSY    12 // can set to -1 to not use a pin (will wait a fixed delay)
#define SRAM_CS     9
#define EPD_RESET   11  // can set to -1 and share with microcontroller Reset!
#define EPD_SPI     &SPI // primary SPI

// Tri-Color Displays
ThinkInk_154_Tricolor_Z90 display(EPD_DC, EPD_RESET, EPD_CS, SRAM_CS, EPD_BUSY, EPD_SPI);

#if defined(USE_SD_CARD)
  SdFat                    SD;         // SD card filesystem
  Adafruit_ImageReader_EPD reader(SD); // Image-reader object, pass in SD filesys
#else
// SPI or QSPI flash filesystem (i.e. CIRCUITPY drive)
  #if defined(__SAMD51__) || defined(NRF52840_XXAA)
    Adafruit_FlashTransport_QSPI flashTransport(PIN_QSPI_SCK, PIN_QSPI_CS,
      PIN_QSPI_IO0, PIN_QSPI_IO1, PIN_QSPI_IO2, PIN_QSPI_IO3);
  #else
    #if (SPI_INTERFACES_COUNT == 1 || defined(ADAFRUIT_CIRCUITPLAYGROUND_M0))
      Adafruit_FlashTransport_SPI flashTransport(SS, &SPI);
    #else
      Adafruit_FlashTransport_SPI flashTransport(SS1, &SPI1);
    #endif
  #endif
  Adafruit_SPIFlash         flash(&flashTransport);
  FatVolume             filesys;
  Adafruit_ImageReader_EPD  reader(filesys); // Image-reader, pass in flash filesys
#endif

static void queryImageDim(const char* imageName);
static void loadImage(const char* imageName);
static void clearScreen();


Adafruit_Image_EPD   img;        // An image loaded into RAM
int32_t              width  = 0, // BMP image dimensions
                     height = 0;


static void queryImageDim(const char* imageName) {
  ImageReturnCode stat; // Status from image-reading functions
  // Query the dimensions of image WITHOUT loading to screen:
  Serial.print(F("Querying ")); Serial.print(imageName); Serial.println(F(" image size..."));
  stat = reader.bmpDimensions(imageName, &width, &height);
  reader.printStatus(stat);   // How'd we do?
  if(stat == IMAGE_SUCCESS) { // If it worked, print image size...
    Serial.print(F("Image dimensions: "));
    Serial.print(width);
    Serial.write('x');
    Serial.println(height);
  }
}

static void loadImage(const char* imageName) {
  ImageReturnCode stat; // Status from image-reading functions
  // Load full-screen BMP file 'imageName' at position (0,0) (top left).
  // Notice the 'reader' object performs this, with 'epd' as an argument.
  Serial.print(F("Loading ")); Serial.print(imageName); Serial.println(F(" to canvas..."));
  stat = reader.drawBMP((char*)imageName, display, 0, 0);
  reader.printStatus(stat); // How'd we do?

  queryImageDim(imageName);//This assumes the image is at the root of the file system.

  Serial.print(F("Drawing canvas to EPD..."));

  // Load small BMP 'imageName' into a GFX canvas in RAM. This should fail
  // gracefully on Arduino Uno and other small devices, meaning the image
  // will not load, but this won't make the program stop or crash, it just
  // continues on without it. Should work on larger ram boards like M4, etc.
  stat = reader.loadBMP(imageName, img);
  reader.printStatus(stat); // How'd we do?
}

static void clearScreen() {
  display.fillScreen(0);
  display.clearBuffer();
}


void setup(void) {
  Serial.begin(9600);
  while(!Serial);           // Wait for Serial Monitor before continuing

  display.begin(THINKINK_TRICOLOR);

  Serial.print(F("Initializing filesystem..."));
  // SPI or QSPI flash requires two steps, one to access the bare flash
  // memory itself, then the second to access the filesystem within...
#if defined(USE_SD_CARD)
  // SD card is pretty straightforward, a single call...
  if(!SD.begin(SD_CS, SD_SCK_MHZ(10))) { // Breakouts require 10 MHz limit due to longer wires
    Serial.println(F("SD begin() failed"));
    for(;;); // Fatal error, do not continue
  }
#else
  // SPI or QSPI flash requires two steps, one to access the bare flash
  // memory itself, then the second to access the filesystem within...
  if(!flash.begin()) {
    Serial.println(F("flash begin() failed"));
    for(;;);
  }
  if(!filesys.begin(&flash)) {
    Serial.println(F("filesys begin() failed"));
    for(;;);
  }
#endif
  Serial.println(F("OK!"));

}

void loop() {
  loadImage("capitalone5.bmp");
  clearScreen();
  display.setRotation(2);
  img.draw(display, 0, 0);
  display.display();

  delay(MIN_REFRESH_DELAY);

  loadImage("qrcode-rb.bmp");
  clearScreen();
  img.draw(display, 0, 0);
  display.display();

  delay(MIN_REFRESH_DELAY);

  loadImage("qrcode-wb.bmp");
  clearScreen();
  img.draw(display, 0, 0);
  display.display();

  delay(MIN_REFRESH_DELAY);

  loadImage("qrcode-br.bmp");
  clearScreen();
  img.draw(display, 0, 0);
  display.display();

  delay(MIN_REFRESH_DELAY);

  loadImage("qrcode-rw.bmp");
  clearScreen();
  img.draw(display, 0, 0);
  display.display();

  delay(MIN_REFRESH_DELAY);

  loadImage("qrcode-wr.bmp");
  clearScreen();
  img.draw(display, 0, 0);
  display.display();

  delay(MIN_REFRESH_DELAY);
}
