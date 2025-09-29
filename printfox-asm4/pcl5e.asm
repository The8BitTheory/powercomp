*=$1300

!to "pcl5e.bin.prg",cbm

; send data to the printer using the PCL5e language

dataDirectionReg        = $dd03
dataReg                 = $dd01
strobeReg               = $dd00
;bParseCommaUint16       = $880f ; skip comma, read unsigned 16-bit value to AAYY (also stored in linnum)
;bParseUint16CommaUint8  = $8803 ; read unsigned 16-bit value to linnum, comma, unsigned 8-bit value to X
bSkipComma              = $795c ; if comma: skip, otherwise: syntax error
bParseUint8toX          = $87f4 ; read unsigned 8-bit value to X
;chkcom          = $aefd
;frmnum          = $ad8a
;getadr          = $b7f7


.dataStart              = $fb

;sendToPrinter
    ; basic writes datastart to $fb/$fc
;    sta .dataStart
;    stx .dataStart+1
    sta .nrLines
    
;    jsr bSkipComma
;    jsr bParseUint8toX
    stx .nrLines+1
    
;    jsr bSkipComma
;    jsr bParseUint8toX
    sty .rasterLen
        
    ; set all data bits to output
    lda #$ff
    sta dataDirectionReg
    
    ; send printer setup data (page size, resolution, etc)
    ldy .headerEnd-.header
    ldx #0
    
-   lda .header,x
    jsr writeAndStrobe
    inx
    dey
    bne -
    
    ; put length of rasterline into sequence bytes
    lda .rasterLen
    jsr hexToDec

    ; repeat for .nrLines times
    
    
sendRasterline
; write rasterline esc sequence
    ldy .rasterEnd-.rasterline
    ldx #0
    
-   lda .rasterline,x
    jsr writeAndStrobe
    inx
    dey
    bne -
    
; write rasterline data
    ldx .rasterLen
    
    ldy #0
-   lda (.dataStart),y
    jsr writeAndStrobe
    iny
    bne +       ; if .y rolls over, increase the .dataStart high-byte
    inc .dataStart+1

+   dex
    bne -       ; if .x is zero, the rasterline is complete     
    
; decrease nrLines
    dec .nrLines
    bne sendRasterline
    dec .nrLines+1
    bpl sendRasterline

; once all rasterlines are sent, send graphics end to printer
    ldy .rasterTrailEnd-.rasterTrail
    ldx #0
    
-   lda .rasterTrail,x
    jsr writeAndStrobe
    inx
    dey
    bne -
    
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
        sta .rasterLen,x
        inc .lenPos
        PLA
        RTS
        
;.parseAddressParameter
;    jsr chkcom
;    jsr frmnum
;    jmp getadr

.nrLines    !word 0
.lenPos     !byte 0

; format setup data.
.header     !byte 27,69                 ;reset printer  ESC E
            !byte 27,38,108,50,65       ;page size a4   ESC & l 2 A
            !byte 27,42,114,48,70       ;raster reset   ESC * r 0 F
            !byte 27,42,114,55,53,82    ;75 dpi         ESC * r 75 R
            !byte 27,42,114,49,65       ;raster start   ESC * r 1 A
.headerEnd
            
.rasterline !byte 27,42,98              ;rasterline pre ESC * b
.rasterLen  !byte 0,0,0                 ;here comes length of rasterline in bytes (in ascii characters)
            !byte 87                    ;'W' concludes the rasterline definition
.rasterEnd

;then comes rasterdata. must consist of nr of bytes given just above

.rasterTrail!byte 27,42,114,67          ;raster end     ESC * r C
.rasterTrailEnd


.ff         !byte 12
.lf         !byte 13