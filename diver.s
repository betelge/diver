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

loop:
	jmp loop

palette:
	.byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	.byte $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F

NMI:
IRQ:

.segment "VECTORS"
	.word NMI
	.word RESET
	.word IRQ

.segment "CHARS"
