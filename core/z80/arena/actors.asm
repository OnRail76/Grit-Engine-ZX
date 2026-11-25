; GRIT ENGINE V0.3: reusable, bounded actor/projectile pools, inspired by
; HALCONES' fixed-size waves / attack routines, not a copy of game content.
; 16 actors x 8 bytes: type, x, y, signed vx, signed vy, hp, age, flags.
; 24 bullets x 6 bytes: type, x, y, signed vx, signed vy, ttl.
; Positions are 16x16 top-left for actors, 8x8 for projectiles.
; When reaching an illegal coordinate, deactivates instead of wrapping
; to 253..255 (lesson from the HALCONES CROW reset).
; Alloc input A=type (nonzero), D=Y, E=X. Output A=1/0, HL=slot if full.
; For active game logic call actor_pool_step / bullet_pool_step.

actor_pool_init:
 xor a
 ld (pool_hit_count),a
 ld (pool_hit_count+1),a
 ld (pool_kill_count),a
 ld hl,actor_slots
 ld de,actor_slots+1
 ld bc,127
 ld (hl),a
 ldir
 ld hl,bullet_slots
 ld de,bullet_slots+1
 ld bc,143
 ld (hl),a
 ldir
 ret

actor_pool_alloc:
 ld (pool_new_type),a
 ld a,e
 ld (pool_new_x),a
 ld a,d
 ld (pool_new_y),a
 ld hl,actor_slots
 ld de,8
 ld b,16
actor_alloc_find:
 ld a,(hl)
 or a
 jp z,actor_alloc_found
 add hl,de
 djnz actor_alloc_find
 xor a
 ret
actor_alloc_found:
 push hl
 ld a,(pool_new_type)
 ld (hl),a
 inc hl
 ld a,(pool_new_x)
 ld (hl),a
 inc hl
 ld a,(pool_new_y)
 ld (hl),a
 inc hl
 xor a
 ld (hl),a
 inc hl
 ld (hl),a
 inc hl
 inc a
 ld (hl),a                 ; HP=1
 inc hl
 xor a
 ld (hl),a                 ; age=0
 inc hl
 ld (hl),a                 ; flags=0
 pop hl
 ld a,1
 ret

bullet_pool_alloc:
 ld (pool_new_type),a
 ld a,e
 ld (pool_new_x),a
 ld a,d
 ld (pool_new_y),a
 ld hl,bullet_slots
 ld de,6
 ld b,24
bullet_alloc_find:
 ld a,(hl)
 or a
 jp z,bullet_alloc_found
 add hl,de
 djnz bullet_alloc_find
 xor a
 ret
bullet_alloc_found:
 push hl
 ld a,(pool_new_type)
 ld (hl),a
 inc hl
 ld a,(pool_new_x)
 ld (hl),a
 inc hl
 ld a,(pool_new_y)
 ld (hl),a
 inc hl
 xor a
 ld (hl),a
 inc hl
 ld (hl),a
 inc hl
 ld a,50
 ld (hl),a                  ; default TTL=50 steps
 pop hl
 ld a,1
 ret

actor_pool_step:
 call engine_is_terminal
 ret nz
 push bc
 push de
 push ix
 ld ix,actor_slots
 ld b,16
 ld de,8
actor_step_next:
 ld a,(ix+0)
 or a
 jp z,actor_step_advance
 ld a,(ix+1)
 ld c,a
 ld a,(ix+3)
 add a,c
 cp 177
 jp nc,actor_step_kill
 ld (ix+1),a
 ld a,(ix+2)
 ld c,a
 ld a,(ix+4)
 add a,c
 cp 177
 jp nc,actor_step_kill
 ld (ix+2),a
 inc (ix+6)
 jp actor_step_advance
actor_step_kill:
 xor a
 ld (ix+0),a
actor_step_advance:
 add ix,de
 djnz actor_step_next
 pop ix
 pop de
 pop bc
 ret

bullet_pool_step:
 call engine_is_terminal
 ret nz
 push bc
 push de
 push ix
 ld ix,bullet_slots
 ld b,24
 ld de,6
bullet_step_next:
 ld a,(ix+0)
 or a
 jp z,bullet_step_advance
 ld a,(ix+1)
 ld c,a
 ld a,(ix+3)
 add a,c
 cp 185
 jp nc,bullet_step_kill
 ld (ix+1),a
 ld a,(ix+2)
 ld c,a
 ld a,(ix+4)
 add a,c
 cp 185
 jp nc,bullet_step_kill
 ld (ix+2),a
 ld a,(ix+5)
 or a
 jp z,bullet_step_kill
 dec (ix+5)
 jp bullet_step_advance
bullet_step_kill:
 xor a
 ld (ix+0),a
bullet_step_advance:
 add ix,de
 djnz bullet_step_next
 pop ix
 pop de
 pop bc
 ret

pool_new_type: db 0
pool_new_x: db 0
pool_new_y: db 0
actor_slots: ds 128
bullet_slots: ds 144

; Bullet point vs 16x16 actor AABB, unsigned delta < 16 on both axes.
; 24 bullets x 16 actors; empty slots skipped. One bullet damages ONE actor.
; For game-specific friendly-fire use type/flags filtering above this API.
; This general collision uses x/y only, never draws, returns all regs intact.
bullet_actor_collisions:
 call engine_is_terminal
 ret nz
 push bc
 push de
 push ix
 push iy
 ld iy,bullet_slots
 ld b,24
collision_bullet_loop:
 push bc
 ld a,(iy+0)
 or a
 jp z,collision_next_bullet
 ld ix,actor_slots
 ld de,8
 ld b,16
collision_actor_loop:
 ld a,(ix+0)
 or a
 jp z,collision_next_actor
 ld a,(ix+1)
 ld c,a
 ld a,(iy+1)
 sub c
 cp 16
 jp nc,collision_next_actor
 ld a,(ix+2)
 ld c,a
 ld a,(iy+2)
 sub c
 cp 16
 jp nc,collision_next_actor
 ; Valid collision. Remove projectile and subtract one health.
 xor a
 ld (iy+0),a
 ld a,(ix+5)
 or a
 jp z,collision_kill_actor
 dec a
 ld (ix+5),a
 jp nz,collision_count_hit
collision_kill_actor:
 xor a
 ld (ix+0),a
 ld hl,pool_kill_count
 inc (hl)
collision_count_hit:
 ld hl,(pool_hit_count)
 inc hl
 ld (pool_hit_count),hl
 jp collision_next_bullet
collision_next_actor:
 add ix,de
 djnz collision_actor_loop
collision_next_bullet:
 ld de,6
 add iy,de
 pop bc
 djnz collision_bullet_loop
 pop iy
 pop ix
 pop de
 pop bc
 ret

pool_hit_count: dw 0

pool_kill_count: db 0
