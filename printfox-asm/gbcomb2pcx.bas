#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0,uppercase,10,10
1 REM GBCOMB2PCX PROGRAM - COMBINES TOP AND BOTTOM HALF-PAGES AND WRITES THEM TO PCX
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
24 PRINT "LOADING FSAVE-1E33.BIN...";:BLOAD"FSAVE-1E33.BIN",B0,U(DD):PRINT "DONE:"ST

30 PN$="":PR$="":FM=0:TF=0:FF=0:SB=0:SA=0:DB=0:DA=0:FE=0:EA=0:PM=31:DM=6
32 DIM IM(DM),PN$(DM,PM),PS(DM,PM),PR%(DM,PM),SO(DM,PM),SO$(DM,PM),TS(DM,PM),DN$(DM)

40 PRINT "LOADING DATAFILE...";:GOSUB 1100:PRINT "DONE"
50 PRINT "PROCESSING RANKS...";:GOSUB 1400:PRINT "DONE"

80 FOR CD=0 TO 5

82  IF CD=0 THEN GOSUB 1500

#   REVERSE SORT ORDER FOR MINI PUTT
85  FOR P = 0 TO IM(CD)

 
86   PN$=PN$(CD,SO(CD,P))
87   PN$=LEFT$(PN$(CD,P),3) 
92   PR$=MID$(STR$(PR%(CD,P)),2)
94   DN$=LEFT$(DN$(CD),4)

#99  PRINT "P="P", PN$="PN$", PR$="P$", PR%="PR%(CD,P)",PS="PS(CD,SO(CD,P))

#     STEP 1
100   FI$="S24-"+DN$+"-"+PN$+".GB1":SB=1:SA=VE+32000:DD=8:GOSUB 2000:G1=FE:SE=FE

#     STEP 2 - UNCOMPRESS
110   DB=1:DA=VE:GOSUB 1000

#     STEP 3 - CREATE PCX HEADER AND COMPRESS GB1-PCX FILE
120   SB=1:SA=VE:DB=0:DA=BE:SY=DEC("1726"):GOSUB 3000:E1=EA


122   FI$="S24-"+DN$+"-"+PR$+".GB2":SB=1:SA=VE+32000:DD=8:GOSUB 2000:G2=FE:SE=FE

#     UNCOMPRESS
124   DB=1:DA=VE:GOSUB 1000

#     COMPRESS GB2-PCX FILE
126   SB=1:SA=VE:DB=0:DA=E1:SY=DEC("1729"):GOSUB 3000:E2=EA

#     STEP 4
140   SB=0:SA=BE:DA=E2:FI$="S24-"+DN$+"-"+PN$+".PCX,P,W":DD=10:GOSUB 5000

#145  IF P/24 = 0 THEN GETKEY I$

150  NEXT
160 NEXT

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
1140  IF T>128 THEN DN$(D)=CHR$((T-96) AND (255-32))+MID$(DN$(D),2)

1145  INPUT#1,IM(D)

1150  FOR L=0 TO IM(D)
1155   INPUT#1,PN$(D,L)

1156   PN$=""
1157   FOR I=1 TO 3
1160    T=ASC(MID$(PN$(D,L),I,1))
1165    IF T>128 THEN C$=CHR$((T-96) AND (255-32)):ELSE C$=MID$(PN$(D,L),I,1)
1166    PN$=PN$+C$
1170   NEXT

1175   PN$(D,L)=PN$+MID$(PN$(D,L),4)

1189   INPUT#1,PS(D,L)
1190  NEXT

1192 NEXT
1193 CLOSE1

1199 RETURN

##################################
# FILL SORT-ORDER ARRAY WITH SCORE (IE ORDER BY SCORE)7
##################################
1400 REM ENTRYPOINT

1402 FOR CD=0 TO DX

1405 FOR L=0 TO IM(CD):SO(CD,L)=L:TS(CD,L)=PS(CD,L):NEXT

1410 DO:KG=0
1415  FOR L=0 TO IM(CD)-1
1420   IF TS(CD,L) < TS(CD,L+1) THEN BEGIN
1425    SO=SO(CD,L):SO(CD,L)=SO(CD,L+1):SO(CD,L+1)=SO:KG=-1
1430    TS=TS(CD,L):TS(CD,L)=TS(CD,L+1):TS(CD,L+1)=TS
1435   BEND
1440  NEXT
1445 LOOP WHILE KG

#    FILL RANKS ARRAY (CHECK FOR SAME POINTS BETWEEN PLAYERS)
1450 T=1:REM TEMP VAR TO HOLD CURRENT RANK
1455 PR%(CD,0)=T:T=T+1
1460 FOR L=1 TO IM(CD)

1465  IF PS(CD,SO(CD,L))=PS(CD,SO(CD,L-1)) THEN PR%(CD,L)=PR%(CD,L-1):ELSE PR%(CD,L)=T
1470  T=T+1

#    L
1475 NEXT

#    CD
1480 NEXT

1499 RETURN

###########
1500 REM "EVERSING ORT RDER:GOSUB1120"

1505 L1=0
1510 FOR L=IM(CD) TO 0 STEP -1
1515  TS(CD,L)=SO(CD,L1)
1520  L1=L1+1
1525 NEXT
1530 FOR L=0 TO IM(CD)
1535  SO(CD,L)=TS(CD,L)
1540 NEXT

1542 IF PR%(CD,0)<=0 THEN 1599

#    FILL RANKS ARRAY (CHECK FOR SAME POINTS BETWEEN PLAYERS)
1550 T=1:REM TEMP VAR TO HOLD CURRENT RANK
1555 PR%(CD,0)=T:T=T+1
1560 FOR L=1 TO IM(CD)

1565  IF PS(CD,SO(CD,L))=PS(CD,SO(CD,L-1)) THEN PR%(CD,L)=PR%(CD,L-1):ELSE PR%(CD,L)=T
1570  T=T+1

1575 NEXT

1599 RETURN



################
# LOAD GB FILE #
################
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

5010 POKE 1002,F0:REM PRINT "FILENAME LENGTH:"F0
5020 POKE 1000,F1:POKE 1001,F2:REM PRINT "FILENAME ADDRESS:"(F1+F2*256)


#    FILE START-ADDRESS
5030 POKE DEC("FB"),FNLB(SA):POKE DEC("FC"),FNHB(SA)
#    FILE END-ADDRESS
5040 POKE 998,FNLB(E2):POKE 999,FNHB(E2)

#    FILE BANK
5050 POKE 1003,SB

5055 POKE 186,DD
5060 PRINT "SAVING "SA" TO "E2" AS "FI$"...";:SYS DEC("1E33"):PRINT "DONE:"ST


5999 RETURN


