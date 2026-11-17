# powercomp.bas - Power Competition Manager, GUI-Fassung (Textmodus, GUIT, ohne VDC-BASIC)
# Vorlage: powercomp v1.3. Logik (Laden, Speichern, Sortieren, Export) unveraendert,
# Oberflaeche: powercomp.gui. Control-Nummern laut powercomp.inc:
#   1 txtComp, 3 lblFile, 4 lblDirty, Tabelle ab 10 (je Zeile lblId, txtName, txtScore, lblRank),
#   82+2*d lblD(d), 83+2*d txtDisc(d), 96 lblStatus; frmFile: 0 lstFiles, 1 lblRen, 2 txtRen;
#   frmSave: 1 txtSave; frmProg: 0 lblProg, 1 pbProg.
11 du=peek(186):if du<8 then du=8
12 fast:graphic1:graphic5:bload "guilib",b1:bload "guit",b0:sys 7168:clr:gvload "gui.chr":
13 gload "powercomp.gut",du:gshow 0
14 trap 60000
17 def fn pn(zz)=asc(left$(so$(cd,zz),1))
30 k=0:k$="":e=0:c=0:p=0:h=0:cq=0:m=0:f=0:i=0
31 be=peek(4624)+peek(4625)*256:du=peek(186):if du<8 then du=8
32 pm=31:dm=6:im=0:df=0:fd=0:ts=0:pi=0:cn$="":cd=0:dn$="":cf$="":t$="":pc=0:pw=0:at=0:ea=0:tx=0:po=0
33 q$=chr$(34):cm=0:a$="":b$="":l$="":ep$=chr$(0):pu=0:nw=0:ix=0:pn$="":c$="":dx=0:pg=0:fm=0:rf=0:ac=0
100 dim pn$(dm,pm),ps(dm,pm),pr%(dm,pm),so(dm,pm),so$(dm,pm),ts(dm,pm),dn$(dm),im(dm),rc(pm)
101 dim ce$(143),tl$(9),ti$(17),tn$(17),tv$(17),tk$(17)
120 pu$(0)="  ## ################  ###,###,###"
121 pu$(1)="  ## ################  ###,###,###.#"
122 pu$(2)="  ## ################  ###,###,###.##"
140 gosub 32000
143 if len(dn$)>0 then t$="Loading "+dn$:gosub 1120:gosub 1160
150 gosub 1200:gosub 700:gcaption 82,">1"
152 if len(cn$)=0 then gfocus 1:else gfocus 11
156 rc(0)=8:rc(1)=13:rc(2)=9:for l=3 to pm:rc(l)=15:next
# Hauptschleife: BASIC holt die Taste, eigene Tasten zuerst, sonst Standardbedienung (GKEY)
220 do
222 ggetkey k$:k=asc(k$+ep$):if k>31 and k<128 or k>191 and k<252 or k=143 then 300
223 if cq then gosub 3250
224 gmenusel m,i:if m or fm then 300
230 if k=6 then gmenu 1,0:goto 400
231 if k=15 then gmenu 1,1:goto 400
232 if k=7 then gmenu 1,2:goto 400
234 gget 255,241,f
236 if k=17 or k=145 then if f>=11 and f<=81 then gosub 420:goto 400
238 if k=17 or k=145 then if f>=83 and f<=95 then gosub 480:goto 400
240 if k=13 then if f=1 or f>=83 then gfocus 11:goto 400
250 if k=137 then gfocus 1:goto 400
251 if k=138 then gfocus 83+2*cd:goto 400
252 if k=140 then gosub 2000:goto 399
253 if k=129 then gfocus 83:goto 400
254 if k>148 and k<155 then gfocus 83+2*(k-148):goto 400
255 if k=177 then gosub 2200:goto 399
256 if k=165 then gosub 1100:goto 400
257 if k=175 then gosub 1900:goto 399
258 if k=167 then gosub 2600:goto 399
259 if k=174 then gosub 950:goto 400
260 if k=176 then gosub 2100:goto 400
261 if k=182 then gosub 1102:goto 400
262 if k=170 then nw=-1:goto 400
263 if k=189 then 55350
300 gkey k$,e,c,p,h
310 if e=0 then 330
319 if cq then if h<14 or h>16 then gosub 3250
320 if h then on h gosub 980,1102,950,2100,55350,1250,1300,1400,1500,1900,1100,2200,2600,3200,3200,3200,3400,3500,3600,3700,3800,3900,3950
322 if h>5 and h<14 then rf=-1
330 if rf=0 then 400
399 rf=0:gosub 700
400 loop until nw
# File/New: Statusdatei loeschen und von vorn
415 scratch "powercomp.state",u(du):clr:goto 14
# Tabelle: Cursor hoch/runter, am Rand blaettern
420 r=int((f-10)/4)
422 if k=145 then 450
424 if r<17 then gfocus f+4:return
426 if po+18>pm or po+17>im(cd) then return
428 po=po+1:gosub 800:return
450 if r>0 then gfocus f-4:return
452 if po=0 then return
454 po=po-1:gosub 800:return
# Disziplinen: Cursor hoch/runter (der Fokuswechsel meldet DiscFocus)
480 x=(f-83)/2:if k=17 then x=x+1:if x>dm then x=0
482 if k=145 then x=x-1:if x<0 then x=dm
484 gfocus 83+2*x:return
# alles neu anzeigen
700 gosub 1130:gosub 800:gosub 1800:return
800 vp=im(cd)-po:if vp>17 then vp=17
805 for l=0 to 17:x=so(cd,l+po):tk$(l)=""
806 if l>vp then ti$(l)="":tn$(l)="":tv$(l)="":goto 830
807 ti$(l)=mid$(str$(x),2):tn$(l)=pn$(cd,x):tv$(l)=mid$(str$(ps(cd,x)),2):if ps(cd,x)=0 and tn$(l)="" then tv$(l)=""
808 if pr%(cd,l+po) then tk$(l)=mid$(str$(pr%(cd,l+po)),2)
830 next
835 gcaption 10,18,ti$(0),4:gsettext 11,18,tn$(0),4:gsettext 12,18,tv$(0),4:gcaption 13,18,tk$(0),4
840 gsettext 1,cn$:gcaption 3,dn$:gcaption 4,mid$(" *",1-fd,1)
890 return
# Speichern
950 if len(dn$)=0 then 2100
952 gosub 1000:rf=-1:return
980 nw=-1:return
1000 t$="Saving to disk":gosub 1120
1001 open 1,du,3,"@0:"+dn$+",w"
1002 if len(cn$)=0 then cn$="Unnamed competition"
1006 print#1,q$+cn$+q$
1009 print#1,str$(dx)
1010 pc=0:pw=38/(dx+1)
1012 for d=0 to dx
1015 print#1,q$+dn$(d)+q$
1018 print#1,im(d)
1021 for l=0 to im(d)
1024 print#1,q$+pn$(d,l)+q$
1027 print#1,ps(d,l)
1030 next
1032 pc=d*pw:gosub 1140
1033 next
1036 close 1
1042 gosub 2410
1099 return
# Datei-Dialog (ac=0 Wettbewerb laden, ac=1 Printfox-Vorlage)
1100 ac=1:goto 1104
1102 ac=0
1104 gshow 1:fm=1:gclear 0:gsettext 2,"":gosub 10000:if cm>0 then gset 0,21,0
1105 gfocus 0:return
# Fortschrittsfenster
1120 if pg=0 then gshow 3:pg=1
1122 gcaption 0,t$:gset 1,16,0:return
1127 gcaption 0,t$:return
1130 if pg then gclose:pg=0
1132 return
1140 gset 1,16,pc:return
# Laden
1160 open 1,du,3,dn$+",r":if ds then close 1:dn$="":return
1181 input#1,cn$
1182 input#1,dx
1183 pw=38/(dx+1):pc=0:gosub 1140
1184 for d=0 to dx
1185 input#1,dn$(d)
1186 input#1,im(d)
1187 for l=0 to im(d)
1188 input#1,pn$(d,l)
1189 input#1,ps(d,l)
1190 next
1191 pc=(d+1)*pw:gosub 1140
1192 next
1193 close 1
1194 open 1,du,2,"@0:powercomp.state,s,w":print#1,dn$:close 1
1195 gosub 2410:po=0
1198 gosub 1200
1199 return
1200 for l=0 to pm
1202 so(cd,l)=l
1208 next
1210 for l=0 to im(cd)
1212 pr%(cd,l)=0
1214 next
1219 return
1250 t$="Sorting by ID":gosub 1120:gosub 1200:return
1300 t$="Sorting by name":gosub 1120
1301 for l=0 to im(cd):so(cd,l)=l:so$(cd,l)=pn$(cd,l):next
1302 do:kg=0
1303 for l=0 to im(cd)-1
1304 if fn pn(l)>fn pn(l+1) then begin
1305 so=so(cd,l):so(cd,l)=so(cd,l+1):so(cd,l+1)=so:kg=-1
1306 so$=so$(cd,l):so$(cd,l)=so$(cd,l+1):so$(cd,l+1)=so$
1307 bend
1308 next
1309 loop while kg
1310 for l=0 to im(cd)
1312 pr%(cd,l)=0
1314 next
1399 return
1400 t$="Sorting by score":gosub 1120
1405 for l=0 to im(cd):so(cd,l)=l:ts(cd,l)=ps(cd,l):next
1410 do:kg=0
1415 for l=0 to im(cd)-1
1420 if ts(cd,l)<ts(cd,l+1) then begin
1425 so=so(cd,l):so(cd,l)=so(cd,l+1):so(cd,l+1)=so:kg=-1
1430 ts=ts(cd,l):ts(cd,l)=ts(cd,l+1):ts(cd,l+1)=ts
1435 bend
1440 next
1445 loop while kg
1450 t=1
1455 pr%(cd,0)=t:t=t+1
1460 for l=1 to im(cd)
1465 if ps(cd,so(cd,l))=ps(cd,so(cd,l-1)) then pr%(cd,l)=pr%(cd,l-1):else pr%(cd,l)=t
1470 t=t+1
1475 next
1499 return
1500 t$="Reversing sort order":gosub 1120
1505 l1=0
1510 for l=im(cd) to 0 step -1
1515 ts(cd,l)=so(cd,l1)
1520 l1=l1+1
1525 next
1530 for l=0 to im(cd)
1535 so(cd,l)=ts(cd,l)
1540 next
1542 if pr%(cd,0)>0 then 1450
1599 return
# Disziplinen anzeigen, Disziplin wechseln (x = neue Nummer)
1800 gsettext 83,7,dn$(0),2:return
1850 if x=cd then return
1852 gcaption 82+2*cd," "+mid$(str$(cd+1),2)
1854 cd=x:po=0:gcaption 82+2*cd,">"+mid$(str$(cd+1),2):gosub 1200:gosub 800:return
# Scoreboard auf dem 40-Zeichen-Schirm
1900 if pr%(cd,0)=0 then gosub 1400:gosub 1130:gosub 800
1901 t$="Scoreboard on 40 col display":gosub 1120:gcaption 0,"D: decimals, other key: close"
1905 slow:graphic 0:color 5,16:print chr$(14);chr$(147);
1910 print using "   =##################################";dn$(cd)
1915 print:ix=1
1920 for l=0 to im(cd)
1921 ts$=pn$(cd,so(cd,l))
1922 if len(ts$)<3 then 1929
1923 ts=ps(cd,so(cd,l))
1924 color 5,rc(pr%(cd,ix-1)-1)
1925 print using pu$(pu);pr%(cd,ix-1),ts$,ts
1926 ix=ix+1
1929 next
1990 ggetkey i$:if i$=chr$(143) then gkey "",e,c,p,h:goto 1990
1991 if asc(i$)>251 then 1990
1992 if i$="d" or i$="D" then pu=pu+1:if pu>2 then pu=0
1993 if i$="d" or i$="D" then 1905
1998 fast:gosub 1130
1999 return
# F8: Spieler mit Fokus loeschen
2000 if f<11 or f>81 then return
2001 pi=po+int((f-10)/4):if pi>im(cd) then return
2002 ix=so(cd,pi)
2005 for l=ix to im(cd)-1
2010 pn$(cd,so(cd,l))=pn$(cd,so(cd,l+1))
2011 ps(cd,so(cd,l))=ps(cd,so(cd,l+1))
2015 next
2016 pn$(cd,so(cd,im(cd)))=""
2017 ps(cd,so(cd,im(cd)))=0
2020 if im(cd)>0 then im(cd)=im(cd)-1
2022 gosub 2400
2099 return
# Speichern unter
2100 gshow 2:fm=2:gsettext 1,dn$:gfocus 1:return
# CSV
2200 t$="Exporting to CSV":gosub 1120
2201 cf$=left$(dn$(cd),12)+".csv"
2204 open 1,du,3,"@0:"+cf$+",p,w"
2206 ix=1:pw=38/(im(cd)+1)
2208 for l=0 to im(cd)
2210 ts$=pn$(cd,so(cd,l))
2212 if len(ts$)<3 then 2222
2214 ts=ps(cd,so(cd,l))
2218 t$=mid$(str$(ix),2)+";"+ts$+";"+mid$(str$(ts),2)
2219 gosub 2300:print#1,t2$chr$(13)chr$(10);
2220 ix=ix+1
2221 pc=l*pw:gosub 1140
2222 next
2224 close 1
2299 return
2300 t2$=""
2305 for x=1 to len(t$)
2310 c$=mid$(t$,x,1):a=asc(c$)
2320 if a>=193 and a<=218 then a=a-128:t2$=t2$+chr$(a):goto 2340
2325 if a>=65 and a<=90 then a=a+32:t2$=t2$+chr$(a):goto 2340
2330 t2$=t2$+c$
2340 next
2399 return
2400 if fd then return
2401 fd=-1:if pg=0 and fm=0 then gcaption 4,"*"
2402 return
2410 fd=0:return
# Automation
2600 t$="Exporting for automation":gosub 1120
2605 t2$=left$(dn$(cd),4)
2610 t=asc(left$(t2$,1)+ep$)
2612 if t>128 then t2$=chr$((t-96) and (255-32))+mid$(t2$,2)
2614 cf$="S24-"+t2$+".auto,s,w"
2616 open 1,du,2,"@0:"+cf$
2618 ix=0:pw=38/(im(cd)+1):x=l+2
2620 for l=0 to im(cd)
2622 t$=left$(pn$(cd,so(cd,l)),3)
2626 pn$=""
2628 for i=1 to len(t$)
2630 t=asc(mid$(t$,i,1))
2632 if t>128 then c$=chr$((t-96) and (255-32)):else c$=mid$(t$,i,1)
2634 pn$=pn$+c$
2636 next
2638 t$=mid$(str$(x),2)
2640 print#1,"G0,S24.GB1,-,-,1,0"
2642 print#1,"UN,-,1,0,0,0"
2644 print#1,"G+,DISZ"+t2$+".GB,-,-,1,1"
2646 print#1,"UO,-,1,1,0,0"
2648 print#1,"G+,SPI"+pn$+".GB,-,-,1,"+t$
2650 print#1,"UO,-,1,"+t$+",0,0"
2652 print#1,"PG,-,0,0,0,1"
2654 print#1,"FS,S24-"+t2$+"-"+pn$+".GB1,0,1,-,-"
2710 pc=l*pw:gosub 1140
2719 x=x+1
2720 next
2730 close 1
2740 return
# Handler (ON H GOSUB)
# Change (Name, Punkte, Wettbewerb, Disziplin): nur merken; gelesen wird erst, wenn eine andere
# Taste oder ein anderes Event kommt (3250) - so kostet ein getipptes Zeichen nur GGETKEY + GKEY
3200 if cq<>c and cq then gosub 3250
3205 cq=c:goto 2400
3250 q=cq:cq=0:ggettext q,t$:if q=1 then cn$=t$:return
3255 if q>=83 then x=(q-83)/2:dn$(x)=t$:if dx<x then dx=x
3256 if q>=83 then return
3260 r=int((q-10)/4):x=q-10-4*r:l=po+r:i=so(cd,l)
3262 if x=1 then pn$(cd,i)=t$
3264 if x=2 then ps(cd,i)=val(t$)
3266 if t$<>"" and im(cd)<l then im(cd)=l:gcaption q-x,mid$(str$(i),2)
3268 return
3400 x=(c-83)/2:goto 1850
3500 gget 0,21,x:if x<0 or x>=cm then return
3502 dn$=ce$(x):gclose:fm=0
3504 if ac=0 then t$="Loading "+dn$:gosub 1120:gosub 1160
3506 if ac=1 then gosub 30000
3508 rf=-1:return
3600 gget 0,21,x:if x<0 or x>=cm then return
3602 scratch (ce$(x)),u(du):gclear 0:goto 10000
3700 gget 0,21,x:if x<0 or x>=cm then return
3702 ggettext 2,t$:if t$="" then gfocus 2:return
3704 rename (ce$(x)) to (t$),u(du):gsettext 2,"":gclear 0:goto 10000
3800 gclose:fm=0:return
3900 ggettext 1,t$:if t$="" then return
3902 gclose:fm=0:dn$=t$:gosub 1000:rf=-1:return
3950 gclose:fm=0:return
# Verzeichnis lesen: Namen nach ce$(), in die Liste
10000 gcaption 1,"Reading...":open 1,du,0,"$":cm=0:hd=0:get#1,a$,a$
10002 get#1,a$,a$,a$,a$:if st then 10020
10004 l$=""
10005 get#1,a$:if a$<>"" then l$=l$+a$:if st=0 then 10005
10008 p1=instr(l$,chr$(34)):if p1=0 then 10002
10010 p2=instr(l$,chr$(34),p1+1):if p2=0 then 10002
10012 if hd=0 then hd=1:goto 10002
10014 ce$(cm)=mid$(l$,p1+1,p2-p1-1):gadd 0,ce$(cm):cm=cm+1:if cm<144 then 10002
10020 close 1:gcaption 1,"New name:":return
# Printfox: Vorlage hinter das Programm laden (BE, nicht mehr $1302: dort liegt die GUI)
30000 t$="Loading template":gosub 1120
30005 open 1,du,0,dn$:get#1,a$,b$:close 1
30015 if a$<>chr$(84) then gosub 1130:gcaption 96,"Not a Printfox file: "+dn$:return
30025 bank 0:poke be,84:poke be+1,asc(b$+ep$):bank 15
30030 bload (dn$),u(du),p(be+2),b0
30031 ea=peek(174)+peek(175)*256
30035 bank 0
30036 tx=0:tl$(tx)="":pw=38/9
30040 for l=be+1 to ea-3
30045 tv=peek(l)
30050 if tv=35 then tx=tx+1:tl$(tx)="":pc=pw*tx:bank 15:gosub 1140:bank 0:goto 30060
30055 tl$(tx)=tl$(tx)+chr$(tv)
30060 next
30065 bank 15
30105 t$="Generate scorelist":gosub 1127
30106 ix=1:sl$="":pw=38/(im(cd)+1)
30107 pc=0:gosub 1140
30108 for l=0 to im(cd)
30110 ts$=pn$(cd,so(cd,l))
30112 if len(ts$)<3 then 30122
30114 ts=ps(cd,so(cd,l))
30118 t$=mid$(str$(pr%(cd,ix-1)),2)+chr$(7)+ts$+chr$(7)+mid$(str$(ts),2)
30119 gosub 2300:sl$=sl$+t2$+chr$(13)
30120 ix=ix+1
30121 pc=l*pw:gosub 1140
30122 next
30130 y2=740-im(cd)*11:y1=y2-20
30135 y1$=mid$(str$(y1),2)
30137 y2$=mid$(str$(y2),2)
30150 t$=cn$:gosub 2300:tc$=t2$
30151 t$=dn$(cd):gosub 2300:td$=t2$
30152 t$="27.Juli - 11.August 2024":gosub 2300:tt$=t2$
30160 t$="Generate files":gosub 1127
30170 ix=1:pw=38/(im(cd)+1)
30180 pc=0:gosub 1140
30185 fx=1
30190 gosub 31050
30202 for l=0 to im(cd)
30203 ts$=pn$(cd,so(cd,l))
30204 if len(ts$)<3 then 30230
30205 gcaption 0,ts$
30206 t$=ts$:gosub 2300:ts$=t2$
30207 t$="Der Spieler":gosub 2300:pg$=t2$
30215 tr%=pr%(cd,l):tr$=mid$(str$(tr%),2)
30216 print#1,tl$(0)tc$tl$(1)tt$tl$(2)pg$;
30217 print#1,tl$(3)ts$tl$(4)td$tl$(5)tr$tl$(6)y1$tl$(7)y2$tl$(8)sl$chr$(1);
30220 ix=ix+1
30221 pc=l*pw:gosub 1140
30230 next
30235 gosub 31100
31001 return
31050 cf$=left$(dn$(cd),11)+"-"+mid$(str$(fx),2)+".ft"
31055 open 1,du,1,"@0:"+cf$
31060 print#1,chr$(84);
31070 return
31100 print#1,chr$(0)chr$(0);
31110 close 1
31120 return
32000 dopen#1,"powercomp.state",r,u(du)
32010 if ds>0 then 32040
32020 input#1,dn$
32040 dclose#1
32090 return
55350 gend:graphic 5:print "bye!":end
# Fehler (Diskette, Datei): melden und weiter
60000 close 1:gosub 1130:if fm then gclose:fm=0
60010 gcaption 96,"Error"+str$(er)+" in"+str$(el)+": "+err$(er):resume 399
