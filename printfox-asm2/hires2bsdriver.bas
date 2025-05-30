#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0 VDC,uppercase,10,10

10 GRAPHIC 1,1:GRAPHIC0:COLOR 0,2:COLOR 1,1
20 GRAPHIC 5
30 BANK 15:POKE 57,0:POKE58,39:CLR

32 DEF FN HB(ZZ)=INT(ZZ/256)
34 DEF FN LB(ZZ)=ZZ-INT(ZZ/256)*256


40 DD=PEEK(186)

# BASIC END
41 BE=PEEK(4624)+PEEK(4625)*256

# VARIABLE END
42 VE=PEEK(57)+PEEK(58)*256


43 PRINT "BASIC END:"BE
44 PRINT "VARIABLE END:"VE

45 PRINT "LOADING BSPACK.BIN...";:BLOAD"BSPACK.BIN",B0,U(DD):PRINT "DONE"
46 PRINT "LOADING FSAVE.BIN...";:BLOAD"FSAVE-1C20.BIN",B0,U(DD):PRINT "DONE"



50 DIM FI$(67)
60 IX=0

70 FOR B=1 TO 40
80  FI$(IX)="BILD"+STR$(B)
90  IX=IX+1
100 NEXT

110 B1=1:B2=118

120 FOR B=B1 TO B2 STEP 9
130  IF B=100 THEN 190
140  IF B<10 THEN NR$="00"+MID$(STR$(B),2):GOTO 170
150  IF B<100 THEN NR$="0"+MID$(STR$(B),2):GOTO 170

160  NR$=MID$(STR$(B),2)
170  FI$(IX)="PM"+NR$+"-*"
180  IX=IX+1

190 NEXT


200 IF B1=1 THEN B1=123:B2=168:GOTO 120
210 IF B1=123 THEN B1=186:B2=240:GOTO 120
220 IF B1=186 THEN B1=248:B2=257:GOTO 120

#230 FOR B=0 TO 67
230 B=0
240  FI$=FI$(B)
250  PRINT "SHOWING "FI$
260  BLOAD (FI$),B0,U(DD),P(BE)


270  SB=1:SA=VE:GOSUB 1000

280  GOSUB 5000

#290 NEXT

300 END




#     PACK PARAMETERS
# SOURCE BANK: 996
# SOURCE START ADDRESS (COMP GB):997/998

# VIC-II RAM. BANK 0, ADDRESS $2000
1000 POKE 996,0
1010 POKE 997,FNLB(BE):POKE 998,FNHB(BE)

# DEST BANK: 999
# DEST START ADDRESS (UNCOMP GB):1000/1001
1020 POKE 999,SB
1030 POKE 1000,FNLB(SA):POKE 1001,FNHB(SA)


1040 PRINT "PACKING... TO B1,"SA+1;:S=TI:SYS DEC("1300"):S=TI-S
1050 PRINT "DONE. TOOK "S" JIFFIES"

1060 EA=PEEK(1002)+PEEK(1003)*256
1070 PRINT "PACKED GB RESIDES IN B1 FROM "SA" TO "EA

1090 RETURN



#########################
# FSAVE 
#########################
# TAKES SA AS START ADDRESS
#       EA AS END ADDRESS
#       SB AS SAVE-BANK


5000 FI$=FI$+".BS"
5005 FP=POINTER(FI$):BANK 1:F0=PEEK(FP):F1=PEEK(FP+1):F2=PEEK(FP+2):BANK15

5010 POKE 1002,F0:REM PRINT "FILENAME LENGTH:"F0
5020 POKE 1000,F1:POKE 1001,F2:REM PRINT "FILENAME ADDRESS:"(F1+F2*256)

#    FILE START-ADDRESS
5030 POKE DEC("FB"),FNLB(SA):POKE DEC("FC"),FNHB(SA)
#    FILE END-ADDRESS
5040 POKE 998,FNLB(EA):POKE 999,FNHB(EA)

#    FILE BANK
5050 POKE 1003,SB

#285 SCRATCH (FI$)
5060 PRINT "SAVING "SA" TO "EA" AS "FI$"...";:SYS DEC("1C20"):PRINT "DONE"


5999 RETURN