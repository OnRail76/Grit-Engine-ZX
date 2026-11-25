ORG $9000
ground0 equ ground_bank+0
ground1 equ ground_bank+24
ground2 equ ground_bank+48
ground3 equ ground_bank+72
ground4 equ ground_bank+96
ground5 equ ground_bank+120
ground6 equ ground_bank+144
ground7 equ ground_bank+168
entry:
    di
    ld sp,$8fe0
    ld iy,$5c3a
    im 2
    ei
    xor a
    ld (joymode),a
    jp menu
load_vertical:
    jp $793e
menu:
    xor a
    ld (nav_latch),a
    xor a
    ld (mode),a
    ld a,1
    ld (selection),a
    call setup_screen
    call menu_draw
    call release_fire
menu_loop:
    halt
    call keys
    ld bc,63486
    in a,(c)
    ld c,a
    ld a,c
    bit 0,a
    jp nz,menu_num_0
    ld a,1
    ld (selection),a
    jp menu_choose
menu_num_0:
    ld a,c
    bit 1,a
    jp nz,menu_num_1
    ld a,2
    ld (selection),a
    jp menu_choose
menu_num_1:
    ld a,c
    bit 2,a
    jp nz,menu_num_2
    ld a,3
    ld (selection),a
    jp menu_choose
menu_num_2:
    ld a,c
    bit 3,a
    jp nz,menu_num_3
    ld a,4
    ld (selection),a
    jp menu_choose
menu_num_3:
    ld a,c
    bit 4,a
    jp nz,menu_num_4
    ld a,5
    ld (selection),a
    jp menu_choose
menu_num_4:
    ld a,(dy)
    or a
    jp z,menu_y_release
    ld a,(nav_latch)
    or a
    jp nz,menu_fire
    ld a,1
    ld (nav_latch),a
    ld a,(dy)
    cp 255
    jp nz,menu_down
    ld a,(selection)
    cp 1
    jp z,menu_fire
    dec a
    jp menu_store
menu_down:
    ld a,(selection)
    cp 5
    jp z,menu_fire
    inc a
menu_store:
    ld (selection),a
    call menu_draw
    jp menu_fire
menu_y_release:
    xor a
    ld (nav_latch),a
menu_fire:
    ld a,(fire)
    or a
    jp z,menu_loop
menu_choose:
    call release_fire
    ld a,(selection)
    cp 5
    jp z,load_vertical
    ld (mode),a
    jp start_demo
menu_draw:
    ld hl,menu_map
    ld de,new_map
    ld bc,576
    ldir
    ld a,(selection)
    add a,a
    add a,4
    ld d,a
    ld e,1
    ld a,11
    call put_cell
    call present
    ret 
keys:
    xor a
    ld (dx),a
    xor a
    ld (dy),a
    xor a
    ld (fire),a
    xor a
    ld (escape),a
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
    ld bc,57342
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
    ld bc,65278
    in a,(c)
    bit 2,a
    jp nz,kx
    ld a,1
    ld (escape),a
kx:
    ld bc,31
    in a,(c)
    ld c,a
    and 224
    ret nz
    ld a,c
    bit 4,a
    jp z,joy_no_fire
    ld a,1
    ld (joymode),a
    ld a,1
    ld (fire),a
joy_no_fire:
    ld a,(joymode)
    or a
    ret z
    ld a,c
    bit 0,a
    jp z,joy_r
    ld a,1
    ld (dx),a
joy_r:
    ld a,c
    bit 1,a
    jp z,joy_l
    ld a,255
    ld (dx),a
joy_l:
    ld a,c
    bit 2,a
    jp z,joy_d
    ld a,1
    ld (dy),a
joy_d:
    ld a,c
    bit 3,a
    ret z
    ld a,255
    ld (dy),a
    ret 
release_fire:
    halt
    call keys
    ld a,(fire)
    or a
    jp nz,release_fire
    ret 
setup_screen:
    xor a
    out ($fe),a
    ld hl,16384
    ld de,16385
    ld bc,6143
    ld (hl),0
    ldir
    ld hl,22528
    ld a,(mode)
    ld l,a
    ld h,0
    ld de,palette
    add hl,de
    ld a,(hl)
    ld hl,22528
    ld (hl),a
    ld de,22529
    ld bc,767
    ldir
    ld hl,old_map
    ld (hl),255
    ld de,old_map
    inc de
    ld bc,575
    ldir
    ld a,(mode)
    or a
    ret z
    ld hl,22552
    ld b,24
hud_attr_loop:
    push bc
    push hl
    ld b,8
hud_attr_inner:
    ld (hl),71
    inc hl
    dec b
    jp nz,hud_attr_inner
    pop hl
    ld de,32
    add hl,de
    pop bc
    dec b
    jp nz,hud_attr_loop
    ld hl,hud_descriptors
hud_text_loop:
    ld a,(hl)
    or a
    jp z,hud_text_done
    ld b,a
    inc hl
    ld e,(hl)
    inc hl
    ld d,(hl)
    inc hl
hud_char_loop:
    ld a,(hl)
    inc hl
    push hl
    push de
    push bc
    ex de,hl
    call draw_tile
    pop bc
    pop de
    pop hl
    inc de
    dec b
    jp nz,hud_char_loop
    jp hud_text_loop
hud_text_done:
    ld a,(mode)
    add a,48
    ld hl,16603
    call draw_tile
    ret 
start_demo:
    call setup_screen
    xor a
    ld (tick),a
    xor a
    ld (kills),a
    ld a,255
    ld (last_score),a
    xor a
    ld (edge),a
    xor a
    ld (shield),a
    xor a
    ld (shield_cd),a
    xor a
    ld (tank),a
    xor a
    ld (grace),a
    xor a
    ld (fire_latch),a
    xor a
    ld (scroll_phase),a
    ld a,12
    ld (px),a
    ld a,20
    ld (py),a
    ld a,0
    ld (face_x),a
    ld a,255
    ld (face_y),a
    ld a,255
    ld (by),a
    ld a,255
    ld (ey),a
    ld a,12
    ld (powerx),a
    ld a,14
    ld (powery),a
    ld a,5
    ld (boss_hp),a
    ld a,5
    ld (e0x),a
    ld a,3
    ld (e0y),a
    ld a,1
    ld (e0hp),a
    xor a
    ld (e0dead),a
    ld a,9
    ld (e1x),a
    ld a,4
    ld (e1y),a
    ld a,1
    ld (e1hp),a
    xor a
    ld (e1dead),a
    ld a,13
    ld (e2x),a
    ld a,5
    ld (e2y),a
    ld a,1
    ld (e2hp),a
    xor a
    ld (e2dead),a
    ld a,17
    ld (e3x),a
    ld a,6
    ld (e3y),a
    ld a,1
    ld (e3hp),a
    xor a
    ld (e3dead),a
    ld a,(mode)
    cp 3
    jp nz,init_non_arena
    ld a,12
    ld (py),a
