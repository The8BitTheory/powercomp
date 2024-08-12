#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0 VDC,uppercase,10,10
# SET 80 COL GRAPHICS, CLEAR FUNCTION KEY DEFINITIONS
10 GRAPHIC5:COLOR4,15:COLOR0,7:COLOR5,4:COLOR6,7:POKE 828,183:FAST
15 T$="BLITZ!":T=0:FOR L=1 TO LEN(T$):IF PEEK(DEC("1C25")+L)=ASC(MID$(T$,L,1)) THEN T=T+1:NEXT
16 IC=(T=6):PRINT "IS COMPILED:"IC

#20 PRINT "KEY":GETKEY I$
20 DU=PEEK(186)
22 BLOAD "VDCBASIC2D.0AC6",U(DU):SYS DEC("AC6")

24 DEF FN PN(ZZ)=ASC(LEFT$(SO$(CD,ZZ),1))

26 PI$=""
#AI$:ALPHABETICAL INPUT FOR WHICH COLUMN INDICES (ALL EXCEPT FILE DIALOG AND SCORES)
27 AI$=CHR$(0)+CHR$(2)+CHR$(3)+CHR$(5)+CHR$(6)
#NI$:NUMERICAL INPUT (ALL EXCEPT FILE DIALOG)
28 NI$=CHR$(0)+CHR$(1)+CHR$(2)+CHR$(3)+CHR$(5)+CHR$(6)
#C1$:CURSOR UP/DOWN INDICES
29 C1$=CHR$(0)+CHR$(1)+CHR$(2)+CHR$(4)
#C2$:CURSOR LEFT/RIGHT INDICES
30 C2$=CHR$(0)+CHR$(1)

#PM: PLAYER-MAXIMUM
#DM: DISCIPLINE MAXIMUM COUNT
#CD: CURRENT DISCIPLINE
#IM(): ID-MAXIMUM (NEXT AVAILABLE ID) PER DISCIPLINE
#DF: DIRTY-FLAG (CURRENT INPUT FIELD CHANGED)
#FD: FILE-DIRTY (CURRENT DATAFILE NOT SAVED)
#PN$(): PLAYER NAMES
#PS(DISCIPLINE-ID,PLAYER-ID): PLAYER SCORES
#PR%(): PLAYER RANKS
#PI:PLAYER INDEX (CURRENTLY SELECTED PLAYER)
#DX:DISCIPLINE MAX INDEX USED (EQUIVALENT TO IM)
#CN$:COMPETITION NAME
#DN$():DISCIPLINE NAMES
#SO():SORT-ORDER
#TS() AND TS:TEMPORARY SCORE ARRAY (FOR ORDERING BY SCORE)
#NM:NAVIGATION MODE(0=PLAYER NAMES,1=SCORES,2=DISCIPLINES,3=COMPETITION NAME,4=FILE DIALOG)
#SC:SHOW CURSOR
#DN$:DATAFILE NAME ON DISK
#CF$:CSV-FILENAME
#PC:PROGRESS INDICATOR CURRENT
#PW:PROGRESS INDICATOR WIDTH (SIZE OF ONE STEP)
#IC:IS-COMPILED. TRUE IF RUNNING A BLITZ COMPILED VERSION
#AT:ACTION TAKEN. TRUE IF ACTION WAS TAKEN INSIDE FILE DIALOG
#EA:END-ADDRESS OF DISK OPERATION
32 PM=18:DM=6:IM=0:DF=0:FD=0:TS=0:PI=0:CN$="":CD=0:SC=-1:DN$="":CF$="":T$="":PC=0:PW=0:AT=0:EA=0:TX=0
#CX:DIRECTORY (CATALOG) COUNTER
#CM:LAST DIRECTORY ENTRY (ARRAY HAS 144 ELEMENTS, BUT NOT ALL ARE USED PROBABLY)
#CC:CURRENT CATALOG (DIRECTORY) INDEX
#A$,B$,L$,H$: USED FOR LISTING DIRECTORY
#PU:INDEX VARIABLE FOR "PRINT USING"
#CI:COLUMN INDEX
#SP:SAVE PENDING (USED WHEN SAVING WITHOUT SET DATAFILE NAME)
#DT$:DRIVE TYPE STRING
#DT:DRIVE TYPE ID (USED FOR DETERMINING ZEROPAGE ADDRESS OF DISK-CHANGE INDICATOR)
#DC:DISK CHANGE INDICATOR
#NN$():USED TO STORE "DER SPIELER", PLAYERNAME PLUS ACCORDING FORMATLINES
#TL$():CONTAINS TEMPLATE FOR PRINTFOX GENERATION
#AC:PREVIOUS ACTION (FOR LOADING DIALOG. LOADING SCORES OR FT-TEMPLATE?)
33 CX=0:CM=0:A$="":B$="":L$="":H$="":EP$=CHR$(0):CC=0:PU=0:CI=0:SP=-1:DT$="":DT=-1:DC=-1
35 TR%=0:SL$="":TC$="":TD$=""

100 DIM PN$(DM,PM),PS(DM,PM),PR%(DM,PM),SO(DM,PM),SO$(DM,PM),TS(DM,PM),DN$(DM),IM(DM),CP(6),CL(6),RC(PM)
105 DIM CE$(143),PU$(2),NN$(PM),TL$(6)

#CP:CURSOR POSITION
# 0:PLAYER NAME
# 1:PLAYER SCORE
# 2:DISCIPLINE LIST
# 3:COMPETITION NAME INPUT
# 4:FILE DIALOG - FILE LIST
# 5:DATAFILE NAME
# 6:RENAME FILE

