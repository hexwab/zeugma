*fx11
AUTO
REMMODE 4:linelen=&140
MODE0:linelen=&280
HIMEM=&4800
C.129:C.0
CLS
V.28,0,31,79,20
DIM code% 2048
chars=&4800
OSCLI"L.CHARS "+STR$~chars
nchars=chars?0
widthlo=chars+2
widthhi=chars+2+nchars
h%=chars?1
DIM blank h%
FOR I%=0 TOh%-1:blank?I%=0:NEXT
tmp1=&70
tmp2=&71
tmp=&72
revmask=&73
ptr1=&74
ptr2=&76
ptr3=&86
tmp3=&88
lmask=&78
rmask=&79
fontwidth=&7A
xoffset=&7B
fontptr=&7C
height=&80
drawnlines=&81
screenptr=&84
fontptr2=&8A
FOR I%=0 TO2 STEP 2
P%=code%
[OPT I%
.lmasks
\	7F BF DF EF F7 FB FD FE
\	3F 9F CF E7 F3 F9 FC FE
\	1F 8F C7 E3 F1 F8 FC FE
\	0F 87 C3 E1 F0 F8 FC FE
\	07 83 C1 E0 F0 F8 FC FE
\	03 81 C0 E0 F0 F8 FC FE
\	01 80 C0 E0 F0 F8 FC FE
\	00 80 C0 E0 F0 F8 FC FE
	equd &E0C08000: equd &FEFCF8F0 \ width >=8
	equd &EFDFBF7F: equd &FEFDFBF7 \ width 1
	equd &E7CF9F3F: equd &FEFCF9F3 \ width 2
	equd &E3C78F1F: equd &FEFCF8F1 \ width 3
	equd &E1C3870F: equd &FEFCF8F0 \ width 4
	equd &E0C18307: equd &FEFCF8F0 \ width 5
	equd &E0C08103: equd &FEFCF8F0 \ width 6
	equd &E0C08001: equd &FEFCF8F0 \ width 7
\	equd &E0C08000: equd &FEFCF8F0 \ width 8
\ width >8 are all the same as 8

\if width+offset<=8 rmask=FF
.rmasks
	equb &7F
	equb &3F
	equb &1F
	equb &0F
	equb &07
	equb &03
	equb &01
	equb &00 \ width 9

\7654321076543210
\  vvvvvvvv

\tmp1 is left byte mask
\tmp2 is right byte mask
\tmp is right byte data to plot

.branches1 \ PC+2+off
	equb b1_0-b1_ \ unused
	equb b1_1-b1_
	equb b1_2-b1_
	equb b1_3-b1_
	equb b1_4-b1_
	equb b1_5-b1_
	equb b1_6-b1_
	equb b1_7-b1_

.branches2byte
\	equb 23
\	equb 20
\	equb 17
\	equb 14
\	equb 11
\	equb 8
\	equb 5
\	equb 2
	equb twoblank-branch2_
	equb b2_1-branch2_
	equb b2_2-branch2_
	equb b2_3-branch2_
	equb b2_4-branch2_
	equb b2_5-branch2_
	equb b2_6-branch2_
	equb b2_7-branch2_

.thischar
EQUB 32
.speedtest
LDA thischar
JSR plot
INC thischar
BPL speedtest
LDA #32
STA thischar
RTS

.wrchv
STA thischar
TXA
PHA
TYA
PHA
LDA thischar
SEC
SBC#32
JSR plot
PLA
TAY
PLA
TAX
RTS

.plot
tax
lda widthlo,X
sta fontptr
lda widthhi,X
and #&0F
clc
adc #chars DIV256
sta fontptr+1
lda widthhi,X
lsr a
lsr a
lsr a
lsr a
\clc \ already clear
adc #1
sta fontwidth
lda #h%
sta height

\copy screenptr to ptr1
lda screenptr
sta ptr1
lda screenptr+1
sta ptr1+1

.doplot

lda ptr1
and #7
eor #7
clc
adc #1
\ A is how many lines we can draw
cmp height
bcc drawsome \ >= height?
beq drawsome
.drawall
lda height
.drawsome
tay
sty drawnlines
dey
\sta tmp
\lda height
\sec
\sbc tmp
\sta height
tya
eor #&FF
clc
adc height
sta height

\lda drawnlines
\ora #&30
\jsr &FFEE

.draw
\ put ptr1+8 in ptr2
clc
lda ptr1
adc #8
sta ptr2
lda ptr1+1
adc #0
sta ptr2+1

\get lmask
lda fontwidth
bit #&F8
beq widthle8 \ <= 8

\set fontptr2 to second byte by adding height
lda #h%
clc
adc fontptr
sta fontptr2
lda fontptr+1
adc #0
sta fontptr2+1
ldx xoffset
bpl getlmask \ always
.widthle8
asl a
asl a
asl a
ora xoffset
tax
lda #blank MOD256
sta fontptr2
lda #blank DIV256
sta fontptr2+1

.getlmask
lda lmasks,X \ 8 bytes each, 1-indexed
sta lmask

\get rmask if needed
clc
lda fontwidth
adc xoffset
cmp #9
bcc onebyte \ width+offset<=8 -> one byte
tax
cpx #17
bcc twobytes

.threebytes
lda rmasks-17,X
sta rmask
\brk
jmp threebytesreal

.twobytes
lda rmasks-9,X
sta rmask
ldx xoffset
lda branches2byte,X
sta branch2+1
.loop1
lda (fontptr2),Y
sta tmp
lda (ptr1),Y
and lmask
sta tmp1
lda (ptr2),Y
and rmask
sta tmp2
lda (fontptr),Y
\eor revmask
.branch2
bne branch2
.branch2_
beq twoblank
.b2_7
\asl a
\sta tmp
\lda #0
\adc #0
\bcc twoblank \ always
lsr a
ror tmp
.b2_6
lsr a
ror tmp
.b2_5
lsr a
ror tmp
.b2_4
lsr a
ror tmp
.b2_3
lsr a
ror tmp
.b2_2
lsr a
ror tmp
.b2_1
lsr a
ror tmp
.twoblank
ora tmp1
sta (ptr1),Y
lda tmp2
ora tmp
sta (ptr2),Y
dey
bpl loop1
jmp done

.noshift
bit lmask
bmi noshiftnomask
.loopnoshift
lda (ptr1),Y
and lmask
ora (fontptr),Y
sta (ptr1),Y
dey
bpl loopnoshift
jmp done

.noshiftnomask
.loopnsnm
lda (fontptr),Y
sta (ptr1),Y
dey
bpl loopnsnm
jmp done

.onebyte
ldx xoffset
\ check for no shifting required
beq noshift
lda branches1,X
sta loop11branch+1
clc
.loop1byte
lda (ptr1),Y
and lmask
sta tmp1
lda (fontptr),Y
\eor revmask
.loop11branch
bcc loop11branch
.b1_
.b1_7
lsr a
.b1_6
lsr a
.b1_5
lsr a
.b1_4
lsr a
.b1_3
lsr a
.b1_2
lsr a
.b1_1
lsr a
.b1_0
ora tmp1
sta (ptr1),Y
dey
bpl loop1byte
\jmp done

.done
lda height
beq reallydone
.add2802
clc
lda ptr1
adc #linelen MOD256
and #&F8
sta ptr1
lda ptr1+1
adc #linelen DIV256
sta ptr1+1
\no need for clc
lda fontptr
adc drawnlines
sta fontptr
lda fontptr+1
adc #0
sta fontptr+1
jmp doplot

.reallydone
clc
lda fontwidth
adc xoffset
sta tmp
and #7
sta xoffset
lda tmp
and #&F8
beq noscreeninc
sta tmp
\no need for clc
lda screenptr
adc tmp
sta screenptr
bcc noscreeninc
inc screenptr+1
.noscreeninc
rts


.threebytesreal
lda ptr1
clc
adc #16
sta ptr3
lda ptr1+1
adc #0
sta ptr3+1
.loop3
lda (fontptr2),Y
sta tmp
lda #0
sta tmp3
lda (ptr1),Y
and lmask
sta tmp1
lda (ptr3),Y
and rmask
sta tmp2
lda (fontptr),Y
ldx xoffset
beq nothreeloop
.threeloop
lsr a
ror tmp
ror tmp3
dex
bne threeloop
.nothreeloop
ora tmp1
sta (ptr1),Y
lda tmp
sta (ptr2),Y
lda tmp3
ora tmp2
sta (ptr3),Y
dey
bpl loop3
jmp done

]
NEXT
DIM string 100
REM$string="Hello, world!"
$string="Pack my box with five dozen liquor jugsssssASD"
?xoffset=0
REPEAT
REMFOR n%=0 TO LEN$string-1
REMch%=string?n%-32
!screenptr=&5800+RND(&2800)
FOR A%=0 TO95
CALLplot
NEXT
IFGET
UNTIL 0
END
!fontptr=fontdata
?fontwidth=7
?xoffset=0
!ptr1=&4000
FOR C=0 TO 77
CALLplot
V.30
P."lmask=",~?lmask," rmask=",~?rmask
IFGET
?xoffset=?xoffset+?fontwidth
IF ?xoffset>=8:?xoffset=?xoffset-8:!ptr1=!ptr1+8
NEXT