init_non_arena:
    cp 4
    jp nz,init_non_ground
init_non_ground:
    ld a,(mode)
    cp 4
    jp nz,init_done
    ld a,8
    ld (e0x),a
    ld a,2
    ld (e0y),a
    ld a,2
    ld (e0hp),a
    ld a,12
    ld (e1x),a
    ld a,6
    ld (e1y),a
    ld a,3
    ld (e1hp),a
    ld a,15
    ld (e2x),a
    ld a,10
    ld (e2y),a
    ld a,2
    ld (e2hp),a
    ld a,10
    ld (e3x),a
    ld a,14
    ld (e3y),a
    ld a,3
    ld (e3hp),a
init_done:
    call background
    call compose
    call present
    call release_fire
    ld a,(36497)
    ld (last_frame),a
demo_loop:
    call frame_sync
    call keys
    ld a,(escape)
    or a
    jp nz,menu
    ld a,(tick)
    inc a
    ld (tick),a
    call background
    call player_move
    call shoot
    call enemies
    call projectiles
    call compose
    call present
    jp demo_loop
frame_sync:
    ld hl,36497
sync_wait:
    ld a,(last_frame)
    ld b,a
    ld a,(hl)
    sub b
    cp 2
    jp nc,sync_done
    halt
    jp sync_wait
sync_done:
    ld a,(hl)
    ld (last_frame),a
    ret 
background:
    ld a,(mode)
    cp 4
    jp z,bg_ground
    dec a
    ld l,a
    ld h,0
    add hl,hl
    ld de,bg_ptrs
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    jp bg_copy
bg_ground:
    ld a,(tick)
    and 7
    jp nz,bg_keep
    ld a,(scroll_phase)
    dec a
    ld (scroll_phase),a
    ld a,(scroll_phase)
    and 7
    ld (scroll_phase),a
bg_keep:
    ld a,(scroll_phase)
    ld l,a
    ld h,0
    add hl,hl
    ld de,ground_ptrs
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
bg_copy:
    ld de,base_map
    ld bc,576
    ldir
    ret 
player_move:
    ld a,(grace)
    or a
    jp z,pm_grace_end
    ld a,(grace)
    dec a
    ld (grace),a
pm_grace_end:
    ld a,(shield)
    or a
    jp z,pm_shield_end
    ld a,(shield)
    dec a
    ld (shield),a
pm_shield_end:
    ld a,(shield_cd)
    or a
    jp z,pm_cd_end
    ld a,(shield_cd)
    dec a
    ld (shield_cd),a
pm_cd_end:
    ld a,(mode)
    cp 1
    jp nz,pm_not_circo
    ld a,(dx)
    or a
    jp z,pm_circo_release
    ld a,(edge)
    or a
    ret nz
    ld a,1
    ld (edge),a
    jp pm_x
pm_circo_release:
    xor a
    ld (edge),a
    ret 
pm_not_circo:
    ld a,(mode)
    cp 2
    jp nz,pm_not_space
    ld a,(dy)
    cp 1
    jp nz,pm_space_release
    ld a,(edge)
    or a
    jp nz,pm_space_lock
    ld a,1
    ld (edge),a
    ld a,(shield_cd)
    or a
    jp nz,pm_space_lock
    ld a,35
    ld (shield),a
    ld a,110
    ld (shield_cd),a
    jp pm_space_lock
pm_space_release:
    xor a
    ld (edge),a
pm_space_lock:
    xor a
    ld (dy),a
pm_not_space:
    ld a,(tick)
    and 1
    ret nz
pm_x:
    ld a,(px)
    ld (oldx),a
    ld a,(py)
    ld (oldy),a
    ld a,(dx)
    or a
    jp z,pm_x_face
    ld (face_x),a
    ld a,(dy)
    ld (face_y),a
pm_x_face:
    ld a,(dx)
    ld b,a
    ld a,(px)
    add a,b
    cp 23
    jp nc,px_bound_dx
    cp 1
    jp c,px_bound_dx
    ld (px),a
px_bound_dx:
    ld a,(mode)
    cp 1
    jp z,pm_check
    cp 2
    jp z,pm_check
    ld a,(dy)
    or a
    jp z,pm_y_face
    ld (face_y),a
    ld a,(dx)
    ld (face_x),a
pm_y_face:
    ld a,(dy)
    ld b,a
    ld a,(py)
    add a,b
    cp 23
    jp nc,py_bound_dy
    cp 1
    jp c,py_bound_dy
    ld (py),a
py_bound_dy:
pm_check:
    ld a,(mode)
    cp 4
    ret nz
    ld a,(px)
    ld e,a
    ld a,(py)
    ld d,a
    ld l,d
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld b,h
    ld c,l
    add hl,hl
    add hl,bc
    ld b,0
    ld c,e
    add hl,bc
    ld de,base_map
    add hl,de
    ld a,(hl)
    cp 1
    jp z,pm_revert
    cp 2
    jp z,pm_revert
    ld a,(px)
    ld e,a
    ld a,(py)
    ld d,a
    ld a,(powerx)
    cp e
    ret nz
    ld a,(powery)
    cp d
    ret nz
    ld a,1
    ld (tank),a
    ld a,255
    ld (powery),a
    call beep
    ret 
pm_revert:
    ld a,(oldx)
    ld (px),a
    ld a,(oldy)
    ld (py),a
    ret 
