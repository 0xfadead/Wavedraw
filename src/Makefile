CFLAGS += main.vala gui/Window.vala gui/HeaderBar.vala wave/common.vala IO/save_file.vala wave/wavecreate.vala -X -lm
OUTPUT = -o ../build/main
PKGS   += --pkg gtk+-3.0 --pkg posix --pkg gio-2.0

vc = valac

.PHONY: all debug

all : compile

compile:
	$(vc) $(CFLAGS) $(PKGS) $(OUTPUT)

debug: 
	$(vc) $(CFLAGS) $(PKGS) $(OUTPUT) --define=debug -g
