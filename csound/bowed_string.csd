Bowed String Additive Synth
Jacob Joaquin
March 15, 2010
jacobjoaquin@gmail.com
csound.noisepages.com

<CsoundSynthesizer>
<CsInstruments>
;sr = 44100
;kr = 441
sr=22050
kr=147
ksmps = 150
nchnls = 2
0dbfs = 1.0

; Instruments
# define Synth # 1 #
# define Ssynth # 2 #
# define Sset # 666 #
# define Sbothset # 6666 #

; F-Tables
# define T_Sine # 1 #  ; Sine wave
# define T_Tri  # 2 #  ; Triangle wave
# define T_Amp # 667 #  ; Sine wave
# define T_Pch  # 666 #  ; Triangle wave

; F-tables
gitemp ftgen $T_Sine, 0, 2 ^ 16, 10, 1
gitemp ftgen $T_Tri, 0, 2 ^ 16, -7, -1, 2 ^ 15, 1, 2 ^ 15, -1

opcode Additive_Body, a, kkiiii
    kfreq,        \  ; Frequency
    kmod,         \  ; Frequency modulation
    in_harmonics, \  ; Number of harmonics
    ibody,        \  ; Additive body amplitude table
    ipch_table,   \  ; Additive body tuning table
    i_index       \  ; Index of current harmonic
    xin
    
    ; Frequency for this voice
    kthis_freq = kfreq * (i_index + 1)
    
    ; Apply tuning transfer function
    kcurve expcurve kthis_freq / 22050, 0.5
    kpch tablei kcurve, ipch_table, 1, 0, 0
    kthis_freq = kthis_freq * kpch
    
    ; Frequency modulation
    kthis_freq = kthis_freq + kthis_freq * kmod
    
    ; Amplitude transfer function
    kamp tablei kthis_freq / 22050, ibody, 1, 0, 0

    ; Generate this voice
    a1 oscil 1 / (i_index + 1) * kamp, kthis_freq, $T_Sine, 0

    ; Recursive oscillator
    a2 init 0

    if (i_index < in_harmonics - 1 && i(kthis_freq) < 16000) then
        a2 Additive_Body kfreq, kmod, in_harmonics, ibody, ipch_table, \
                         i_index + 1
    endif

    xout a1 + a2
endop

instr $Synth
    idur = p3          ; Duration
    iamp = p4          ; Amplitude
    ipch = cpspch(p5)  ; Pitch in octave point pitch-class
    ibody = p6         ; Additive body amplitude table
    ipch_table = p7    ; Additive body tuning table
    ipan = p8          ; Pan position
        
    ; Pitch vibrato
    k2 linsegr 0, 0.4, 0, 0.7, 1, 1, 1, 1, 0.3, 0.01, 1
    klfo oscil k2, 4.8 + rnd(0.4), $T_Tri
    krand randh rnd(0.9) + 0.1, 0.125 + rnd(0.25)
    kvibrato = (klfo + krand) * (0.003 +rnd(0.007))
    
    ; Pitch
    kpch linseg 2 ^ (-2 / 12), 0.1, 2 ^ (0 / 12), 0.001, 2 ^ (0 / 12)
    
    ; Generate audio
    a1 Additive_Body ipch, kvibrato + kpch, 32, ibody, ipch_table, 0
    
    ; Amp
    aenv linsegr 0, 0.205, 0.2, 0.1, 0.5, 2, 0.333, 0.2, 0
    asig = a1 * aenv * iamp
    outs asig * sqrt(1 - ipan), asig * sqrt(ipan)
endin
instr $Ssynth
    idur = p3          ; Duration
    iamp = p4          ; Amplitude table
    iampi = p5          ; Amplitude table
    ipch = p6  ; pitch table
    ipchi = p7  ; pitch table index
    ibody = p8         ; Additive body amplitude table
    ipch_table = p9    ; Additive body tuning table
    ipan = p10          ; Pan position
        
    ; Pitch vibrato
    k2 linsegr 0, 0.4, 0, 0.7, 1, 1, 1, 1, 0.3, 0.01, 1
    klfo oscil k2, 4.8 + rnd(0.4), $T_Tri
    krand randh rnd(0.9) + 0.1, 0.125 + rnd(0.25)
    kvibrato = (klfo + krand) * (0.003 +rnd(0.007))
    
    ; Pitch
    kpch linseg 2 ^ (-2 / 12), 0.1, 2 ^ (0 / 12), 0.001, 2 ^ (0 / 12)
    
    kipch	table	   ipchi, ipch
    ; Generate audio
    a1 Additive_Body kipch, kvibrato + kpch, 32, ibody, ipch_table, 0
    
    kiamp	table	   iampi, iamp
    ; Amp
    aenv linsegr 0, 0.205, 0.2, 0.1, 0.5, 2, 0.333, 0.2, 0
    asig = a1 * aenv * kiamp
    outs asig * sqrt(1 - ipan), asig * sqrt(ipan)