110 CP(0)=6:CP(1)=24:CP(2)=44:CP(3)=15:CP(4)=21:CP(5)=63:CP(6)=22
#CL:COLUMN-LENGTH
115 CL(0)=16:CL(1)=8:CL(2)=23:CL(3)=40:CL(4)=18:CL(5)=13:CL(6)=16


# PRINT SCREEN
120 GOSUB 900
# SAVE SCREEN TO OFF-SCREEN
125 GOSUB 1600
# SET SORT ORDER TO ID
130 GOSUB 1200
# FILL ID COLUMN
135 GOSUB 980
# WRITE DISCIPLINES
140 GOSUB 1800

# PLACE THE CURSOR. INITIALLY GO TO COMPETITION NAME INPUT
145 CI=3:P=1:GOSUB 705

# SHOW CURSOR BAR
150 GOSUB 705:GOSUB 780

# FILL COLOR ARRAY
155 RC(0)=8:RC(1)=13:RC(2)=9
160 FOR L=3TOPM
165  RC(L)=15
170 NEXT

# PU$() CONTAINS FORMATS FOR VIC-II PREVIEW
175 PU$(0)="   ## ##################  ###,###"
180 PU$(1)="   ## ##################  ###,###.#"
185 PU$(2)="   ## ##################  ###,###.##"

190 SP$="                                      "



210 S1$="ER PIELER"
212 S2$="IE PIELERIN"




# 703 REMOVE BAR AND STORE T$ TO ARRAY
#1700 OFF-SCREEN TO ON-SCREEN
#1200 FILL SORT-ORDER ARRAY WITH IDS
# 980 WRITE IDS TO SCREEN
# 800 WRITE ALL VALUES TO FIELDS
#1800 WRITE DISCIPLINES
# 705 SHOW BAR AND READ T$ FROM ARRAY



280 DO
290 GETKEY I$

# NUMERIC
292 IF ASC(I$)>47 THEN IF ASC(I$)<58 THEN IF INSTR(NI$,CHR$(CI))>0 THEN GOSUB 540:GOTO 410
# ALPHABETICAL LOWER CASE
294 IF ASC(I$)>64 THEN IF ASC(I$)<91 THEN IF INSTR(AI$,CHR$(CI))>0 THEN GOSUB 540:GOTO 410
# ALPHABETICAL UPPER CASE
296 IF ASC(I$)>192 THEN IF ASC(I$)<219 THEN IF INSTR(AI$,CHR$(CI))>0 THEN GOSUB 540:GOTO 410


# DELETE CHAR
297 IF ASC(I$)=20 THEN BEGIN
298  IF INSTR(NI$,CHR$(CI))>0 THEN GOSUB 590:GOTO 300
299  IF INSTR(AI$,CHR$(CI))>0 THEN GOSUB 590
300 BEND



301 IF I$=" " THEN GOSUB 540:GOTO 410
302 IF I$="-" THEN GOSUB 540:GOTO 410
303 IF I$="." THEN GOSUB 520:GOTO 410



# CHECK ALL FOR FILE-LOADING DIALOG (WHERE CI=4)
304 IF CI=4 THEN BEGIN

#    SELECT FILENAME FROM FILE LIST
306  IF I$=CHR$(13) THEN BEGIN

#     1120=DISPLAY PROGRESS DIALOG,1150=EXTRACT FILENAME
307   T$="OADING FROM ISK":GOSUB1120:GOSUB1150

308   CI=0:PI=0:P=PI+4:SC=-1


#     LOAD SCORE FILE. , 1160=SET RETURN PARAMS AND COMMENCE LOADING
309   IF AC=0 THEN GOSUB1160:AT=-1

#     LOAD TEMPLATE FILE
310   IF AC=1 THEN GOSUB30000:AT=-1

319  BEND



#    CLOSE FILELIST DIALOG WITHOUT LOADING FILE
322  IF I$="" THEN BEGIN
323   IF LEN(CN$)=0 THEN CI=3:P=1:ELSE CI=0:P=PI+4
324   AT=-1
325  BEND

#    R TO RENAME FILE
326  IF I$="R" THEN BEGIN
327   GOSUB703:CI=6:SC=-1:GOSUB 705
328  BEND

329 BEND:IF AT THEN AT=0:SC=-1:PRINTCHR$(19)CHR$(19);:GOTO 399



# RETURN KEY
#   SAVE DISCIPLINE NAME
330 IF I$=CHR$(13) THEN IF CI=2 THEN GOSUB703:CI=0:PI=0:P=PI+4:GOSUB1200:GOTO 399

#   SAVE COMPETITION NAME
331 IF I$=CHR$(13) THEN IF CI=3 THEN IF LEN(T$)>0 THEN GOSUB703:CI=0:PI=0:P=PI+4:GOSUB705:GOTO 410

#   SAVE DATAFILE NAME
332 IF I$=CHR$(13) THEN IF CI=5 THEN GOSUB703:T$="AVING TO ISK":GOSUB1120:GOSUB 1000:DC=-1:CI=0:PI=0:P=PI+4:GOTO399

# CONFIRM RENAMING FILE
333 IF I$=CHR$(13) THEN IF CI=6 THEN GOSUB 2500:GOTO 410

#399 GOSUB 1700:GOSUB 980:GOSUB 800:GOSUB 1800:GOSUB705:GOTO 410
# COMMODORE + NUMBER KEYS
# COMMODORE +1
334 IF I$=CHR$(129) THEN GOSUB703:CD=0:PI=0:P=PI+4:GOSUB1200:GOTO 399
# COMMODORE + 2-6
335 IF ASC(I$)>148 THEN IF ASC(I$)<155 THEN GOSUB703:CD=ASC(I$)-148:PI=0:P=PI+4:GOSUB1200:GOTO 399



