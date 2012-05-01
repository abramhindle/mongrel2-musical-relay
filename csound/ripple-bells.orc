	sr = 44100
	kr = 2205
	ksmps = 20
	nchnls = 1

	instr	1
aamp    adsr (p3*0.1), (p3*0.1), 0.5, (p3*0.1)
a1	oscil	p4, p5, 1
	out	a1*aamp
	endin

	instr	2
aamp    adsr (p3*0.1), (p3*0.1), 0.5, (p3*0.1)
a1	oscil	p4, 5*p5, 1
	out	a1*aamp
	endin



instr 3
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
