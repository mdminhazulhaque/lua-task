PKGC ?= pkg-config

LUA := lua5.1
LUA_CFLAGS := $(shell $(PKGC) --cflags $(LUA))
LUA_LIBDIR := $(shell $(PKGC) --variable=INSTALL_LMOD $(LUA))

CMOD = task.so
OBJS = src/ltask.o src/queue.o src/syncos.o
LIBS = -lpthread

CFLAGS += -fPIC -DLUATASK_API= -DLUATASK_PTHREAD_STACK_SIZE=2097152/16 $(LUA_CFLAGS)
LDFLAGS += -shared

ifdef STAGING_DIR
	CFLAGS += -I${STAGING_DIR}/usr
endif

$(CMOD): $(OBJS)
	$(LD) -o $(CMOD) $(LIBS) $(LDFLAGS) $(OBJS)
.c.o:
	$(CC) $(CFLAGS) -o $@ -c $?
clean:
	$(RM) $(CMOD) $(OBJS)
install: $(CMOD)
	cp $(CMOD) $(LUA_LIBDIR)
uninstall: $(CMOD)
	rm -f $(LUA_LIBDIR)/$(CMOD)