# DOWN
336 IF I$=CHR$(17) THEN IF INSTR(C1$,CHR$(CI))>0 THEN GOSUB 420:GOTO 410
# UP
337 IF I$=CHR$(145) THEN IF INSTR(C1$,CHR$(CI))>0 THEN GOSUB 470:GOTO 410
# RIGHT
338 IF I$=CHR$(29) THEN IF INSTR(C2$,CHR$(CI))>0 THEN GOSUB 630:GOTO 410
# LEFT
339 IF I$=CHR$(157) THEN IF INSTR(C2$,CHR$(CI))>0 THEN GOSUB 670:GOTO 410

# F2:COMPETITION NAME
340 IF ASC(I$)=137 THEN GOSUB 703:CI=3:P=1:GOSUB 705:GOTO 410

# F4:DISCIPLINES
341 IF ASC(I$)=138 THEN GOSUB 703:P=CD+4:CI=2:GOSUB 705:GOTO 410

# F8:DELETE ENTRY
342 IF ASC(I$)=140 THEN GOSUB 2000:GOTO 399



# ARROW-LEFT FOR CANCELLING STATES
# 382 IF ASC(I$)=95 THEN

# COMMODORE+E FOR CSV-EXPORT OF CURRENT DISCIPLINE
343 IF I$=CHR$(177) THEN T$="XPORTING TO ":GOSUB1120:GOSUB 2200:GOTO 399

# COMMODORE+G FOR PRINTFOX-GENERATOR
344 IF I$=CHR$(165) THEN AC=1:GOSUB1100:GOTO410

# COMMODORE+S FOR SAVE
345 IF ASC(I$)=174 THEN BEGIN
346  IF LEN(DN$)=0 THEN GOSUB2100:GOTO399:ELSE T$="AVING TO ISK":GOSUB1120:GOSUB 1000:GOTO 399
347 BEND

# COMMODORE+A FOR SAVE AS...
387 IF ASC(I$)=176 THEN GOSUB 2100:GOTO 399

# COMMODORE+L FOR LOAD
392 IF ASC(I$)=182 THEN AC=0:CI=4:P=7:GOSUB 1100:GOTO 410

# CBM+P - PREVIEW
393 IF I$=CHR$(175) THEN T$="HOWING SCOREBOARD ON 40 COL DISPLAY":GOSUB1120:GOSUB 1900:GOTO 399


# ORDER BY ID
394 IF ASC(I$)=133 THEN T$="ORTING BY ":GOSUB1120:GOSUB 1200:PRINT CHR$(19)CHR$(19);:GOTO 399

# ORDER BY PLAYER NAME
# 1300:SORT ALPHABETICALLY
# 1700 CLEAR SCREEN AND RESTORE GRID
# 980 WRITE IDS TO SCREEN
# 800 FILL NAMES AND SCORES
395 IF ASC(I$)=134 THEN T$="ORTING BY AME":GOSUB1120:GOSUB 1300:PRINT CHR$(19)CHR$(19);:GOTO 399

# ORDER BY PLAYER SCORE
396 IF ASC(I$)=135 THEN T$="ORTING BY CORE":GOSUB1120:GOSUB 1400:PRINT CHR$(19)CHR$(19);:GOTO 399

# REVERSE ORDER OF CURRENT LIST
397 IF ASC(I$)=136 THEN T$="EVERSING ORT RDER":GOSUB1120:GOSUB 1500:PRINT CHR$(19)CHR$(19);:GOTO 399

398 GOTO 410



# FINAL STEP FOR ORDERING
399 GOSUB 1700:GOSUB 980:GOSUB 800:GOSUB 1800:GOSUB705
## PUT NOTHING IN BETWEEN THESE TWO LINES (399 AND 410)
410 LOOP



# DOWN (PLAYER NAME AND SCORE LIST)
420 IF CI=2 THEN 430
421 IF CI=4 THEN 440
422 IF CI>2 THEN 426

423 GOSUB 703
424 PI=PI+1:IF PI>PM THEN PI=0
425 P=PI+4
426 GOSUB 705
427 RETURN

# DOWN (DISCIPLINE LIST)
430 GOSUB 703
431 CD=CD+1:IF CD>DM THEN CD=0
432 P=CD+4
433 GOSUB 705
434 RETURN

# DOWN (FILE LIST)
440 GOSUB 703
441 CC=CC+1:IF CC>CM-2 THEN CC=CM-2
442 P=CC+7
443 GOSUB 705
444 RETURN



# UP
470 IF CI=2 THEN 480
471 IF CI=4 THEN 490
472 IF CI>2 THEN 477

473 GOSUB 703
474 PI=PI-1:IF PI<0 THEN PI=PM
475 P=PI+4
476 GOSUB 705
477 RETURN

# UP (DISCIPLINE LIST)
480 GOSUB 703
481 CD=CD-1:IF CD<0 THEN CD=DM
482 P=CD+4
483 GOSUB 705
484 RETURN

# UP (FILE LIST)
490 GOSUB 703
491 CC=CC-1:IF CC<0 THEN CC=0
492 P=CC+7
493 GOSUB 705
499 RETURN

# FOR SCORE, ONLY ONE FRACTION POINT ALLOWED
520 IF CI<>1 THEN 540
530 IF INSTR(T$,".")>0 THEN PRINT CHR$(7);:GOTO 580

# ALPHANUMERIC
540 IF CI<2 THEN IF LEN(T$)=16 THEN PRINT CHR$(7);:GOTO 580
545 IF CI>=2 THEN IF LEN(T$)=CL(CI) THEN PRINT CHR$(7);:GOTO 580

