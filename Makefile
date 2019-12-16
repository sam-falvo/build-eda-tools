.phony: help
help:
	@echo "This makefile is intended to automate the construction of my preferred EDA build environment."
	@echo "To really commence the build, which can cause significant changes to your runtime environment,"
	@echo "please type one of the following commands to confirm the build."
	@echo
	@echo " - make debian :: Build software on a Debian(-like/-derived) host OS."

.phony: debian
debian: deb-deps generic-deps

.phony: deb-deps
deb-deps: deb-virtualenv3

.phony: deb-virtualenv3
deb-virtualenv3: deb-python3
	sudo apt install virtualenv

.phony: deb-python3
deb-python3:
	sudo apt install python3

.phony: generic-deps
generic-deps: nmigen

nmigen: opt
	(cd opt; git clone git@github.com:m-labs/nmigen)

opt:
	mkdir -p opt
