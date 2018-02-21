.segment "HEADER"
	.byte "NES"
	.byte $1A
	.byte $02
	.byte $01
	.byte $00
	.byte $00
	.byte $01
	.byte $00

; ppu hardware
PPUCTRL = $2000 ; (nmi,ppu mstr,spr size, bg tbl, spr tbl,PPUDATA inc,nametbl)
PPUMASK = $2001 ; (B,G,R,spr,bg,leftSpr,leftBg,grey)
PPUSTATUS = $2002 ; (vblank,spr0hit,sprOverflow,_,_,_,_)
OAMADDR = $2003
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007
OAM_DMA = $4014

;input hardware
JOYPAD1 = $4016
JOYPAD2 = $4017

; local defines
OAM = $0200

.zeropage
buttons: .res 1

.segment "STARTUP"

RESET:
; Turn off ppu
	sei
	lda #$00
	sta PPUCTRL
	sta PPUMASK

; Reset stack
	ldx #$ff
	txs

; Wait two vsyncs for ppu to stabilize
	lda #%10000000
vsync1:
	bit PPUSTATUS
	bpl vsync1
; We have free cycles to do something between these two vsyncs
vsync2:
	bit PPUSTATUS
	bpl vsync2

; Load palette
	ldx #$00
	lda #$3F	; Point ppu to palette memory $3F00-$3F1F
	sta PPUADDR
	lda #$00
	sta PPUADDR
paletteloop:
	lda palette, x
	sta PPUDATA
	inx
	cpx #32
	bne paletteloop

; Populate nametables
	lda #$20
	sta PPUADDR
	lda #$00
	sta PPUADDR
	ldx #$00
hloop:
	ldy #$00
wloop0:
	lda #$00
	sta PPUDATA
	lda #$01
	sta PPUDATA
	iny
	cpy #$10
	bne wloop0
	ldy #$00
wloop1:
	lda #$10
	sta PPUDATA
	lda #$11
	sta PPUDATA
	iny
	cpy #$10
	bne wloop1
	inx
	cpx #$0f
	bne hloop

; Set oam
	ldx #0
	lda #$80 ; y pos
	sta OAM, x
	inx
	lda #$00 ; tile index
	sta OAM, x
	inx
	lda #%00000011 ; vhP___pp
	sta OAM, x
	inx
	lda #$80 ; x pos
	sta OAM, x
	inx

; Start ppu
	lda #%10001000
	sta PPUCTRL
	lda #%00011110
	sta PPUMASK
	cli

loop:
	jmp loop

NMI:
; Upload oam
	lda #0
	sta OAMADDR ; Point oam address to start of oam memory
	lda #>OAM
	sta OAM_DMA ; Point the dma to top byte of the oam address in ram
; Poll controller pad
	lda #$01
	sta JOYPAD1 ; Strobe controller
	sta buttons
	lda #$00
	sta JOYPAD1
inputloop:
	lda JOYPAD1
	lsr a ; bit 0 into carry
	rol buttons ; carry into bit 0, bit 7 into carry
	bcc inputloop
; Move sprite
	lda buttons
	lsr a
	bcc noright
	pha
	inc OAM + 3
	lda OAM + 2
	and #%10111111 ; Flip diver right
	sta OAM + 2
	pla
noright:
	lsr a
	bcc noleft
	pha
	dec OAM + 3
	lda OAM + 2
	ora #%01000000 ; Flip diver left
	sta OAM + 2
	pla
noleft:
	lsr a
	bcc nodown
	inc OAM
nodown:
	lsr a
	bcc noup
	dec OAM
noup:
	rti

IRQ:
	rti

.segment "VECTORS"
	.word NMI
	.word RESET
	.word IRQ

.segment "CHARS"
.incbin "tiles.chr"
.incbin "sprites.chr"

.rodata
palette:
.incbin "palette.dat"
