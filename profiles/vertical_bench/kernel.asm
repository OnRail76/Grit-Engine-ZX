ORG $6000
band_entry equ $816C
player_y equ $6BB2
e0_y equ $6BB4
e1_y equ $6BB6
e2_y equ $6BB8
e3_y equ $6BBA
s0_y equ $6BBC
s1_y equ $6BBE
s2_y equ $6BC0
s3_y equ $6BC2
entry:
    jp boot
hud_bitmap:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 7,255,255,255,255,255,255,224,7,255,255,255,255,255,255,224,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,128,0,0,0,96,0,0,1,128,0,0,6
    db 96,0,2,1,192,128,0,6,96,0,7,3,193,192,0,6,96,0,7,7,225,192,0,6
    db 96,0,15,135,227,224,0,6,96,0,15,143,243,224,0,6,96,0,31,193,135,240,0,6
    db 96,0,3,1,128,192,0,6,96,0,3,1,128,192,0,6,96,0,3,1,128,192,0,6
    db 96,0,3,1,128,192,0,6,96,0,3,1,128,192,0,6,96,0,3,1,131,192,0,6
    db 96,0,3,129,142,0,0,6,96,0,0,225,240,0,0,6,96,0,0,29,192,0,0,6
    db 96,0,0,7,128,0,0,6,96,0,0,1,128,0,0,6,96,0,0,1,128,0,0,6
    db 96,0,0,1,128,0,0,6,96,0,0,1,128,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,25,125,231,219,100,224,6,96,25,125,231,219,100,224,6,96,29,97,177,27,117,176,6
    db 96,29,97,177,27,117,176,6,96,29,97,177,27,117,176,6,96,29,97,177,27,117,176,6
    db 96,27,121,225,27,109,176,6,96,27,121,225,27,109,176,6,96,27,97,129,27,109,176,6
    db 96,27,97,129,27,109,176,6,96,25,97,129,27,101,176,6,96,25,97,129,27,101,176,6
    db 96,25,125,129,14,100,224,6,96,25,125,129,14,100,224,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,227,227,135,142,0,6,96,0,227,227,135,142,0,6
    db 96,1,176,134,204,27,0,6,96,1,176,134,204,27,0,6,96,1,176,134,204,27,0,6
    db 96,1,176,134,204,27,0,6,96,1,240,135,204,31,0,6,96,1,240,135,204,31,0,6
    db 96,1,176,134,204,27,0,6,96,1,176,134,204,27,0,6,96,1,176,134,204,27,0,6
    db 96,1,176,134,204,27,0,6,96,1,176,134,199,155,0,6,96,1,176,134,199,155,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,40,40,40,40,40,40,6
    db 96,124,124,124,124,124,124,6,96,239,239,239,239,239,239,6,97,195,195,195,195,195,195,134
    db 96,129,129,129,129,129,129,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,3,205,178,249,199,128,6
    db 96,3,109,186,35,108,0,6,96,3,109,186,35,108,0,6,96,3,205,182,35,103,0,6
    db 96,3,13,182,35,97,128,6,96,3,13,178,35,97,128,6,96,3,7,50,33,207,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,7,14,28,56,112,224,6,96,7,14,28,56,112,224,6,96,13,155,54,108,217,176,6
    db 96,13,155,54,108,217,176,6,96,13,155,54,108,217,176,6,96,13,155,54,108,217,176,6
    db 96,13,155,54,108,217,176,6,96,13,155,54,108,217,176,6,96,13,155,54,108,217,176,6
    db 96,13,155,54,108,217,176,6,96,13,155,54,108,217,176,6,96,13,155,54,108,217,176,6
    db 96,7,14,28,56,112,224,6,96,7,14,28,56,112,224,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,40,40,40,40,40,40,6
    db 96,124,124,124,124,124,124,6,96,239,239,239,239,239,239,6,97,195,195,195,195,195,195,134
    db 96,129,129,129,129,129,129,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,54,239,28,120,0,6
    db 96,0,54,77,182,192,0,6,96,0,54,77,182,192,0,6,96,0,54,77,190,112,0,6
    db 96,0,54,77,182,24,0,6,96,0,28,77,182,24,0,6,96,0,8,239,54,240,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,128,1,0,2,0,6
    db 96,0,128,1,0,2,0,6,96,1,192,3,128,7,0,6,96,1,64,2,128,5,0,6
    db 96,3,96,6,192,13,128,6,96,7,112,14,224,29,192,6,96,6,176,13,96,26,192,6
    db 96,2,32,4,64,8,128,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,40,40,40,40,40,40,6,96,124,124,124,124,124,124,6,96,239,239,239,239,239,239,6
    db 97,195,195,195,195,195,195,134,96,129,129,129,129,129,129,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,1,243,143,124,4,0,6,96,1,134,216,96,12,0,6,96,1,134,216,96,4,0,6
    db 96,1,231,206,120,4,0,6,96,1,134,195,96,4,0,6,96,1,134,195,96,4,0,6
    db 96,1,134,222,124,14,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6,96,0,0,0,0,0,0,6
    db 96,0,0,0,0,0,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,7,255,255,255,255,255,255,224,7,255,255,255,255,255,255,224
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
hud_attrs:
    db 67,67,67,67,67,67,67,67,67,70,70,70,70,70,70,67,67,70,70,70,70,70,70,67
    db 67,70,70,70,70,70,70,67,67,69,69,69,69,69,69,67,67,69,69,69,69,69,69,67
    db 67,66,66,66,66,66,66,67,67,66,66,66,66,66,66,67,67,69,69,69,69,69,69,67
    db 67,71,71,71,71,71,71,67,67,70,70,70,70,70,70,67,67,71,71,71,71,71,71,67
    db 67,71,71,71,71,71,71,67,67,71,71,71,71,71,71,67,67,69,69,69,69,69,69,67
    db 67,71,71,71,71,71,71,67,67,70,70,70,70,70,70,67,67,71,71,71,71,71,71,67
    db 67,71,71,71,71,71,71,67,67,69,69,69,69,69,69,67,67,71,71,71,71,71,71,67
    db 67,70,70,70,70,70,70,67,67,71,71,71,71,71,71,67,67,67,67,67,67,67,67,67
