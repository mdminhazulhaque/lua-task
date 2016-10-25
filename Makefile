PKGC ?= pkg-config

LUAPKG := lua lua5.0 lua5.1 lua5.2 lua5.3
LUAPKGC := $(shell for pc in $(LUAPKG); do \
	$(PKGC) --exists $$pc && echo $$pc && break; \
	done)
	
LUA_LIBDIR := $(shell $(PKGC) --variable=INSTALL_LMOD $(LUAPKGC))
LUA_CFLAGS := $(shell $(PKGC) --cflags $(LUAPKGC))

CMOD = task.so
OBJS = src/ltask.o src/queue.o src/syncos.o
LIBS = -lpthread

LTASKDEFS= -DLUATASK_API= -DLUATASK_PTHREAD_STACK_SIZE=2097152/16
CFLAGS += -fPIC
# $(LUA_CFLAGS) $(LTASKDEFS)
LDFLAGS += -shared

# CC = /openwrt/staging_dir/toolchain-mipsel_24kec+dsp_gcc-5.3.0_musl-1.1.15/bin/mipsel-openwrt-linux-gcc
# LD = /openwrt/staging_dir/toolchain-mipsel_24kec+dsp_gcc-5.3.0_musl-1.1.15/bin/mipsel-openwrt-linux-ld
# CFLAGS += -I/openwrt/staging_dir/target-mipsel_24kec+dsp_musl-1.1.15/usr/include

$(CMOD): $(OBJS)
	$(LD) -o $(CMOD) $(LIBS) $(LDFLAGS) $(OBJS)
.c.o:
	$(CC) $(CFLAGS) -o $@ -c $?
install:
	mkdir -p $(DESTDIR)$(LUA_LIBDIR)/
	cp $(CMOD) $(DESTDIR)$(LUA_LIBDIR)/
clean:
	$(RM) $(CMOD) $(OBJS)
