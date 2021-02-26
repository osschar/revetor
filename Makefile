# . /cvmfs/sft.cern.ch/lcg/views/ROOT-latest/x86_64-centos7-gcc7-opt/setup.sh
# . /home/viz/root-bld/bin/thisroot.sh

all: revetor install

revetor: revetor.C
	c++ `root-config --cflags` -L`root-config --libdir` -lCore -lMathCore -lNet -lROOTWebDisplay -lROOTEve revetor.C -o revetor

install: revetor.pl
	@echo -e "\nYou might want to run: cp -a revetor.pl /var/www/cgi-bin/"
	@echo -e "    Or you might not, as due to SE linux it makes more sense to edit it in place."

clean:
	rm -f *.outerr revetor

tarball: clean
	cd ..; tar czf revetor-`date +%Y-%m-%d`.tgz revetor/

.PHONY: install clean tarball
