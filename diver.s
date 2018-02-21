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
PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
OAMADDR = $2003
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007
OAM_DMA = $4014

; local defines
OAM = $0200

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

; Set oam
	ldx #0
	lda #$80 ; y pos
	sta OAM, x
	inx
	lda #$00 ; tile index
	sta OAM, x
	inx
	lda #%00000001 ; vhP___pp
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

palette:
	.byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	.byte $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F

NMI:
	inc OAM
; Upload oam
	lda #0
	sta OAMADDR ; Point oam address to start of oam memory
	lda #>OAM
	sta OAM_DMA ; Point the dma to top byte of the oam address in ram
	rti

IRQ:
	rti

.segment "VECTORS"
	.word NMI
	.word RESET
	.word IRQ

.segment "CHARS"
; tiles
	.repeat $100
	.byte $55,$56,$57,$58,$59,$5A,$65,$75,$85,$95,$A5,$55,$55,$55,$55,$55
	.endrepeat
; sprites
	.repeat $1000
	.byte $ff
	.endrepeat
