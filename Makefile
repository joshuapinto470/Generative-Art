UNAME_S := $(shell uname)

ifeq ($(UNAME_S), Darwin)
	LDFLAGS = -Xlinker -framework,OpenGL -Xlinker -framework,GLUT
else
	LDFLAGS += -L/usr/local/cuda/samples/common/lib/linux/x86_64
	LDFLAGS += -lglut -lGL -lGLU -lGLEW -lcurand
endif

NVCC = /usr/local/cuda/bin/nvcc
NVCC_FLAGS = -Xcompiler "-Wall -Wno-deprecated-declarations"

all: main

main.exe: main.o kernel.o
	$(NVCC) $^ -o $@ $(LDFLAGS)

main.o: src/main.cpp includes/kernel.h includes/interactions.h
	$(NVCC) $(NVCC_FLAGS) -c $< -o $@

kernel.o: src/kernel.cu includes/kernel.h
	$(NVCC) $(NVCC_FLAGS) -c $< -o $@
