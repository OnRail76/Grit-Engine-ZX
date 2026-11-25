; Blocking beeper: tone B=cycles, C=delay (approximate pitch/duration).
; From GRIT's MIT-licensed engine. Preserve register state.
tone:
 push af
 push bc
 push de
tone_cycle:
 ld a,0x10
 out (0xfe),a
 ld d,c
tone_high:
 dec d
 jp nz,tone_high
 xor a
 out (0xfe),a
 ld d,c
tone_low:
 dec d
 jp nz,tone_low
 djnz tone_cycle
 pop de
 pop bc
 pop af
 ret
fx_fire:
 ld b,12
 ld c,18
 jp tone
fx_hit:
 ld b,40
 ld c,28
 jp tone
fx_damage:
 ld b,55
 ld c,60
 jp tone