shoot:
    ld a,(by)
    cp 255
    ret nz
    ld a,(fire)
    or a
    ret z
    ld a,(px)
    ld (bx),a
    ld a,(py)
    ld (by),a
    xor a
    ld (bvx),a
    ld a,255
    ld (bvy),a
    ld a,(mode)
    cp 3
    jp z,shoot_free
    cp 4
    jp nz,shoot_free
shoot_free:
    ld a,(mode)
    cp 3
    jp z,shoot_dir
    cp 4
    jp nz,shoot_sound
shoot_dir:
    ld a,(face_x)
    ld (bvx),a
    ld a,(face_y)
    ld (bvy),a
shoot_sound:
    call beep
    ret 
enemies:
    ld a,(tick)
    and 3
    jp nz,enemy_fire
    ld a,(e0dead)
    or a
    jp z,e0_alive
    ld a,(e0dead)
    dec a
    ld (e0dead),a
    jp nz,e0_next
    ld a,2
    ld (e0y),a
    ld a,5
    ld (e0x),a
    ld a,1
    ld (e0hp),a
    ld a,(mode)
    cp 4
    jp nz,e0_next
    ld a,8
    ld (e0x),a
    ld a,2
    ld (e0hp),a
    jp e0_next
e0_alive:
    ld a,(mode)
    cp 3
    jp z,e0_arena
    cp 2
    jp z,e0_space
    jp e0_down
e0_arena:
    ld a,(e0x)
    ld b,a
    ld a,(px)
    cp b
    jp z,e0_ay
    jp c,e0_axleft
    ld a,(e0x)
    inc a
    ld (e0x),a
    jp e0_ay
e0_axleft:
    ld a,(e0x)
    dec a
    ld (e0x),a
e0_ay:
    ld a,(e0y)
    ld b,a
    ld a,(py)
    cp b
    jp z,e0_next
    jp c,e0_ayup
    ld a,(e0y)
    inc a
    ld (e0y),a
    jp e0_next
e0_ayup:
    ld a,(e0y)
    dec a
    ld (e0y),a
    jp e0_next
e0_space:
    ld a,(tick)
    and 16
    jp z,e0_sl
    ld a,(e0x)
    cp 22
    jp nc,e0_down
    ld a,(e0x)
    inc a
    ld (e0x),a
    jp e0_down
e0_sl:
    ld a,(e0x)
    cp 1
    jp z,e0_down
    ld a,(e0x)
    dec a
    ld (e0x),a
e0_down:
    ld a,(mode)
    cp 4
    jp nz,e0_adv
    ld a,(tick)
    and 3
    jp nz,e0_next
e0_adv:
    ld a,(e0y)
    inc a
    ld (e0y),a
    cp 23
    jp c,e0_next
    ld a,2
    ld (e0y),a
e0_next:
    ld a,(e1dead)
    or a
    jp z,e1_alive
    ld a,(e1dead)
    dec a
    ld (e1dead),a
    jp nz,e1_next
    ld a,3
    ld (e1y),a
    ld a,9
    ld (e1x),a
    ld a,1
    ld (e1hp),a
    ld a,(mode)
    cp 4
    jp nz,e1_next
    ld a,12
    ld (e1x),a
    ld a,3
    ld (e1hp),a
    jp e1_next
e1_alive:
    ld a,(mode)
    cp 3
    jp z,e1_arena
    cp 2
    jp z,e1_space
    jp e1_down
e1_arena:
    ld a,(e1x)
    ld b,a
    ld a,(px)
    cp b
    jp z,e1_ay
    jp c,e1_axleft
    ld a,(e1x)
    inc a
    ld (e1x),a
    jp e1_ay
e1_axleft:
    ld a,(e1x)
    dec a
    ld (e1x),a
e1_ay:
    ld a,(e1y)
    ld b,a
    ld a,(py)
    cp b
    jp z,e1_next
    jp c,e1_ayup
    ld a,(e1y)
    inc a
    ld (e1y),a
    jp e1_next
e1_ayup:
    ld a,(e1y)
    dec a
    ld (e1y),a
    jp e1_next
e1_space:
    ld a,(tick)
    and 16
    jp z,e1_sl
    ld a,(e1x)
    cp 22
    jp nc,e1_down
    ld a,(e1x)
    inc a
    ld (e1x),a
    jp e1_down
e1_sl:
    ld a,(e1x)
    cp 1
    jp z,e1_down
    ld a,(e1x)
    dec a
    ld (e1x),a
e1_down:
    ld a,(mode)
    cp 4
    jp nz,e1_adv
    ld a,(tick)
    and 7
    jp nz,e1_next
e1_adv:
    ld a,(e1y)
    inc a
    ld (e1y),a
    cp 23
    jp c,e1_next
    ld a,3
    ld (e1y),a
e1_next:
    ld a,(e2dead)
    or a
    jp z,e2_alive
    ld a,(e2dead)
    dec a
    ld (e2dead),a
    jp nz,e2_next
    ld a,4
    ld (e2y),a
    ld a,13
    ld (e2x),a
    ld a,1
    ld (e2hp),a
    ld a,(mode)
    cp 4
    jp nz,e2_next
    ld a,15
    ld (e2x),a
    ld a,2
    ld (e2hp),a
    jp e2_next
e2_alive:
    ld a,(mode)
    cp 3
    jp z,e2_arena
    cp 2
    jp z,e2_space
    jp e2_down
e2_arena:
    ld a,(e2x)
    ld b,a
    ld a,(px)
    cp b
    jp z,e2_ay
    jp c,e2_axleft
    ld a,(e2x)
    inc a
    ld (e2x),a
    jp e2_ay
e2_axleft:
    ld a,(e2x)
    dec a
    ld (e2x),a
e2_ay:
    ld a,(e2y)
    ld b,a
    ld a,(py)
    cp b
    jp z,e2_next
    jp c,e2_ayup
    ld a,(e2y)
    inc a
    ld (e2y),a
    jp e2_next
e2_ayup:
    ld a,(e2y)
    dec a
    ld (e2y),a
    jp e2_next
e2_space:
    ld a,(tick)
    and 16
    jp z,e2_sl
    ld a,(e2x)
    cp 22
    jp nc,e2_down
    ld a,(e2x)
    inc a
    ld (e2x),a
    jp e2_down
