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
      icon = 2
      iwidth = iw
      iheight = ih
      ar4 randh ix/iwidth, 16 * icon
      ar5 randh iy/iheight, 32 * icon
      ar6 randh idist/imaxd, 64 * icon
      ar7 randh ipx/iwidth, 128 * icon
      ar8 randh ipy/iheight, 256 * icon
       
      asum = ar4 + ar5 + ar6 + ar7 + ar8
      ascaled = 8000*asum/8
      out ascaled

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
      kenv     linseg    0, .01, iamp, p3-.02, 1, .01, 0      
      awhite rand   1
      ahigh butterbp awhite, 8000, 1000
      
      out kenv * ahigh

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
      ixc = ix - iw/2
      iyc = iy - ih/2
      icenterd = sqrt( ixc * ixc + iyc * iyc )

      ; 
      kenv     linseg    0, idur, 1
      ab1 oscili    1,  kenv*30*100*icenterd/imaxd, 1
      out iamp*ab1
endin

; i"buzz" 0 5 1000 666 50 50 101 101 200 200
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
      ixc = ix - iw/2
      iyc = iy - ih/2
      icenterd = sqrt( ixc * ixc + iyc * iyc )

      ; low noise
      ab1 oscili    1,  30*100*icenterd/imaxd, 1
      ab2 oscili    1,  60*100*icenterd/imaxd, 1
      ab3 oscili    1,  120*100*icenterd/imaxd, 1
      ab4 oscili    1,  240*100*icenterd/imaxd, 1
      
      out iamp*(ab1+ab2+ab3+ab4)/4 

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

      ; low noise
      ab1 oscili    1,  30, 1
      ab2 oscili    1,  33, 1
      ab3 oscili    1,  39, 1
      ab4 oscili    1,  41, 1
      ab5 oscili    1,  (40+idist), 1
      
      asum = (10+iamp)*(ab1+ab2+ab3+ab4+ab5)/5
      aout distort1 asum, 0.3, 0.6, 0.1, 0.2
      
      out aout
endin

instr None

endin

</CsInstruments>
<CsScore>
f 1 0 8192 10 1
f 0 3600
;
;i"growl" 0 5 1000
;; buzz  5s 5d junk distjunk x y px py width height
;i"buzz" 5 5 1000 666 50 50 101 101 200 200
;;
;i"hiss" 10 5 1000 666 50 50 101 101 200 200
;;
;i"fuzz" 15 5 1000 666 50 50 101 101 200 200
;
</CsScore>
</CsoundSynthesizer>
