.phony: help
help:
	@echo "This makefile is intended to automate the construction of my preferred EDA build environment."
	@echo "To really commence the build, which can cause significant changes to your runtime environment,"
	@echo "please type one of the following commands to confirm the build."
	@echo
	@echo " - make clean :: Remove all build artifacts."
	@echo "                 DOES NOT uninstall previously installed packages."
	@echo " - make debian :: Build software on a Debian(-like/-derived) host OS."

.phony: clean
clean:
	rm -rf boolector extavy opt SymbiYosys yices2 yosys z3

.phony: debian
debian: deb-deps src-deps

.phony: deb-deps
deb-deps: deb-virtualenv3 deb-sby-deps deb-nextpnr-deps

.phony: deb-virtualenv3
deb-virtualenv3: deb-python3
	sudo apt install virtualenv

.phony: deb-python3
deb-python3:
	sudo apt install python3

.phony: deb-sby-deps
deb-sby-deps:
	sudo apt install build-essential clang bison flex libreadline-dev gawk tcl-dev libffi-dev git mercurial graphviz xdot pkg-config python python3 libftdi-dev gperf libboost-program-options-dev autoconf libgmp-dev cmake

.phony: deb-nextpnr-deps
deb-nextpnr-deps:
	sudo apt install cmake clang-format qt5-default python3-dev libboost-all-dev libeigen3-dev

.phony: src-deps
src-deps: nmigen symbiyosys yices2 z3 avy boolector

nmigen: opt
	(cd opt; git clone git@github.com:m-labs/nmigen)

opt:
	mkdir -p opt

yosys: yosys-git
	(cd yosys && make -j$(nproc) && sudo make install)

symbiyosys: yosys symbiyosys-git
	(cd SymbiYosys && sudo make install)

yices2: yices2-git
	(cd yices2 && autoconf && ./configure && make -j$(nproc) && sudo make install)

z3: z3-git
	(cd z3 && python scripts/mk_make.py && cd build && make -j$(nproc) && sudo make install)

avy: avy-git
	(cd extavy && git submodule update --init && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j$(nproc) && sudo cp avy/src/avy /usr/local/bin/ && sudo cp avy/src/avybmc /usr/local/bin/)

boolector: boolector-git
	(cd boolector && ./contrib/setup-btor2tools.sh && ./contrib/setup-lingeling.sh && ./configure.sh && make -C build -j$(nproc) && sudo cp build/bin/boolector /usr/local/bin && sudo cp build/bin/btor* /usr/local/bin/ && sudo cp deps/btor2tools/bin/btorsim /usr/local/bin/)

yosys-git:
	git clone git@github.com:YosysHQ/yosys.git yosys

symbiyosys-git:
	git clone git@github.com:YosysHQ/SymbiYosys.git SymbiYosys

yices2-git:
	git clone https://github.com/SRI-CSL/yices2.git yices2

z3-git:
	git clone https://github.com/Z3Prover/z3.git z3

avy-git:
	git clone https://bitbucket.org/arieg/extavy.git

boolector-git:
	git clone https://github.com/boolector/boolector
