; QAOP + SPACE, half rows direct port reads. Active LOW.
; Set move_dx/move_dy to 0 or 1 or 255, fire_down to 0 or 1.
keys_poll:
 xor a
 ld (move_dx),a
 ld (move_dy),a
 ld (fire_down),a
 ld bc,0xfbfe
 in a,(c)
 bit 0,a
 jp nz,key_no_q
 ld a,255
 ld (move_dy),a
key_no_q:
 ld bc,0xfdfe
 in a,(c)
 bit 0,a
 jp nz,key_no_a
 ld a,1
 ld (move_dy),a
key_no_a:
 ld bc,0xdffe
 in a,(c)
 bit 1,a
 jp nz,key_no_o
 ld a,255
 ld (move_dx),a
key_no_o:
 in a,(c)
 bit 0,a
 jp nz,key_no_p
 ld a,1
 ld (move_dx),a
key_no_p:
 ld bc,0x7ffe
 in a,(c)
 bit 0,a
 ret nz
 ld a,1
 ld (fire_down),a
 ret
; Synchronise new SPACE press without reusing held input from prior screen.
space_release:
 ld bc,0x7ffe
space_release_wait:
 halt
 in a,(c)
 bit 0,a
 jp z,space_release_wait
 ret
space_press:
 ld bc,0x7ffe
space_press_wait:
 halt
 in a,(c)
 bit 0,a
 jp nz,space_press_wait
 ret
