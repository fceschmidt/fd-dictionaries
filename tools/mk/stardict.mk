# This file contains all the rules to export our dictionaries into the FreeDict
# format. It relies on the dictd format. This has the disadvantage that it
# doesn't support nice formatting, but that's a matter of writing another XSL
# transformation for which manpower (or womenpower) is missing.


# This tool comes from the XDXF project
MAKEDICT ?= makedict
STARDICT_BASE=build
MAKEDICT_BUILD_DIR = $(STARDICT_BASE)/freedict-$(dictname)
STARDICT_DICT_NAME = freedict-$(dictname)

# makedict drops the stardict files into a subdirectory, but that's actually
# quite handy, because it prevents a mess in the dictionary directory of
# stardict; the prefix for those directory names is `freedict-`
$(MAKEDICT_BUILD_DIR)/$(STARDICT_DICT_NAME).dict.dz \
		$(MAKEDICT_BUILD_DIR)/$(STARDICT_DICT_NAME).idx \
		$(MAKEDICT_BUILD_DIR)/$(STARDICT_DICT_NAME).ifo: \
			$(dictname).index $(dictname).dict
	if [ -d "$(STARDICT_BASE)" ]; then \
		rm -rf "$(STARDICT_BASE)"; \
	fi
	mkdir -p "$(STARDICT_BASE)"; \
	# copy files for stardict build, rename them to get a prefix for the output
	# files
	cp $(dictname).dict $(STARDICT_BASE)/$(STARDICT_DICT_NAME).dict
	cp $(dictname).index $(STARDICT_BASE)/$(STARDICT_DICT_NAME).index
	cd $(STARDICT_BASE) && $(MAKEDICT) -i dictd -o stardict $(STARDICT_DICT_NAME).index
	# drop version suffix (rename from stardict-freedict-$(dictname)-version)
	cd $(STARDICT_BASE) && mv stardict-$(STARDICT_DICT_NAME)* $(STARDICT_DICT_NAME)/
	# remove temporary dictd format copies
	rm $(STARDICT_BASE)/$(STARDICT_DICT_NAME).dict $(STARDICT_BASE)/$(STARDICT_DICT_NAME).index
	# compress .dict file and drop original file
	cd $(MAKEDICT_BUILD_DIR) && dictzip $(STARDICT_DICT_NAME).dict

# create README to explain to the user what to do with this file
$(STARDICT_BASE)/README-stardict.md:
	@echo "Adding README-stardict.md"
	cp $(FREEDICT_TOOLS)/mk/resources/README-stardict.md $@

stardict: $(MAKEDICT_BUILD_DIR)/$(STARDICT_DICT_NAME).dict.dz \
	$(MAKEDICT_BUILD_DIR)/$(STARDICT_DICT_NAME).idx \
	$(MAKEDICT_BUILD_DIR)/$(STARDICT_DICT_NAME).ifo

STRDCT_RELEASE_DIR=$(FREEDICTDIR)/release/stardict
$(FREEDICTDIR)/release/stardict/freedict-$(dictname)-$(version)-stardict.tar.bz2: \
       	stardict $(STARDICT_BASE)/README-stardict.md
	@if [ ! -d $(STRDCT_RELEASE_DIR) ]; then \
		mkdir $(STRDCT_RELEASE_DIR); fi
	cd $(STARDICT_BASE) && tar cvjf freedict-$(dictname)-$(version)-stardict.tar.bz2 \
	  $(STARDICT_DICT_NAME) README-stardict.md
	mv $(STARDICT_BASE)/freedict-$(dictname)-$(version)-stardict.tar.bz2 \
		$(STRDCT_RELEASE_DIR)

release-stardict: \
	$(FREEDICTDIR)/release/stardict/freedict-$(dictname)-$(version)-stardict.tar.bz2


clean::
	rm -f $(FREEDICTDIR)/release/stardict/freedict-$(dictname)-$(version)-stardict.tar.bz2
	rm -rf $(STARDICT_BASE)

