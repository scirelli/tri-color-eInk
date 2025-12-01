# Tri-Color-Display


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
