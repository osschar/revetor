# . /cvmfs/sft.cern.ch/lcg/views/ROOT-latest/x86_64-centos7-gcc7-opt/setup.sh
# . /home/viz/root-bld/bin/thisroot.sh

WWW_DIR := /var/www/html/cmsShowWeb
# WWW_DIR := /var/www/cgi-bin

all: revetor install

revetor: revetor.C
	c++ `root-config --cflags` -L`root-config --libdir` -lCore -lMathCore -lNet -lROOTWebDisplay -lROOTEve revetor.C -o revetor

install: revetor.pl
	cp -a revetor.pl ${WWW_DIR}
	@echo -e "\ncp of revetor.pl to ${WWW_DIR} done"
	@echo -e "You might need to do some SE linux fixes there."

clean:
	rm -f *.outerr revetor

tarball: clean
	cd ..; tar czf revetor-`date +%Y-%m-%d`.tgz revetor/

.PHONY: install clean tarball
