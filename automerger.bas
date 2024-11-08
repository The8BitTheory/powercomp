#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0,uppercase,10,10
10 REM AUTOMATIC CERTIFICATE MERGER

15 S1=TI:FAST:GRAPHIC1:GRAPHIC0:GRAPHIC5:BANK15:POKE 57,0:POKE58,39:CLR

#  ACTIVE DISK DRIVE (WILL NEED READ AND WRITE DRIVE, GOING FORWARD)
20 DD=PEEK(186)

#  BASIC END. START OF USABLE MEMORY IN BANK 0
21 BE=PEEK(4624)+PEEK(4625)*256

#  VARIABLE END. START OF USABLE MEMORY IN BANK 1
22 VE=PEEK(57)+PEEK(58)*256


28 DEF FN HB(ZZ)=INT(ZZ/256)
29 DEF FN LB(ZZ)=ZZ-INT(ZZ/256)*256


#  I$: INPUT OF ACTION TO EXECUTE
#  M0(1,1): MEMORY SLOTS OF BANK 0
#  M1(50,1): MEMORY SLOTS OF BANK 1(FIRST VALUE IS THE ID, SECOND IS KEY FOR START- OR END-ADDRESS)
#  FD$(50): FILENAME DICTIONARY. KEEPS THE FILENAME THAT WAS LOADED INTO A SLOT. NEEDED FOR EXCEPTION HANDLING
#  SL(): HOLDS THE NEXT AVAILABLE SLOT-ID FOR EACH BANK (BOTH VALUES INITIALLY ZERO)
30 DIM I$(5),MS(50,1),FD$(50),SL(1)

#  FIRST MEMORY SLOT IN BANK1
35 M0(0,0)=BE:M1(0,0)=VE



########################
# LOAD AUTOMATION FILE #
########################
# FORMAT:
# 0:COMMAND
# 1:FILENAME (- IF NOT INVOLVED)
# 2:BANK TO READ FROM
# 3:ADDRESS TO READ FROM
# 4:BANK TO WRITE TO
# 5:ADDRESS TO WRITE TO

# ADDRESSES REFERS TO MEMORY SLOTS
# EACH MEMORY SLOT CONTAINS START- AND END-ADDRESS
# MEMORY SLOTS EXIST PER RAM-BANK (IE TWO LISTS OF MEMORY SLOTS)

200 OPEN128,DD,2,"S24-HYPE.AUTO,S,R"

# WE JUST ITERATE THROUGH THE OPEN FILE INSTEAD OF STORING ALL COMMANDS TO AN ARRAY
# THAT SAVES A TON OF MEMORY AND IS TOTALLY SUFFICIENT BECAUSE LINES DON'T REFERENCE EACH OTHER

210 DO
220  INPUT#128,I$(0),I$(1),I$(2),I$(3),I$(4)

#    GET IMAGE DATA (FROM DISK OR MEMORY)
230  IF I$(0)="G0" THEN GOSUB 1000:GOTO 290
235  IF I$(0)="G+" THEN GOSUB 1100:GOTO 290

#    UNCOMPRESS (REGULAR, OR, TO CONTINUOUS BYTES)
240  IF I$(0)="UN" THEN GOSUB 2000:GOTO 290
245  IF I$(0)="UO" THEN GOSUB 3000:GOTO 290
250  IF I$(0)="UX" THEN GOSUB 4000:GOTO 290

#    PACK TO GB FILE
255  IF I$(0)="PG" THEN GOSUB 5000:GOTO 290
#    PACK PCX FILE (WITH HEADER FOR FIRST HALF, WITHOUT HEADER FOR SECOND HALF)
260  IF I$(0)="PH" THEN SY=1309:GOSUB 9000:GOTO 290
265  IF I$(0)="PD" THEN SY=1306:GOSUB 9000:GOTO 290

#    FILE-SAVE (WITHOUT LEADING ADDRESS BYTES)
270  IF I$(0)="FS" THEN GOSUB 10000:GOTO 290

