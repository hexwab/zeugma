CFLAGS=-Wall
VERSION=1.2

all:	zeugma.ssd
#zeugma-c64-reu-${VERSION}.prg zeugma-c64-reu-widehack-${VERSION}.prg


zeugma-beeb:			zeugma.s.beeb
						xa -DWIDEHACK=0 -o $@ -l mapfile.beeb $<

plot2.ssd:			plot
				rm -f $@
				perl -pe 's/\n/\r/g' <plot >plot2
				bbcim -a plot2.ssd plot2
				bbcim -a plot2.ssd chars
				bbcim -a plot2.ssd widths

scroll.ssd:			scroll
				rm -f $@
				perl -pe 's/\n/\r/g' <scroll >scroll2
				bbcim -a scroll.ssd scroll2

dis-c64:
				dxa  -a dump -l mapfile.c64 zeugma-c64-reu-1.2.prg

dis-beeb:
				dxa -g 1400 -a dump -l mapfile.beeb zeugma-beeb

zeugma.ssd:		zeugma-beeb
						rm -f $@
						bbcim -a zeugma.ssd zeugma-beeb
						bbcim -a zeugma.ssd boot
						bbcim -a zeugma.ssd game


zeugma-c64-reu-${VERSION}.prg:			zeugma.s font.bin zeugma.bin
						xa -DWIDEHACK=0 -o $@ -l mapfile $<

zeugma-c64-reu-widehack-${VERSION}.prg:		zeugma.s font.bin zeugma.bin
						xa -DWIDEHACK=1 -o $@ -l mapfile $<


font.bin:					clR6x8.bdf mkfont
						./mkfont <$< >$@

zeugma.bin:					zeugma.ppm mklogo
						./mklogo <$< >$@
