<CsoundSynthesizer>
<CsInstruments>
sr = 44100
kr = 441
ksmps = 100
nchnls = 1
0dbfs = 1.0

instr fuzz
      idur  = p3  ; Duration
      iamp  = p4  ; Amplitude
      idist = p5  ; distance
      ix    = p6  ; X coord
      iy    = p7  ; Y coord
      ipx   = p8  ; old-X coord
      ipy   = p9  ; old-Y coord
      iw    = p10 ; width
      ih    = p11 ; height
      imaxd = sqrt(iw * iw + ih * ih) 

      ; pink noise filtered?

endin

instr hiss
      idur  = p3  ; Duration
      iamp  = p4  ; Amplitude
      idist = p5  ; distance
      ix    = p6  ; X coord
      iy    = p7  ; Y coord
      ipx   = p8  ; old-X coord
      ipy   = p9  ; old-Y coord
      iw    = p10 ; width
      ih    = p11 ; height
      imaxd = sqrt(iw * iw + ih * ih) 

      ; white noise bandpass filtered 

endin

instr squawk
      idur  = p3  ; Duration
      iamp  = p4  ; Amplitude
      idist = p5  ; distance
      ix    = p6  ; X coord
      iy    = p7  ; Y coord
      ipx   = p8  ; old-X coord
      ipy   = p9  ; old-Y coord
      iw    = p10 ; width
      ih    = p11 ; height
      imaxd = sqrt(iw * iw + ih * ih) 
      ; 

endin

instr buzz
      idur  = p3  ; Duration
      iamp  = p4  ; Amplitude
      idist = p5  ; distance
      ix    = p6  ; X coord
      iy    = p7  ; Y coord
      ipx   = p8  ; old-X coord
      ipy   = p9  ; old-Y coord
      iw    = p10 ; width
      ih    = p11 ; height
      imaxd = sqrt(iw * iw + ih * ih) 

      ; low noise

endin

instr growl
      idur  = p3  ; Duration
      iamp  = p4  ; Amplitude
      idist = p5  ; distance
      ix    = p6  ; X coord
      iy    = p7  ; Y coord
      ipx   = p8  ; old-X coord
      ipy   = p9  ; old-Y coord
      iw    = p10 ; width
      ih    = p11 ; height
      imaxd = sqrt(iw * iw + ih * ih) 

      ; low noise with distortion and harmonics?

endin
