;***********************************
;	lab example number one
;***********************************
;=========Includes =================
;
.NOLIST
.include	"m16def.inc"
.LIST



;====== Register definitions =======
.DEF ZeroReg = r0
.DEF TmpReg = r21
.EQU size = 16
;display_4_digit: .byte _4disp_SZ



;=====+== PROGRAM segment ==========
.DSEG
muj_block: .byte size
.CSEG
;******** Interrupt vectors ********
		.ORG	0x0000
		jmp	RESET			; Reset Handler
		jmp	EXT_INT0		; External Interrupt Request 0 Handler
		jmp	EXT_INT1		; External Interrupt Request 1 Handler
		jmp	TIM2_COM		; Timer2 Compare Match Handler
		jmp	TIM2_OVF		; Timer2 Overflow Handler
		jmp	TIM1_CAP		; Timer1 Capture Handler
		jmp	TIM1_COMA		; Timer1 Compare Match A Handler
		jmp	TIM1_COMB		; Timer1 Compare Match B Handler
		jmp	TIM1_OVF		; Timer1 Overflow Handler
		jmp	TIM0_OVF		; Timer0 Overflow Handler
		jmp	SPI_STC			; SPI Transfer Complete Handler
		jmp	UART_RXC		; UART RX Complete Handler
		jmp	UART_DRE		; UART Data Register Empty Handler
		jmp	UART_TXC		; UART TX Complete Handler
		jmp	ADC_COMP		; ADC Conversion Complete Handler
		jmp	EE_RDY			; EEPROM Write Complete (Ready) Handler
		jmp	ANA_COMP		; Analog Comparator Handler
		jmp	TWI				; Two-wire Serial Interface Handler
		jmp	EXT_INT2		; External Interrup Request 2 Handler
		jmp	TIM0_COM		; Timer0 Compare Match Handler
		jmp	SPM_RDY			; Store Program Memory Ready


;******* Reset ********
;********************************** Unused interrupt vectors ***************************************************
EXT_INT0:
EXT_INT1:
TIM2_COM:
TIM2_OVF:
TIM1_CAP:
TIM1_COMA:
TIM1_COMB:
TIM1_OVF:
TIM0_OVF: 
SPI_STC:
UART_DRE:
UART_TXC:
UART_RXC:
ADC_COMP:
EE_RDY:
ANA_COMP:
TWI:
EXT_INT2:
TIM0_COM:
SPM_RDY:	reti


;************************************************
		
		.ORG	0x0030
Reset:		
	
		clr	ZeroReg
		ldi	TmpReg, low(RAMEND)	; Stack Ptr
		out	SPL, TmpReg
		ldi	TmpReg, high(RAMEND)
		out	SPH, TmpReg

		ldi	TmpReg, 0b10000000	; Disable JTAG interface
		out	MCUCSR, TmpReg
		out	MCUCSR, TmpReg

		ldi	TmpReg, 0xFF
		out	DDRA, TmpReg		; Set direction of port A (all inputs)
		out	DDRB, TmpReg		; Set direction of port B (all inputs)
		out	DDRC, TmpReg		; Set direction of port C (all outputs)
		out	DDRD, TmpReg		; Set direction of port D (all outputs)

		out	PortA, ZeroReg		; Set port A to 00h
		out	PortB, ZeroReg		; Set port A to 00h
		out	PortC, ZeroReg		; Set port A to 00h
		out	PortD, ZeroReg		; Set port A to 00h


		rjmp	Main
;***************************************

.def number = r16

.def tisic = r30
.def tisicW = r31

.def sto = r17
.def stoW = r20

.def deset = r18
.def desetW = r21

.def jedna = r19
.def jednaW = r22

.def tick = r23





;************** Delay (PDelReg[ms]) ***************
.DEF	PDelReg		= r23
.DEF	PDelReg0	= r24
.DEF	PDelReg1	= r25
.DEF	PDelReg2	= r2
; this is a delay subroutine 
Delay1m:	mov	PDelReg2, PDelReg
Delay1m0:	ldi	PDelReg0, 20
Delay1m1:	ldi	PDelReg1, 245
Delay1m2:	dec	PDelReg1
		brne	Delay1m2
		dec	PDelReg0
		brne	Delay1m1
		dec	PDelReg2
		brne	Delay1m0
		ret

vypsat:

ldi pdelreg, 1

	ldi r28, 0b00010000
	out portD, r28
	out portC, tisic
	rcall delay1m

	ldi r28, 0b00010100
	out portD, r28
	out portc, sto
	rcall delay1m
	
	ldi r28, 0b00011000
	out portD, r28
	out portc, deset
	rcall delay1m

	ldi r28, 0b00011100
	out portD, r28
	out portc, jedna
	rcall delay1m


ret

init_z_pointer:

	ldi ZL, low(tabulka*2)
	ldi ZH, high(tabulka*2)

ret


get_table_end:
	ldi XL, low(end_tabulka*2)
	ldi XH, high(end_tabulka*2)
ret

prevod:

	rcall init_z_pointer
	add ZL, tisic
	adc ZH, ZeroReg
	lpm stoW, Z
	
	rcall init_z_pointer
	add ZL, sto
	adc ZH, ZeroReg
	lpm stoW, Z
	
	rcall init_z_pointer
	add ZL, deset
	adc ZH, ZeroReg
	lpm desetW, Z
	
	rcall init_z_pointer
	add ZL, jedna
	adc ZH, ZeroReg
	lpm jednaW, Z

ret



Main:

	rcall prevod
	rcall vypsat


	jednotky:
		inc r24
		mov jedna, r24
		subi jedna, 1
		rcall prevod
		rcall vypsat
		ldi pdelreg, 100
rcall delay1m
		cpi r24, 10
		breq jednotky
		clr r24
		rcall desitky

	desitky:
		inc r25
		mov deset, r25
		subi deset, 1
		rcall prevod
		rcall vypsat
		ldi pdelreg, 100
rcall delay1m
		cpi r25, 10
		brne jednotky
		rcall stovky

	stovky:
		inc r26
		mov sto, r26
		subi sto, 1
		rcall prevod
		rcall vypsat
		ldi pdelreg, 100
rcall delay1m
		cpi r26, 10
		brne jednotky
		rcall tisice

	tisice:
		inc r27
		mov tisic, r27
		subi tisic, 1
		rcall prevod
		rcall vypsat
		ldi pdelreg, 100
rcall delay1m
		cpi r27, 10
		brne jednotky

		clr r24
		clr r25
		clr r26
		clr r27
		clr jedna
		clr deset
		clr sto
		clr tisic 



		





rjmp Main




tabulka:
.db 0b11000000,0b11111001 ;0,1
.db 0b10100100,0b10110000 ;2,3
.db 0b10011001,0b10010010 ;4,5
.db 0b10000010,0b11111000 ;6,7
.db 0b10000000,0b10010000 ;8,9

end_tabulka:
