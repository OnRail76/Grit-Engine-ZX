; OPTIONAL VERTICAL SCROLL: one 8-pixel tile DOWN, HUD columns 24..31 fixed.
; Derived from GRIT's 8px scroll and isolated from its bosses/AI/maps.
; CONTRACT: caller erases sprites FIRST, then updates actor coordinates,
; then redraws sprites. HL -> 24 tile IDs for incoming TOP row.
scroll_down_8:
 push af
 push bc
 push de
 push hl
 ld (scroll_top_ptr),hl
 call scroll_bitmap_down
 ld hl,map_data+735
 ld de,map_data+767
 ld bc,736
 lddr
 ld d,0
 ld e,0
scroll_incoming_row:
 ld hl,(scroll_top_ptr)
 ld a,(hl)
 inc hl
 ld (scroll_top_ptr),hl
 call map_set
 call tile_draw
 inc e
 ld a,e
 cp 24
 jp nz,scroll_incoming_row
 ld a,1
 ld (full_redraw),a
 pop hl
 pop de
 pop bc
 pop af
 ret

scroll_bitmap_down:
 ld a,23
scroll_bitmap_row:
 ld (scroll_row),a
 ld d,a
 ld e,0
 call playfield_addr
 ld (scroll_dst),hl
 dec d
 call playfield_addr
 ld (scroll_src),hl
 ld b,8
scroll_scanline:
 push bc
 ld hl,(scroll_src)
 ld de,(scroll_dst)
 ld bc,24
 ldir
 ld hl,(scroll_src)
 inc h
 ld (scroll_src),hl
 ld hl,(scroll_dst)
 inc h
 ld (scroll_dst),hl
 pop bc
 djnz scroll_scanline
 ld a,(scroll_row)
 ld d,a
 ld e,0
 call attribute_addr
 ld (scroll_dst),hl
 dec d
 call attribute_addr
 ld de,(scroll_dst)
 ld bc,24
 ldir
 ld a,(scroll_row)
 dec a
 jp nz,scroll_bitmap_row
 ret

scroll_top_ptr: dw 0
scroll_row: db 0
scroll_src: dw 0
scroll_dst: dw 0
