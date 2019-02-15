#----------------------------------------------------------------------------------
# Base
#----------------------------------------------------------------------------------

ROOTDIR := $(shell pwd)
OUTPUT_DIR ?= $(ROOTDIR)/site
SOURCES := $(shell find . -name "*.md" )

RELEASE := "true"
ifeq ($(TAGGED_VERSION),)
	# TAGGED_VERSION := $(shell git describe --tags)
	# This doesn't work in CI, need to find another way...
	TAGGED_VERSION := vdev
	RELEASE := "false"
endif
VERSION ?= $(shell echo $(TAGGED_VERSION) | cut -c 2-)

#----------------------------------------------------------------------------------
# Docs
#----------------------------------------------------------------------------------

site:
	if [ ! -d themes ]; then  git clone https://github.com/matcornic/hugo-theme-learn.git themes/hugo-theme-learn; fi
	hugo --config docs.toml

.PHONY: deploy-site
deploy-site: site
ifeq ($(RELEASE),"true")
	firebase deploy --only hosting:glooe-site
endif

.PHONY: serve-site
serve-site: site
	hugo --config docs.toml server -D