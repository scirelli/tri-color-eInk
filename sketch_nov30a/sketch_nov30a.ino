#define VBAT_PIN     A6
#define ECS_PIN      5  # E-Ink Chip Select
#define DATA_CMD_PIN 6  # Data/Command Pin E-Ink
#define SRCS_PIN     9  # SRAM Chip Select (E-Ink)
#define SDCS_PIN     10 # SDcard Chip Select (E-Ink)
#define RST_PIN      11 # E-Ink Reset pin
#define BUSY_PIN     12 # E-Ink Busy pin

/**
* Notes:
* 1.54" Tri-Color 200x200 Pixel Display
* Do not update more than once every 180 seconds or you may permanently damage the display
* The larger red ink dots will slowly rise, turning the display pinkish instead of white background.
* To keep the background color clear and pale, refresh once a day
*/
void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(115200);
  while (!Serial) {
    delay(10);
  }
}

void loop() {
  float measuredvbat = analogRead(VBAT_PIN);
  measuredvbat *= 2;     // we divided by 2, so multiply back
  measuredvbat *= 3.3;   // Multiply by 3.3V, our reference voltage
  measuredvbat /= 1024;  // convert to voltage
  Serial.print("VBat: ");
  Serial.println(measuredvbat);
  digitalWrite(LED_BUILTIN, HIGH);  // turn the LED on (HIGH is the voltage level)
  delay(1000);                      // wait for a second
  digitalWrite(LED_BUILTIN, LOW);   // turn the LED off by making the voltage LOW
  delay(1000);
}
