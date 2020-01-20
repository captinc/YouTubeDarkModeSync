ARCHS = arm64 arm64e
TARGET = iphone:clang::13.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YouTubeDarkModeSync
YouTubeDarkModeSync_FILES = Tweak.xm
YouTubeDarkModeSync_CFLAGS = -fobjc-arc
YouTubeDarkModeSync_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
