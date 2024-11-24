; this reads a Fox (Printfox BS and GB, Pagefox) file from disk.
; while reading, it directly unpacks to a target memory area.

; this is based on https://codebase64.org/doku.php?id=base:reading_a_file_byte-by-byte

;!to "gbdskvdc.bin.prg",cbm

*= $ac6 ;2758 decimal


k_indfet = $ff74
k_indsta = $ff77

k_basic_end = $1210

m_filename = $100     ; tape error log.
z_filename_len =$fa
m_temp    = $aba      ; 2746. 6 bytes available

z_temp_w    = $fb       ; 


;$1210,$1211 contains basic end (bank0)
;$57,$58 contain variable end (bank1)

;Accumulator holds filename length
;X and Y hold LB,HB of location of filename
; store these, so we can use them for indfet

        pha                     ;push filename length to stack
        sta z_filename_len
        stx z_temp_w
        sty z_temp_w+1

        ldy #0
        
-       lda #z_temp_w
        ldx #1
        jsr k_indfet
        sta m_filename,y
        iny
        dec z_filename_len
        bne -
        
        pla                     ;restore filename length from stack
        ldx #<m_filename
        ldy #>m_filename
        
        ;LDA #fname_end-fname
        ;LDX #<fname
        ;LDY #>fname
        JSR $FFBD     ; call SETNAM
        
        
        ;--------------
        ;lda k_basic_end
        ;sta z_temp_w
        ;lda k_basic_end+1
        ;sta z_temp_w+1
        
        lda #$ae
        sta $02b9
        ;--------------

        LDA #$02      ; file number 2
        LDX $BA       ; last used device number
        BNE .skip
        LDX #$08      ; default to device 8
.skip   LDY #$02      ; secondary address 2
        JSR $FFBA     ; call SETLFS

        JSR $FFC0     ; call OPEN
        BCS .error    ; if carry set, the file could not be opened

        ; check drive error channel here to test for
        ; FILE NOT FOUND error etc.

        LDX #$02      ; filenumber 2
        JSR $FFC6     ; call CHKIN (file 2 now used as input)

        ;LDA #<load_address
        LDA k_basic_end     ; basic end LB
        STA $AE
        ;LDA #>load_address
        LDA k_basic_end+1     ; basic end HB
        STA $AF

        LDY #$00
.loop   JSR $FFB7     ; call READST (read status byte)
        BNE .eof      ; either EOF or read error
        JSR $FFCF     ; call CHRIN (get a byte from file)
        
        
        ldx #0
        JSR k_indsta
        ;STA ($AE),Y   ; write byte to memory
        
        ;iny
        INC $AE
        BNE .skip2
        INC $AF
.skip2  JMP .loop     ; next byte

.eof
        AND #$40      ; end of file?
        BEQ .readerror
.close
        LDA #$02      ; filenumber 2
        JSR $FFC3     ; call CLOSE

        JSR $FFCC     ; call CLRCHN
        RTS
.error
        ; Akkumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)

        ;... error handling for open errors ...
        JMP .close    ; even if OPEN failed, the file has to be closed
.readerror
        ; for further information, the drive error channel has to be read

        ;... error handling for read errors ...
        JMP .close


