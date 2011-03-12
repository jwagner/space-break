<CsoundSynthesizer>
<CsOptions>
</CsOptions>

<CsInstruments>
sr     = 48000
ksmps  = 100
nchnls = 1

instr  1
    idelay = p3*0.2
;    k1 expseg 0, .04, 1, p3-.29, 0 ;envelope for noise amplitude
    k1 expseg 0.001, 0.01, 1, p3*0.1, 0.001
    k2 line 555, p3, 425 ;envelope for fofilter frequency peak

    ;a1 noise 1000*k1, 0.1 ;Generate noise
    a1 oscil 50*k1, 440, 1

    a3 fofilter a1, k2, 0.005, 0.08

    ;a4 jspline a3, 0.1, 1.0
    a5 reverb a3, p3*0.8
    ;a5 delay a5, 0.05
    out a5*3

endin
</CsInstruments>

<CsScore>
f1 0 4096 10 1
i1 0 1.0
e
</CsScore>
</CsoundSynthesizer>
