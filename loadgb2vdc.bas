#RetroDevStudio.MetaData.BASIC:7169,BASIC V7.0 VDC,uppercase,10,10
# A=SOURCE ADDR
# B=SOURCE BANK
# C=DEST ADDR
# D=DEST BANK
# E=END ADDRESS OF INPUT FILE
# F=START OF UNCOMPRESSED IMAGE-AREA
# G=START OF SECOND IMAGE UNCOMPRESSED AREA
# I=IMAGE NR (1 FOR FIRST IMAGE, 2 FOR SECOND IMAGE)
# L=LINEOFFSET
# M=MAGIC BYTE
# O=COLUMNCTR
# R=REPEATS
# T=TARGET ADDR (=DEST ADDR + LINEOFFSET)
# V=VALUE
# X=LOOP VARIABLE FOR SOURCEDATA
# Y=LOOP VARIABLE FOR UNPACK
# Z=SOURCE SIZE
5 GRAPHIC0
6 POKE 57,80:POKE58,43:CLR:PRINT FRE(0) FRE(1)
10 PRINT "INSERT DATADISK":GETKEY I$
20 DD=PEEK(186)
30 BLOAD"VDCBASIC2D.0AC6":SYS DEC("AC6")

32 ::RGO DEC("19"),128:REM BITMAP MODE
34 ::RGA DEC("19"),191:REM NO ATTRIBUTES
36 ::RGO DEC("1C"),16

38 I=1

40 PRINT "LOADING GB..."
50 BANK 15:REM DOIT
#50 CATALOG U(DD)
#60 PRINT "FILENAME:";:INPUT NM$
65 IF I=1 THEN NM$="RAHMEN.GB1":ELSE IF I=2 THEN NM$="URKSCHRIFT.GB"

# END OF BASIC PROGRAM
70 A=PEEK(4624)
80 A=PEEK(4625)*256+A
81 PRINT "END OF BASIC(A): B0"A



# LOAD COMPRESSED FILE TO BANK 0
82 OPEN1,8,0,NM$
84 GET#1,P$,P$
85 BANK 0:POKE A+1,ASC(P$)
86 CLOSE1
87 PRINT ASC(P$)

90 BLOAD (NM$),P(A+2),B0,U8
95 POKE A,DEC("47")

110 BANK15

150 B=0

160 C=PEEK(57)+PEEK(58)*256:C1=C:REM C=0
165 IF I=2 THEN C1=C1+8000
166 PRINT "END OF VARIABLES(C1): B1"C1

170 D=1
180 E=PEEK(174)+PEEK(175)*256+E
195 PRINT "END OF FILE AREA(E): B0"E

210 M=DEC("9B")
220 L=0
230 O=0

240 A=A+1

250 S=TI:FAST:DO

260  BANK B
270  V=PEEK(A)
280  A=A+1

290  IF V=M THEN GOSUB320: ELSE BANK D:GOSUB400
295  IF T>8000 THEN SLOW:GRAPHIC0:PRINT "FIRST HALF DONE":E=0
300 LOOP UNTIL A>=E

305 S=TI-S:PRINT "I "I" TOOK "S" JIFFIES"

310 IF I<2 THEN CLR:I=2:GOTO50

311 CLR:GOSUB 500

315 BANK15:END

# UNPACK
320 R=PEEK(A)      :A=A+1
330 R=PEEK(A)*256+R:A=A+1
340 V=PEEK(A)      :A=A+1
350 BANK D
360 FOR Y = 1 TO R
370  GOSUB400
380 NEXT
390 RETURN

# COPY
400 REM T=C+L
410 POKE C1+L,V

430 L=L+80
440 IF L>560 THEN L=0:C=C+1:C1=C1+1:O=O+1:IF O>79 THEN O=0:C=C+560:C1=C1+560
450 RETURN


# MERGE TWO IMAGES FROM BANK 1 AND PUT THEM INTO BANK 0
#C: DEST ADDRESS (BANK0, AFTER BASIC END)
#D: DEST BANK: 0
500 BANK15:C=PEEK(4624)+PEEK(4625)*256:D=0:C1=C
502 PRINT "DEST - END OF BASIC(C): B0"C

#A: SOURCE ADDRESS (AFTER VARIABLES IN BANK 1)
#B: SOURCE BANK (1)
505 A=PEEK(57)+PEEK(58)*256:B=1
506 PRINT "SOURCE - AFTER VARIABLES: B1"A
#F: MEM-INDEX FIRST IMAGE
#G: MEM-INDEX SECOND IMAGE

510 F=A:G=F+8000

515 I=1:S=TI

# STASH:NR BYTES,RAM-ADDR,REU-ADDR,REU-BANK
# FETCH:NR BYTES,RAM-ADDR,REU-ADDR,REU-BANK

520 SLOW
522 BANK B:STASH 8000,A,0,0
525 BANK D:FETCH 8000,C1,0,0

#515 FAST:DO
#520  BANK B:V1=PEEK(F):REM V2=PEEK(G):V=V1:REM OR V2
#525  BANK D:POKE C,V1
#530  F=F+1:G=G+1:C=C+1
#535 LOOP UNTIL F=A+8000:SLOW

540 BANK D:RTV C1,(I-1)*8000,8000:BANK15

545 A=A+8000:I=I+1:IF I<2 THEN 520

550 S=TI-S:PRINT "MERGE TOOK " S " JIFFIES"




590 RETURN

