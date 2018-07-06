CXX ?= g++
CC ?= gcc
CFLAGS = -Wall -Wconversion -O3 -fPIC
LIBS = blas/blas.a
SHVER = 3
OS = $(shell uname)
#LIBS = -lblas

all: train predict lib

lib: linear.o tron.o blas/blas.a
	if [ "$(OS)" = "Darwin" ]; then \
		LIBEXT=".dylib"; \
		SHARED_LIB_FLAG="-dynamiclib -install_name $(PREFIX)/lib/liblinear$${LIBEXT}"; \
	else \
		LIBEXT=".so.$(SHVER)"; \
 		SHARED_LIB_FLAG="-shared -Wl,-soname,liblinear$${LIBEXT}"; \
	fi; \
	$(CXX) $${SHARED_LIB_FLAG} linear.o tron.o blas/blas.a -o liblinear$${LIBEXT}

train: tron.o linear.o train.c blas/blas.a
	$(CXX) $(CFLAGS) -o train train.c tron.o linear.o $(LIBS)

predict: tron.o linear.o predict.c blas/blas.a
	$(CXX) $(CFLAGS) -o predict predict.c tron.o linear.o $(LIBS)

tron.o: tron.cpp tron.h
	$(CXX) $(CFLAGS) -c -o tron.o tron.cpp

linear.o: linear.cpp linear.h
	$(CXX) $(CFLAGS) -c -o linear.o linear.cpp

blas/blas.a: blas/*.c blas/*.h
	make -C blas OPTFLAGS='$(CFLAGS)' CC='$(CC)';

install:
	if [ "$(OS)" = "Darwin" ]; then \
		LIBFILE="liblinear.dylib"; \
	else \
		LIBFILE="liblinear.so.$(SHVER)"; \
	fi; \
	cp $${LIBFILE} /usr/local/lib
	cp predict /usr/local/bin
	cp train /usr/local/bin

clean:
	make -C blas clean
	make -C matlab clean
	rm -f *~ tron.o linear.o train predict liblinear.so.$(SHVER) liblinear.dylib
