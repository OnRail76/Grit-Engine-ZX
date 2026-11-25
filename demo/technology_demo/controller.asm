ORG $793E
vertical_entry:
    di
    ld sp,$9000
    ld a,(40571)
    ld (26571),a
    ld hl,36412
    ld (36495),hl
    ld hl,25605
    ld (lut_ptr),hl
    ld de,41472
    call make_band
    call make_band
    ld a,127
    ld i,a
    im 2
    xor a
    ld (31033),a
    ld (31037),a
    ld (36350),a
    ld (26574),a
    ld (26578),a
    out ($fe),a
    ld (26665),a
    ld (26666),a
    ld (26667),a
    ld (26668),a
    ld (26669),a
    ld (26670),a
    ld a,3
    ld (26651),a
    call v_init_level
    jp v_main
boot_once:
    di
    ld sp,$8fe0
    ld hl,36864
    ld de,23296
    ld bc,1280
    ldir
    jp menu_restore
menu_restore:
    di
    ld sp,$8fe0
    xor a
    out ($fe),a
    ld hl,22528
    ld (hl),0
    ld de,22529
    ld bc,767
    ldir
    ld de,16384
    ld hl,23296
    ld bc,1280
    ldir
    ld hl,30081
    ld bc,952
    ldir
    ld hl,31866
    ld bc,17
    ldir
    ld hl,31940
    ld bc,189
    ldir
    ld hl,32249
    ld bc,119
    ldir
    ld hl,36498
    ld bc,110
    ldir
    ld hl,50856
    ld bc,88
    ldir
    ld hl,64480
    ld bc,416
    ldir
    ld hl,63808
    ld bc,288
    ldir
    ld hl,64992
    ld bc,192
    ldir
    ld hl,65280
    ld bc,23
    ldir
    ld hl,16384
    ld de,36864
    call decode
    ld hl,25605
    ld de,42353
    ld b,24
lut_row:
    push bc
    push hl
    ld c,(hl)
    inc hl
    ld b,(hl)
    ld a,24
lut_col:
    push af
    ld a,c
    ld (de),a
    inc de
    ld a,b
    ld (de),a
    inc de
    inc bc
    pop af
    dec a
    jp nz,lut_col
    pop hl
    ld bc,16
    add hl,bc
    pop bc
    dec b
    jp nz,lut_row
    ld hl,menu_irq
    ld (36495),hl
    xor a
    ld (36497),a
    ld a,127
    ld i,a
    im 2
    jp menu_entry
menu_irq:
    push af
    push hl
    ld hl,36497
    inc (hl)
    pop hl
    pop af
    ei
    reti
keys_x:
    ld bc,65278
    in a,(c)
    bit 2,a
    jp z,menu_restore
    jp v_keys
decode:
    ld a,(hl)
    inc hl
    or a
    ret z
    bit 7,a
    jp nz,match
    ld c,a
    ld b,0
    ldir
    jp decode
match:
    push af
    bit 6,a
    jp nz,long_match
    ld c,(hl)
    inc hl
    ld b,0
    inc bc
    jp match_copy
long_match:
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl
match_copy:
    push hl
    push de
    pop hl
    or a
    sbc hl,bc
    pop bc
    pop af
    push bc
    and 63
    add a,3
    ld c,a
    ld b,0
    ldir
    pop hl
    jp decode
make_band:
    ld hl,band_head
    ld bc,4
    ldir
    ld a,96
    ld (row_count),a
band_row:
    ld hl,(lut_ptr)
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl
    ld (lut_ptr),hl
    ld h,b
    ld l,c
    ld (vram_ptr),hl
    ld a,2
    ld (group_count),a
band_group:
    push de
    ld hl,group_template
    ld bc,24
    ldir
    pop hl
    push de
    ld bc,12
    add hl,bc
    push hl
    ld a,(row_count)
    cp 1
    jp nz,chain_next
    ld a,(group_count)
    cp 1
    jp nz,chain_next
    ld hl,36608
    jp chain_target
chain_next:
    ld h,d
    ld l,e
    inc hl
chain_target:
    ld b,h
    ld c,l
    pop hl
    ld (hl),c
    inc hl
    ld (hl),b
    inc hl
    inc hl
    push hl
    ld hl,(vram_ptr)
    ld bc,12
    add hl,bc
    ld (vram_ptr),hl
    ld b,h
    ld c,l
    pop hl
    ld (hl),c
    inc hl
    ld (hl),b
    pop de
    ld a,(group_count)
    dec a
    ld (group_count),a
    jp nz,band_group
    ld a,(row_count)
    dec a
    ld (row_count),a
    jp nz,band_row
    ld hl,band_tail
    ld bc,5
    ldir
    ret 
band_head:
    db 237,115,211,103
group_template:
    db 49,0,0,193,209,225,217,193,209,225,237,115,29,162,49,12,64,229,213,197,217,229,213,197
band_tail:
    db 237,123,211,103,201
row_count:
    db 0
group_count:
    db 0
lut_ptr:
    db 0,0
vram_ptr:
    db 0,0