550 IF CI=1 THEN IF LEFT$(T$,2)=" 0" THEN T$=" "+MID$(T$,3)
560 T$=T$+I$:DF=-1:IF NOT FD THEN GOSUB 2400
570 CHAR 1,CP(CI),P,T$
575 GOSUB 780
580 RETURN

# DELETE
590 IF LEN(T$)=0 THEN PRINT CHR$(7);:GOTO 620
600 T$=LEFT$(T$,LEN(T$)-1):DF=-1:IF NOT FD THEN GOSUB 2400
610 CHAR 1,CP(CI),P,T$+" "
615 GOSUB 780
620 RETURN

# RIGHT (FROM PLAYER TO SCORE COLUMN)
630 IF CI<>0 THEN 660
640 GOSUB 703:CI=1
650 VMF 2048+CP(CI)+P*80,207+128,8:GOSUB 770

660 RETURN

# LEFT (FROM SCORE TO PLAYER COLUMN)
670 IF CI<>1 THEN 700
680 GOSUB 703:CI=0
690 GOSUB 705

700 RETURN

# REMOVE CURSOR BAR
703 VMF 2048+CP(CI)+P*80,143,CL(CI):GOSUB 710:GOSUB790:RETURN

# DRAW CURSOR BAR
705 VMF 2048+CP(CI)+P*80,207,CL(CI):GOSUB 770:GOSUB780:RETURN



# STORE TO ARRAY
710 IF NOT DF THEN 760
720 DF=0
730 IF CI=0 THEN PN$(CD,SO(CD,PI))=T$:GOTO759
750 IF CI=1 THEN PS(CD,SO(CD,PI))=VAL(T$):GOTO759
753 IF CI=2 THEN DN$(CD)=T$:IFDX<CD+1 THEN DX=CD+1:GOTO 760
754 IF CI=3 THEN CN$=T$:GOTO 760
755 IF CI=4 THEN 760
756 IF CI=5 THEN DN$=T$:GOTO 760
757 IF CI=6 THEN TT$=T$:GOTO 760
759 IF IM(CD)<PI THEN IM(CD)=PI
760 RETURN

# READ VALUE INTO T$
770 IF CI=0 THEN T$=PN$(CD,SO(CD,PI))
772 IF CI=1 THEN T$=STR$(PS(CD,SO(CD,PI)))
774 IF CI=2 THEN T$=DN$(CD)
775 IF CI=3 THEN T$=CN$
776 IF CI=4 THEN 779
777 IF CI=5 THEN T$=DN$
778 IF CI=6 THEN GOSUB1150:T$=DN$
779 RETURN

# PLACE CURSOR
780 IF NOT SC THEN 789
781 CU=CP(CI)+P*80+LEN(T$)
782 VMO 2048+CU,16
784 VMW CU,160
789 RETURN

# REMOVE CURSOR
790 IF NOT SC THEN 799
791 VMA 2048+CU,239
792 VMW CU,32
799 RETURN

# WRITE NAMES AND SCORES TO FIELDS, AND COMP NAME AND FILENAME
800 FOR L=0 TO IM(CD)
810  CHAR1,CP(0),4+L,PN$(CD,SO(CD,L))
820  CHAR1,CP(1),4+L,STR$(PS(CD,SO(CD,L)))
825  CHAR1,35,4+L,STR$(PR%(CD,L))
830 NEXT

840 CHAR1,CP(3),1,CN$
850 CHAR1,CP(5),1,DN$
860 IF FD THEN CHAR1,77,1,"*"

890 RETURN

# CREATE SCREEN
900 PRINT CHR$(142)"";
905 PRINT "";
910 PRINT "                                                                             ";
915 PRINT "";
920 FOR L=1TO20
925 PRINT "                                                                             ";
930 NEXT
935 PRINT ""CHR$(14)"BY OODWELL"CHR$(142)"";
936 CHAR 1,41,11,"////POWER COMPETITION MANAGER V1.3////"
937 CHAR 1,2,1,CHR$(14)+"OMPETITION"+CHR$(142)+":"
938 CHAR 1,58,1,CHR$(14)+"ILE"+CHR$(142)+":"
939 CHAR 1,2,3,CHR$(2)+CHR$(14)+""
940 CHAR 1,6,3,"LAYER"
941 CHAR 1,24,3,"CORE"
942 CHAR 1,34,3,"ANK"

943 CHAR 1,42,3,"ISCIPLINES"


944 PRINT CHR$(130);


950 WINDOW 42,12,78,22,1
952 PRINT "1: RDER BY  (SC.)"
954 PRINT "3: RDER BY LAYER AME (SC.)"
956 PRINT "5: RDER BY CORE (ESC.)"
958 PRINT "7: EVERSE RDER"
960 PRINT "2: DIT OMPETITION AME"
962 PRINT "4: DIT ISCIPLINES"
964 PRINT "8: ELETE LAYER NTRY"
966 PRINT "=+: AVE TO ISK,  =+: AVE AS..."
968 PRINT "=+: OAD FROM ISK,=+: XPORT "
970 PRINT "=+1-7: UMP TO ISCIPLINE"
972 PRINT "=+: REVIEW ON 40 OL ISPLAY"CHR$(19)CHR$(19);


979 RETURN

# WRITE IDS TO SCREEN
980 FOR L=0 TO IM(CD)
# VL:VALUE
981  VL=SO(CD,L)
982  IF VL>9 THEN L$=MID$(STR$(VL),2):GOTO 985
983  L$=" "+MID$(STR$(VL),2)
985  CHAR 1,2,4+L,L$
986 NEXT
989 RETURN


