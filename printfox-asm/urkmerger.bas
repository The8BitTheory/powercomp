#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0,uppercase,10,10
#########################
# THIS ORS TWO GB FILES #
#########################

# SOURCE IMAGES RESIDE IN BANK 1
# DEST IMAGE IS WRITTEN TO BANK 0


2 S1=TI:FAST:GRAPHIC1:GRAPHIC0:GRAPHIC5:BANK15:POKE 57,0:POKE58,40:CLR
4 DD=PEEK(186)

# BASIC END (CONTAINS COMPRESSED GB FILE)
6 BE=PEEK(4624)+PEEK(4625)*256

# VARIABLE END (CONTAINS UNCOMPRESSED GB FILES)
8 VE=PEEK(57)+PEEK(58)*256

10 PRINT "BASIC END (COMPRESSED GB):"BE
12 PRINT "VARIABLE END (UNCOMP. GB):"VE



15 PRINT "LOADING GB.BIN...";:BLOAD"GB.BIN",B0,U(DD):PRINT "DONE"
16 PRINT "LOADING FSAVE.BIN...";:BLOAD"FSAVE-1C20.BIN",B0,U(DD):PRINT "DONE"


20 DEF FN HB(ZZ)=INT(ZZ/256)
21 DEF FN LB(ZZ)=ZZ-INT(ZZ/256)*256

25 PM=31:DM=6:DIM IM(DM),PN$(DM,PM),PS(DM,PM)

# LOAD DATAFILE
30 GOSUB 1100
31 PRINT FRE(0) FRE(1)


100 FOR CD=0 TO 4

110  FI$="24SUM3.GB1"    :SB=0:SA=BE      :DB=1:DA=VE:GOSUB 1000

142  FI$="DISZ"+LEFT$(DN$(CD),4)+".GB":SB=1:SA=VE+32000:DB=0:DA=BE:GOSUB 1000

200  PRINT "MERGING GB FILES"

# IMG1 BANK: 996
# IMG1 START ADDRESS (UNCOMP GB):997/998

# IMG2 BANK: 1001
# IMG2 START ADDRESS (UNCOMP GB):1002/1003
210  POKE 996,1
212  POKE 997,FNLB(VE):POKE 998,FNHB(VE)

220  POKE 1001,0
222  POKE 1002,FNLB(BE):POKE 1003,FNHB(BE)

250  PRINT "MERGING... ";:S=TI:SYS DEC("1306"):S=TI-S
255  PRINT "DONE. TOOK "S" JIFFIES"

#257 PRINT "SAVE MERGED FILE... ";:BSAVE "@MERGED.GB",B0,P(BE) TO P(BE+32000),U(DD):PRINT"DONE"

# SOURCE BANK: 996
# SOURCE START ADDRESS (COMP GB):997/998

262  POKE 996,0
264  POKE 997,FNLB(BE):POKE 998,FNHB(BE)

# DEST BANK: 999
# DEST START ADDRESS (UNCOMP GB):1000/1001
266  POKE 999,1
268  POKE 1000,FNLB(VE):POKE 1001,FNHB(VE)


270  PRINT "PACKING...";:S=TI:SYS DEC("1309"):S=TI-S
272  PRINT "DONE. TOOK "S" JIFFIES"

275  EA=PEEK(1002)+PEEK(1003)*256
276  PRINT "PACKED GB FROM "VE" TO "EA

277  FI$="2TEST-"+LEFT$(DN$(CD),4)+".GB1,P,W"

278  FP=POINTER(FI$):BANK 1:F0=PEEK(FP):F1=PEEK(FP+1):F2=PEEK(FP+2):BANK15

279  POKE 1002,F0:PRINT "FILENAME LENGTH:"F0
280  POKE 1000,F1:POKE 1001,F2:PRINT "FILENAME ADDRESS:"(F1+F2*256)

#285  BSAVE"@24SUM-"+LEFT$(DN$(CD),4)+".GB1",B1,P(VE) TO P(EA),U(DD)

#    FILE START-ADDRESS
282  POKE DEC("FB"),FNLB(VE):POKE DEC("FC"),FNHB(VE)
#    FILE END-ADDRESS
283  POKE 998,FNLB(FE):POKE 999,FNHB(FE)

#    FILE BANK
284  POKE 1003,1

#285  SCRATCH (FI$)
286  PRINT "SAVING "FI$"...";:SYS DEC("1C20"):PRINT "DONE"

300  REM ITERATE OVER PARTICIPANTS OF THIS DISCIPLINE
310  REM MERGE EACH PARTICIPANT NAME WITH THE PACKED IMAGE FILE FROM LINE #285
320  REM SAVE IMAGE AS 24SUMXXXXYYY.GB1

499 NEXT


500 REM ITERATE OVER DISCIPLINES
510 REM LOAD BOTTOM PAGE (24SUM-??.GB2)
520 REM ITERATE OVER PARTICIPANTS OF THIS DISCIPLINE
530 REM MERGE EACH PARTICIPANT RANK WITH THE BOTTOM PAGE
540 REM SAVE IMAGE AS 24SUMXXXXYYY.GB2



999 BANK15:GRAPHIC5:S1=TI-S1:PRINT "TOTAL:"S1:END


##############
# UNCOMPRESS #
##############
1000 GOSUB 2000



# SET VARIABLES FOR GB2VDC.BIN

# SOURCE BANK
1030 POKE 996,SB

# SOURCE START ADDRESS
#1040 POKE 997,PEEK(4624):POKE 998,PEEK(4625)
1040 POKE 997,FNLB(SA):POKE 998,FNHB(SA)

# SOURCE END ADDRESS
1050 POKE 999,PEEK(174):POKE 1000,PEEK(175)

# DESTINATION BANK
1060 POKE 1001,DB

# DESTINATION ADDRESS
#1070 POKE 1002,FNLB(VE):POKE 1003,FNHB(VE)
1070 POKE 1002,FNLB(DA):POKE 1003,FNHB(DA)

1080 PRINT "UNCOMPRESSING TO: B"DB",DA"DA" - "(DA+32000)
1090 S=TI:SYS DEC("130C"):S=TI-S
1092 PRINT "DONE. TOOK "S" JIFFIES"

1099 RETURN


##################
# LOAD DATA FILE #
##################

1100 DN$="SOMMER2024.PC"
1110 OPEN1,DD,3,DN$+",R"
1120 INPUT#1,CN$
1130 INPUT#1,DX


1132 FOR D=0 TO DX
1134  INPUT#1,DN$(D)

# MAKE ALL CHARACTERS UPPERCASE (OR 64)
1135  T=ASC(LEFT$(DN$(D),1))
1137   PRINT DN$(D) " STARTS WITH " T
1140   IF T>128 THEN BEGIN 

1150   DN$(D)=CHR$((T-96) AND (255-32))+MID$(DN$(D),2)

1160   
1170  BEND




1186  INPUT#1,IM(D)

1187  FOR L=0 TO IM(D)
1188   INPUT#1,PN$(D,L)
1189   INPUT#1,PS(D,L)
1190  NEXT




1192 NEXT
1193 CLOSE1

1199 RETURN

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


