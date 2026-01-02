export PATH := $(PATH):$(shell pwd)/stm32cube/bin
export PATH := $(PATH):/opt/AppImages/ImageMagick

CNT_MNGR ?= podman

install-CubePrgr: stm32cube
	echo 'Installig Cube Programmer'
	@touch install-CubePrgr

stm32cube: build-CubePrgr
	$(CNT_MNGR) create --name temp_container org.cirelli.containers/stm32cubeprogrammer
	$(CNT_MNGR) cp temp_container:/app/stm32cube ./stm32cube
	$(CNT_MNGR) rm temp_container

.PHONY: build-CubePrgr
build-CubePrgr: stm32cubeprg-lin.zip
	$(CNT_MNGR) build --platform linux/amd64 -t org.cirelli.containers/stm32cubeprogrammer -f STM32Container .

.PHONY: build-QREncode
build-QREncode: .qrencoder

.qrencoder:
	@$(CNT_MNGR) build -t org.cirelli.containers/qrencode -f QREncodeContainer .
	@touch .qrencoder

.PHONY: clean-QREncode
clean-QREncode:
	rm -f .qrencoder

.mosquitto:
	@$(CNT_MNGR) build -t org.cirelli.containers/mosquitto -f MosquittoContainer .
	@touch .mosquitto

.PHONY: build-Mosquitto
build-mosquitto: .mosquitto

.PHONY: clean-mosquitto
clean-mosquitto:
	@podman rmi org.cirelli.containers/mosquitto:latest
	@rm -f .mosquitto

OS := $(shell uname -s)
.PHONY: run-arduino
run-arduino: install-CubePrgr
ifeq ($(OS),Darwin)
	open -a "Arduino IDE"
else ifeq ($(OS),Linux)
	/opt/AppImages/ArduinoIDE/arduino-ide.AppImage
endif

.PHONY: run-mosquitto
run-mosquitto: .mosquitto
	@$(CNT_MNGR) run \
		--rm \
		--name mosquitto \
		--publish 1883:1883 \
		--publish 8883:8883 \
		--publish 9001:9001 \
		org.cirelli.containers/mosquitto:latest
#-v ./mosquitto.conf:/etc/mosquitto/conf.d/mosquitto.conf
#-v ./mosquitto.conf:/mosquitto/config/mosquitto.conf

TYPE ?= PNG
OUTPUTFILE ?= /tmp/qrcode.bmp
INPUTFILE ?= ./qr.txt
DATA ?= 'Hello world'
.PHONY: gen-qrencode
gen-qrencode: .qrencoder gen-qrencode-bw

.PHONY: gen-qrencode-wb
gen-qrencode-wb: .qrencoder
	@$(CNT_MNGR) run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% -type TrueColor BMP3:$(OUTPUTFILE)
	@# --read-from=$(INPUTFILE)
	@# --output=$(OUTPUTFILE)
	@#magick $(OUTPUTFILE) -background white -flatten -sample 200x200! -threshold 50% -type TrueColor BMP3:$(OUTPUTFILE).bmp
	@#-resize 200x200!
	@#-scale 200x200

.PHONY: gen-qrencode-bw
gen-qrencode-bw: .qrencoder
	@$(CNT_MNGR) run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors white,black -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: gen-qrencode-rb
gen-qrencode-rb: .qrencoder
	@$(CNT_MNGR) run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors red,black -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: gen-qrencode-br
gen-qrencode-br: .qrencoder
	@$(CNT_MNGR) run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors black,red -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: gen-qrencode-rw
gen-qrencode-rw: .qrencoder
	@$(CNT_MNGR) run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors red,white -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: gen-qrencode-wr
gen-qrencode-wr: .qrencoder
	@$(CNT_MNGR) run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors white,red -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: run-qrencode
run-qrencode: .qrencoder gen-qrencode
