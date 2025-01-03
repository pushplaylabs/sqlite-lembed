
COMMIT=$(shell git rev-parse HEAD)
VERSION=$(shell cat VERSION)
DATE=$(shell date +'%FT%TZ%z')

LLAMA_CMAKE_FLAGS=-DLLAMA_OPENMP=OFF
ifndef CC
CC=gcc
endif
ifndef AR
AR=ar
endif

ifeq ($(shell uname -s),Darwin)
CONFIG_DARWIN=y
else ifeq ($(OS),Windows_NT)
CONFIG_WINDOWS=y
else
CONFIG_LINUX=y
endif

ifdef CONFIG_DARWIN
LOADABLE_EXTENSION=dylib
CFLAGS+=-framework Accelerate -framework Foundation -framework Metal -framework MetalKit
LLAMA_CMAKE_FLAGS+=-DLLAMA_METAL=0
endif

ifdef CONFIG_LINUX
LOADABLE_EXTENSION=so
LLAMA_CMAKE_FLAGS+=-DCMAKE_POSITION_INDEPENDENT_CODE=ON
endif

ifdef CONFIG_WINDOWS
LOADABLE_EXTENSION=dll
endif


ifdef python
PYTHON=$(python)
else
PYTHON=python3
endif

release=1
ifdef release
LLAMA_CMAKE_FLAGS+=-DCMAKE_BUILD_TYPE=Release
else
LLAMA_CMAKE_FLAGS+=-DCMAKE_BUILD_TYPE=Debug
endif

prefix=dist

$(prefix):
	mkdir -p $(prefix)

TARGET_LOADABLE=$(prefix)/lembed0.$(LOADABLE_EXTENSION)
TARGET_STATIC=$(prefix)/libsqlite_lembed0.a
TARGET_STATIC_H=$(prefix)/sqlite-lembed.h

loadable: $(TARGET_LOADABLE)
static: $(TARGET_STATIC)


BUILD_DIR=$(prefix)/.build



$(BUILD_DIR):
	rm -rf @ || true
	cmake -B $@ $(LLAMA_CMAKE_FLAGS)


ifdef CONFIG_WINDOWS
ifdef release
BUILT_LOADABLE_PATH=$(BUILD_DIR)/Release/lembed0.$(LOADABLE_EXTENSION)
EXTRA_CMAKE_BUILD=--config Release
else
BUILT_LOADABLE_PATH=$(BUILD_DIR)/Debug/lembed0.$(LOADABLE_EXTENSION)
endif
else
BUILT_LOADABLE_PATH=$(BUILD_DIR)/lembed0.$(LOADABLE_EXTENSION)
endif

$(TARGET_LOADABLE): sqlite-lembed.c sqlite-lembed.h $(BUILD_DIR) $(prefix)
	cmake --build $(BUILD_DIR) -t sqlite_lembed $(EXTRA_CMAKE_BUILD)
	ls $(BUILD_DIR)
	cp $(BUILT_LOADABLE_PATH) $@


sqlite-lembed.h: sqlite-lembed.h.tmpl VERSION
	VERSION=$(shell cat VERSION) \
	DATE=$(shell date -r VERSION +'%FT%TZ%z') \
	SOURCE=$(shell git log -n 1 --pretty=format:%H -- VERSION) \
	envsubst < $< > $@

MODELS_DIR=$(prefix)/.models

$(MODELS_DIR): $(BUILD_DIR)
	mkdir -p $@

$(MODELS_DIR)/all-MiniLM-L6-v2.e4ce9877.q8_0.gguf: $(MODELS_DIR)
	curl -L -o $@ https://huggingface.co/asg017/sqlite-lembed-model-examples/resolve/main/all-MiniLM-L6-v2/all-MiniLM-L6-v2.e4ce9877.q8_0.gguf

test-loadable: $(TARGET_LOADABLE) $(MODELS_DIR)/all-MiniLM-L6-v2.e4ce9877.q8_0.gguf
	$(PYTHON) -m pytest tests/test-loadable.py


FORMAT_FILES=sqlite-lembed.c
format: $(FORMAT_FILES)
	clang-format -i $(FORMAT_FILES)

clean:
	rm -rf dist/
