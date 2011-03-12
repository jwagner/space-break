<CsoundSynthesizer>
<CsOptions>
</CsOptions>

<CsInstruments>
sr     = 48000
ksmps  = 100
nchnls = 2

instr  1
;    k1 expseg 0, .04, 1, p3-.29, 0 ;envelope for noise amplitude
    k1 expseg 0.001, 0.11, 1, 1.0, 1, p3-(p3/2), 0.001
    k2 line 55, p3, 25 ;envelope for fofilter frequency peak

    a1 noise 1000*k1, 0.9 ;Generate noise
    a3 fofilter a1, k2, 0.015, 0.08

    a4 jspline a3, 0.001, 0.5
;    a4 clip a3, 0, 500, 0.9

    a5 reverb a3, p3*0.5
    a6 compress a5*k1+a4+a5, a1, 0, 40, 60, 3, 0.01, 0.5, 0.02
    a7 lowpass2 a6, 50, 1

    a8 reverb a3, p3*0.7
    a9 compress a5*k1+a4+a5, a1, 0, 40, 60, 3, 0.01, 0.5, 0.02
    a10 lowpass2 a6, 52, 1

    out (a7+a6+a3), (a10+a9+a3)

endin
</CsInstruments>

<CsScore>
f1 0 4096 10 1
i1 0 3.0
e
</CsScore>
</CsoundSynthesizer>
