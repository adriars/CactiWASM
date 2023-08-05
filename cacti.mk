TARGET = cacti
SHELL = /bin/sh
.PHONY: all depend clean
.SUFFIXES: .cc .o

ifndef NTHREADS
  NTHREADS = 8
endif


LIBS = 
INCS = -lm

ifeq ($(TAG),dbg)
  DBG = -Wall 
  OPT = -ggdb -g -O0 -DNTHREADS=1
else
  DBG = 
  OPT = -g  -msse2 -mfpmath=sse -DNTHREADS=$(NTHREADS)
endif

#CXXFLAGS = -Wall -Wno-unknown-pragmas -Winline $(DBG) $(OPT) 
CXXFLAGS = -Wno-unknown-pragmas $(DBG) $(OPT) 
CXX = em++
CC  = emcc

SRCS  = area.cc bank.cc mat.cc main.cc Ucache.cc io.cc technology.cc basic_circuit.cc parameter.cc \
		decoder.cc component.cc uca.cc subarray.cc wire.cc htree2.cc extio.cc extio_technology.cc \
		cacti_interface.cc router.cc nuca.cc crossbar.cc arbiter.cc powergating.cc TSV.cc memorybus.cc \
		memcad.cc memcad_parameters.cc
		

OBJS = $(patsubst %.cc,obj_$(TAG)/%.o,$(SRCS))
PYTHONLIB_SRCS = $(patsubst main.cc, ,$(SRCS)) obj_$(TAG)/cacti_wrap.cc
PYTHONLIB_OBJS = $(patsubst %.cc,%.o,$(PYTHONLIB_SRCS)) 
INCLUDES       = -I /usr/include/python2.4 -I /usr/lib/python2.4/config

all: obj_$(TAG)/$(TARGET)

obj_$(TAG)/$(TARGET) : $(OBJS)
	$(CXX) $(OBJS) -o $@.html $(INCS) $(CXXFLAGS) $(LIBS) -pthread --embed-file tech_params/ --pre-js pre_js.js --shell-file template.html -s ALLOW_MEMORY_GROWTH=1 -s PTHREAD_POOL_SIZE=8 -s STACK_SIZE=131072 -s PROXY_TO_PTHREAD

#obj_$(TAG)/%.o : %.cc
#	$(CXX) -c $(CXXFLAGS) $(INCS) -o $@ $<

obj_$(TAG)/%.o : %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	-rm -f *.o _cacti.so cacti.py $(TARGET)