# SAVE TO SEQ FILE
# IF NO FILENAME IS SET, GO TO "SAVE AS" ROUTINE
1000 OPEN1,DU,3,"@0:"+DN$+",W"

# FAILSAFE
1002 IF LEN(CN$)=0 THEN CN$="UNNAMED COMPETITION"

# COMPETITION NAME
1006 PRINT#1,CN$

# NR OF DISCIPLINES
1009 PRINT#1,STR$(DX)

1010 PC=0:PW=38/(DX+1)

1012 FOR D=0 TO DX

# BEGIN DISCIPLINE BLOCK
# NAME OF DISCIPLINE
1015  PRINT#1,DN$(D)

# NUMBER OF NAME-SCORE ENTRIES
1018  PRINT#1,IM(D)

1021  FOR L=0 TO IM(D)
1024   PRINT#1,PN$(D,L)
1027   PRINT#1,PS(D,L)
1030  NEXT

1032  PC=D*PW:GOSUB 1130

1033 NEXT

1036 CLOSE1
1039 PRINT CHR$(19)CHR$(19);

# CLEAR "DIRTY" ASTERISK (FILE CHANGE INDICATOR)
1042 GOSUB 2410

1099 RETURN




# DISPLAY FILE SELECTION DIALOG
1100 IF DT THEN GOSUB 9800
1101 GOSUB703:CI=4:SC=0:CC=0:P=CC+7:WINDOW 10,2,70,22,1
1102 PRINTCHR$(27)"M"CHR$(142)"";
1103 PRINT" "CHR$(14)"                          OAD ILE                       "CHR$(142)"";

1105 FOR L=4 TO 21:PRINT"";:NEXT

1106 CHAR 1,0,1

1107 FOR L=3 TO 20:PRINT"";:NEXT

1108 PRINT"  "CHR$(14)": ANCEL       ETURN: OAD ILE       : ENAME ILE   "CHR$(142)"";
1109 PRINT""CHR$(14)CHR$(27)"L";


1113 IF DC=-1 THEN DC=0:GOSUB 10000:GOTO 1119

1114 GOSUB 9900:REM CHECK DISK CHANGE FLAG
1115 IF DC=1 THEN GOSUB 10000:ELSE GOSUB 9700

1119 RETURN


# DISPLAY PROGRESS INDICATOR DIALOG
1120 GOSUB 703:WINDOW 20,8,60,12,1
1122 PRINTCHR$(27)"M"CHR$(142)"";
1123 PRINT"";
1124 CHAR 1,0,1
1125 PRINT"";
1126 PRINT""CHR$(14)CHR$(27)"L";

1127 T=(40-LEN(T$))/2
1128 CHAR1,1,1,LEFT$(SP$,T-1)+T$+LEFT$(SP$,T-1)

1129 RETURN



# UPDATE PROGRESS INDICATOR
1130 T$=LEFT$(PI$,PC)
1132 T$=T$+LEFT$(SP$,38-PC)

1134 CHAR 1,2,2,CHR$(142)+T$+CHR$(14)

1149 RETURN



# EXTRACT FILENAME FROM DIRECTORY LINE
1150 T$=CE$(CC+1)

1154 P1=INSTR(T$,CHR$(34))+1
1155 P2=INSTR(T$,CHR$(34),P1)-P1
1156 DN$=MID$(T$,P1,P2)
1159 RETURN

# SET CURSOR VALUES FOR AFTER CLOSING DIALOG
1160 REM "CI=0:PI=0:P=PI+4:SC=-1"



# LOAD SELECTED HIGHSCORE-FILE FROM DISK
1180 OPEN1,DU,3,DN$+",R"
1181 INPUT#1,CN$
1182 INPUT#1,DX
1183 PW=38/(DX+1):PC=0:GOSUB1130

1184 FOR D=0 TO DX
1185  INPUT#1,DN$(D)
1186  INPUT#1,IM(D)

1187  FOR L=0 TO IM(D)
1188   INPUT#1,PN$(D,L)
1189   INPUT#1,PS(D,L)
1190  NEXT
1191  PC=(D+1)*PW:GOSUB 1130

1192 NEXT
1193 CLOSE1

1194 PRINT "";

# CLEAR DATAFILE DIRTY FLAG
1195 GOSUB 2410

#399 GOSUB 1700:GOSUB 980:GOSUB 800:GOSUB 1800:GOSUB705:GOTO 410
#GOTO 399 DOESN'T WORK HERE BECAUSE OF RETURN INSTEAD OF GOTO410
#1198 GOSUB1700:GOSUB 980:GOSUB 800:GOSUB 1800:GOSUB 1200:GOSUB 705
1198 GOSUB 1200


1199 RETURN


# FILL SORT-ORDER ARRAY WITH IDS
1200 FOR L=0 TO PM
1202  SO(CD,L)=L
1208 NEXT

1210 FOR L=0 TO IM(CD)
1212  PR%(CD,L)=0
1214 NEXT

1219 RETURN





# FILL SORT-ORDER ARRAY ALPHABETICAL (IE ORDER BY NAME)
# USES SO$() AND SO$ AS TEMPORARY VARIABLES FOR ORDERING
# SO() AND SO ARE USED PERMANENTLY IN THE REST OF THE PROGRAM
# KG:KEEP GOING
1300 FOR L=0 TO IM(CD):SO(CD,L)=L:SO$(CD,L)=PN$(CD,L):NEXT
1302 DO:KG=0
1303  FOR L=0 TO IM(CD)-1
1304   IF FNPN(L) > FNPN(L+1) THEN BEGIN
1305    SO=SO(CD,L):SO(CD,L)=SO(CD,L+1):SO(CD,L+1)=SO:KG=-1
1306    SO$=SO$(CD,L):SO$(CD,L)=SO$(CD,L+1):SO$(CD,L+1)=SO$
1307   BEND
1308  NEXT
1309 LOOP WHILE KG

