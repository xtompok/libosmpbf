OSM_BINARY_PATH=../OSM-binary

SRC_FILES=open.c free.c realloc.c util.c parse.c \
	pbf-util.c pbf.c \
	xml.c xml-relation.c xml-way.c xml-node.c xml-write.c \
	gpx-write.c \
	fileformat.pb-c.c osmformat.pb-c.c

OBJECT_FILES=open.o free.o realloc.o util.o parse.o \
	pbf-util.o pbf.o \
	xml.o xml-relation.o xml-way.o xml-node.o xml-write.o \
	gpx-write.o \
	fileformat.pb-c.o osmformat.pb-c.o

GENERATED_FILES=fileformat.pb-c.c osmformat.pb-c.c \
                fileformat.pb-c.h osmformat.pb-c.h

EXEC_FILES=osmpbf2osm osm-extract osm2gpx
LIB_FILES=libosm.so

#CC_FLAGS=-Wall -g
CC_FLAGS=-Wall -g -O2
LD_FLAGS=-lm -lprotobuf-c -lz


%.o: %.c proto_c_gen 
	#$(CC) $(CC_FLAGS) -o $@ -c $*.c
	$(CC) -Wl,--export-dynamic -shared -fPIC $(CC_FLAGS) -o $@ -c $*.c

all: lib osmpbf2osm osm_extract osm2gpx

lib: proto_c_gen $(OBJECT_FILES) 
	$(CC) -Wl,--export-dynamic -shared -fPIC $(CC_FLAGS) $(LD_FLAGS) -o libosm.so $(OBJECT_FILES)

osmpbf2osm: lib
	#$(CC) $(CC_FLAGS) -o osmpbf2osm.o -c osmpbf2osm.c
	#$(CC) $(LD_FLAGS) -o osmpbf2osm osmpbf2osm.o $(OBJECT_FILES)
	$(CC) $(LD_FLAGS) -L. -losm -o osmpbf2osm osmpbf2osm.c
	
osm_extract: lib
	#$(CC) $(CC_FLAGS) -o osm-extract.o -c osm-extract.c
	#$(CC) $(LD_FLAGS) -o osm-extract osm-extract.o $(OBJECT_FILES)
	$(CC) $(LD_FLAGS) -L. -losm -o osm-extract osm-extract.c

osm2gpx: lib
	#$(CC) $(CC_FLAGS) -o osm2gpx.o -c osm2gpx.c
	#$(CC) $(LD_FLAGS) -o osm2gpx osm2gpx.o $(OBJECT_FILES)
	$(CC) $(LD_FLAGS) -L. -losm -o osm2gpx osm2gpx.c

clean:
	rm -f $(OBJECT_FILES) $(GENERATED_FILES) $(EXEC_FILES) $(LIB_FILES)

proto_c_gen:
	protoc-c --proto_path=$(OSM_BINARY_PATH)/src \
		--c_out=. $(OSM_BINARY_PATH)/src/*.proto

fileformat.pb-c.o: proto_c_gen
	#$(CC) $(CC_FLAGS) -o $@ -c $*.c
	$(CC) -Wl,--export-dynamic -shared -fPIC $(CC_FLAGS) -o $@ -c $*.c

osmformat.pb-c.o: proto_c_gen
	#$(CC) $(CC_FLAGS) -o $@ -c $*.c
	$(CC) -Wl,--export-dynamic -shared -fPIC $(CC_FLAGS) -o $@ -c $*.c

# vim: syn=make ts=8 sw=8 noexpandtab