rowptr:
    db 0,144,24,144,48,144,72,144,96,144,120,144,144,144,168,144,192,144,216,144,240,144,8,145
    db 32,145,56,145,80,145,104,145,128,145,152,145,176,145,200,145,224,145,248,145,16,146,40,146
    db 64,146,88,146,112,146,136,146,160,146,184,146,208,146,232,146,0,147,24,147,48,147,72,147
    db 96,147,120,147,144,147,168,147,192,147,216,147,240,147,8,148,32,148,56,148,80,148,104,148
    db 128,148,152,148,176,148,200,148,224,148,248,148,16,149,40,149,64,149,88,149,112,149,136,149
    db 160,149,184,149,208,149,232,149,0,150,24,150,48,150,72,150,96,150,120,150,144,150,168,150
    db 192,150,216,150,240,150,8,151,32,151,56,151,80,151,104,151,128,151,152,151,176,151,200,151
    db 224,151,248,151,16,152,40,152,64,152,88,152,112,152,136,152,160,152,184,152,208,152,232,152
    db 0,153,24,153,48,153,72,153,96,153,120,153,144,153,168,153,192,153,216,153,240,153,8,154
    db 32,154,56,154,80,154,104,154,128,154,152,154,176,154,200,154,224,154,248,154,16,155,40,155
    db 64,155,88,155,112,155,136,155,160,155,184,155,208,155,232,155,0,156,24,156,48,156,72,156
    db 96,156,120,156,144,156,168,156,192,156,216,156,240,156,8,157,32,157,56,157,80,157,104,157
    db 128,157,152,157,176,157,200,157,224,157,248,157,16,158,40,158,64,158,88,158,112,158,136,158
    db 160,158,184,158,208,158,232,158,0,159,24,159,48,159,72,159,96,159,120,159,144,159,168,159
    db 192,159,216,159,240,159,8,160,32,160,56,160,80,160,104,160,128,160,152,160,176,160,200,160
    db 224,160,248,160,16,161,40,161,64,161,88,161,112,161,136,161,160,161,184,161,208,161,232,161