1310 FOR L=0 TO IM(CD)
1312  PR%(CD,L)=0
1314 NEXT

1399 RETURN

# FILL SORT-ORDER ARRAY WITH SCORE (IE ORDER BY SCORE)
1400 FOR L=0 TO IM(CD):SO(CD,L)=L:TS(CD,L)=PS(CD,L):NEXT
1401 DO:KG=0
1402  FOR L=0 TO IM(CD)-1
1403   IF TS(CD,L) < TS(CD,L+1) THEN BEGIN
1404    SO=SO(CD,L):SO(CD,L)=SO(CD,L+1):SO(CD,L+1)=SO:KG=-1
1405    TS=TS(CD,L):TS(CD,L)=TS(CD,L+1):TS(CD,L+1)=TS
1406   BEND
1407  NEXT
1408 LOOP WHILE KG

#    FILL RANKS ARRAY (CHECK FOR SAME POINTS BETWEEN PLAYERS)
1410 T=1:REM TEMP VAR TO HOLD CURRENT RANK
1411 PR%(CD,0)=T:T=T+1
1412 FOR L=1 TO IM(CD)

1416  IF PS(CD,SO(CD,L))=PS(CD,SO(CD,L-1)) THEN PR%(CD,L)=PR%(CD,L-1):ELSE PR%(CD,L)=T
1417  T=T+1

1418 NEXT

1499 RETURN

# REVERSE SORT-ORDER ARRAY (TOGGLE ASC/DESC)
1500 L1=0
1510 FOR L=IM(CD) TO 0 STEP -1
1515  TS(CD,L)=SO(CD,L1)
1520  L1=L1+1
1525 NEXT
1530 FOR L=0 TO IM(CD)
1535  SO(CD,L)=TS(CD,L)
1540 NEXT


1542 IF PR%(CD,0)>0 THEN 1410


1599 RETURN

# COPY SCREEN TO OFF-SCREEN
1600 VMC 0,4096,2048
1605 VMC 2048,6144,2048
1610 RETURN

# COPY OFF-SCREEN TO SCREEN
1700 PRINT "";
1702 VMC 6144,2048,2048
1705 VMC 4096,0,2048
1710 RETURN

# WRITE LIST OF DISCIPLINES
1800 WINDOW 42,4,78,10,1
1805 FOR L=0 TO DX
1810  PRINT MID$(STR$(L+1),2)" "DN$(L)
1815 NEXT
1830 PRINT "";

1840 VMF 2048+CP(2)+(4+CD)*80,207,CL(2)

1899 RETURN

# SHOW SCOREBOARD ON VIC SCREEN
1900 CHAR 1,2,2,"RESS  TO CHANGE NR OF ECIMALS"
1902 CHAR 1,2,3,"NY OTHER KEY CLOSES COREBOARD"

1905 GRAPHIC0:COLOR5,15:PRINT""CHR$(14):SLOW
1910 PRINT USING "   =##################################";DN$(CD)
1915 PRINT:PRINT:IX=1
1920 FOR L=0 TO IM(CD)
1921  TS$=PN$(CD,SO(CD,L))
1922  IF LEN(TS$)<3 THEN 1929
1923  TS=PS(CD,SO(CD,L))
1924  COLOR 5,RC(PR%(CD,IX-1)-1)
1925  PRINT USING PU$(PU);PR%(CD,IX-1),TS$,TS
1926  IX=IX+1
1929 NEXT


1990 GETKEY I$
1992 IF I$="D" THEN BEGIN
1994  PU=PU+1:IF PU>2 THEN PU=0
1996 BEND:GOTO 1905

1998 FAST:PRINT"":GRAPHIC5:PRINT "";:COLOR 5,5
1999 RETURN



# DELETE PLAYER NAME-SCORE ENTRY
2000 IX=SO(CD,PI)
2005 FOR L=IX TO IM(CD)-1
2010  PN$(CD,SO(CD,L))=PN$(CD,SO(CD,L+1))
2011  PS(CD,SO(CD,L))=PS(CD,SO(CD,L+1))
2015 NEXT
2016 PN$(CD,SO(CD,IM(CD)))=""
2017 PS(CD,SO(CD,IM(CD)))=0
2020 IM(CD)=IM(CD)-1
2022 GOSUB 2400
2099 RETURN



# SAVE AS
2100 GOSUB 703
2102 P=1:CI=5:GOSUB 705

2199 RETURN

# EXPORT TO CSV

2200 CF$=LEFT$(DN$(CD),12)+".CSV"

2204 OPEN1,DU,3,"@0:"+CF$+",P,W"

2206 IX=1:PW=38/IM(CD)
2208 FOR L=0 TO IM(CD)
2210  TS$=PN$(CD,SO(CD,L))
2212  IF LEN(TS$)<3 THEN 2222
2214  TS=PS(CD,SO(CD,L))
2218  T$=MID$(STR$(IX),2)+";"+TS$+";"+MID$(STR$(TS),2)
2219  GOSUB 2300:PRINT#1,T2$CHR$(13)CHR$(10);
2220  IX=IX+1
2221  PC=L*PW:GOSUB1130
2222 NEXT

2224 CLOSE 1
2225 PRINT "";

2299 RETURN


