*=$1a00

!to "pcl5erl.bin.prg",cbm

; send data to the printer using the PCL5e language

fetch_address           = $02aa
k_fetch                 = $02a2 ; read a value from any bank

dataReg                 = $dd01
strobeReg               = $dd00

.dataStart              = $fb

    jmp sendToPrinter

setup
    sei
    lda #$ff		; $dd01: Ausgang
	sta $dd03
	
    lda $dd02		; Bit 2 von $dd00 auf Ausgang
	ora #4
	sta $dd02
	
    lda strobeReg		; setzen
	ora #4
	sta strobeReg
	
    lda #$10		; _FLAG_ setzen
	sta $dd0d
	lda $dd0d
	cli

    rts

sendToPrinter    
    sta .dataStart
    stx .dataStart+1
    sty .rasterLen

    lda #.dataStart
    sta fetch_address
        
    ; put length of rasterline into sequence bytes
    lda .rasterLen
    jsr hexToDec

; write rasterline esc sequence
    ldy #.rasterEnd-.rasterline
    ldx #0
    
-   lda .rasterline,x
    jsr writeAndStrobe
    inx
    dey
    bne -
    
;-   lda $dd0d
;    and #$10
;    beq -


; write rasterline data
    ldy #0
    sty .storeY

-   ;lda (.dataStart),y
    ; check if printer is ready
    lda #$ff
    tax
    tay

busy	
    lda $dd0d
	dex
	bne bsy0
	dey
	beq .done
bsy0	
    and #$10		; warten auf BUSY
	beq busy

.do
    ldy .storeY
    ldx #$3f        ;bank 0
    jsr k_fetch

    jsr writeAndStrobe
    inc .storeY
    bne +       ; if .y rolls over, increase the .dataStart high-byte
    inc .dataStart+1

+   dec .rasterLen
    bne -       ; if .rasterLen is zero, the rasterline is complete     

.done    
    rts
    
    
    
writeAndStrobe
    sta dataReg
    
    ; set strobe bit (set to low)
    lda strobeReg
    and #255-4
    sta strobeReg
    
    ; clear strobe bit (set to high)
    ;lda strobeReg
    ora #4
    sta strobeReg
    
    rts
    
hexToDec
; DECOUT: output a decimal value using CHROUT (always 3 chars)
; .A the value to output
        ldx #0
        stx .lenPos
        LDX #$FF
        SEC
PR100:  INX
        SBC #100
        BCS PR100       ; count 100s
        ADC #100
        JSR DECDIGIT    ; print 100s
        LDX #$FF
        SEC             ; prepare for subtraction
PR10:   INX
        SBC #10
        BCS PR10        ; count 10s
        ADC #10
        JSR DECDIGIT    ; print 10s
        TAX             ; 1s -> .X
DECDIGIT:
        PHA
        TXA             ; save .A pass digit to .A
        ORA #48
        ldx .lenPos
        sta .rasterLenD,x
        inc .lenPos
        PLA
        RTS
        
.lenPos     !byte 0

.rasterline !byte 27,42,98              ;rasterline pre ESC * b
.rasterLenD !byte 0,0,0                 ;here comes length of rasterline in bytes (in ascii characters)
            !byte 87                    ;'W' concludes the rasterline definition
.rasterEnd

.rasterLen  !byte 0
.storeY     !byte 0