screen_lut:
    db 0,64,0,65,0,66,0,67,0,68,0,69,0,70,0,71,32,64,32,65,32,66,32,67
    db 32,68,32,69,32,70,32,71,64,64,64,65,64,66,64,67,64,68,64,69,64,70,64,71
    db 96,64,96,65,96,66,96,67,96,68,96,69,96,70,96,71,128,64,128,65,128,66,128,67
    db 128,68,128,69,128,70,128,71,160,64,160,65,160,66,160,67,160,68,160,69,160,70,160,71
    db 192,64,192,65,192,66,192,67,192,68,192,69,192,70,192,71,224,64,224,65,224,66,224,67
    db 224,68,224,69,224,70,224,71,0,72,0,73,0,74,0,75,0,76,0,77,0,78,0,79
    db 32,72,32,73,32,74,32,75,32,76,32,77,32,78,32,79,64,72,64,73,64,74,64,75
    db 64,76,64,77,64,78,64,79,96,72,96,73,96,74,96,75,96,76,96,77,96,78,96,79
    db 128,72,128,73,128,74,128,75,128,76,128,77,128,78,128,79,160,72,160,73,160,74,160,75
    db 160,76,160,77,160,78,160,79,192,72,192,73,192,74,192,75,192,76,192,77,192,78,192,79
    db 224,72,224,73,224,74,224,75,224,76,224,77,224,78,224,79,0,80,0,81,0,82,0,83
    db 0,84,0,85,0,86,0,87,32,80,32,81,32,82,32,83,32,84,32,85,32,86,32,87
    db 64,80,64,81,64,82,64,83,64,84,64,85,64,86,64,87,96,80,96,81,96,82,96,83
    db 96,84,96,85,96,86,96,87,128,80,128,81,128,82,128,83,128,84,128,85,128,86,128,87
    db 160,80,160,81,160,82,160,83,160,84,160,85,160,86,160,87,192,80,192,81,192,82,192,83
    db 192,84,192,85,192,86,192,87,224,80,224,81,224,82,224,83,224,84,224,85,224,86,224,87
top_links:
    db 5,162,53,162,101,162,149,162,197,162,245,162,37,163,85,163,133,163,181,163,229,163,21,164
    db 69,164,117,164,165,164,213,164,5,165,53,165,101,165,149,165,197,165,245,165,37,166,85,166
    db 133,166,181,166,229,166,21,167,69,167,117,167,165,167,213,167,5,168,53,168,101,168,149,168
    db 197,168,245,168,37,169,85,169,133,169,181,169,229,169,21,170,69,170,117,170,165,170,213,170
    db 5,171,53,171,101,171,149,171,197,171,245,171,37,172,85,172,133,172,181,172,229,172,21,173
    db 69,173,117,173,165,173,213,173,5,174,53,174,101,174,149,174,197,174,245,174,37,175,85,175
    db 133,175,181,175,229,175,21,176,69,176,117,176,165,176,213,176,5,177,53,177,101,177,149,177
    db 197,177,245,177,37,178,85,178,133,178,181,178,229,178,21,179,69,179,117,179,165,179,213,179
bottom_links:
    db 14,180,62,180,110,180,158,180,206,180,254,180,46,181,94,181,142,181,190,181,238,181,30,182
    db 78,182,126,182,174,182,222,182,14,183,62,183,110,183,158,183,206,183,254,183,46,184,94,184
    db 142,184,190,184,238,184,30,185,78,185,126,185,174,185,222,185,14,186,62,186,110,186,158,186
    db 206,186,254,186,46,187,94,187,142,187,190,187,238,187,30,188,78,188,126,188,174,188,222,188
    db 14,189,62,189,110,189,158,189,206,189,254,189,46,190,94,190,142,190,190,190,238,190,30,191
    db 78,191,126,191,174,191,222,191,14,192,62,192,110,192,158,192,206,192,254,192,46,193,94,193
    db 142,193,190,193,238,193,30,194,78,194,126,194,174,194,222,194,14,195,62,195,110,195,158,195
    db 206,195,254,195,46,196,94,196,142,196,190,196,238,196,30,197,78,197,126,197,174,197,222,197
