      	sr = 22050      
	kr = 2205       
	ksmps = 10
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
