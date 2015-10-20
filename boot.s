osbyte = $fff4
	* = $0000
	lda #118	; update leds
	jsr osbyte

	lda #$EA		; check for tube
	jsr readosbyte
	cpx #0
	bne tube

	lda #$81		; read machine type 
	jsr readosbyte
	cpx #$FD 		; master
	beq master
	cpx #$F5		; compact
	beq master
#if 0
	cpx #$FB		; B+
	bne go
	
	lda #$44 		; test for swram
	jsr osbyte
	txa
	and #8 			; FIXME
	beq go
	bne master
#else
	bne go
#endif
readosbyte
	ldx #0
	ldy #255
	jmp ($20A)
tube
	lda #8
	sta m1+1	; goddamn tube client grrr
	lda #'T'
	.byt $2C
master
	lda #'M'
	sta fn1

go
	cli
	lda #202	; turn caps lock off
	jsr readosbyte
	pha
	txa
	ora #16
	tax
	pla
	jsr osbyte
	
	lda #11		; disable autorepeat
	ldx #0
	jsr osbyte
	
	ldx #<fn
	ldy #>fn
	lda #2
m1	jmp ($21E)

fn
	.byt "Zeugma"
fn1
	.byt 13,13
