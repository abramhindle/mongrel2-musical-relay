
; FLUTE INSTRUMENT BASED ON PERRY COOK'S SLIDE FLUTE

sr        =         44100
kr        =         4410
ksmps     =         10
nchnls    =         1

          instr     1
; i1 1.00000e-02 1.50000e-02 3.37500e+03 1.50000e+01 -6.85550e+02 4.01500e+02 -7.98378e-01 6.33933e-01
; i1 now dur mass radius x y xv yv
; i1 p2 p3   p4   p5     p5p7p8 p9
          schedule 1902, 0.01, p3, (10000 * log(p4 * p5)/24), (6.00 + 3.0 * (log(p8*p8 + p9*p9))/30), 0.9, 0.136, 0.45, 0.35
endin

	instr	2
aamp    adsr (p3*0.1), (p3*0.1), 0.5, (p3*0.1)
a1	oscil	p4, p5, 1
	out	a1*aamp
	endin


          instr     1902

aflute1   init      0
;ifqc      =         cpspch(p5)
iafqc      pow       2,p5
ifqc       = 200 + iafqc
ipress    =         p6
ibreath   =         p7
ifeedbk1  =         p8
ifeedbk2  =         p9

; FLOW SETUP
kenv1     linseg    0, .06, 1.1*ipress, .2, ipress, p3-.16, ipress, .02, 0 
kenv2     linseg    0, .01, 1, p3-.02, 1, .01, 0
kenvibr   linseg    0, .5, 0, .5, 1, p3-1, 1 ; VIBRATO ENVELOPE

; THE VALUES MUST BE APPROXIMATELY -1 TO 1 OR THE CUBIC WILL BLOW UP
aflow1    rand      kenv1
kvibr     oscil     .1*kenvibr, 5, 3

; ibreath CAN BE USED TO ADJUST THE NOISE LEVEL
asum1     =         ibreath*aflow1 + kenv1 + kvibr
asum2     =         asum1 + aflute1*ifeedbk1

afqc      =         1/ifqc - asum1/20000 -9/sr + ifqc/12000000

; EMBOUCHURE DELAY SHOULD BE 1/2 THE BORE DELAY
; ax      delay     asum2, (1/ifqc-10/sr)/2
atemp1    delayr    1/ifqc/2
ax        deltapi   afqc/2                   ; - asum1/ifqc/10 + 1/1000
          delayw    asum2
                              
apoly     =         ax - ax*ax*ax
asum3     =         apoly + aflute1*ifeedbk2

avalue    tone      asum3, 2000

; BORE, THE BORE LENGTH DETERMINES PITCH.  SHORTER IS HIGHER PITCH
atemp2    delayr    1/ifqc
aflute1   deltapi   afqc
          delayw    avalue

          out       avalue*p4*kenv2

          endin



          instr      1903
areedbell init  0
;ifqc      =          cpspch(p5)
iafqc      pow       2,p5
ifqc       = 200 + iafqc
ifco      =          p7
ibore     =          1/ifqc-15/sr

; I GOT THE ENVELOPE FROM PERRY COOKE'S CLARINET
kenv1     linseg     0, .005, .55 + .3*p6, p3 - .015, .55 + .3*p6, .01, 0
kenvibr   linseg     0, .1, 0, .9, 1, p3-1, 1    ; VIBRATO ENVELOPE

; SUPPOSEDLY HAS SOMETHING TO DO WITH REED STIFFNESS?
kemboff   =          p8

; BREATH PRESSURE
avibr     oscil      .1*kenvibr, 5, 3
apressm   =          kenv1 + avibr

; REFLECTION FILTER FROM THE BELL IS LOWPASS
arefilt   tone      areedbell, ifco

; THE DELAY FROM BELL TO REED
abellreed delay     arefilt, ibore

; BACK PRESSURE AND REED TABLE LOOK UP
asum2     =         - apressm -.95*arefilt - kemboff
areedtab  tablei    asum2/4+.34, p9, 1, .5
amult1    =         asum2 * areedtab

; FORWARD PRESSURE
asum1     =         apressm + amult1

areedbell delay     asum1, ibore

aofilt    atone     areedbell, ifco

          out       aofilt*p4

          endin



          instr     1904    ; DRUM STICK 1




gadrum    init      0

; FREQUENCY
ifqc      =         cpspch(p5)

; INITIALIZE THE DELAY LINE WITH NOISE
ashape    linseg     0, 1/ifqc/8, -1/2, 1/ifqc/4, 1/2, 1/ifqc/8, 0, p3-1/ifqc, 0
gadrum    tone      ashape, p6

          endin

          instr     1905    ; A SQUARE DRUM

irt2      init      sqrt(2)
itube     init      p7
ifdbck1   init      p8
ifdbck2   init      p9
anodea    init      0
anodeb    init      0
anodec    init      0
anoded    init      0
afiltr    init      0
ablocka2  init      0
ablocka3  init      0
ablockb2  init      0
ablockb3  init      0
ablockc2  init      0
ablockc3  init      0
ablockd2  init      0
ablockd3  init      0

; FREQUENCY
ifqc      =          cpspch(p5)
ipfilt    =          p6

; AMPLITUDE ENVELOPE
kampenv   linseg 0, .01, p4, p3-.02, p4, .01, 0
                
