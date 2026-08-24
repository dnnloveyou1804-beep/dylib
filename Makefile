TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DucNamHomeBar

DucNamHomeBar_FILES = Tweak.x
DucNamHomeBar_CFLAGS = -fobjc-arc
DucNamHomeBar_FRAMEWORKS = UIKit WebKit

include $(THEOS_MAKE_PATH)/tweak.mk
