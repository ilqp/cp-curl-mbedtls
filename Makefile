.PHONY: all mbedtls

export PLATFORM=osx
export DEPS_DIR=$(CURDIR)/install
export CURL_VER=curl-7.59.0
export MBED_VER=mbedtls-2.9.0

all: curl-$(PLATFORM)

curl-linux: curl-osx

curl-osx: mbedtls-osx
	cd $(CURL_VER) && ./buildconf
	mkdir -p curl_build && cd curl_build 				&&  \
	../$(CURL_VER)/configure 					    \
		--prefix=$(DEPS_DIR)/$(CURL_VER)/$(PLATFORM)/ 		    \
		--without-ssl 						    \
		--with-mbedtls=$(DEPS_DIR)/$(MBED_VER)/$(PLATFORM) 	&&  \
	make -j32 && make install
	rm -rf curl_build

mbedtls-osx:
	cmake								    \
		-H./$(MBED_VER)/ -Bmbedtls_build 			    \
		-DCMAKE_INSTALL_PREFIX=$(DEPS_DIR)/$(MBED_VER)/$(PLATFORM)  \
		-DENABLE_TESTING=OFF 					    \
		-DENABLE_PROGRAMS=OFF
	make -C mbedtls_build install
	rm -rf mbedtls_build

curl-android: mbedtls-android
	cd $(CURL_VER) && ./buildconf
	mkdir -p curl_build && cd curl_build 				&&  \
	$(eval TARGET=android-21)					    \
	$(eval NDK_ROOT=/opt/android-ndk-r14b/) 			    \
	$(eval SYSROOT=${NDK_ROOT}/platforms/${TARGET}/arch-arm)  	    \
	CC=$(shell ${NDK_ROOT}/ndk-which gcc)				    \
	LD=$(shell ${NDK_ROOT}/ndk-which ld)				    \
	AS=$(shell ${NDK_ROOT}/ndk-which as)				    \
	AR=$(shell ${NDK_ROOT}/ndk-which ar)				    \
	CPP=$(shell ${NDK_ROOT}/ndk-which cpp)				    \
	CXX=$(shell ${NDK_ROOT}/ndk-which g++)				    \
	RANLIB=$(shell ${NDK_ROOT}/ndk-which ranlib)			    \
	CFLAGS=--sysroot=${SYSROOT}				  	    \
	CPPFLAGS="-I${SYSROOT}/usr/include --sysroot=${SYSROOT}"	    \
	../$(CURL_VER)/configure 					    \
		--host=arm-linux-androideabi 				    \
		--target=arm-linux-androideabi 				    \
		--prefix=$(DEPS_DIR)/$(CURL_VER)/$(PLATFORM)/ 		    \
		--without-ssl 						    \
		--with-mbedtls=$(DEPS_DIR)/$(MBED_VER)/$(PLATFORM) 	&&  \
	make -j32 && make install
	rm -rf curl_build


mbedtls-android:
	$(eval NDK_ROOT=/Users/user/Library/Android/sdk/ndk-bundle)
	cmake 										\
		-H./$(MBED_VER)/ -Bmbedtls_build 					\
		-DCMAKE_TOOLCHAIN_FILE=$(NDK_ROOT)/build/cmake/android.toolchain.cmake	\
		-DANDROID_PLATFORM=android-21						\
		-DANDROID_ABI=armeabi-v7a						\
		-DCMAKE_INSTALL_PREFIX=$(DEPS_DIR)/$(MBED_VER)/$(PLATFORM)		\
		-DENABLE_TESTING=OFF 							\
		-DENABLE_PROGRAMS=OFF
	make -C mbedtls_build install
	rm -rf mbedtls_build
