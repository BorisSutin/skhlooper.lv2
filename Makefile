	
	STRIP ?= strip
	# check if user is root
	user = $(shell whoami)
	INSTALL_DIR = /usr/lib/lv2
	

	
	# set bundle name
	NAME = skhlooper
	BUNDLE = $(NAME).lv2
	VER = 0.2

	

	# set compile flags
	CFLAGS += -I. -I./dsp  -fPIC -DPIC -O2 -Wall -funroll-loops \
	-ffast-math -fomit-frame-pointer -fstrength-reduce -fdata-sections -Wl,--gc-sections \
	-pthread $(SSE_CFLAGS)
	CXXFLAGS += -std=c++11 $(CFLAGS)
	LDFLAGS += -I. -lm -shared -Llibrary -lm -fPIC -DPIC 
	
	# invoke build files
	OBJECTS = $(NAME).cpp 
	GUI_OBJECTS = $(NAME)_x11ui.c
	#RES_OBJECTS = record.o
	## output style (bash colours)
	BLUE = "\033[1;34m"
	RED =  "\033[1;31m"
	NONE = "\033[0m"

.PHONY : mod all clean install uninstall 

all : check $(NAME)
	@mkdir -p ../$(BUNDLE)
	@cp ./*.ttl ../$(BUNDLE)
	@mv ./*.so ../$(BUNDLE)
	@if [ -f ../$(BUNDLE)/$(NAME).so ]; then echo $(BLUE)"build finish, now run make install"; \
	else echo $(RED)"sorry, build failed"; fi
	@echo $(NONE)



check :
ifdef ARMCPU
	@echo $(RED)ARM CPU DEDECTED, please check the optimization flags
	@echo $(NONE)
endif

$(RESOURCEHEADER): $(RESOURCES_OBJ)
	rm -f $(RESOURCEHEADER)
	for f in $(RESOURCE_EXTLD); do \
		echo 'EXTLD('$${f}')' >> $(RESOURCEHEADER) ; \
	done

clean :
	rm -f *.a *.o *.so 
	@rm -f $(NAME).so
	@rm -rf ../$(BUNDLE)
	#@rm -rf ./$(RES_OBJECTS)
	@echo ". ." $(BLUE)", clean up"$(NONE)

dist-clean :
	@rm -f $(NAME).so
	@rm -rf ../$(BUNDLE)
	@rm -rf ../$(BUNDLE_MINI)
	#@rm -rf ./$(RES_OBJECTS)
	@echo ". ." $(BLUE)", clean up"$(NONE)

install :
ifneq ("$(wildcard ../$(BUNDLE))","")
	@mkdir -p $(DESTDIR)$(INSTALL_DIR)/$(BUNDLE)
	cp -r ../$(BUNDLE)/* $(DESTDIR)$(INSTALL_DIR)/$(BUNDLE)
	@echo ". ." $(BLUE)", done"$(NONE)
	sudo systemctl restart pipedald
else
	@echo ". ." $(BLUE)", you must build first"$(NONE)
endif
ifneq ("$(wildcard ../$(BUNDLE_MINI))","")
	@mkdir -p $(DESTDIR)$(INSTALL_DIR)/$(BUNDLE_MINI)
	cp -r ../$(BUNDLE_MINI)/* $(DESTDIR)$(INSTALL_DIR)/$(BUNDLE_MINI)
endif

uninstall :
	@rm -rf $(INSTALL_DIR)/$(BUNDLE)
	@rm -rf $(INSTALL_DIR)/$(BUNDLE_MINI)
	@echo ". ." $(BLUE)", done"$(NONE)

$(NAME) : clean $(RES_OBJECTS)
	$(CXX) $(CXXFLAGS) $(OBJECTS) $(LDFLAGS) -o $(NAME).so
	
	$(STRIP) -s -x -X -R .note.ABI-tag $(NAME).so
	

doc:
	#pass
