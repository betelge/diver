.segment "HEADER"
	.byte "NES"
	.byte $1A
	.byte $02
	.byte $01
	.byte $00
	.byte $00
	.byte $01
	.byte $00

PPUCTRL = $2000
PPUMASK = $2001
PPUSTATUS = $2002
PPUSCROLL = $2005
PPUADDR = $2006
PPUDATA = $2007

.segment "STARTUP"

RESET:
	sei
	lda #$00
	sta PPUCTRL
	sta PPUMASK
	ldx #$ff
	txs

	lda #%10000000
vsync1:
	bit PPUSTATUS
	bpl vsync1
vsync2:
	bit PPUSTATUS
	bpl vsync2

	ldx #$00
	lda #%10000000
loop:
vsync3:
	bit PPUSTATUS
;	bpl vsync3
	lda #$3F	; Point ppu to palette memory $3F00-$3F1F
	sta PPUADDR
	lda #$00
	sta PPUADDR
	stx PPUDATA
	inx
	jmp loop

NMI:
IRQ:

.segment "VECTORS"
	.word NMI
	.word RESET
	.word IRQ

.segment "CHARS"