e2_sl:
    ld a,(e2x)
    cp 1
    jp z,e2_down
    ld a,(e2x)
    dec a
    ld (e2x),a
e2_down:
    ld a,(mode)
    cp 4
    jp nz,e2_adv
    ld a,(tick)
    and 3
    jp nz,e2_next
e2_adv:
    ld a,(e2y)
    inc a
    ld (e2y),a
    cp 23
    jp c,e2_next
    ld a,4
    ld (e2y),a
e2_next:
    ld a,(e3dead)
    or a
    jp z,e3_alive
    ld a,(e3dead)
    dec a
    ld (e3dead),a
    jp nz,e3_next
    ld a,5
    ld (e3y),a
    ld a,17
    ld (e3x),a
    ld a,1
    ld (e3hp),a
    ld a,(mode)
    cp 4
    jp nz,e3_next
    ld a,10
    ld (e3x),a
    ld a,3
    ld (e3hp),a
    jp e3_next
e3_alive:
    ld a,(mode)
    cp 3
    jp z,e3_arena
    cp 2
    jp z,e3_space
    jp e3_down
e3_arena:
    ld a,(e3x)
    ld b,a
    ld a,(px)
    cp b
    jp z,e3_ay
    jp c,e3_axleft
    ld a,(e3x)
    inc a
    ld (e3x),a
    jp e3_ay
e3_axleft:
    ld a,(e3x)
    dec a
    ld (e3x),a
e3_ay:
    ld a,(e3y)
    ld b,a
    ld a,(py)
    cp b
    jp z,e3_next
    jp c,e3_ayup
    ld a,(e3y)
    inc a
    ld (e3y),a
    jp e3_next
e3_ayup:
    ld a,(e3y)
    dec a
    ld (e3y),a
    jp e3_next
e3_space:
    ld a,(tick)
    and 16
    jp z,e3_sl
    ld a,(e3x)
    cp 22
    jp nc,e3_down
    ld a,(e3x)
    inc a
    ld (e3x),a
    jp e3_down
e3_sl:
    ld a,(e3x)
    cp 1
    jp z,e3_down
    ld a,(e3x)
    dec a
    ld (e3x),a
e3_down:
    ld a,(mode)
    cp 4
    jp nz,e3_adv
    ld a,(tick)
    and 7
    jp nz,e3_next
e3_adv:
    ld a,(e3y)
    inc a
    ld (e3y),a
    cp 23
    jp c,e3_next
    ld a,5
    ld (e3y),a
e3_next:
enemy_fire:
    ld a,(e0dead)
    or a
    ret nz
    ld a,(mode)
    cp 1
    ret z
    ld a,(ey)
    cp 255
    ret nz
    ld a,(mode)
    cp 2
    jp nz,ef_normal
    ld a,(boss_hp)
    or a
    jp z,ef_normal
    cp 3
    jp nc,ef_normal
    ld a,(tick)
    and 7
    ret nz
    jp ef_boss
ef_normal:
    ld a,(tick)
    and 15
    ret nz
    ld a,(mode)
    cp 2
    jp nz,ef_actor
    ld a,(boss_hp)
    or a
    jp z,ef_actor
    ld a,(tick)
    and 16
    jp z,ef_actor
ef_boss:
    ld a,11
    ld (ex),a
    ld a,2
    ld (ey),a
    jp ef_aim
ef_actor:
    ld a,(e0x)
    ld (ex),a
    ld a,(e0y)
    ld (ey),a
ef_aim:
    ld a,0
    ld (evx),a
    ld a,1
    ld (evy),a
    ld a,(ex)
    ld b,a
    ld a,(px)
    cp b
    jp z,enemy_fire_y
    jp c,enemy_fire_left
    ld a,1
    ld (evx),a
    jp enemy_fire_y
enemy_fire_left:
    ld a,255
    ld (evx),a
enemy_fire_y:
    ld a,(ey)
    ld b,a
    ld a,(py)
    cp b
    ret nc
    ld a,255
    ld (evy),a
    ret 
projectiles:
    ld a,(by)
    cp 255
    jp z,proj_enemy
    ld a,(bvx)
    ld b,a
    ld a,(bx)
    add a,b
    cp 24
    jp nc,bullet_remove
    ld (bx),a
    ld a,(bvy)
    ld b,a
    ld a,(by)
    add a,b
    cp 24
    jp nc,bullet_remove
    ld (by),a
    ld a,(e0dead)
    or a
    jp nz,e0_hit_next
    ld a,(bx)
    ld b,a
    ld a,(e0x)
    cp b
    jp nz,e0_hit_next
    ld a,(by)
    ld b,a
    ld a,(e0y)
    cp b
    jp nz,e0_hit_next
    ld a,(e0hp)
    dec a
    ld (e0hp),a
    jp nz,bullet_remove
    ld a,4
    ld (e0dead),a
    ld a,(kills)
    inc a
    ld (kills),a
    call boom
    jp bullet_remove
e0_hit_next:
    ld a,(e1dead)
    or a
    jp nz,e1_hit_next
    ld a,(bx)
    ld b,a
    ld a,(e1x)
    cp b
    jp nz,e1_hit_next
    ld a,(by)
    ld b,a
    ld a,(e1y)
    cp b
    jp nz,e1_hit_next
    ld a,(e1hp)
    dec a
    ld (e1hp),a
    jp nz,bullet_remove
    ld a,4
    ld (e1dead),a
    ld a,(kills)
    inc a
    ld (kills),a
    call boom
    jp bullet_remove
e1_hit_next:
    ld a,(e2dead)
    or a
    jp nz,e2_hit_next
    ld a,(bx)
    ld b,a
    ld a,(e2x)
    cp b
    jp nz,e2_hit_next
    ld a,(by)
    ld b,a
    ld a,(e2y)
    cp b
    jp nz,e2_hit_next
    ld a,(e2hp)
    dec a
    ld (e2hp),a
    jp nz,bullet_remove
    ld a,4
    ld (e2dead),a
    ld a,(kills)
    inc a
    ld (kills),a
    call boom
    jp bullet_remove
