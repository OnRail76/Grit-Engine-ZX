; Generic 16x16 masked sprite. Four 8x8 cells in row-major order.
; Input: HL = 32-byte bitmap, mask_src = 32-byte mask, D=row E=col,
; A=ZX attribute. D/E top-left must be <=22. Saves all caller registers.
sprite_draw_2x2:
 push af
 ld a,d
 cp 23
 jp nc,sprite_draw_invalid
 ld a,e
 cp 23
 jp nc,sprite_draw_invalid
 pop af
 push af
 push bc
 push de
 push hl
 ld (sprite_bitmap_ptr),hl
 ld (sprite_draw_attr),a
 ld hl,(mask_src)
 ld (sprite_mask_ptr),hl
 call sprite_draw_one
 inc e
 call sprite_draw_one
 inc d
 dec e
 call sprite_draw_one
 inc e
 call sprite_draw_one
 pop hl
 pop de
 pop bc
 pop af
 ret
sprite_draw_invalid:
 pop af
 ret
sprite_draw_one:
 push af
 push bc
 push de
 push hl
 ld hl,(sprite_mask_ptr)
 ld (mask_src),hl
 ld hl,(sprite_bitmap_ptr)
 ld a,(sprite_draw_attr)
 call blit_masked_cell
 ld hl,(sprite_bitmap_ptr)
 ld bc,8
 add hl,bc
 ld (sprite_bitmap_ptr),hl
 ld hl,(sprite_mask_ptr)
 add hl,bc
 ld (sprite_mask_ptr),hl
 pop hl
 pop de
 pop bc
 pop af
 ret
; Restore the 4 background tiles under a sprite, e.g. before movement.
sprite_restore_2x2:
 ld a,d
 cp 23
 ret nc
 ld a,e
 cp 23
 ret nc
 push de
 call map_restore
 inc e
 call map_restore
 inc d
 dec e
 call map_restore
 inc e
 call map_restore
 pop de
 ret
sprite_bitmap_ptr: dw 0
sprite_mask_ptr: dw 0
sprite_draw_attr: db 7