ship_ptr:
    db 0,241,96,241,192,241,32,242,128,242,224,242,64,243,160,243
drone_ptr:
    db 0,244,48,244,96,244,144,244,192,244,240,244,32,245,80,245
fighter_ptr:
    db 128,245,176,245,224,245,16,246,64,246,112,246,160,246,208,246
bullet_ptr:
    db 0,247,12,247,24,247,36,247,48,247,60,247,72,247,84,247
blank_ptr:
    db 96,247,108,247,120,247,132,247,144,247,156,247,168,247,180,247
head:
    db 0
world_y:
    db 0
tick:
    db 0
dx:
    db 0
dy:
    db 0
fire:
    db 0
joymode:
    db 0
joyraw:
    db 0
cool:
    db 0
sound:
    db 0
bandrow:
    db 0
patch_on:
    db 0
draw_h:
    db 0
phase_error:
    db 0
saved_sp:
    db 0,0
patch_addr:
    db 0,0
patch_value:
    db 0,0
band_table:
    db 0,0
src_start:
    db 0,0
sprite_table:
    db 0,0
sprite_data:
    db 0,0
tmp_ptr:
    db 0,0
player:
    db 88,152
e0:
    db 36,16
e1:
    db 72,48
e2:
    db 112,80
e3:
    db 144,112
s0:
    db 0,255
s1:
    db 0,255
s2:
    db 0,255
s3:
    db 0,255
old_player:
    db 0,255
old_e0:
    db 0,255
old_e1:
    db 0,255
old_e2:
    db 0,255
old_e3:
    db 0,255
old_s0:
    db 0,255
old_s1:
    db 0,255
old_s2:
    db 0,255
old_s3:
    db 0,255
    defs 4651,0
im2_vectors:
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    db 142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142,142
    defs 255,0
boot:
    di
    ld sp,$9000
    im 1
    ld iy,$5c3a
    ei
    call load_level
    jp nc,load_failed
    call init_level
    jp main
load_failed:
    ld a,2
    out ($fe),a
    halt
    jp load_failed
load_level:
    di
    im 1
    ld iy,$5c3a
    ei
    ld ix,$a200
    ld de,24064
    ld a,255
    scf
    call $0556
    di
    push af
    ld a,126
    ld i,a
    im 2
    pop af
    ei
    ret 
init_level:
    di
    xor a
    out ($fe),a
    ld hl,hud_bitmap
    ld (tmp_ptr),hl
    ld hl,screen_lut
    ld (sprite_table),hl
    ld b,192
hud_loop:
    push bc
    ld hl,(sprite_table)
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
    ld (sprite_table),hl
    ex de,hl
    ld de,24
    add hl,de
    ex de,hl
    ld hl,(tmp_ptr)
    ld bc,8
    ldir
    ld (tmp_ptr),hl
    pop bc
    dec b
    jp nz,hud_loop
    ld hl,22528
    ld de,hud_attrs
    ld b,24
attrrow:
    push bc
    ld b,24
attrleft:
    ld (hl),69
    inc hl
    dec b
    jp nz,attrleft
    ld b,8
attrright:
    ld a,(de)
    ld (hl),a
    inc de
    inc hl
    dec b
    jp nz,attrright
    pop bc
    dec b
    jp nz,attrrow
    ld hl,55552
    ld de,36864
    ld bc,4608
    ldir
    ld hl,36864
    ld de,50944
    ld bc,4608
    ldir
    xor a
    ld (head),a
    ld a,0
    ld (world_y),a
    call draw_snapshot
    call blit_top
    call blit_bottom
    call restore_snapshot
    ei
    ret 
main:
    halt
    call keys
    call logic
    call draw_snapshot
    call top_delay
    call blit_top
    halt
    call blit_bottom
    call keys
    call logic
    call restore_snapshot
    call scroll_one
    jp main
top_delay:
    ld bc,80
delay_loop:
    dec bc
    ld a,b
    or c
    jp nz,delay_loop
    ret 
blit_top:
    ld a,(head)
    ld hl,top_links
    ld de,41472
    jp blit_setup