; DELAY LINES
alineab   delay      anodea+gadrum+afiltr, 1/ifqc
alineba   delay      anodeb+gadrum+afiltr, 1/ifqc
alinebc   delay      anodeb+gadrum+afiltr, 1/ifqc
alinecb   delay      anodec+gadrum+afiltr, 1/ifqc
alinecd   delay      anodec+gadrum+afiltr, 1/ifqc
alinedc   delay      anoded+gadrum+afiltr, 1/ifqc
alinead   delay      anodea+gadrum+afiltr, 1/ifqc
alineda   delay      anoded+gadrum+afiltr, 1/ifqc
alineac   delay      anodea+gadrum+afiltr, 1/ifqc*irt2
alineca   delay      anodec+gadrum+afiltr, 1/ifqc*irt2
alinebd   delay      anodeb+gadrum+afiltr, 1/ifqc*irt2
alinedb   delay      anoded+gadrum+afiltr, 1/ifqc*irt2

; FILTER THE DELAYED SIGNAL AND FEEDBACK INTO THE DELAY
; IMPLEMENTS DC BLOCKING
ablocka1  =         -(alineba + alineca + alineda)/ifdbck1
ablocka2  =         ablocka1 - ablocka3 + .99*ablocka2
ablocka3  =         ablocka1
anodea    =         ablocka2
     
; NODE B
ablockb1  =         -(alineba + alineca + alineda)/ifdbck1
ablockb2  =         ablockb1 - ablockb3 + .99*ablockb2
ablockb3  =         ablockb1
anodeb    =         ablockb2

; NODE C
ablockc1  =         -(alineba + alineca + alineda)/ifdbck1
ablockc2  =         ablockc1 - ablockc3 + .99*ablockc2
ablockc3  =         ablockc1
anodec    =         ablockc2

; NODE D
ablockd1  =         -(alineba + alineca + alineda)/ifdbck1
ablockd2  =         ablockd1 - ablockd3 + .99*ablockd2
ablockd3  =         ablockd1
anoded    =         ablockd2

; BODY RESONANCE
atube     delay      anodea, itube/ifqc
afiltr    tone      atube, 1000
afiltr    =          afiltr/ifdbck2

; SCALE AND OUTPUT
          out       anodea*kampenv*1000

          endin

          instr      1906 ; DRUM STICK 2

gadrum2   init      0

; FREQUENCY
ifqc      =          cpspch(p5)

; INITIALIZE THE DELAY LINE WITH NOISE
ashape    linseg     0, 1/ifqc/8, -1/2, 1/ifqc/4, 1/2, 1/ifqc/8, 0, p3-1/ifqc, 0
gadrum2   tone      ashape, p6

          endin

          instr      1907    ; A SQUARE DRUM
                
irt2      init      sqrt(2)
itube     init      p7
ifdbck1   init      p8
ifdbck2   init      p9
anodea    init      0
anodeb    init      0
anodec    init      0
anoded    init      0
afiltr    init      0
ablocka2  init      0
ablocka3  init      0
ablockb2  init      0
ablockb3  init      0
ablockc2  init      0
ablockc3  init      0
ablockd2  init      0
ablockd3  init      0

; FREQUENCY
ifqc      =          cpspch(p5)
ipfilt    =          p6

; AMPLITUDE ENVELOPE
kampenv   linseg     0, .01, p4, p3-.02, p4, .01, 0

; DELAY LINES
alineab   delay      anodea+gadrum2+afiltr, 1/ifqc
alineba   delay      anodeb+gadrum2+afiltr, 1/ifqc
alinebc   delay      anodeb+gadrum2+afiltr, 1/ifqc
alinecb   delay      anodec+gadrum2+afiltr, 1/ifqc
alinecd   delay      anodec+gadrum2+afiltr, 1/ifqc
alinedc   delay      anoded+gadrum2+afiltr, 1/ifqc
alinead   delay      anodea+gadrum2+afiltr, 1/ifqc
alineda   delay      anoded+gadrum2+afiltr, 1/ifqc
alineac   delay      anodea+gadrum2+afiltr, 1/ifqc*irt2
alineca   delay      anodec+gadrum2+afiltr, 1/ifqc*irt2
alinebd   delay      anodeb+gadrum2+afiltr, 1/ifqc*irt2
alinedb   delay      anoded+gadrum2+afiltr, 1/ifqc*irt2

; FILTER THE DELAYED SIGNAL AND FEEDBACK INTO THE DELAY
; IMPLEMENTS DC BLOCKING
ablocka1  =         -(alineba + alineca + alineda)/ifdbck1
ablocka2  =         ablocka1 - ablocka3 + .99*ablocka2
ablocka3  =         ablocka1
anodea    =         ablocka2

; NODE B
ablockb1  =         -(alineba + alineca + alineda)/ifdbck1
ablockb2  =         ablockb1 - ablockb3 + .99*ablockb2
ablockb3  =         ablockb1
anodeb    =         ablockb2

; NODE C
ablockc1  =         -(alineba + alineca + alineda)/ifdbck1
ablockc2  =         ablockc1 - ablockc3 + .99*ablockc2
ablockc3  =         ablockc1
anodec    =         ablockc2

; NODE D
ablockd1  =         -(alineba + alineca + alineda)/ifdbck1
ablockd2  =         ablockd1 - ablockd3 + .99*ablockd2
ablockd3  =         ablockd1
anoded    =         ablockd2

; BODY RESONANCE
atube     delay      anodea, itube/ifqc
afiltr    tone      atube, 1500
afiltr    =          afiltr/ifdbck2

; SCALE AND OUTPUT
          out       anodea*kampenv*1000

          endin