e2_hit_next:
    ld a,(e3dead)
    or a
    jp nz,e3_hit_next
    ld a,(bx)
    ld b,a
    ld a,(e3x)
    cp b
    jp nz,e3_hit_next
    ld a,(by)
    ld b,a
    ld a,(e3y)
    cp b
    jp nz,e3_hit_next
    ld a,(e3hp)
    dec a
    ld (e3hp),a
    jp nz,bullet_remove
    ld a,4
    ld (e3dead),a
    ld a,(kills)
    inc a
    ld (kills),a
    call boom
    jp bullet_remove
e3_hit_next:
    ld a,(mode)
    cp 2
    jp nz,proj_enemy
    ld a,(boss_hp)
    or a
    jp z,proj_enemy
    ld a,(by)
    cp 2
    jp nz,proj_enemy
    ld a,(bx)
    cp 10
    jp c,proj_enemy
    cp 14
    jp nc,proj_enemy
    ld a,(boss_hp)
    dec a
    ld (boss_hp),a
    jp nz,boss_hit_sound
    ld a,(kills)
    inc a
    ld (kills),a
boss_hit_sound:
    call boom
    jp bullet_remove
bullet_remove:
    ld a,255
    ld (by),a
proj_enemy:
    ld a,(ey)
    cp 255
    jp z,contact
    ld a,(evx)
    ld b,a
    ld a,(ex)
    add a,b
    cp 24
    jp nc,enemy_bullet_remove
    ld (ex),a
    ld a,(evy)
    ld b,a
    ld a,(ey)
    add a,b
    cp 24
    jp nc,enemy_bullet_remove
    ld (ey),a
    ld a,(ex)
    ld b,a
    ld a,(px)
    cp b
    jp nz,contact
    ld a,(ey)
    ld b,a
    ld a,(py)
    cp b
    jp nz,contact
    call damage
enemy_bullet_remove:
    ld a,255
    ld (ey),a
contact:
    ld a,(e0dead)
    or a
    jp nz,e0_contact_next
    ld a,(e0x)
    ld b,a
    ld a,(px)
    cp b
    jp nz,e0_contact_next
    ld a,(e0y)
    ld b,a
    ld a,(py)
    cp b
    jp nz,e0_contact_next
    ld a,(shield)
    or a
    jp nz,e0_contact_kill
    ld a,(tank)
    or a
    jp nz,e0_contact_kill
    call damage
    jp e0_contact_next
e0_contact_kill:
    ld a,4
    ld (e0dead),a
    ld a,(kills)
    inc a
    ld (kills),a
    call boom
e0_contact_next:
    ld a,(e1dead)
    or a
    jp nz,e1_contact_next
    ld a,(e1x)
    ld b,a
    ld a,(px)
    cp b
    jp nz,e1_contact_next
    ld a,(e1y)
    ld b,a
    ld a,(py)
    cp b
    jp nz,e1_contact_next
    ld a,(shield)
    or a
    jp nz,e1_contact_kill
    ld a,(tank)
    or a
    jp nz,e1_contact_kill
    call damage
    jp e1_contact_next
e1_contact_kill:
    ld a,4
    ld (e1dead),a
    ld a,(kills)
    inc a
    ld (kills),a
    call boom
e1_contact_next:
    ld a,(e2dead)
    or a
    jp nz,e2_contact_next
    ld a,(e2x)
    ld b,a
    ld a,(px)
    cp b
    jp nz,e2_contact_next
    ld a,(e2y)
    ld b,a
    ld a,(py)
    cp b
    jp nz,e2_contact_next
    ld a,(shield)
    or a
    jp nz,e2_contact_kill
    ld a,(tank)
    or a
    jp nz,e2_contact_kill
    call damage
    jp e2_contact_next
e2_contact_kill:
    ld a,4
    ld (e2dead),a
    ld a,(kills)
    inc a
    ld (kills),a
    call boom
e2_contact_next:
    ld a,(e3dead)
    or a
    jp nz,e3_contact_next
    ld a,(e3x)
    ld b,a
    ld a,(px)
    cp b
    jp nz,e3_contact_next
    ld a,(e3y)
    ld b,a
    ld a,(py)
    cp b
    jp nz,e3_contact_next
    ld a,(shield)
    or a
    jp nz,e3_contact_kill
    ld a,(tank)
    or a
    jp nz,e3_contact_kill
    call damage
    jp e3_contact_next
e3_contact_kill:
    ld a,4
    ld (e3dead),a
    ld a,(kills)
    inc a
    ld (kills),a
    call boom
e3_contact_next:
    ret 
damage:
    ld a,(shield)
    or a
    ret nz
    ld a,(grace)
    or a
    ret nz
    ld a,(tank)
    or a
    jp z,damage_player
    xor a
    ld (tank),a
    jp damage_grace
damage_player:
    ld a,12
    ld (px),a
    ld a,20
    ld (py),a
damage_grace:
    ld a,75
    ld (grace),a
    call boom
    ret 
compose:
    ld hl,base_map
    ld de,new_map
    ld bc,576
    ldir
    ld a,(mode)
    cp 2
    jp nz,compose_noboss
    ld a,(boss_hp)
    or a
    jp z,compose_noboss
    ld d,2
    ld e,10
    ld a,8
    call put_cell
    ld d,2
    ld e,11
    ld a,8
    call put_cell
    ld d,2
    ld e,12
    ld a,8
    call put_cell
    ld d,2
    ld e,13
    ld a,8
    call put_cell
compose_noboss:
    ld a,(mode)
    cp 4
    jp nz,compose_no_power
    ld a,(powerx)
    ld e,a
    ld a,(powery)
    ld d,a
    ld a,9
    call put_cell
compose_no_power:
    ld a,(e0dead)
    or a
    jp z,e0_draw_live
    ld a,(e0x)
    ld e,a
    ld a,(e0y)
    ld d,a
    ld a,7
    call put_cell
    jp e0_draw_done
e0_draw_live:
    ld a,(mode)
    cp 4
    jp nz,e0_draw_air
    ld a,(e0x)
    ld e,a
    ld a,(e0y)
    ld d,a
    ld a,6
    call put_cell
    jp e0_draw_done