# CONVERT FROM PETSCII TO ASCII
2300 T2$=""
2305 FOR X=1 TO LEN(T$)
2310  C$=MID$(T$,X,1):A=ASC(C$)
2320  IF A>=193 AND A<=218 THEN A=A-128:T2$=T2$+CHR$(A):GOTO 2340
2325  IF A>=65 AND A<=90 THEN A=A+32:T2$=T2$+CHR$(A):GOTO 2340
2330  T2$=T2$+C$
2340 NEXT

2399 RETURN


# SET DATAFILE DIRTY FLAG
2400 FD=-1:CHAR1,77,1,"*":RETURN

# CLEAR DATAFILE DIRTY FLAG
2410 FD=0:CHAR1,77,1," ":RETURN


# RENAME FILE
#    KEEP INPUT OF NEW NAME (T$ IS USED ELSEWHERE)
2500 TT$=T$
#    EXTRACT FILENAME FROM SELECTED CATALOG LINE (INTO DN$)
2501 GOSUB 1150
2502 CF$="R:"+TT$+"="+DN$

2505 OPEN1,DU,15,CF$:CLOSE1

# ASSEMBLE NEW CATALOG LINE (BLOCKS, NAME, TYPE)
2507 T$=LEFT$(CE$(CC+1),6)+TT$+CHR$(34)

2510 CE$(CC+1)=T$+LEFT$(SP$,24-LEN(T$))+MID$(CE$(CC+1),25)

2512 GOSUB 703
2519 GOTO 1100


# LIST DISK CATALOG FROM MEMORY
9700 FOR CX=1 TO CM
9702  CHAR 1,6,4+CX,CE$(CX)
9704 NEXT
9706 GOSUB 705

9708 PRINTCHR$(14)"";
9709 PRINT CHR$(19)CHR$(19);


9799 RETURN


# GET DRIVE TYPE (1541, 1571, 1581, SD2IEC, ETC)
# TAKEN FROM HTTPS://WWW.LEMON64.COM/FORUM/VIEWTOPIC.PHP?T=46509
9800 A=65331:DT$="UNKNOWN":DT=-1
9810 HI=INT(A/256)
9820 LO=A-256*HI
9830 OPEN1,DU,15

9840 PRINT#1,"M-R";CHR$(LO);CHR$(HI)
9850 GET#1,A$
9860 T=ASC(A$)
9870 IF T=108 THEN DT$="1581":DT=1
9872 IF T=173 THEN DT$="1571":DT=0
9874 IF T=170 THEN DT$="1541":DT=0
9876 IF T=76 THEN DT$="1541-II":DT=0

#9910 PRINT"DRIVE TYPE:";DT$;

9880 CLOSE1

9899 RETURN


# CHECK FOR DISK-CHANGE FLAG
9900 OPEN1,DU,15

9905 IF DT=0 THEN DC=DEC("1C"):ELSE IF DT=1 THEN DC=DEC("25")

9910 PRINT#1,"M-R";CHR$(DC);CHR$(0)
9920 GET#1,A$

9930 DC=ASC(A$)
9980 CLOSE1

9990 RETURN


# DISK DIRECTORY LISTING ROUTINE
#CV:CURSOR-VISIBLE
10000 OPEN 1,DU,0,"$":CX=0:CV=0

10002 GET#1,A$,A$

10004 GET#1,A$,A$,H$,L$:IF ST THEN 10026

# BEGIN OF LINE
10006 CE$(CX)=MID$(STR$(ASC(H$+EP$)+256*ASC(L$+EP$))+" ",2)

# NEXT TWO BYTES FROM CONTENT
10008 DO:GET#1,A$,B$
10010 IF B$ THEN CE$(CX)=CE$(CX)+A$+B$:LOOP WHILE ST=0

# END OF LINE
10012 CE$(CX)=CE$(CX)+A$

10014 IF CX=0 THEN 10024

10016 CHAR 1,6,4+CX,CE$(CX)
10018 IF NOT CV THEN GOSUB 705:CV=-1

10020 GET I$:IF LEN(I$)=0 THEN 10024
10021 IF I$=CHR$(17) THEN GOSUB 10260:GOTO 10024
10022 IF I$=CHR$(145) THEN GOSUB 10320:GOTO 10024

# ENTER
#10023 IF I$=CHR$(13) THEN GOSUB 10026:T$="OADING FROM ISK":GOSUB1120:GOSUB1150:GOSUB1160:AT=-1:GOTO 10026

10024 CX=CX+1:IF CX<145 THEN GOTO 10004
10026 CLOSE 1:CM=CX-1

10027 PRINTCHR$(14)"";
10028 PRINT CHR$(19)CHR$(19);
10029 RETURN

# DO-LOOP GET#: 164
# GOTO GET#:    310


# DOWN (EQUIVALENT TO 440)
#10250 IF I$=CHR$(17) THEN BEGIN
10260  VMF 2048+CP(CI)+P*80,143,CL(CI)
10270  CC=CC+1:IF CC>CX-2 THEN CC=CX-2
10280  P=CC+7
10290  VMF 2048+CP(CI)+P*80,207,CL(CI)
10300 RETURN

# UP (EQUIVALENT TO 490)
#10310 IF I$=CHR$(145) THEN BEGIN
10320  VMF 2048+CP(CI)+P*80,143,CL(CI):
10330  CC=CC-1:IF CC<0 THEN CC=0
10340  P=CC+7
10350  VMF 2048+CP(CI)+P*80,207,CL(CI)
10360 RETURN



######################
# PRINTFOX GENERATOR #
######################

# READ TEMPLATE FILE FOR CERTIFICATE

# SELECT FILENAME
30000 GOSUB 1120

