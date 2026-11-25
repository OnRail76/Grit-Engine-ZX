frame_sync:
 ld hl,0x5c78            ; FRAMES (lo incrementa la interrupcion IM1 de la ROM)
fs_wait:
 ld a,(last_frames)
 ld b,a
 ld a,(sync_need)
 ld c,a
 ld a,(hl)
 sub b
 cp c
 jp nc,fs_done
 halt
 jp fs_wait
fs_done:
 ld a,(hl)
 ld (last_frames),a
 ld a,2
 ld (sync_need),a
 ret
