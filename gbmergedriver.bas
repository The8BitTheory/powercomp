#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0 VDC,uppercase,10,10
#########################
# THIS ORS TWO GB FILES #
#########################

# SOURCE IMAGES RESIDE IN BANK 1
# DEST IMAGE IS WRITTEN TO BANK 0


4 GRAPHIC0:SLOW:BANK15:POKE 57,0:POKE58,5:CLR:PRINT FRE(0) FRE(1)
5 DD=PEEK(186)


# THE MC-COMPILED ROUTINE TO UNCOMPRESS GB FROM BE TO VE
7 PRINT "LOADING GB2VDC...";:BLOAD"GBUNPACK.BIN",B0,U(DD):PRINT "DONE"

9 PRINT "LOADING VDC-BASIC";:BLOAD"VDCBASIC2D.0AC6",B0,U(DD):SYS DEC("AC6"):RST3


# BASIC END (CONTAINS COMPRESSED GB FILE)
10 BE=PEEK(4624)+PEEK(4625)*256

# VARIABLE END (CONTAINS UNCOMPRESSED GB FILES)
12 VE=PEEK(57)+PEEK(58)*256

14 PRINT "BASIC END (COMPRESSED GB):"BE
16 PRINT "VARIABLE END (UNCOMP. GB):"VE

20 DEF FN HB(ZZ)=INT(ZZ/256)
21 DEF FN LB(ZZ)=ZZ-INT(ZZ/256)*256

# SETUP VDC CHIP
30 ::RGO DEC("19"),128:REM BITMAP MODE
32 ::RGA DEC("19"),191:REM NO ATTRIBUTES
34 ::RGO DEC("1C"),16:REM 64KB VRAM
#35 RGW 8,3:RGW4,64:RGW6,50:RGW7,58:RGW0,128


100 FI$="RAHMEN.GB1":DB=1:DA=VE:SB=0:SA=BE:GOSUB 1000
110 PRINT "COPYING GB TO VRAM...";
120 RTV BE,0,32000
130 PRINT "DONE.":PRINT "FREE MEM:"FRE(0) FRE(1)

150 FI$="URKSCHRIFT2.GB":DB=0:DA=BE:SA=VE+32000:SB=1:GOSUB 1000
160 PRINT "COPYING GB TO VRAM...";
170 RTV DA,32000,32000
180 PRINT "DONE.":PRINT "FREE MEM:"FRE(0) FRE(1)


200 PRINT "MERGING GB FILES"

# IMG1 BANK: 996
# IMG1 START ADDRESS (COMP GB):997/998

# IMG2 BANK: 1001
# IMG2 START ADDRESS (UNCOMP GB):1002/1003
210 POKE 996,1
212 POKE 997,FNLB(VE):POKE 998,FNHB(VE)

220 POKE 1001,0
222 POKE 1002,FNLB(BE):POKE 1003,FNHB(BE)

240 PRINT "LOADING GB.BIN...";:BLOAD"GB.BIN",B0,U(DD):PRINT "DONE"
250 FAST:S=TI:SYS DEC("1309"):S=TI-S:SLOW
255 PRINT "DONE. TOOK "S" JIFFIES"


260 BSAVE"MERGED.GB",B0,P(BE) TO P(BE+32000),U(DD)

#260 RTV BE,0,32000


#300 DD=0:DO
#310 GETKEY A$
# DOWN
#320 IF ASC(A$)=17 THEN DD=DD+640:IF DD>48000 THEN DD=0
#330 IF ASC(A$)=145 THEN DD=DD-640:IF DD<0 THEN DD=48000
#335 IF A$=" " THEN PRINT DD
#340 DISP DD
#350 LOOP


999 GRAPHIC0:END


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
1090 FAST:S=TI:SYS DEC("1300"):S=TI-S:SLOW
1100 PRINT "DONE. TOOK "S" JIFFIES"

# STASH TO REU  :NR BYTES,RAM-ADDR,REU-ADDR,REU-BANK
# FETCH FROM REU:NR BYTES,RAM-ADDR,REU-ADDR,REU-BANK
1105 IF DB=0 THEN 1199
1110 BANK 1:STASH 32000,DA,0,0
1120 BANK 0:FETCH 32000,BE,0,0
1125 BANK 15

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


