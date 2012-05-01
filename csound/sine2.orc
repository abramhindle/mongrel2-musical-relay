	sr = 44100
	kr = 2205
	ksmps = 20
	nchnls = 1

	instr	1
aamp    adsr (p3*0.1), (p3*0.1), 0.5, (p3*0.1)
a1	oscil	p4, p5, 1
	out	a1*aamp
	endin

