      	sr = 44100
	kr = 2205       
	ksmps = 20
	nchnls = 1

	instr	1
iindex      =   p4
itableamp   =   2
itablepitch =   3
kpitch  table iindex, itablepitch
kamp    table iindex, itableamp
a1	oscil	kamp, kpitch, 1
	out	a1
	endin

        instr 666
p3      =     1/44100
iindex  =     p4	; index
iloud   =     p5	; 
ipitch  =     p6     ;
itableamp =   2
itablepitch = 3
tableiw     iloud  , iindex, itableamp,   0, 0, 0 
tableiw     ipitch , iindex, itablepitch, 0, 0, 0 
endin

; p4 is 0-30000 
; p5 is 20-20000
instr bell
  idur   = p3
  iamp   = p4
  ifenv  = 51                    ; bell settings:
  ifdyn  = 52                    ; amp and index envelopes are exponential
  ifq1   = 5*p5/5;cpspch(p5)*5          ; decreasing, N1:N2 is 5:7, imax=10
  if1    = 1                     ; duration = 15 sec
  ifq2   = 7*p5/5;cpspch(p5)*7
  if2    = 1
  imax   = 10
  
  aenv  oscili  iamp, 1/idur, ifenv             ; envelope
  
  adyn  oscili  ifq2*imax, 1/idur, ifdyn        ; dynamic
  amod  oscili  adyn, ifq2, if2                 ; modulator
  
  a1    oscili  aenv, ifq1+amod, if1            ; carrier
        out     a1
endin