endin

instr $Sset
p3 = 1/44100
itable = p4	; table
iindex = p5	; index
tableiw     p6   , iindex, itable, 0, 0, 0 
endin


instr $Sbothset
p3 = 1/44100
iindex = p4	; index
iamp   = p5	; val
ipch   = p6	; val
tableiw     iamp   , iindex, $T_Amp, 0, 0, 0 
tableiw     ipch   , iindex, $T_Pch, 0, 0, 0 
endin
</CsInstruments>
<CsScore>

; Instruments
# define Synth # 1 #
# define T_Amp # 667 #  ; Sine wave
# define T_Pch  # 666 #  ; Triangle wave

t 0 30

; Transfer functions
f 100 0 16 -2 1 1 0 0 1 0 1 0 1 1 1 0 0 0 1 1
f 101 0 [2 ^ 11] 21 3 1
f 102 0 [2 ^ 11] 21 3 1
f 103 0 2 -2 1 1
f 200 0 16 -2 1 0.5 1 1 1 1 1 1 1 1 1.5 1 1 1 2 1
f 201 0 256 -7 1.059 256 1
f 202 0 16 -2 1 1 1.059 1 0.998 1 1 1 1.2 1 1 1 1 1 1 1
f 203 0 16 -2 1 0.999 1.059 1 0.998 1.059 1 0.98 1.2 1 1 1.1 0.98 1 1 1
f 204 0 16 -2 1 0.999 1.001 1 0.998 1.001 1 0.98 1.001 1 1 1 1 1 1 1
f $T_Pch 0 128 7 0 128
f $T_Amp  0 128 7 0 128

 i 666  0 0 667 1 1 ; turn volume up
 i 666  0 0 666 1 240 ; set pitch
 i 666  1 0 666 1 480 ; set pitch
 i 666  2 0 666 1 120 ; set pitch
 i 666  2.5 0 667 1 0.1 ; turn volume down
 
 
 i 666  0 0   667 2 0.2 ; turn volume up
 i 666  0 0   666 2 40 ; set pitch
 i 666  1 0   666 2 80 ; set pitch
 i 666  2 0   666 2 120 ; set pitch
 i 666  2.5 0 667 2 0.1 ; turn volume down
 
 i 666  0 0   667 3 0.3 ; turn volume up
 i 666  0 0   666 3 240 ; set pitch
 i 666  1 0   666 3 280 ; set pitch
 i 666  2 0   666 3 320 ; set pitch
 i 666  2.5 0 667 3 0.1 ; turn volume down
 
 
 i 666  0 0   667 4 0.4 ; turn volume up
 i 666  0 0   666 4 360 ; set pitch
 i 666  1 0   666 4 400 ; set pitch
 i 666  2 0   666 4 440 ; set pitch
 i 666  2.5 0 667 4 0.1 ; turn volume down
 
 
 i 666  0 0   667 5 0.5 ; turn volume up
 i 666  0 0   666 5 20 ; set pitch
 i 666  1 0   666 5 30 ; set pitch
 i 666  2 0   666 5 40 ; set pitch
 i 666  2.5 0 667 5 0.1 ; turn volume down
; 
; i 2 0 3.000 667 1    666 1 102 204 0.25
; i 2 0 3.000 667 2    666 2 102 204 0.25
; i 2 0 3.000 667 3    666 3 102 204 0.25
; i 2 0 3.000 667 4    666 4 102 204 0.25
; i 2 0 3.000 667 5    666 5 102 204 0.25

