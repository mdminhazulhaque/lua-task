PKGC ?= pkg-config

LUAPKG ?= lua lua5.1 lua5.2 lua5.3
# lua's package config can be under various names
LUAPKGC := $(shell for pc in $(LUAPKG); do \
		$(PKGC) --exists $$pc && echo $$pc && break; \
	done)

LUA_VERSION := $(shell $(PKGC) --variable=V $(LUAPKGC))
LUA_LIBDIR := $(shell $(PKGC) --variable=libdir $(LUAPKGC))
LUA_CFLAGS := $(shell $(PKGC) --cflags $(LUAPKGC))
LUA_LDFLAGS := $(shell $(PKGC) --libs-only-L $(LUAPKGC))

CMOD = task.so
OBJS = src/ltask.o src/queue.o src/syncos.o
LIBS = -lpthread

LTASKDEFS= -DLUATASK_API= -DLUATASK_PTHREAD_STACK_SIZE=2097152/16
CFLAGS += -fPIC $(LUA_CFLAGS) $(LTASKDEFS)
LDFLAGS += -shared

ifeq ($(OPENWRT_BUILD),1)
LUA_VERSION=
endif
$(CMOD): $(OBJS)
	$(LD) -o $(CMOD) $(LIBS) $(LDFLAGS) $(OBJS)
.c.o:
	$(CC) $(CFLAGS) -o $@ -c $?
install:
	mkdir -p $(DESTDIR)$(LUA_LIBDIR)/lua/$(LUA_VERSION)
	cp $(CMOD) $(DESTDIR)$(LUA_LIBDIR)/lua/$(LUA_VERSION)
clean:
	$(RM) $(CMOD) $(OBJS)
