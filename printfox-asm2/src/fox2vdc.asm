; this loads Printfox and Pagefox files and displays them 
; on the VDC Chip.

k_indfet = $ff74
k_indsta = $ff77
k_primm  = $ff7d

t_gb            = 71
t_bs            = 66
t_pg            = 80

indsta_addr     = $02B9
magic_byte      = $9b
source_address  = $fa ;$fa-$fb
write_address    = $fc; $fc-$fd

*= $1300

    jmp start

source_bank             !byte 0
source_end_address      !word 0
dest_bank               !byte 0
dest_address            !word 0

file_type               !byte 0 ;71 for gb, 66 for bs, 80 for pg
nr_columns              !byte 0 ;80 for gb, 40 for bs, variable for pg
nr_rows                 !byte 0 ;50 for gb, 25 for bs, variable for pg

read_offset             !byte 0
line_offset             !word 0 ;L in basic version
column_counter          !byte 0 ;O in basic version
unpack_repeats          !word 0 ;R in basic version
line_offset_count       !byte 8 ;makes it easier to compare to than to 560

start 

    lda $3e4
    sta source_bank

    ldx $3e5
    stx source_address
    ldy $3e6
    sty source_address+1

    ldx $3e7
    stx source_end_address
    ldy $3e8
    sty source_end_address+1

    lda $3e9
    sta dest_bank

    ldx $3ea
    stx dest_address
    ldy $3eb
    sty dest_address+1

; read filetype
    ldx source_bank
    ldy #0
    lda #source_address
    jsr k_indfet
    jsr .inc_source_address
    sta file_type

    ;x-reg nr columns
    ;y-reg nr rows

    cmp #t_bs
    bne +
    lda #40
    sta nr_columns
    lda #25
    sta nr_rows
    jmp process_image_data

+   cmp #t_gb
    bne +
    lda #80
    sta nr_columns
    lda #50
    sta nr_rows
    jmp process_image_data

+   cmp #t_pg
    bne .invalid
    ldx source_bank
    lda #source_address
    jsr k_indfet
    sta nr_rows

    jsr .inc_source_address

    ldx source_bank
    lda #source_address
    sta nr_columns

    ;skip "Kontur" area (until next zero-byte)
-   iny
    bne +
    inc source_address+1
    
+   ldx source_bank
    lda #source_address
    jsr k_indfet
    bne -
    jsr .inc_source_address

    sty read_offset
    jmp process_image_data

.invalid
    jsr k_primm
    !pet "Invalid format"

    sec
    rts

;---------
; read image data
process_image_data

-   ldy read_offset
    ldx source_bank
    lda #source_address
    jsr k_indfet
    jsr .inc_source_address
    sty read_offset

    cmp magic_byte
    beq .unpack
    jsr .copy    
    
continue_processing
    ;check end condition


    ;if end met, clear carry flag and return from subroutine
    clc
    rts

; write Acc-Value to the next write-position (write_address)
.copy
    ; write_address = dest_address + line_offset
    ; line_offset = line_offset + nr_columns. if line_offset > 7*nrColumns then line_offset=0,column_counter=0,dest_address+=1
    
+   pha
    
    clc
    lda dest_address
    adc line_offset
    sta write_address
    lda dest_address+1
    adc line_offset+1
    sta write_address+1

;   write value
    ldy #0
    ldx dest_bank
    pla
    jsr k_indsta
    

;   increase line_offset
    clc
    lda line_offset
    adc nr_columns
    sta line_offset
    bcc +
    inc line_offset+1

+   dec line_offset_count
    bne .end_copy

    ;l=0
    lda #8
    sta line_offset_count
    lda #0
    sta line_offset
    sta line_offset+1

;c=c+1
    inc dest_address
    bne +
    inc dest_address+1

    ;o=o+1
+   inc column_counter

    ldx column_counter
    cpx nr_columns  ;if o=f (o>f-1)
    bne .end_copy           ;no

    ;o=0
    ldx #0
    stx column_counter

    ;c=j+c
    clc
    lda write_address
    adc nr_columns
    sta dest_address
    bcc .end_copy
    inc dest_address+1

.end_copy
    

.end
    rts


.unpack
    ;y is the right value upon jumping here

    ;load nr of repeats
    ldx source_bank
    lda #source_address
    jsr k_indfet
    jsr .inc_source_address
    sta unpack_repeats

    ldx file_type
    cpx #t_pg   ;pagefox only has one byte for repeats
    beq +       ;if pagefox, set high-byte to 1

    ;if not pagefox:
    ;read high-byte of unpack-repeats
    ldx source_bank
    lda #source_address
    jsr k_indfet
    jsr .inc_source_address
    sta unpack_repeats+1
    jmp .read_value

    ;if pagefox and low-byte is zero, set high-byte to 1
+   cmp #0
    bne .read_value
    lda #1
    sta unpack_repeats+1

    ;read value that's repeated
.read_value
    ldx source_bank
    lda #source_address
    jsr k_indfet
    jsr .inc_source_address
    sty read_offset

    ; copy current value a number of times
    ; unpack_repeats could start at $00, runs 256 times then
-   jsr .copy
    dec unpack_repeats
    bne -

    ; unpack_repeats+1 (only for gb and bs) can be maximum 125
    ; which is always positive
    ; if it is zero at start (no high-byte), BPL should make sure
    ;  that we're ending immediately
    dec unpack_repeats+1
    bpl -

    jmp continue_processing

.inc_source_address
    iny
    bne +
    inc source_address+1

+   rts