<CsoundSynthesizer>
<CsOptions>
</CsOptions>

<CsInstruments>
sr     = 48000
ksmps  = 100
nchnls = 1

instr  1
;    k1 expseg 0, .04, 1, p3-.29, 0 ;envelope for noise amplitude
;    k1 expseg 0.001, 0.01, 1, p3-(p3/3), 0.001
;    k2 line 555, p3, 425 ;envelope for fofilter frequency peak

    ;a1 noise 1000*k1, 0.1 ;Generate noise
    ; clipping a 51 hz sine results in a nice hum
    a1 oscil 300000, 51, 1

;    a3 fofilter a1, k2, 0.005, 0.08

    ;a4 jspline a3, 0.1, 1.0
;    a2 reverb a1, (p3)

    out a1

endin
</CsInstruments>

<CsScore>
f1 0 4096 10 1
i1 0 1.0
e
</CsScore>
</CsoundSynthesizer>
