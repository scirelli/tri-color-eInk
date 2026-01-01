export PATH := $(PATH):$(shell pwd)/stm32cube/bin
export PATH := $(PATH):/opt/AppImages/ImageMagick

install-CubePrgr: stm32cube
	echo 'Installig Cube Programmer'
	@touch install-CubePrgr

stm32cube: build-CubePrgr
	podman create --name temp_container localhost/org.cirelli.stm32cubeprogrammer
	podman cp temp_container:/app/stm32cube ./stm32cube
	podman rm temp_container

.PHONY: build-CubePrgr
build-CubePrgr: stm32cubeprg-lin.zip
	podman build --platform linux/amd64 -t org.cirelli.stm32cubeprogrammer -f STM32Container .

.PHONY: build-QREncode
build-QREncode: .qrencoder

.qrencoder:
	podman build -t org.cirelli.qrencode -f QREncodeContainer .
	touch .qrencoder

OS := $(shell uname -s)
.PHONY: run-arduino
run-arduino: install-CubePrgr
ifeq ($(OS),Darwin)
	open -a "Arduino IDE"
else ifeq ($(OS),Linux)
	/opt/AppImages/ArduinoIDE/arduino-ide.AppImage
endif


TYPE ?= PNG
OUTPUTFILE ?= /tmp/qrcode.bmp
INPUTFILE ?= ./qr.txt
DATA ?= 'Hello world'
.PHONY: gen-qrencode
gen-qrencode: .qrencoder gen-qrencode-bw

.PHONY: gen-qrencode-wb
gen-qrencode-wb: .qrencoder
	@podman run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% -type TrueColor BMP3:$(OUTPUTFILE)
	@# --read-from=$(INPUTFILE)
	@# --output=$(OUTPUTFILE)
	@#magick $(OUTPUTFILE) -background white -flatten -sample 200x200! -threshold 50% -type TrueColor BMP3:$(OUTPUTFILE).bmp
	@#-resize 200x200!
	@#-scale 200x200

.PHONY: gen-qrencode-bw
gen-qrencode-bw: .qrencoder
	@podman run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors white,black -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: gen-qrencode-rb
gen-qrencode-rb: .qrencoder
	@podman run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors red,black -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: gen-qrencode-br
gen-qrencode-br: .qrencoder
	@podman run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors black,red -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: gen-qrencode-rw
gen-qrencode-rw: .qrencoder
	@podman run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors red,white -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: gen-qrencode-wr
gen-qrencode-wr: .qrencoder
	@podman run -v /tmp:/tmp --rm qrencode:latest -l H --type=$(TYPE) -o - $(DATA) \
		| magick - -background white -flatten -sample 200x200! -threshold 50% +level-colors white,red -type TrueColor BMP3:$(OUTPUTFILE)

.PHONY: run-qrencode
run-qrencode: .qrencoder gen-qrencode
