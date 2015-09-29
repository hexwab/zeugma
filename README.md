# Zeugma for the BBC Micro

This is the source code for Zeugma (BBC Micro version), a modern Z-machine
interpreter for the 6502 processor family.

Zeugma was created by Linus Akesson:
http://www.linusakesson.net/software/zeugma/.

BBC Micro port by Tom Hargreaves <hex@freezone.co.uk>.

Prereqs:
* xa65
* bbcim

## Instructions

Choose your configuration.  The following configurations are
supported:

* BBC with 6502 second processor (80x32 screen, 42K cache, recommended)
* BBC Master 128/B+ 128 (80x32 screen, 15K cache)
* BBC model B (not v8, 40x25 screen, 12K cache)

There is no autodetection, define TUBE or MASTER (or neither) in
zeugma.s.

Type "ln -sf story.z5 game && rm zeugma.ssd && make", where story.z5
is the game you want to play.  A DFS disc image is built in
zeugma.ssd.

Zeugma reads the story from a a file called GAME.  It must be able to
write to this file.  You should restore the file to its original
pristine condition before restarting Zeugma.

Z-machine version 5 is your best bet.  Version 8 files may work,
assuming you can fit them onto a disc and that you're not running a
plain model B.  Version 4 is untested.

Play with caps lock off.

## TODO
* "first 64k always dirty" <-- CHECKME
* bounce buffer for better swram usage
* check cache behaviour wrt banking
* screen model
* integrate font support, split screen
* split vm into ro and rw files
* re-enable propcache
* write-behind cache on IO proc when in 2P mode?
* integrate font support
* restart
* save, load
* undo