e0_draw_air:
    ld a,(e0x)
    ld e,a
    ld a,(e0y)
    ld d,a
    ld a,4
    call put_cell
e0_draw_done:
    ld a,(e1dead)
    or a
    jp z,e1_draw_live
    ld a,(e1x)
    ld e,a
    ld a,(e1y)
    ld d,a
    ld a,7
    call put_cell
    jp e1_draw_done
e1_draw_live:
    ld a,(mode)
    cp 4
    jp nz,e1_draw_air
    ld a,(e1x)
    ld e,a
    ld a,(e1y)
    ld d,a
    ld a,5
    call put_cell
    jp e1_draw_done
e1_draw_air:
    ld a,(e1x)
    ld e,a
    ld a,(e1y)
    ld d,a
    ld a,4
    call put_cell
e1_draw_done:
    ld a,(e2dead)
    or a
    jp z,e2_draw_live
    ld a,(e2x)
    ld e,a
    ld a,(e2y)
    ld d,a
    ld a,7
    call put_cell
    jp e2_draw_done
e2_draw_live:
    ld a,(mode)
    cp 4
    jp nz,e2_draw_air
    ld a,(e2x)
    ld e,a
    ld a,(e2y)
    ld d,a
    ld a,6
    call put_cell
    jp e2_draw_done
e2_draw_air:
    ld a,(e2x)
    ld e,a
    ld a,(e2y)
    ld d,a
    ld a,4
    call put_cell
e2_draw_done:
    ld a,(e3dead)
    or a
    jp z,e3_draw_live
    ld a,(e3x)
    ld e,a
    ld a,(e3y)
    ld d,a
    ld a,7
    call put_cell
    jp e3_draw_done
e3_draw_live:
    ld a,(mode)
    cp 4
    jp nz,e3_draw_air
    ld a,(e3x)
    ld e,a
    ld a,(e3y)
    ld d,a
    ld a,5
    call put_cell
    jp e3_draw_done
e3_draw_air:
    ld a,(e3x)
    ld e,a
    ld a,(e3y)
    ld d,a
    ld a,4
    call put_cell
e3_draw_done:
    ld a,(bx)
    ld e,a
    ld a,(by)
    ld d,a
    ld a,3
    call put_cell
    ld a,(ex)
    ld e,a
    ld a,(ey)
    ld d,a
    ld a,10
    call put_cell
    ld a,(grace)
    or a
    jp z,draw_player
    ld a,(tick)
    and 2
    jp nz,draw_player_skip
draw_player:
    ld a,(shield)
    or a
    jp z,draw_not_shield
    ld a,(px)
    ld e,a
    ld a,(py)
    ld d,a
    ld a,12
    call put_cell
    jp draw_player_skip
draw_not_shield:
    ld a,(tank)
    or a
    jp z,draw_not_tank
    ld a,(px)
    ld e,a
    ld a,(py)
    ld d,a
    ld a,5
    call put_cell
    jp draw_player_skip
draw_not_tank:
    ld a,(px)
    ld e,a
    ld a,(py)
    ld d,a
    ld a,13
    call put_cell
draw_player_skip:
    ret 
put_cell:
    push af
    ld a,d
    cp 24
    jp nc,put_invalid
    ld a,e
    cp 24
    jp nc,put_invalid
    ld l,d
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld b,h
    ld c,l
    add hl,hl
    add hl,bc
    ld b,0
    ld c,e
    add hl,bc
    ld de,new_map
    add hl,de
    pop af
    ld (hl),a
    ret 
put_invalid:
    pop af
    ret 
present:
    ld hl,new_map
    ld de,old_map
    ld bc,576
present_loop:
    ld a,(de)
    cp (hl)
    jp z,present_next
    ld a,(hl)
    ld (de),a
    push bc
    push de
    push hl
    push af
    ld de,new_map
    or a
    sbc hl,de
    add hl,hl
    ld de,cell_lut
    add hl,de
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    pop af
    call draw_tile
    pop hl
    pop de
    pop bc
present_next:
    inc hl
    inc de
    dec bc
    ld a,b
    or c
    jp nz,present_loop
    ld a,(mode)
    or a
    ret z
    ld a,(kills)
    ld b,a
    ld a,(last_score)
    cp b
    ret z
    ld a,b
    ld (last_score),a
    cp 100
    jp c,score_ok
    ld a,99
score_ok:
    ld b,a
    ld a,0
digit_tens:
    ld c,a
    ld a,b
    cp 10
    jp c,digit_done
    sub 10
    ld b,a
    ld a,c
    inc a
    jp digit_tens
digit_done:
    ld a,c
    add a,48
    push bc
    ld hl,18490
    call draw_tile
    pop bc
    ld a,b
    add a,48
    ld hl,18491
    call draw_tile
    ret 
draw_tile:
    push hl
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,glyphs
    add hl,de
    ex de,hl
    pop hl
    ld a,(de)
    ld (hl),a
    inc de
    inc h
    ld a,(de)
    ld (hl),a
    inc de
    inc h
    ld a,(de)
    ld (hl),a
    inc de
    inc h
    ld a,(de)
    ld (hl),a
    inc de
    inc h
    ld a,(de)
    ld (hl),a
    inc de
    inc h
    ld a,(de)
    ld (hl),a
    inc de
    inc h
    ld a,(de)
    ld (hl),a
    inc de
    inc h
    ld a,(de)
    ld (hl),a
    ret 
beep:
    ld a,16
    out ($fe),a
    ld b,24
beep_wait:
    dec b
    jp nz,beep_wait
    xor a
    out ($fe),a
    ret 
boom:
    ld c,4
boom_loop:
    push bc
    call beep
    pop bc
    dec c
    jp nz,boom_loop
    ret 
mode:
    db 0
selection:
    db 0
nav_latch:
    db 0
joymode:
    db 0
dx:
    db 0
dy:
    db 0
fire:
    db 0
escape:
    db 0
tick:
    db 0
kills:
    db 0
edge:
    db 0
shield:
    db 0
shield_cd:
    db 0
tank:
    db 0
grace:
    db 0
fire_latch:
    db 0
scroll_phase:
    db 0
px:
    db 0
py:
    db 0
oldx:
    db 0
oldy:
    db 0
face_x:
    db 0
