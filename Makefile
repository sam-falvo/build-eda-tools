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
	rm -rf boolector extavy opt SymbiYosys yices2 yosys z3 icestorm prjtrellis nextpnr verilator

.phony: debian
debian: deb-deps src-deps

.phony: deb-deps
deb-deps: deb-virtualenv3 deb-sby-deps deb-nextpnr-deps deb-gtkwave

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
	sudo apt install cmake clang-format python3-dev libboost-all-dev libeigen3-dev

.phony: deb-gtkwave
deb-gtkwave:
	sudo apt install gtkwave

.phony: src-deps
src-deps: built-nmigen built-symbiyosys built-yices2 built-z3 built-boolector built-nextpnr built-verilator

built-nmigen: opt
	(cd opt; git clone git@github.com:m-labs/nmigen)
	touch built-nmigen

opt:
	mkdir -p opt

built-yosys: yosys-git
	(cd yosys && make -j$(nproc) && sudo make install)
	touch built-yosys

built-symbiyosys: built-yosys symbiyosys-git
	(cd SymbiYosys && sudo make install)
	touch built-symbiyosys

built-yices2: yices2-git
	(cd yices2 && autoconf && ./configure && make -j$(nproc) && sudo make install)
	touch built-yices2

built-z3: z3-git
	(cd z3 && python scripts/mk_make.py && cd build && make -j$(nproc) && sudo make install)
	touch built-z3

built-boolector: boolector-git
	(cd boolector && ./contrib/setup-btor2tools.sh && ./contrib/setup-lingeling.sh && ./configure.sh && make -C build -j$(nproc) && sudo cp build/bin/boolector /usr/local/bin && sudo cp build/bin/btor* /usr/local/bin/ && sudo cp deps/btor2tools/bin/btorsim /usr/local/bin/)
	touch built-boolector

built-icestorm: icestorm-git
	(cd icestorm && make -j$(nproc) && sudo make install)
	touch built-icestorm

built-prjtrellis: prjtrellis-git
	(cd prjtrellis/libtrellis && cmake -DCMAKE_INSTALL_PREFIX=/usr . && make && sudo make install)
	touch built-prjtrellis

built-nextpnr: built-icestorm built-prjtrellis nextpnr-git
	(cd nextpnr && cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local . && make -j$(nproc) && sudo make install)
	(cd nextpnr && cmake -DARCH=ecp5 -DTRELLIS_INSTALL_PREFIX=/usr . && make -j$(nproc) && sudo make install)
	touch built-nextpnr

built-verilator: verilator-git
	(unset VERILATOR_ROOT && cd verilator && git checkout stable && autoconf && ./configure && make && sudo make install)
	touch built-verilator

verilator-git:
	git clone https://git.veripool.org/git/verilator

yosys-git:
	git clone git@github.com:YosysHQ/yosys

symbiyosys-git:
	git clone git@github.com:YosysHQ/SymbiYosys

yices2-git:
	git clone https://github.com/SRI-CSL/yices2

z3-git:
	git clone https://github.com/Z3Prover/z3

#avy-git:
#	git clone https://bitbucket.org/arieg/extavy

boolector-git:
	git clone https://github.com/boolector/boolector

icestorm-git:
	git clone https://github.com/cliffordwolf/icestorm

nextpnr-git:
	git clone https://github.com/YosysHQ/nextpnr

prjtrellis-git:
	git clone --recursive https://github.com/SymbiFlow/prjtrellis