blit_bottom:
    ld a,(head)
    add a,96
    jp c,bottom_carry
    cp 192
    jp c,bottom_ok
    sub 192
    jp bottom_ok
bottom_carry:
    add a,64
bottom_ok:
    ld hl,bottom_links
    ld de,46089
blit_setup:
    ld (bandrow),a
    ld (band_table),hl
    ex de,hl
    ld (band_entry),hl
    ld l,a
    ld h,0
    add hl,hl
    ld de,rowptr
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld hl,(band_table)
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld (hl),e
    inc hl
    ld (hl),d
    xor a
    ld (patch_on),a
    ld a,(bandrow)
    cp 97
    jp c,blit_go
    ld c,a
    ld a,192
    sub c
    ld l,a
    ld h,0
    add hl,hl
    ld de,(band_table)
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    ld (patch_value),hl
    ld (hl),0
    inc hl
    ld (hl),144
    dec hl
    ld de,65523
    add hl,de
    ld (patch_addr),hl
    ld de,saved_sp_sink
    ld (hl),e
    inc hl
    ld (hl),d
    ld a,1
    ld (patch_on),a
blit_go:
    di
band_call:
    call $A200
    ei
    ld a,(patch_on)
    or a
    ret z
    ld hl,(patch_addr)
    ld de,(patch_value)
    ld (hl),e
    inc hl
    ld (hl),d
    ret 
keys:
    xor a
    ld (dx),a
    ld (dy),a
    ld (fire),a
    ld bc,64510
    in a,(c)
    bit 0,a
    jp nz,kq
    ld a,255
    ld (dy),a
kq:
    ld bc,65022
    in a,(c)
    bit 0,a
    jp nz,ka
    ld a,1
    ld (dy),a
ka:
    ld bc,57342
    in a,(c)
    bit 1,a
    jp nz,ko
    ld a,255
    ld (dx),a
ko:
    in a,(c)
    bit 0,a
    jp nz,kp
    ld a,1
    ld (dx),a
kp:
    ld bc,32766
    in a,(c)
    bit 0,a
    jp nz,ks
    ld a,1
    ld (fire),a
ks:
    ld bc,31
    in a,(c)
    ld b,a
    and 224
    ret nz
    ld a,b
    ld (joyraw),a
    bit 4,a
    jp z,kj
    ld a,1
    ld (joymode),a
kj:
    ld a,(joymode)
    or a
    ret z
    ld a,(joyraw)
    bit 0,a
    jp z,kj1
    ld a,1
    ld (dx),a
kj1:
    ld a,(joyraw)
    bit 1,a
    jp z,kj2
    ld a,255
    ld (dx),a
kj2:
    ld a,(joyraw)
    bit 2,a
    jp z,kj3
    ld a,1
    ld (dy),a
kj3:
    ld a,(joyraw)
    bit 3,a
    jp z,kj4
    ld a,255
    ld (dy),a
kj4:
    ld a,(joyraw)
    bit 4,a
    ret z
    ld a,1
    ld (fire),a
    ret 
logic:
    ld a,(tick)
    inc a
    ld (tick),a
    ld a,(dx)
    ld b,a
    ld a,(player)
    add a,b
    cp 169
    jp nc,mx
    ld (player),a
mx:
    ld a,(dy)
    ld b,a
    ld a,(player_y)
    add a,b
    cp 177
    jp nc,my
    ld (player_y),a
my:
    ld a,(e0_y)
    inc a
    cp 177
    jp c,e0_yy
    xor a
e0_yy:
    ld (e0_y),a
    ld a,(tick)
    add a,0
    and 31
    cp 16
    jp c,e0_xx
    ld b,a
    ld a,31
    sub b
e0_xx:
    add a,36
    ld (e0),a
    ld a,(e1_y)
    inc a
    cp 177
    jp c,e1_yy
    xor a
e1_yy:
    ld (e1_y),a
    ld a,(tick)
    add a,16
    and 31
    cp 16
    jp c,e1_xx
    ld b,a
    ld a,31
    sub b
e1_xx:
    add a,72
    ld (e1),a
    ld a,(e2_y)
    inc a
    cp 177
    jp c,e2_yy
    xor a