285  PRINT "UNKNOWN COMMAND: "I$(0)

290 LOOP UNTIL (ST AND 64)=64

298 CLOSE128

999 END



################
# LOAD GB FILE #
################
# FI$:FILENAME
# WB :WRITE-BANK
# WS :WRITE-SLOT
# WA :WRITE-ADDRESS (RETRIEVED VIA WS FROM MEMORY-SLOT ARRAY)


# G0 SETS WS TO 0
1000 WS=0:GOTO 1110

# G+ READS WS FROM .AUTO FILE
1100 WS=VAL(I$(5))

1110 FI$=I$(1):WB=VAL(I$(4))

1105 IF WB=0 THEN WA=M0(WS,0)
1106 IF WB=1 THEN WA=M1(WS,0)

1109 PRINT "LOADING "FI$" TO B"WB",AD"WA;
1110 DOPEN #1,U(DD),(FI$),R
1120 GET#1,A$,B$
1130 DCLOSE #1

1140 IF A$<>"G" THEN PRINT FI$" IS NOT A GB FILE":END

# LOAD BINARY FILE. LEAVE TWO BYTES EMPTY AND MANUALLY POKE THE VALUES (BLOAD SKIPS THESE)
1150 BLOAD (FI$),B(WB),P(WA+2),U(DD)
1160 PRINT "DONE"


# FILE END (END OF COMPRESSED GB FILE
1170 FE=PEEK(174)+PEEK(175)*256
1175 IF WB=0 THEN M0(WS,1)=FE
1176 IF WB=1 THEN M1(WS,1)=FE

1178 FD$(WS)=FI$

1180 PRINT " FILE END:"FE


1190 BANK WB
1200 POKE WA,ASC(A$):POKE WA+1,ASC(B$)
1210 BANK 15

1220 RETURN


################################
# UNCOMPRESS                   #
# KEEPS BYTE ORDER AS IT IS    #
# USED TO HAVE MERGABLE IMAGES #
################################

# SET VARIABLES FOR UNCOMPRESSION

# SOURCE BANK
2000 POKE 996,SB

# SOURCE START ADDRESS
#1040 POKE 997,PEEK(4624):POKE 998,PEEK(4625)
2040 POKE 997,FNLB(SA):POKE 998,FNHB(SA)

# SOURCE END ADDRESS
2050 POKE 999,PEEK(174):POKE 1000,PEEK(175)

# DESTINATION BANK
2060 POKE 1001,DB

# DESTINATION ADDRESS
#1070 POKE 1002,FNLB(VE):POKE 1003,FNHB(VE)
2070 POKE 1002,FNLB(DA):POKE 1003,FNHB(DA)

2080 PRINT "UNCOMPRESSING TO: B"DB",DA"DA" - "(DA+32000)
2090 S=TI:SYS DEC("130C"):S=TI-S
2092 PRINT "DONE. TOOK "S" JIFFIES"

2099 RETURN

################################
# UNCOMPRESS BY OR'ING VALUES  #
# KEEPS BYTE ORDER AS IT IS    #
# USED TO MERGE WHEN UNPACKING #
################################

# IMG1 BANK: 996
# IMG1 START ADDRESS (UNCOMP GB):997/998

# IMG2 BANK: 1001
# IMG2 START ADDRESS (UNCOMP GB):1002/1003
3000 POKE 996,SB
3010 POKE 997,FNLB(SA):POKE 998,FNHB(SA)

3020 POKE 999,FNLB(FE):POKE 1000,FNHB(FE)

3030 POKE 1001,DB
3040 POKE 1002,FNLB(DA):POKE1003,FNHB(DA)

#3050 PRINT "LOADING GBUNPACKOR.BIN...";:BLOAD"GBUNPACKOR.BIN",B0,U(DD):PRINT "DONE"

