# Tri-Color-Display
[Project Source](https://github.com/scirelli/tri-color-eInk)

## Setup

### ArdruinoIDE
* [Download](https://www.arduino.cc/en/software/)


### STM32F405 Feather Express
#### Board Setup
* From the "File" menu select "Preferences", find the "Additional Board Manager URLs" text box. The box is comma seperated.
* Add `https://github.com/stm32duino/BoardManagerFiles/raw/main/package_stmicroelectronics_index.json`
* From the "Tools" menu, go down to "Board" submenu and select "Board Manager"
* Search "STM32" and install.
* Quit and restart the Arduino IDE

* From the "Tools" menu, select "Generic STM32F4"
* Then select "Board part number" -> "Adafruit Feather STM32F405"
* Under "USB Support" select "CDC supercedes USART" so that Serial points to the USB port not the hardware serial
* Select "STM32CubeProgrammer (DFU)" as the upload method

##### Activate the Bootloader
* You must manually put the board into bootloader mode every time you want to upload. Do that by connecting the `B0` pin to 3.3V and clicking reset button.

##### Build/Install Cube Programmer
See Notes for why. This is Linux only. For Mac you will have to install teh STM32CubeProgrammer dmg.
* Download the cube programming [zip file](https://downloads.cirelli.org/files/stm32cubeprg-lin-v2-21-0.zip).
    ```
    wget -O stm32cubeprg-lin.zip https://downloads.cirelli.org/files/stm32cubeprg-lin-v2-21-0.zip
    ```
* Install it
    ```
    make install-CubePrgr
    ```

### Run Arduino IDE
* Use the make command `run-arduino` so that the STM32 directory is added to your path and Arduiino IDE can find the programmer.

### MacOS
* There is some bugs in the mac programmer version. The shell script they use looks for the wrong file.
* Go to `/Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs`
  ```
  cd /Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs
  ln -s STM32CubeProgrammer STM32_Programmer_CLI
  mkdir bin
  cd bin
  ln -s /Applications/STMicroelectronics/STM32Cube/STM32CubeProgrammer/STM32CubeProgrammer.app/Contents/MacOs/STM32CubeProgrammer STM32_Programmer_CLI
  ```
* This names the file to what it's the script. The script with the bugs is `/Users/$USER/Library/Arduino15/packages/STMicroelectronics/tools/STM32Tools/2.4.0/stm32CubeProg.sh`


### Notes
* Used a container to install the STM32CubeProgrammer then copied out the installed dir.
    ```
    make build
    podman create --name temp_container localhost/org.cirelli.stm32cubeprogrammer
    podman cp temp_container:/app/stm32cube ./stm32cube
    podman rm temp_container
    ```
* This seemed to work
* I then updated my path to include the bin directory in the STM32Cube dir.
    ```
    export PATH="$PATH":$(pwd)/stm32cube/bin
    ```
* I did add some extra udev rules, I'm not sure if they helped but they were already there from other attempts
    /etc/udev/rules.d/99-stm32-udev.rules 
    ```
    SUBSYSTEMS=='usb', ATTRS{idVendor}=='0483', GROUP='dialout', MODE='0666', SYMLINK+="STM32"
    ```
    /etc/udev/rules.d/99-arduino.rules 
    ```
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", GROUP="plugdev", MODE="0666"
    ```
* I was not able to use the Flatpak Arduino for some reason. I think it had to do with my PATH. Even running from the same terminal did not work. I ended up using the AppImage.


## References
* [Adafruit STM32 Setup Guide](https://learn.adafruit.com/adafruit-stm32f405-feather-express/arduino-ide-setup)