e2_yy:
    ld (e2_y),a
    ld a,(tick)
    add a,32
    and 31
    cp 16
    jp c,e2_xx
    ld b,a
    ld a,31
    sub b
e2_xx:
    add a,112
    ld (e2),a
    ld a,(e3_y)
    inc a
    cp 177
    jp c,e3_yy
    xor a
e3_yy:
    ld (e3_y),a
    ld a,(tick)
    add a,48
    and 31
    cp 16
    jp c,e3_xx
    ld b,a
    ld a,31
    sub b
e3_xx:
    add a,144
    ld (e3),a
    ld a,(s0_y)
    cp 255
    jp z,s0_skip
    cp 4
    jp nc,s0_move
    ld a,255
    jp s0_store
s0_move:
    sub 4
s0_store:
    ld (s0_y),a
s0_skip:
    ld a,(s1_y)
    cp 255
    jp z,s1_skip
    cp 4
    jp nc,s1_move
    ld a,255
    jp s1_store
s1_move:
    sub 4
s1_store:
    ld (s1_y),a
s1_skip:
    ld a,(s2_y)
    cp 255
    jp z,s2_skip
    cp 4
    jp nc,s2_move
    ld a,255
    jp s2_store
s2_move:
    sub 4
s2_store:
    ld (s2_y),a
s2_skip:
    ld a,(s3_y)
    cp 255
    jp z,s3_skip
    cp 4
    jp nc,s3_move
    ld a,255
    jp s3_store
s3_move:
    sub 4
s3_store:
    ld (s3_y),a
s3_skip:
    ld a,(cool)
    or a
    jp z,tryfire
    dec a
    ld (cool),a
    ret 
tryfire:
    ld a,(fire)
    or a
    ret z
    ld a,(player_y)
    cp 4
    ret c
    ld a,(s0_y)
    cp 255
    jp z,spawn0
    ld a,(s1_y)
    cp 255
    jp z,spawn1
    ld a,(s2_y)
    cp 255
    jp z,spawn2
    ld a,(s3_y)
    cp 255
    jp z,spawn3
    ret 
spawn0:
    ld a,(player)
    add a,7
    ld (s0),a
    ld a,(player_y)
    sub 4
    ld (s0_y),a
    ld a,7
    ld (cool),a
    call beep
    ret 
spawn1:
    ld a,(player)
    add a,7
    ld (s1),a
    ld a,(player_y)
    sub 4
    ld (s1_y),a
    ld a,7
    ld (cool),a
    call beep
    ret 
spawn2:
    ld a,(player)
    add a,7
    ld (s2),a
    ld a,(player_y)
    sub 4
    ld (s2_y),a
    ld a,7
    ld (cool),a
    call beep
    ret 
spawn3:
    ld a,(player)
    add a,7
    ld (s3),a
    ld a,(player_y)
    sub 4
    ld (s3_y),a
    ld a,7
    ld (cool),a
    call beep
    ret 
beep:
    ld b,3
beep_loop:
    ld a,16
    out ($fe),a
    ld c,24
beep_high:
    dec c
    jp nz,beep_high
    xor a
    out ($fe),a
    ld c,24
beep_low:
    dec c
    jp nz,beep_low
    dec b
    jp nz,beep_loop
    ret 
ring_addr:
    ld a,(head)
    add a,b
    jp c,ring_carry
    cp 192
    jp c,ring_ok
    sub 192
    jp ring_ok
ring_carry:
    add a,64
ring_ok:
    ld l,a
    ld h,0
    add hl,hl
    ld de,rowptr
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    ld a,c
    rrca
    rrca
    rrca
    and 31
    ld e,a
    ld d,0
    add hl,de
    ret 
draw_snapshot:
    ld bc,(player)
    ld hl,ship_ptr
    ld a,16
    call draw_mask
    ld bc,(e0)
    ld hl,drone_ptr
    ld a,16
    call draw_or
    ld bc,(e1)
    ld hl,fighter_ptr
    ld a,16
    call draw_or
    ld bc,(e2)
    ld hl,drone_ptr
    ld a,16
    call draw_or
    ld bc,(e3)
    ld hl,fighter_ptr
    ld a,16
    call draw_or
    ld bc,(s0)
    ld hl,bullet_ptr
    ld a,4
    call draw_or
    ld bc,(s1)
    ld hl,bullet_ptr
    ld a,4
    call draw_or
    ld bc,(s2)
    ld hl,bullet_ptr
    ld a,4
    call draw_or
    ld bc,(s3)
    ld hl,bullet_ptr
    ld a,4
    call draw_or
    ld hl,player
    ld de,old_player
    ld bc,18
    ldir
    ret 
