; GRIT ENGINE 0.2: defensive states, stack sentinel, and deterministic tick.
; The V0.1 code is never modified. This module is the V0.2 implementation.
; State: 0 TITLE, 1 ACTIVE, 2 GAME OVER, 3 VICTORY.
; Do not run enemy AI/physics if engine_terminal_lock != 0.
engine_quality_init:
 xor a
 ld (engine_error_code),a
 ld (engine_last_phase),a
 ld (engine_tick_lo),a
 ld (engine_tick_hi),a
 ld (engine_state),a
 ld (engine_terminal_lock),a
 ld a,0xa5
 ld (0x7b00),a
 ld a,0x5a
 ld (0x7b01),a
 ld a,0x3c
 ld (0x7b02),a
 ld a,0xc3
 ld (0x7b03),a
 ret

; Strict guard called ONLY from runtime/main_loop (entry SP=0x7FEE because of CALL).
; The extra two PUSH instructions below imply SP=0x7FEA at the check.
; Detects subtle SP drift that a broad stack-window check would miss.
engine_guard_frame:
 push af
 push hl
 ld hl,0
 add hl,sp
 ld a,h
 cp 0x7f
 jp nz,engine_fault_stack
 ld a,l
 cp 0xea
 jp nz,engine_fault_stack
 pop hl
 pop af
 jp engine_guard_check

; Check before/after each game update: low-memory canaries and live stack window.
; Entry SP includes CALL return address. Keeps A and HL transparent to caller.
engine_guard_check:
 push af
 push hl
 ld hl,0
 add hl,sp
 ld a,h
 cp 0x7b
 jp c,engine_fault_stack
 cp 0x80
 jp nc,engine_fault_stack
 ld a,(0x7b00)
 cp 0xa5
 jp nz,engine_fault_canary
 ld a,(0x7b01)
 cp 0x5a
 jp nz,engine_fault_canary
 ld a,(0x7b02)
 cp 0x3c
 jp nz,engine_fault_canary
 ld a,(0x7b03)
 cp 0xc3
 jp nz,engine_fault_canary
 pop hl
 pop af
 ret

engine_fault_stack:
 ld a,1
 jp engine_fault
engine_fault_canary:
 ld a,2
 jp engine_fault
engine_fault:
 ld (engine_error_code),a
 di
 ; colour 2 (red) for stack, 3 (magenta) for guard region
 cp 1
 jp nz,engine_fault_colour_canary
 ld a,2
 jp engine_fault_border
engine_fault_colour_canary:
 ld a,3
engine_fault_border:
 out (0xfe),a
engine_fault_stop:
 halt
 jp engine_fault_stop

engine_enter_play:
 xor a
 ld (engine_terminal_lock),a
 ld a,1
 ld (engine_state),a
 ret
engine_enter_gameover:
 ld a,1
 ld (engine_terminal_lock),a
 ld a,2
 ld (engine_state),a
 ret
engine_enter_victory:
 ld a,1
 ld (engine_terminal_lock),a
 ld a,3
 ld (engine_state),a
 ret
; Z set means simulation is enabled. NZ means do not update game actors.
engine_is_terminal:
 ld a,(engine_terminal_lock)
 or a
 ret

; One tick per *game update*, nominally 25 Hz in demo (not a 50-Hz IRQ clock).
engine_tick:
 ld hl,(engine_tick_lo)
 inc hl
 ld (engine_tick_lo),hl
 ret

; B = number of 50-Hz HALT intervals for short menu/end interludes.
; This is HALT-counted; no IM2 vector or memory layout change in V0.2.
engine_wait_50hz:
engine_wait_loop:
 halt
 djnz engine_wait_loop
 ret

engine_state: db 0
engine_terminal_lock: db 0
engine_error_code: db 0
; Check this byte in Fuse if a crash is trapped: 1=before, 2=logic, 3=after, 4=presenter.
engine_last_phase: db 0
engine_tick_lo: db 0
engine_tick_hi: db 0
