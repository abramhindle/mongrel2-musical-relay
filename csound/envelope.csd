<CsoundSynthesizer>
<CsInstruments>

sr=44100
kr=441
ksmps=100
nchnls=1   
0dbfs = 1.0

giamp init 1000

instr 1 ; simple waveguide
	it1 = p4
	it2 = p5
arg	oscili	   1,2,it2
ar      oscili     giamp, 1000*arg,it1 
out ar
endin


instr 2 ; simple waveguide w waveguide control
        it1 = p4 ; wavetable
        it2 = p5 ; pitch
        it3 = p6 ; amplitude
kpch    oscil     1,2,it3
arg     oscil      1,4*kpch,it2
ar      oscil     giamp, 1000*arg,it1
out ar
endin

instr 3 ; simple waveguide w waveguide control interpolated
        it1 = p4 ; wavetable
        it2 = p5 ; pitch
        it3 = p6 ; amplitude
kpch    oscili     1,2,it3
arg     oscili      1,4*kpch,it2
ar      oscili     giamp, 1000*arg,it1
out ar
endin

instr 4 ; simple waveguide w waveguide control interpolated but lower frequency on everything
        it1 = p4 ; wavetable
        it2 = p5 ; pitch
        it3 = p6 ; amplitude
kpch    oscili     1,1/4,it3
arg     oscili     1,4*kpch,it2
ar      oscili     giamp, 100*arg,it1
out ar
endin




instr 6666
p3 = 1/44100
itable = p4	; table
iindex = p5	; index
tableiw     p6   , iindex, itable, 0, 0, 2
endin
</CsInstruments>
<CsScore>
f 1  0 16 7 0 16
f 2  0 16 7 0 16
f 3  0 16 7 0 16
f 4  0 16 7 0 16
f 5  0 16 7 0 16
f 6  0 16 7 0 16
f 7  0 16 7 0 16
f 8  0 16 7 0 16
f 9  0 16 7 0 16
f 10 0 16 7 0 16
f 11  0 16 7 0 16
f 12  0 16 7 0 16
f 13  0 16 7 0 16
f 14  0 16 7 0 16
f 15  0 16 7 0 16
f 16  0 16 7 0 16
f 17  0 16 7 0 16
f 18  0 16 7 0 16
f 19  0 16 7 0 16
f 20  0 16 7 0 16
f 21  0 16 7 0 16
f 22  0 16 7 0 16
f 23  0 16 7 0 16
f 24  0 16 7 0 16
f 25  0 16 7 0 16
f 26  0 16 7 0 16
f 27  0 16 7 0 16
f 28  0 16 7 0 16
f 29  0 16 7 0 16
f 30  0 16 7 0 16
i2 0 3600 1 2 3
i2 0 3600 4 5 6
i2 0 3600 7 8 9
i2 0 3600 10 11 12
i3 0 3600 13 14 15
i3 0 3600 16 17 18
i3 0 3600 19 20 21
i3 0 3600 22 23 24
i4 0 3600 25 26 27
i4 0 3600 28 29 30
</CsScore>
</CsoundSynthesizer>