3060 PRINT "MERGING... FROM B"SB","SA"-"FE" TO B"DB","DA;:S=TI:SYS DEC("1300"):S=TI-S
3070 PRINT "DONE. TOOK "S" JIFFIES"

###############################################
# UNCOMPRESS GB FILE TO CONTINUOUS BIT STREAM #
# USED BEFORE PCX COMPRESSION                 #
###############################################

# SOURCE BANK
4000 POKE 996,SB

# SOURCE START ADDRESS
#1040 POKE 997,PEEK(4624):POKE 998,PEEK(4625)
4010 POKE 997,FNLB(SA):POKE 998,FNHB(SA)

# SOURCE END ADDRESS
4020 POKE 999,FNLB(SE):POKE 1000,FNHB(SE)

# DESTINATION BANK
4030 POKE 1001,DB

# DESTINATION ADDRESS
#1070 POKE 1002,FNLB(VE):POKE 1003,FNHB(VE)
4040 POKE 1002,FNLB(DA):POKE 1003,FNHB(DA)

4050 PRINT "UNCOMPRESSING TO: B"DB",DA"DA" - "(DA+32000)
4060 S=TI:SYS DEC("1300"):S=TI-S
4070 PRINT "DONE. TOOK "S" JIFFIES"


4080 RETURN


##################################
# PACK TO GB FILE                #
# BYTE ORDER NEEDS TO BE CORRECT #
##################################

#     PACK PARAMETERS
# SOURCE BANK: 996
# SOURCE START ADDRESS (COMP GB):997/998

5000   POKE 996,0
5010   POKE 997,FNLB(BE):POKE 998,FNHB(BE)

# DEST BANK: 999
# DEST START ADDRESS (UNCOMP GB):1000/1001
5020   POKE 999,0
5030   POKE 1000,FNLB(BE+32000):POKE 1001,FNHB(BE+32000)


5040   PRINT "PACKING... B0,"BE" TO B0,"BE+32000;:S=TI:SYS DEC("1309"):S=TI-S
5050   PRINT "DONE. TOOK "S" JIFFIES"



###################
# PCX COMPRESSION #
###################
#     PACK PARAMETERS
# SOURCE BANK: 996
# SOURCE START ADDRESS (COMP GB):997/998

9000 POKE 996,SB
9010 POKE 997,FNLB(SA):POKE 998,FNHB(SA)

# DEST BANK: 999
# DEST START ADDRESS (UNCOMP GB):1000/1001
9020 POKE 999,DB
9030 POKE 1000,FNLB(DA):POKE 1001,FNHB(DA)

9040 PRINT "PACKING... B"SB","SA" TO B"DB","DA;:S=TI:SYS SY:S=TI-S
9050 PRINT "DONE. TOOK "S" JIFFIES"

9060 EA=PEEK(1002)+PEEK(1003)*256
9070 PRINT "PACKED GB RESIDES IN B"DB" FROM "DA" TO "EA

9080 RETURN


#########################
# FSAVE
#########################
# TAKES SA AS START ADDRESS
#       EA AS END ADDRESS
#       SB AS SAVE-BANK


10000 FP=POINTER(FI$):BANK 1:F0=PEEK(FP):F1=PEEK(FP+1):F2=PEEK(FP+2):BANK15

10010 POKE 1002,F0:REM PRINT "FILENAME LENGTH:"F0
10020 POKE 1000,F1:POKE 1001,F2:REM PRINT "FILENAME ADDRESS:"(F1+F2*256)


#    FILE START-ADDRESS
10030 POKE DEC("FB"),FNLB(SA):POKE DEC("FC"),FNHB(SA)
#    FILE END-ADDRESS
10040 POKE 998,FNLB(E2):POKE 999,FNHB(E2)

#    FILE BANK
10050 POKE 1003,SB

10060 POKE 186,DD
10070 PRINT "SAVING "SA" TO "E2" AS "FI$"...";:SYS DEC("1E33"):PRINT "DONE:"ST


10080 RETURN


