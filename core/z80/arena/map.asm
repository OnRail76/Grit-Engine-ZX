; Runtime 24x24 map, in 24 lines, 32-byte stride; 24..31 reserved for HUD.
; Read A=tile index at D(row),E(col), no bounds checks. Preserves DE.
map_address:
 ld l,d
 ld h,0
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 add hl,hl
 ld bc,map_data
 add hl,bc
 ld c,e
 ld b,0
 add hl,bc
 ret
map_get:
 ld a,d
 cp 24
 jp nc,map_get_default
 ld a,e
 cp 24
 jp nc,map_get_default
 push hl
 call map_address
 ld a,(hl)
 pop hl
 ret
map_get_default:
 xor a                  ; benign 0 for forbidden map read; solidity guarded separately
 ret
; Writes map_data cell in A, D/E; caller must repaint via tile_draw.
map_set:
 push af
 ld a,d
 cp 24
 jp nc,map_set_reject
 ld a,e
 cp 24
 jp nc,map_set_reject
 pop af
 push hl
 call map_address
 ld (hl),a
 pop hl
 ret
map_set_reject:
 pop af
 ret
; Return A=0 for passable, 1 for solid.
map_is_solid:
 ld a,d
 cp 24
 jp nc,map_solid_invalid
 ld a,e
 cp 24
 jp nc,map_solid_invalid
 push bc
 push hl
 call map_get
 ld l,a
 ld h,0
 ld bc,tile_solid_flags
 add hl,bc
 ld a,(hl)
 pop hl
 pop bc
 ret
map_solid_invalid:
 ld a,1               ; outside the playfield is always impassable
 ret
; Initialise map from 24x24 packed byte map into 32-byte-stride array.
map_load:
 ld de,map_data
 ld hl,level_map
 ld a,24
map_load_row:
 push af
 ld bc,24
 ldir
 push hl
 ld hl,8
 add hl,de
 ex de,hl
 pop hl
 pop af
 dec a
 jp nz,map_load_row
 ret
; Draw 24x24 map into the shadow RAM (not live VRAM).
map_draw:
 ld d,0
map_draw_row:
 ld e,0
map_draw_col:
 call map_get
 call tile_draw
 inc e
 ld a,e
 cp 24
 jp nz,map_draw_col
 inc d
 ld a,d
 cp 24
 jp nz,map_draw_row
 ret
; Input A=tile ID, D=row 0..23, E=col 0..23.
; Uses opaque blit, deliberately independent from actor masks.
tile_draw:
 push af
 push bc
 push hl
 ld c,a
 ld b,0
 ld hl,tile_attrs
 add hl,bc
 ld a,(hl)
 ld (paint_attr),a
 ld l,c
 ld h,0
 add hl,hl
 add hl,hl
 add hl,hl
 ld bc,tile_glyphs
 add hl,bc
 ld a,(paint_attr)
 call blit_cell
 pop hl
 pop bc
 pop af
 ret
map_restore:
 ld a,d
 cp 24
 ret nc
 ld a,e
 cp 24
 ret nc
 call map_get
 jp tile_draw
; Draw arbitrary 8x8 graphics from ROM font, A=ASCII 32..127, D/E coords.
; The ZX Spectrum ROM font starts at 0x3D00 for ASCII space.
font_cell:
 push af
 push bc
 push hl
 sub 32
 ld l,a
 ld h,0
 add hl,hl
 add hl,hl
 add hl,hl
 ld bc,0x3d00
 add hl,bc
 ld a,(text_attr)
 call blit_cell
 pop hl
 pop bc
 pop af
 ret
; Null-terminated ASCII line at HL. D/E tile position. Max column 31.
text_draw:
 ld a,(hl)
 or a
 ret z
 push hl
 call font_cell
 pop hl
 inc hl
 inc e
 ld a,e
 cp 32
 ret nc
 jp text_draw
