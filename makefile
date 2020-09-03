###############################################################################
#                                                                             #
# MAKEFILE for Mongoose library                                               #
#                                                                             #
# (c) Guy Wilson 2020                                                         #
#                                                                             #
###############################################################################

# Directories
SOURCE = .
BUILD = build
DEP = dep
LIB = lib

# What is our target
TARGET = mg
LIBTARGET = lib$(TARGET).so

# Tools
CPP = g++
C = gcc
LINKER = g++

# postcompile step
PRECOMPILE = @ mkdir -p $(BUILD) $(DEP)
# postcompile step
POSTCOMPILE = @ mv -f $(DEP)/$*.Td $(DEP)/$*.d

PRELINK = @ mkdir -p $(LIB)

CPPFLAGS = -c -O2 -Wall -pedantic -fPIC -std=c++11
CFLAGS = -c -O2 -Wall -pedantic -fPIC
DEPFLAGS = -MT $@ -MMD -MP -MF $(DEP)/$*.Td

# Libraries
STDLIBS = -lstdc++
EXTLIBS =

COMPILE.cpp = $(CPP) $(CPPFLAGS) $(DEPFLAGS) $(MGFLAGS) -o $@
COMPILE.c = $(C) $(CFLAGS) $(DEPFLAGS) $(MGFLAGS) -o $@
LINK.o = $(LINKER) $(STDLIBS) -o $@

CSRCFILES = $(wildcard $(SOURCE)/*.c)
CPPSRCFILES = $(wildcard $(SOURCE)/*.cpp)
OBJFILES := $(patsubst $(SOURCE)/%.c, $(BUILD)/%.o, $(CSRCFILES)) $(patsubst $(SOURCE)/%.cpp, $(BUILD)/%.o, $(CPPSRCFILES))
DEPFILES = $(patsubst $(SOURCE)/%.c, $(DEP)/%.d, $(CSRCFILES)) $(patsubst $(SOURCE)/%.cpp, $(DEP)/%.d, $(CPPSRCFILES))

all: $(LIBTARGET)

# Compile C/C++ source files
#
$(LIBTARGET): $(OBJFILES)
	$(PRELINK)
	$(LINKER) -shared -o $(LIB)/$(LIBTARGET) $^ $(EXTLIBS)

$(BUILD)/%.o: $(SOURCE)/%.c
$(BUILD)/%.o: $(SOURCE)/%.c $(DEP)/%.d
	$(PRECOMPILE)
	$(COMPILE.c) $<
	$(POSTCOMPILE)

$(BUILD)/%.o: $(SOURCE)/%.cpp
$(BUILD)/%.o: $(SOURCE)/%.cpp $(DEP)/%.d
	$(PRECOMPILE)
	$(COMPILE.cpp) $<
	$(POSTCOMPILE)

.PRECIOUS = $(DEP)/%.d
$(DEP)/%.d: ;

-include $(DEPFILES)

install: $(LIBTARGET)
	cp $(LIB)/$(LIBTARGET) /usr/lib
	cp mongoose.h /usr/include

clean:
	rm -r $(BUILD)
	rm -r $(DEP)
	rm -r $(LIB)
	rm $(TARGET)
