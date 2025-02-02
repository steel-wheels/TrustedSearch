# install_xc.mk

PROJECT_NAME	?= TrustedSearch
DERIVED_BASE	=  $(HOME)/build/derived-data/
PRODUCT_PATH	=  Build/Products/Release

all: install

clean:
	(cd $(DERIVED_BASE) && rm -rf $(PROJECT_NAME))

install: dummy
	xcodebuild install \
	  -scheme  $(PROJECT_NAME)_macOS \
	  -project $(PROJECT_NAME).xcodeproj \
	  -destination="generic/platform=macOS" \
	  -configuration Release \
	  -sdk macosx \
	  DSTROOT=/ \
 	  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
 	  SKIP_INSTALL=NO \
 	  ONLY_ACTIVE_ARCH=NO

dummy:

