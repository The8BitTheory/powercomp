#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0 VDC,uppercase,10,10
#10 PRINT "INSERT DISK AND PRESS KEY"
#20 GETKEY I$


#30 INPUT "FILENAME";FI$
#35 PO=POINTER(FI$):BANK1:P0=PEEK(PO):P1=PEEK(PO+1):P2=PEEK(PO+2)

#40 BANK15
#50 SYS DEC("AC6"),P0,P1,P2
9 POKE 58,128:CLR:GRAPHIC0

10 DD=PEEK(186)
11 DEF FN HB(ZZ)=INT(ZZ/256)
12 DEF FN LB(ZZ)=ZZ-INT(ZZ/256)*256

#13 POKE 58,

18 VE=PEEK(57)+PEEK(58)*256


20 PRINT "LOADING FOX2VDC.BIN...";:BLOAD"FOX2VDC.BIN",B0,U(DD):PRINT "DONE"
25 PRINT "LOADING VDCBASICAC6.BIN...";:BLOAD"VDCBASICAC6.BIN",B0,U(DD):PRINT "DONE":SYSDEC("AC6")
30 BE=PEEK(4624)+PEEK(4625)*256

35 RST 3

40 RGO 28,16  :REM 64K VRAM
50 RGO 25,128 :REM BITMAP MODE ON
60 RGA 25,191 :REM NO ATTRIBUTES

61 RGO 24,64  :REM REVERSE MODE

62 RGW 36,0   :REM MINIMAL SCREEN REFRESH CYCLES


# FROM THE INTERLACE EXAMPLE IN MAPPING THE C128
65 RGW 8,3
#66 RGW 4,64
#67 RGW 6,50
66 RGW 4,132
67 RGW 6,132:RGW 9,3
68 RGW 7,58
69 RGW 0,128
70 RGW 27,80


# 0 TOTAL HORIZ CHAR POS: 128
# 4 TOTAL NR SCREEN ROWS: 64
# 6 NR VISIBLE SCREEN ROWS: 50
# 7 VERT SYNC POS: 58
# 8 INTERLACE MODE





# DOUBLE PIXELS
#62 RGW 0,63
#63 RGW 1,40
#64 RGW 2,54
#65 RGO 25,16
#66 RGW 22,8*16+9
#67 RGW 27,40
#70 POKE 238,39


# FROM VDCMODEMANIA 640X480 INTERLACE
#0,126,3,137,4,132,5,3,6,132,8,3,9,3,12,82,13,128,20,0,21,0,25,199,28,255,36,2

#61 RGW 3,137
#62 RGW 8,3
#64 RGW 4,132
#65 RGW 5,3
#66 RGW 6,132
#68 RGW 7,58
#69 RGW 9,3
#70 RGW 0,126

# SELF-CALCULATED
#61 RGW 3,137
#62 RGW 8,3
#64 RGW 4,132
#65 RGW 5,3
#66 RGW 6,132
#68 RGW 7,58
#69 RGW 9,3
#70 RGW 0,126

100 GOSUB 400
105 D=0:DC=0

145 DO
150  GETKEY I$

151 IF I$="S" THEN SLOW
152 IF I$="F" THEN FAST
153 IF I$=" " THEN PRINT "D="D",DC="DC

#UP
160  IF ASC(I$)=145 THEN D=D-640:IF D<0 THEN D=0
#DOWN
162  IF ASC(I$)=17 THEN D=D+640:IF D>NR*640-16000 THEN D=NR*640-16000
#LEFT
164  IF ASC(I$)=157 THEN DC=DC-1:IF DC<0 THEN DC=0
#RIGHT
166  IF ASC(I$)=29 THEN DC=DC+1:IF DC>NC-40 THEN DC=NC-40

167  IF I$="1" THEN DC=0:D=0
168  IF I$="2" THEN DC=NC-40:D=0
169  IF I$="3" THEN DC=0:D=16000
170  IF I$="4" THEN DC=NC-40:D=16000

171  IF I$="D" THEN CATALOG U(DD)
172  IF I$="L" THEN GOSUB 200
173  IF I$="H" THEN GOSUB 400
174  IF I$="U" THEN INPUT DU$:DD=VAL(DU$):POKE 186,DD

175  DISP D+DC

180 LOOP UNTIL I$="X"

190 END


# LOAD NEW IMAGE
200 INPUT "FILENAME";FI$


205 VMF 0,0,65535

#DC:DISPLAY COLUMN
210 D=0:DC=0
220 DISP D


#   STEP 1
230 REM FI$="24SUM-RS-01.GB1"
240 SB=1:SA=VE:GOSUB 2000

#   STEP 2
250 DB=0:DA=BE:GOSUB 1000
251 IF EC THEN EC=0:GOTO 305

260 A=DA

269 FAST
270 FOR R=0 TO NR*8-1
280  RTV A,R*160,NC
290  A=A+NC
#291  RTV A,(3+R)*80+80*204,NC
#292  A=A+NC
300 NEXT
301 SLOW
302 RGW 2,102

305 GOSUB 400

310 RETURN


400 PRINT "D: DISPLAY DIRECTORY"
405 PRINT "L: LOAD FILE"
406 PRINT "U: CHANGE DRIVE"
407 PRINT "F: FAST, S:SLOW"
408 PRINT "I: INTERLACE, N:NON-INTERLACE"
410 PRINT "CURSORS: SCROLL IMAGE"
415 PRINT "X: EXIT TO BASIC"
420 RETURN



999 END


###############################################
# UNCOMPRESS GB FILE TO CONTINUOUS BIT STREAM #
###############################################

# SOURCE BANK
1000 POKE 996,SB

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

1080 V=DA+NC*NR*8:REM PRINT "UNCOMPRESSING TO: B"DB",DA"DA" - "(DA+NC*NR*8);
1081 IF V > 65200 THEN PRINT "FILE TOO LARGE:"NR"X"NC" - "V:SLOW:EC=-1:GOTO 1099
1090 FAST:S=TI:SYS DEC("1300"):S=TI-S:SLOW
1092 REM PRINT "DONE. TOOK "S" JIFFIES"


1099 RETURN


#############################
# LOAD GB FILE TO BASIC-END #
#############################
2000 PRINT "LOADING "FI$" TO B"SB",AD"SA;
2005 DOPEN #1,U(DD),(FI$),R
2010 GET#1,A$,B$
2020 DCLOSE #1

2030 IF A$="G" THEN NC=80:NR=50
2032 IF A$="B" THEN NC=40:NR=25
2034 IF A$="P" THEN NR=ASC(B$)

# LOAD BINARY FILE. LEAVE TWO BYTES EMPTY AND MANUALLY POKE THE VALUES (BLOAD SKIPS THESE)
2040 BLOAD (FI$),B(SB),P(SA+2),U(DD)
2041 PRINT "DONE"


# FILE END (END OF COMPRESSED GB FILE
2042 FE=PEEK(174)+PEEK(175)*256
2044 REM PRINT "FILE END:"FE


2050 BANK SB
2052 POKE SA,ASC(A$):POKE SA+1,ASC(B$)
2053 IF A$="P" THEN NC=PEEK(SA+2)
2054 BANK 15

2060 REM PRINT "FORMAT "A$",COLS "NC",ROWS "NR

2070 RETURN