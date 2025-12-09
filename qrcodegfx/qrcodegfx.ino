#include <Adafruit_GFX.h>         // Core graphics library
#include "Adafruit_ThinkInk.h"
#include <SdFat_Adafruit_Fork.h>  // SD card & FAT filesystem library
#include <Adafruit_SPIFlash.h>    // SPI / QSPI flash library
#include <Adafruit_ImageReader_EPD.h> // Image-reading functions
#include <QRCodeGFX.h>

#define MIN_REFRESH_DELAY (3 * 60 * 1000)

#define SD_CS       13  // SD card chip select
#define EPD_DC      6
#define EPD_CS      5
#define EPD_BUSY    12 // can set to -1 to not use a pin (will wait a fixed delay)
#define SRAM_CS     9
#define EPD_RESET   11  // can set to -1 and share with microcontroller Reset!
#define EPD_SPI     &SPI // primary SPI

// Tri-Color Displays
ThinkInk_154_Tricolor_Z90 display(EPD_DC, EPD_RESET, EPD_CS, SRAM_CS, EPD_BUSY, EPD_SPI);
QRCodeGFX qrcode(display);

void setup() {
  Serial.println(F("Init serial..."));
  Serial.begin(9600);
  while(!Serial);           // Wait for Serial Monitor before continuing

  Serial.println(F("Init display..."));
  display.begin(THINKINK_TRICOLOR);
  display.fillScreen(EPD_BLACK);

  Serial.println(F("Init QR..."));
  qrcode.setScale(4)                  //1 to 20
    .setColors(EPD_BLACK, EPD_RED);
  qrcode.getGenerator()
      .setErrorCorrectionLevel(QRCodeECCLevel::High)
      .setVersion(5);

  Serial.println(F("Draw QR..."));
  // Draw a small black and white QR code
  // Parameters:
  //   text: content to encode
  //   x: horizontal position (upper left corner)
  //   y: vertical position (upper left corner)
  if(!qrcode.draw("https://www.capitalone.com", 15, 15)) {
    // Error generating QR code!
    // Possible causes:
    // - Text too long for selected version
    // - Not enough memory
    Serial.println(F("Failed to generate QR code!"));
  }
  display.display();
}

void loop() {
  delay(MIN_REFRESH_DELAY);
}