face_y:
    db 0
bx:
    db 0
by:
    db 0
bvx:
    db 0
bvy:
    db 0
ex:
    db 0
ey:
    db 0
evx:
    db 0
evy:
    db 0
powerx:
    db 0
powery:
    db 0
boss_hp:
    db 0
last_frame:
    db 0
last_score:
    db 0
e0x:
    db 0
e0y:
    db 0
e0hp:
    db 0
e0dead:
    db 0
e1x:
    db 0
e1y:
    db 0
e1hp:
    db 0
e1dead:
    db 0
e2x:
    db 0
e2y:
    db 0
e2hp:
    db 0
e2dead:
    db 0
e3x:
    db 0
e3y:
    db 0
e3hp:
    db 0
e3dead:
    db 0
palette:
    db 71,70,69,71,68
base_map:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
new_map:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
old_map:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
cell_lut:
    db 0,64,1,64,2,64,3,64,4,64,5,64,6,64,7,64,8,64,9,64,10,64,11,64
    db 12,64,13,64,14,64,15,64,16,64,17,64,18,64,19,64,20,64,21,64,22,64,23,64
    db 32,64,33,64,34,64,35,64,36,64,37,64,38,64,39,64,40,64,41,64,42,64,43,64
    db 44,64,45,64,46,64,47,64,48,64,49,64,50,64,51,64,52,64,53,64,54,64,55,64
    db 64,64,65,64,66,64,67,64,68,64,69,64,70,64,71,64,72,64,73,64,74,64,75,64
    db 76,64,77,64,78,64,79,64,80,64,81,64,82,64,83,64,84,64,85,64,86,64,87,64
    db 96,64,97,64,98,64,99,64,100,64,101,64,102,64,103,64,104,64,105,64,106,64,107,64
    db 108,64,109,64,110,64,111,64,112,64,113,64,114,64,115,64,116,64,117,64,118,64,119,64
    db 128,64,129,64,130,64,131,64,132,64,133,64,134,64,135,64,136,64,137,64,138,64,139,64
    db 140,64,141,64,142,64,143,64,144,64,145,64,146,64,147,64,148,64,149,64,150,64,151,64
    db 160,64,161,64,162,64,163,64,164,64,165,64,166,64,167,64,168,64,169,64,170,64,171,64
    db 172,64,173,64,174,64,175,64,176,64,177,64,178,64,179,64,180,64,181,64,182,64,183,64
    db 192,64,193,64,194,64,195,64,196,64,197,64,198,64,199,64,200,64,201,64,202,64,203,64
    db 204,64,205,64,206,64,207,64,208,64,209,64,210,64,211,64,212,64,213,64,214,64,215,64
    db 224,64,225,64,226,64,227,64,228,64,229,64,230,64,231,64,232,64,233,64,234,64,235,64
    db 236,64,237,64,238,64,239,64,240,64,241,64,242,64,243,64,244,64,245,64,246,64,247,64
    db 0,72,1,72,2,72,3,72,4,72,5,72,6,72,7,72,8,72,9,72,10,72,11,72
    db 12,72,13,72,14,72,15,72,16,72,17,72,18,72,19,72,20,72,21,72,22,72,23,72
    db 32,72,33,72,34,72,35,72,36,72,37,72,38,72,39,72,40,72,41,72,42,72,43,72
    db 44,72,45,72,46,72,47,72,48,72,49,72,50,72,51,72,52,72,53,72,54,72,55,72
    db 64,72,65,72,66,72,67,72,68,72,69,72,70,72,71,72,72,72,73,72,74,72,75,72
    db 76,72,77,72,78,72,79,72,80,72,81,72,82,72,83,72,84,72,85,72,86,72,87,72
    db 96,72,97,72,98,72,99,72,100,72,101,72,102,72,103,72,104,72,105,72,106,72,107,72
    db 108,72,109,72,110,72,111,72,112,72,113,72,114,72,115,72,116,72,117,72,118,72,119,72
    db 128,72,129,72,130,72,131,72,132,72,133,72,134,72,135,72,136,72,137,72,138,72,139,72
    db 140,72,141,72,142,72,143,72,144,72,145,72,146,72,147,72,148,72,149,72,150,72,151,72
    db 160,72,161,72,162,72,163,72,164,72,165,72,166,72,167,72,168,72,169,72,170,72,171,72
    db 172,72,173,72,174,72,175,72,176,72,177,72,178,72,179,72,180,72,181,72,182,72,183,72
    db 192,72,193,72,194,72,195,72,196,72,197,72,198,72,199,72,200,72,201,72,202,72,203,72
    db 204,72,205,72,206,72,207,72,208,72,209,72,210,72,211,72,212,72,213,72,214,72,215,72
    db 224,72,225,72,226,72,227,72,228,72,229,72,230,72,231,72,232,72,233,72,234,72,235,72
    db 236,72,237,72,238,72,239,72,240,72,241,72,242,72,243,72,244,72,245,72,246,72,247,72
    db 0,80,1,80,2,80,3,80,4,80,5,80,6,80,7,80,8,80,9,80,10,80,11,80
    db 12,80,13,80,14,80,15,80,16,80,17,80,18,80,19,80,20,80,21,80,22,80,23,80
    db 32,80,33,80,34,80,35,80,36,80,37,80,38,80,39,80,40,80,41,80,42,80,43,80
    db 44,80,45,80,46,80,47,80,48,80,49,80,50,80,51,80,52,80,53,80,54,80,55,80
    db 64,80,65,80,66,80,67,80,68,80,69,80,70,80,71,80,72,80,73,80,74,80,75,80
    db 76,80,77,80,78,80,79,80,80,80,81,80,82,80,83,80,84,80,85,80,86,80,87,80
    db 96,80,97,80,98,80,99,80,100,80,101,80,102,80,103,80,104,80,105,80,106,80,107,80
    db 108,80,109,80,110,80,111,80,112,80,113,80,114,80,115,80,116,80,117,80,118,80,119,80
    db 128,80,129,80,130,80,131,80,132,80,133,80,134,80,135,80,136,80,137,80,138,80,139,80
    db 140,80,141,80,142,80,143,80,144,80,145,80,146,80,147,80,148,80,149,80,150,80,151,80
    db 160,80,161,80,162,80,163,80,164,80,165,80,166,80,167,80,168,80,169,80,170,80,171,80
    db 172,80,173,80,174,80,175,80,176,80,177,80,178,80,179,80,180,80,181,80,182,80,183,80
    db 192,80,193,80,194,80,195,80,196,80,197,80,198,80,199,80,200,80,201,80,202,80,203,80
    db 204,80,205,80,206,80,207,80,208,80,209,80,210,80,211,80,212,80,213,80,214,80,215,80
    db 224,80,225,80,226,80,227,80,228,80,229,80,230,80,231,80,232,80,233,80,234,80,235,80
    db 236,80,237,80,238,80,239,80,240,80,241,80,242,80,243,80,244,80,245,80,246,80,247,80