i 2 0 3600.000 $T_Amp 1    $T_Pch 1  102 204 0.25
i 2 0 3600.000 $T_Amp 2    $T_Pch 2  102 204 0.25
i 2 0 3600.000 $T_Amp 3    $T_Pch 3  102 204 0.25
i 2 0 3600.000 $T_Amp 4    $T_Pch 4  102 204 0.25
i 2 0 3600.000 $T_Amp 5    $T_Pch 5  102 204 0.25
i 2 0 3600.000 $T_Amp 6    $T_Pch 6  102 204 0.25
i 2 0 3600.000 $T_Amp 7    $T_Pch 7  102 204 0.25
i 2 0 3600.000 $T_Amp 8    $T_Pch 8  102 204 0.25
i 2 0 3600.000 $T_Amp 9    $T_Pch 9  102 204 0.25
i 2 0 3600.000 $T_Amp 10   $T_Pch 10 102 204 0.25
i 2 0 3600.000 $T_Amp 11   $T_Pch 11 102 204 0.25
i 2 0 3600.000 $T_Amp 12   $T_Pch 12 102 204 0.25
i 2 0 3600.000 $T_Amp 13   $T_Pch 13 102 204 0.25
i 2 0 3600.000 $T_Amp 14   $T_Pch 14 102 204 0.25
i 2 0 3600.000 $T_Amp 15   $T_Pch 15 102 204 0.25
i 2 0 3600.000 $T_Amp 16   $T_Pch 16 102 204 0.25
i 2 0 3600.000 $T_Amp 17   $T_Pch 17 102 204 0.25
i 2 0 3600.000 $T_Amp 18   $T_Pch 18 102 204 0.25
i 2 0 3600.000 $T_Amp 19   $T_Pch 19 102 204 0.25

i 2 0 3600.000 $T_Amp 20   $T_Pch 10 102 204 0.25
i 2 0 3600.000 $T_Amp 21   $T_Pch 11 102 204 0.25
i 2 0 3600.000 $T_Amp 22   $T_Pch 12 102 204 0.25
i 2 0 3600.000 $T_Amp 23   $T_Pch 13 102 204 0.25
i 2 0 3600.000 $T_Amp 24   $T_Pch 14 102 204 0.25
i 2 0 3600.000 $T_Amp 25   $T_Pch 15 102 204 0.25
i 2 0 3600.000 $T_Amp 26   $T_Pch 16 102 204 0.25
i 2 0 3600.000 $T_Amp 27   $T_Pch 17 102 204 0.25
i 2 0 3600.000 $T_Amp 28   $T_Pch 18 102 204 0.25
i 2 0 3600.000 $T_Amp 29   $T_Pch 19 102 204 0.25


i 2 0 3600.000 $T_Amp 40   $T_Pch 10 102 204 0.25
i 2 0 3600.000 $T_Amp 41   $T_Pch 11 102 204 0.25
i 2 0 3600.000 $T_Amp 42   $T_Pch 12 102 204 0.25
i 2 0 3600.000 $T_Amp 43   $T_Pch 13 102 204 0.25
i 2 0 3600.000 $T_Amp 44   $T_Pch 14 102 204 0.25
i 2 0 3600.000 $T_Amp 45   $T_Pch 15 102 204 0.25
i 2 0 3600.000 $T_Amp 46   $T_Pch 16 102 204 0.25
i 2 0 3600.000 $T_Amp 47   $T_Pch 17 102 204 0.25
i 2 0 3600.000 $T_Amp 48   $T_Pch 18 102 204 0.25
i 2 0 3600.000 $T_Amp 49   $T_Pch 19 102 204 0.25

;i $Synth 0 1.125 1    5.00 102 204 0.25
;i $Synth + .     .    5.03 .   .   .
;i $Synth + .     .    5.07 .   .   .
;i $Synth + .     .    5.09 .   .   .
;i $Synth + .     .    6.00 .   .   .
;i $Synth + .     .    6.03 .   .   .
;i $Synth + 1     0.86 6.07 .   .   .
;i $Synth + .     .    6.09 .   .   .
;i $Synth + .     .    7.00 .   .   .
;i $Synth + .     .    7.03 .   .   .
;i $Synth + .     .    7.07 .   .   .
;i $Synth + .     .    7.09 .   .   .
;i $Synth + .     .    8.00 .   .   .
;i $Synth + .     .    8.03 .   .   .
;i $Synth + .     .    8.07 .   .   .
;i $Synth + .     .    8.09 .   .   .
;i $Synth + .     .    9.00 .   .   .
;i $Synth + 1.25  .    9.03 .   .   .
;i $Synth + 2     .    9.07 .   .   .
;
;i $Synth 0 3 0.75 7.00 101 202 0.75
;i $Synth + . 0.65 .    .    .  .
;i $Synth + . 0.55 .    .    .  .
;i $Synth + . 0.45 .    .    .  .
;i $Synth + . 0.35 .    .    .  .
;i $Synth + 1 1    6.09 .   .   .
;i $Synth + 3 .    7.00 .   .   .
;i $Synth + 1 .    6.10 .   .   .
;i $Synth + 3 .    6.09 .   .   .
;i $Synth + 4 .    6.00 .   .   .

</CsScore>
</CsoundSynthesizer>

