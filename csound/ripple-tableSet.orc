sr=44100
kr=441
ksmps=100
nchnls=1   



instr 1 ; simple waveguide
	it1 = p4
	it2 = p5
arg	oscili	   1,2,it2
ar      oscili     20000, 1000*arg,it1 
out ar
endin

instr 2 ; simple oscili
      	it1 = p4   
  ipitchmod = p5      
  iwgpitch  = p6
apitch	oscili	   1,iwgpitch,it1
ar      oscili     20000, ipitchmod*apitch, 666
out ar
endin

instr 3 ; simple oscili
      	it1 = p4   
  ipitchmod = p5      
  iwgpitch  = p6
apitch	oscili	   1,iwgpitch,it1
ar      randh      10000, ipitchmod * apitch
out ar
endin




instr 6666
p3 = 1/44100
itable = p4	; table
iindex = p5	; index
tableiw     p6   , iindex, itable, 0, 0, 0 
endin