menu_map:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,71,82,73,84,32,69,78,71,73,78,69,32,52,56,75,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,84,69,67,72,78,79,76,79,71,89,32,68,69,77,79,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,49,32,67,73,82,67,79,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,50,32,83,80,65,67,69,32,83,72,79,79,84,69,82,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,51,32,65,82,69,78,65,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,52,32,71,82,79,85,78,68,32,67,79,77,66,65,84,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,53,32,86,69,82,84,73,67,65,76,32,83,72,77,85,80,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,81,47,65,32,43,32,70,73,82,69,32,47,32,49,45,53,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,88,58,32,86,79,76,86,69,82,32,65,76,32,77,69,78,85,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,53,58,32,77,69,68,73,84,69,82,82,65,78,69,79,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
bg1:
    db 0,0,67,73,82,67,79,32,45,32,80,79,82,32,84,79,81,85,69,83,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,14,0,0,0,0,14,0,0,0,0,14,0,0,0,0,14,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,14,0,0,0,0,14,0,0,0,0,14,0,0,0,0,14,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,14,0,0,0,0,14,0,0,0,0,14,0,0,0,0,14,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,14,0,0,0,0,14,0,0,0,0,14,0,0,0,0,14,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
bg2:
    db 0,0,83,80,65,67,69,32,45,32,69,83,67,85,68,79,32,65,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0
    db 0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0
    db 0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0
    db 0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0
    db 0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0
    db 0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0
    db 0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,14,0,0,0,0,0,0,0
    db 0,14,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
bg3:
    db 0,0,65,82,69,78,65,32,45,32,56,32,68,73,82,69,67,67,73,79,78,69,83,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
ground_bank:
    db 1,1,0,1,1,1,0,14,0,0,0,0,0,0,0,0,14,0,2,2,2,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,14,0,0,0,0,0,0,0,0,14,0,1,1,1,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,14,0,0,0,0,0,0,0,0,14,0,2,2,2,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,14,0,0,0,0,0,0,0,0,14,0,1,1,1,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,14,0,0,0,0,0,0,0,0,14,0,2,2,2,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,14,0,0,0,0,0,0,0,0,14,0,1,1,1,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,14,0,0,0,0,0,0,0,0,14,0,2,2,2,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1
    db 1,1,0,2,2,2,0,14,0,0,0,0,0,0,0,0,14,0,1,1,1,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
    db 1,1,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,1,1
bg_ptrs:
    dw bg1
    dw bg2
    dw bg3
ground_ptrs:
    dw ground0
    dw ground1
    dw ground2
    dw ground3
    dw ground4
    dw ground5
    dw ground6
    dw ground7
hud_descriptors:
    db 4,56,64,71,82,73,84,6,88,64,69,78,71,73,78,69,4,152,64,84,69,67,72,4
    db 184,64,68,69,77,79,5,24,72,66,65,74,65,83,7,152,72,88,58,32,77,69,78,85
    db 4,248,72,81,65,79,80,5,24,80,83,80,65,67,69,8,88,80,75,69,77,80,83,84
    db 79,78,0
glyphs:
    db 0,0,0,0,0,0,0,0,255,129,189,165,165,189,129,255,126,255,219,219,255,219,219,255
    db 0,24,24,24,24,24,0,0,0,36,126,219,255,90,36,0,60,126,255,219,219,255,126,60
    db 24,24,60,126,24,36,36,66,66,24,165,90,90,165,24,66,255,129,189,255,231,255,129,255
    db 60,66,153,165,165,153,66,60,0,0,24,60,60,24,0,0,0,32,48,248,248,48,32,0
    db 60,66,153,165,165,129,66,60,24,24,60,60,126,255,219,0,0,0,0,16,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,16,16,124,16,16,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,48,0,0,0,0,0,0,0,0,0,0,0,0,8,16,16,48,32,32,64
    db 0,24,36,52,36,36,24,0,0,48,16,16,16,16,56,0,0,56,4,4,8,16,60,0
    db 0,60,4,24,4,4,56,0,0,8,24,24,40,60,8,0,0,60,32,56,4,4,56,0
    db 0,28,32,60,36,36,24,0,0,60,4,8,8,8,16,0,0,60,36,24,36,36,24,0
    db 0,24,36,36,60,4,56,0,0,0,0,16,0,0,16,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,24,24,24,24,60,36,0
    db 0,60,36,36,56,36,60,0,0,28,32,32,32,32,28,0,0,56,36,36,36,36,56,0
    db 0,60,32,32,60,32,60,0,0,60,32,32,60,32,32,0,0,28,32,32,44,36,28,0
    db 0,36,36,36,60,36,36,0,0,56,16,16,16,16,56,0,0,12,4,4,4,4,60,0
    db 0,44,40,48,40,40,36,0,0,32,32,32,32,32,60,0,0,36,60,60,60,36,36,0
    db 0,36,52,52,44,44,36,0,0,24,36,36,36,36,24,0,0,56,36,36,56,32,32,0
    db 0,24,36,36,36,36,24,4,0,60,36,36,56,36,38,0,0,28,32,48,28,4,60,0
    db 0,56,16,16,16,16,16,0,0,36,36,36,36,36,24,0,0,36,36,24,24,24,24,0
    db 0,68,68,84,108,40,40,0,0,36,24,24,24,24,36,0,0,108,40,56,16,16,16,0
    db 0,60,12,8,16,48,60,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