draw_mask:
    ld (draw_h),a
    call sprite_setup
    ret c
    ld a,(draw_h)
    ld b,a
maskrow:
    ld a,(de)
    and (hl)
    inc de
    ld c,a
    ld a,(de)
    or c
    ld (hl),a
    inc de
    inc hl
    ld a,(de)
    and (hl)
    inc de
    ld c,a
    ld a,(de)
    or c
    ld (hl),a
    inc de
    inc hl
    ld a,(de)
    and (hl)
    inc de
    ld c,a
    ld a,(de)
    or c
    ld (hl),a
    inc de
    inc hl
    call next_row
    dec b
    jp nz,maskrow
    ret 
draw_or:
    ld (draw_h),a
    call sprite_setup
    ret c
    ld a,(draw_h)
    ld b,a
orrow:
    ld a,(de)
    or (hl)
    ld (hl),a
    inc de
    inc hl
    ld a,(de)
    or (hl)
    ld (hl),a
    inc de
    inc hl
    ld a,(de)
    or (hl)
    ld (hl),a
    inc de
    inc hl
    call next_row
    dec b
    jp nz,orrow
    ret 
sprite_setup:
    ld a,b
    cp 192
    jp nc,sprite_inactive
    ld a,c
    and 7
    add a,a
    ld e,a
    ld d,0
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    push de
    call ring_addr
    pop de
    or a
    ret 
sprite_inactive:
    scf
    ret 
next_row:
    ld a,l
    add a,21
    ld l,a
    jp nc,next_noc
    inc h
next_noc:
    ld a,h
    cp 162
    ret c
    ld h,144
    ret 
restore_snapshot:
    ld bc,(old_player)
    ld a,16
    call restore_rect
    ld bc,(old_e0)
    ld a,16
    call restore_rect
    ld bc,(old_e1)
    ld a,16
    call restore_rect
    ld bc,(old_e2)
    ld a,16
    call restore_rect
    ld bc,(old_e3)
    ld a,16
    call restore_rect
    ld bc,(old_s0)
    ld a,4
    call restore_rect
    ld bc,(old_s1)
    ld a,4
    call restore_rect
    ld bc,(old_s2)
    ld a,4
    call restore_rect
    ld bc,(old_s3)
    ld a,4
    call restore_rect
    ret 
restore_rect:
    ld (draw_h),a
    ld a,b
    cp 192
    ret nc
    call ring_addr
    ld e,l
    ld a,h
    add a,55
    ld d,a
    ld a,(draw_h)
    ld b,a
restore_row:
    ld a,(de)
    ld (hl),a
    inc de
    inc hl
    ld a,(de)
    ld (hl),a
    inc de
    inc hl
    ld a,(de)
    ld (hl),a
    inc de
    inc hl
    call next_row
    ld e,l
    ld a,h
    add a,55
    ld d,a
    dec b
    jp nz,restore_row
    ret 
scroll_one:
    ld a,(head)
    or a
    jp nz,scroll_nz
    ld a,192
scroll_nz:
    dec a
    ld (head),a
    ld l,a
    ld h,0
    add hl,hl
    ld de,rowptr
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (src_start),de
    ld a,(world_y)
    dec a
    ld (world_y),a
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    push hl
    add hl,hl
    pop de
    add hl,de
    ld de,55552
    add hl,de
    ld de,(src_start)
    push hl
    push de
    ld bc,24
    ldir
    pop hl
    pop de
    ex de,hl
    ld a,d
    add a,55
    ld d,a
    ld bc,24
    ldir
    ret 
    defs 2238,0
isr:
    ei
    reti
    defs 111,0
saved_sp_sink:
sink:
    db 0,0
    defs 254,0