#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0,uppercase,10,10
1 REM GB2PCX DRIVER PROGRAM
2 REM DOES THE FOLLOWING STEPS
3 REM 1) BLOAD GB FILE (SPECIAL TREATMENT FOR FIRST 2 BYTES)
4 REM 2) UNPACKS GB FILE BY USING GB2VDC.BIN (IE RE-ORGANIZING BYTES TO BE CONTINOUS)
5 REM 3) PACKS RAW DATA FROM STEP 2 TO PCX FORMAT BY USING PCXPACK.BIN
6 REM 4) FSAVE PACKED PCX-FILE

10 GRAPHIC1:GRAPHIC0:GRAPHIC5:FAST:BANK15:POKE 57,0:POKE58,39:CLR

11 DEF FN HB(ZZ)=INT(ZZ/256)
12 DEF FN LB(ZZ)=ZZ-INT(ZZ/256)*256

14 DD=PEEK(186)

# BASIC END (CONTAINS COMPRESSED GB FILE)
16 BE=PEEK(4624)+PEEK(4625)*256

# VARIABLE END (CONTAINS UNCOMPRESSED GB FILES)
18 VE=PEEK(57)+PEEK(58)*256

20 PRINT "LOADING GB2VDC.BIN...";:BLOAD"GB2VDC.BIN",B0,U(DD):PRINT "DONE"
22 PRINT "LOADING PCXPACK2-1720.BIN...";:BLOAD"PCXPACK2-1720.BI",B0,U(DD):PRINT "DONE"

#   STEP 1
100 FI$="S24-MINI-THE.GB1":SB=1:SA=VE+32000:GOSUB 2000:G1=FE:SE=FE

#   STEP 2 - UNCOMPRESS
110 DB=1:DA=VE:GOSUB 1000

#   STEP 3 - CREATE PCX HEADER AND COMPRESS GB1-PCX FILE
120 SB=1:SA=VE:DB=0:DA=BE:SY=DEC("1726"):GOSUB 3000:E1=EA


122 FI$="S24-MINI-1.GB2":SB=1:SA=VE+32000:GOSUB 2000:G2=FE:SE=FE

#   UNCOMPRESS
124 DB=1:DA=VE:GOSUB 1000

#   COMPRESS GB2-PCX FILE
126 SB=1:SA=VE:DB=0:DA=E1:SY=DEC("1729"):GOSUB 3000:E2=EA

#   STEP 4
130 PRINT "LOADING FSAVE.BIN...";:BLOAD"FSAVE.BIN",B0,U(DD):PRINT "DONE:"ST
140 SB=0:SA=BE:DA=E2:FI$="ONE.PCX,P,W":GOSUB 5000

199 END


###############################################
# UNCOMPRESS GB FILE TO CONTINUOUS BIT STREAM #
###############################################

# SOURCE BANK
1000 POKE 996,SB

# SOURCE START ADDRESS
#1040 POKE 997,PEEK(4624):POKE 998,PEEK(4625)
1040 POKE 997,FNLB(SA):POKE 998,FNHB(SA)

# SOURCE END ADDRESS
1050 POKE 999,FNLB(SE):POKE 1000,FNHB(SE)

# DESTINATION BANK
1060 POKE 1001,DB

# DESTINATION ADDRESS
#1070 POKE 1002,FNLB(VE):POKE 1003,FNHB(VE)
1070 POKE 1002,FNLB(DA):POKE 1003,FNHB(DA)

1080 PRINT "UNCOMPRESSING TO: B"DB",DA"DA" - "(DA+32000)
1090 S=TI:SYS DEC("1300"):S=TI-S
1092 PRINT "DONE. TOOK "S" JIFFIES"


1099 RETURN


#############################
# LOAD GB FILE TO BASIC-END #
#############################
2000 PRINT "LOADING "FI$" TO B"SB",AD"SA;
2005 DOPEN #1,U(DD),(FI$),R
2010 GET#1,A$,B$
2020 DCLOSE #1

2030 IF A$<>"G" THEN PRINT FI$" IS NOT A GB FILE":END

# LOAD BINARY FILE. LEAVE TWO BYTES EMPTY AND MANUALLY POKE THE VALUES (BLOAD SKIPS THESE)
2040 BLOAD (FI$),B(SB),P(SA+2),U(DD)
2041 PRINT "DONE"


# FILE END (END OF COMPRESSED GB FILE
2042 FE=PEEK(174)+PEEK(175)*256
2044 PRINT "FILE END:"FE


2050 BANK SB
2052 POKE SA,ASC(A$):POKE SA+1,ASC(B$)
2054 BANK 15



2070 RETURN


###################
# PCX COMPRESSION #
###################
#     PACK PARAMETERS
# SOURCE BANK: 996
# SOURCE START ADDRESS (COMP GB):997/998

3000 POKE 996,SB
3010 POKE 997,FNLB(SA):POKE 998,FNHB(SA)

# DEST BANK: 999
# DEST START ADDRESS (UNCOMP GB):1000/1001
3020 POKE 999,DB
3030 POKE 1000,FNLB(DA):POKE 1001,FNHB(DA)

3040 PRINT "PACKING... B"SB","SA" TO B"DB","DA;:S=TI:SYS SY:S=TI-S
3050 PRINT "DONE. TOOK "S" JIFFIES"

3060 EA=PEEK(1002)+PEEK(1003)*256
3070 PRINT "PACKED GB RESIDES IN B"DB" FROM "DA" TO "EA

3080 RETURN


#########################
# FSAVE 
#########################
# TAKES SA AS START ADDRESS
#       EA AS END ADDRESS
#       SB AS SAVE-BANK


5000 FP=POINTER(FI$):BANK 1:F0=PEEK(FP):F1=PEEK(FP+1):F2=PEEK(FP+2):BANK15

5010 POKE 1002,F0:PRINT "FILENAME LENGTH:"F0
5020 POKE 1000,F1:POKE 1001,F2:PRINT "FILENAME ADDRESS:"(F1+F2*256)

#5025 PRINT "BSAVEING FROM B"SB","SA"-"DA"...";:BSAVE("@"+FI$),B(SB),P(SA) TO P(DA),U(DD):PRINT "DONE"

#    FILE START-ADDRESS
5030 POKE DEC("FB"),FNLB(SA):POKE DEC("FC"),FNHB(SA)
#    FILE END-ADDRESS
5040 POKE 998,FNLB(E2):POKE 999,FNHB(E2)

#    FILE BANK
5050 POKE 1003,SB

5055 SCRATCH (FI$)
5060 POKE 186,8:PRINT "SAVING "SA" TO "E2" AS "FI$"...";:SYS DEC("1300"):PRINT "DONE:"ST


5999 RETURN