# READ FIRST TWO BYTES, CHECK FILETYPE, POKE THEM TO MEM
30005 OPEN 1,DU,0,DN$
30010  GET#1,A$,B$
30015  IF A$<>CHR$(84) THEN STOP
30020 CLOSE1

30025 BANK0:POKE DEC("1300"),ASC(A$):POKE DEC("1301"),ASC(B$):BANK15

# LOAD THE REST OF THE FILE VIA BLOAD (FIRST TWO BYTES ARE ALREADY POKED)
30030 BLOAD "TPLURKUNDE.FT",U(DU),P(DEC("1302")),B0

# ENDADDRESS OF BLOAD
30031 EA=PEEK(174)+PEEK(175)*256
#30032 SLOW:GRAPHIC0:S=EA-DEC("1300"):PRINT "SIZE:"S:GETKEYI$:FAST:GRAPHIC5

# NOT REALLY REQUIRED, AS WE'RE BELOW ADDR 16384
30035 BANK 0
# TX:INDEX OF TEMPL STRINGS
30036 TX=0:TL$(TX)="":PW=38/6

# EXTRACT TEMPLATE STRINGS

#  FIRST TEMPLATE STRING
#  NAME OF THE CHALLENGE

#  SECOND TEMPLATE STRING
#  DATE OF THE CHALLENGE

#  THIRD TEMPLATE STRING
#  DER SPIELER/DIE SPIELERIN

#  FOURTH TEMPLATE STRING
#  PLAYERNAME

#  FIFTH TEMPLATE STRING
#  DISCIPLINE NAME

#  SIXTH TEMPLATE STRING
#  RANK

#  SEVENTH TEMPLATE STRING
#  LIST OF ALL CONTESTANTS WITH SCORE

#  END WITH TWO ZERO BYTES

# END AT EA-3 BECAUSE THESE ARE JUST ZEROES
30040 FOR L=DEC("1300") TO EA-3
30045  TV=PEEK(L)

#      CHECK FOR 35/$23. IF NOT, APPEND CHARACTER TO TEMPLATE STRING
30050  IF TV=35 THEN TX=TX+1:TL$(TX)="":PC=PW*TX:GOSUB 1130:GOTO 30060

30055  TL$(TX)=TL$(TX)+CHR$(TV)

30060 NEXT

#30070 CHAR 1,10,3:PRINT USING "=####################################","TEMPLATE DONE. NOW SCORELIST"


# GENERATE LIST OF SCORES ONCE. IS SAME FOR ALL
30105 T$="ENERATE CORELIST":GOSUB 1127

30106 IX=1:SL$="":PW=38/IM(CD)
30107 PC=0:GOSUB 1130
30108 FOR L=0 TO IM(CD)
30110  TS$=PN$(CD,SO(CD,L))
30112  IF LEN(TS$)<3 THEN 30122
30114  TS=PS(CD,SO(CD,L))

30118  T$=MID$(STR$(IX),2)+ CHR$(7) +TS$+ CHR$(7) +MID$(STR$(TS),2)

30119  GOSUB 2300:SL$=SL$+T2$+CHR$(13)

30120  IX=IX+1
30121  PC=L*PW:GOSUB 1130
30122 NEXT

#30130 CHAR 1,10,3:PRINT USING "=####################################","SCORELIST DONE. NOW PLAYERS."


#TC$:TEMP COMPETITION NAME (IE ASCII FLAVOR)
#TD$:TEMP DISZIPLINE NAME (ASCII)
30150 T$=CN$:GOSUB 2300:TC$=T2$
30151 T$=DN$(CD):GOSUB 2300:TD$=T2$

30190 T$="ENERATE -ILES":GOSUB 1127

# CONCATENATE
# 2300 DOES PETSCII TO ASCII
30200 IX=1:PW=38/IM(CD)
30201 PC=0:GOSUB 1130
30202 FOR L=0 TO IM(CD)

30204  TS$=PN$(CD,SO(CD,L))
30205  IF LEN(TS$)<3 THEN 30240

30206  CHAR 1,1,3,TS$

30207  T$=TS$:GOSUB 2300:TS$=T2$

30208  CF$=LEFT$(DN$(CD),10)+"-"+MID$(STR$(L+1),2)+".FT"

30210  OPEN1,DU,1,"@0:"+CF$

30215   TR%=PR%(CD,L)

30216   PRINT#1,TL$(0)TC$TL$(1)"AUGUST 2024"TL$(2)"DER SPIELER";
30217   PRINT#1,TL$(3)TS$TL$(4)TD$TL$(5)STR$(TR%)TL$(6)SL$CHR$(0)CHR$(0);

30220   IX=IX+1
30221   PC=L*PW:GOSUB 1130

30239  CLOSE 1

30240 NEXT


#30250 CHAR 1,10,3:PRINT USING "=####################################","ALL DONE"

# GENERATE
#  ITERATE OVER PLAYERS OF CURRENT DISCIPLINE
#  CONCATENATE TEMPLATE STRINGS WITH DATA OF CURRENT PLAYER
#  COUNT LENGTH OF GENERATED FILE
#  IF FILESIZE>30000 CHARS, CONTINUE WITH NEW FILE


# THIS APPROACH IS LIKELY HEAVIER ON THE PRINTFOX FT->GB PART THAN
#  THE MANUAL APPROACH FROM PREVIOUSLY.
#  (GENERATION OF INDIVIDUAL GB FILES AND MERGING ON GB LEVEL)
#  BUT IT SHOULD BE MORE AUTOMATED AND LESS DEPENDENT ON USER INPUT


31000 PRINT CHR$(19)CHR$(19);
31001 RETURN



