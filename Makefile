install: build
    podman create --name temp_container localhost/org.cirelli.stm32cubeprogrammer
    podman cp temp_container:/app/stm32cube ./stm32cube
    podman rm temp_container

.PHONY: build
build:
	podman build -t org.cirelli.stm32cubeprogrammer -f Dockerfile .

all: build

.PHONY: run
run:
	podman run -it --rm localhost/org.cirelli.stm32cubeprogrammer /bin/bash
