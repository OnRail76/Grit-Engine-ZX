from pathlib import Path
from functools import reduce
from operator import xor
import struct,json,hashlib
from emitter import *
from formats import screen_addr,tap_block,read_tap
P=Path(__file__).resolve().parent
# Native cell compositor. Four compact integration exercises + original vertical tape.
# Opcodes are generated directly; listing is emitted in parallel.
def X(s,*v): E(s,*v)
def rr(s):
 if s=='dec de': X(s,0x1b)
 elif s=='dec bc': X(s,0x0b)
 elif s=='cp (hl)': X(s,0xbe)
 elif s=='add a,c': X(s,0x81)
 elif s=='sub c': X(s,0x91)
 elif s=='or e': X(s,0xb3)
 elif s=='ld (hl),a': X(s,0x77)
 else: R(s)
def seq(*s):
 for x in s:rr(x)
def word(n,v): data(n,struct.pack('<H',v))
def addradd(n): ld(n);R('add hl,de')
def cpv(n): R('ld b,a');la(n);R('cp b')
def pos(n): # D=y E=x from two variables
 la(n+'x');R('ld e,a');la(n+'y');R('ld d,a')
def cell(): # D=y,E=x -> HL index (y*24+x); clobber BC
 R('ld l,d','ld h,0','add hl,hl','add hl,hl','add hl,hl','ld b,h','ld c,l','add hl,hl','add hl,bc','ld b,0','ld c,e','add hl,bc')
def sprite(n,t):pos(n);imm(t);C('put_cell')
def move(n,delta,low,high): # signed step -1/0/+1; no wrap
 la(delta);R('ld b,a');la(n);R('add a,b');cp(high+1);J(n+'_bound_'+delta,'nc');cp(low);J(n+'_bound_'+delta,'c');sa(n);L(n+'_bound_'+delta)
def pollrow(port,bitno,label,var,val):
 lc(port);R('in a,(c)');bit(bitno);J(label,'nz');setv(var,val);L(label)
# Entry/loader placed safely below $A200. Fifth profile intentionally transfers control.
L('entry');R('di');W('ld sp,$8fe0',0x31,0x8fe0);X('ld iy,$5c3a',0xfd,0x21,0x3a,0x5c);X('im 2',0xed,0x5e);R('ei');zero('joymode');J('menu')
L('load_vertical');W('jp $793e',0xc3,0x793e)
L('menu');zero('nav_latch');zero('mode');setv('selection',1);C('setup_screen');C('menu_draw');C('release_fire')
L('menu_loop');R('halt');C('keys');lc(0xf7fe);R('in a,(c)');R('ld c,a')
for i in range(5):
 R('ld a,c');bit(i);J('menu_num_'+str(i),'nz');setv('selection',i+1);J('menu_choose');L('menu_num_'+str(i))
la('dy');R('or a');J('menu_y_release','z');la('nav_latch');R('or a');J('menu_fire','nz');setv('nav_latch',1);la('dy');cp(255);J('menu_down','nz');la('selection');cp(1);J('menu_fire','z');R('dec a');J('menu_store');L('menu_down');la('selection');cp(5);J('menu_fire','z');R('inc a');L('menu_store');sa('selection');C('menu_draw');J('menu_fire');L('menu_y_release');zero('nav_latch')
L('menu_fire');la('fire');R('or a');J('menu_loop','z');L('menu_choose');C('release_fire');la('selection');cp(5);J('load_vertical','z');sa('mode');J('start_demo')
L('menu_draw');lh('menu_map');ld('new_map');lc(576);R('ldir');la('selection');R('add a,a');add(4);R('ld d,a','ld e,1');imm(11);C('put_cell');C('present');ret()
# Shared native input. QAOP source contract retained; keyboard plus optional Kempston.
L('keys');zero('dx');zero('dy');zero('fire');zero('escape')
pollrow(0xfbfe,0,'kq','dy',255);pollrow(0xfdfe,0,'ka','dy',1);pollrow(0xdffe,1,'ko','dx',255);pollrow(0xdffe,0,'kp','dx',1);pollrow(0x7ffe,0,'ks','fire',1);pollrow(0xfefe,2,'kx','escape',1)
lc(31);R('in a,(c)','ld c,a');andi(224);ret('nz');R('ld a,c');bit(4);J('joy_no_fire','z');setv('joymode',1);setv('fire',1);L('joy_no_fire');la('joymode');R('or a');ret('z');R('ld a,c');bit(0);J('joy_r','z');setv('dx',1);L('joy_r');R('ld a,c');bit(1);J('joy_l','z');setv('dx',255);L('joy_l');R('ld a,c');bit(2);J('joy_d','z');setv('dy',1);L('joy_d');R('ld a,c');bit(3);ret('z');setv('dy',255);ret()
L('release_fire');R('halt');C('keys');la('fire');R('or a');J('release_fire','nz');ret()
# Setup native VRAM and fixed sidebar. Initial writes happen only at profile entry.
L('setup_screen');R('xor a');X('out ($fe),a',0xd3,0xfe);lh(0x4000);ld(0x4001);lc(6143);R('ld (hl),0','ldir');lh(0x5800);la('mode');R('ld l,a','ld h,0');addradd('palette');R('ld a,(hl)');lh(0x5800);R('ld (hl),a');ld(0x5801);lc(767);R('ldir');lh('old_map');R('ld (hl),255');ld('old_map');X('inc de',0x13);lc(575);R('ldir');la('mode');R('or a');ret('z');
# Static HUD attribute column fill, outside the game loop.
lh(0x5818);R('ld b,24');L('hud_attr_loop');R('push bc','push hl');R('ld b,8');L('hud_attr_inner');X('ld (hl),71',0x36,71);R('inc hl','dec b');J('hud_attr_inner','nz');R('pop hl');ld(32);R('add hl,de','pop bc','dec b');J('hud_attr_loop','nz')
# Draw the same fixed HUD via a compact descriptor table.
lh('hud_descriptors');L('hud_text_loop');R('ld a,(hl)','or a');J('hud_text_done','z');R('ld b,a','inc hl','ld e,(hl)','inc hl','ld d,(hl)','inc hl');L('hud_char_loop');R('ld a,(hl)','inc hl','push hl','push de','push bc','ex de,hl');C('draw_tile');R('pop bc','pop de','pop hl','inc de','dec b');J('hud_char_loop','nz');J('hud_text_loop');L('hud_text_done')
# Profile number at right
la('mode');add(48);lh(screen_addr(6*8,27));C('draw_tile');ret()
# init per profile
L('start_demo');C('setup_screen');zero('tick');zero('kills');setv('last_score',255);zero('edge');zero('shield');zero('shield_cd');zero('tank');zero('grace');zero('fire_latch');zero('scroll_phase');setv('px',12);setv('py',20);setv('face_x',0);setv('face_y',255);setv('by',255);setv('ey',255);setv('powerx',12);setv('powery',14);setv('boss_hp',5)
for i in range(4):setv('e'+str(i)+'x',5+i*4);setv('e'+str(i)+'y',3+i);setv('e'+str(i)+'hp',1);zero('e'+str(i)+'dead')
la('mode');cp(3);J('init_non_arena','nz');setv('py',12);L('init_non_arena');cp(4);J('init_non_ground','nz') # A may be 12 if arena, compare actual mode again below
L('init_non_ground');la('mode');cp(4);J('init_done','nz')
for i,x in enumerate([8,12,15,10]):setv('e'+str(i)+'x',x);setv('e'+str(i)+'y',2+i*4);setv('e'+str(i)+'hp',2 if i%2==0 else 3)
L('init_done');C('background');C('compose');C('present');C('release_fire')
la(0x8e91);sa('last_frame');L('demo_loop');C('frame_sync');C('keys');la('escape');R('or a');J('menu','nz');incv('tick');C('background');C('player_move');C('shoot');C('enemies');C('projectiles');C('compose');C('present');J('demo_loop')
# Claymore-derived FRAMES modulo-256 synchronization, minimum two physical IRQs.
L('frame_sync');lh(0x8e91);L('sync_wait');la('last_frame');R('ld b,a','ld a,(hl)','sub b');cp(2);J('sync_done','nc');R('halt');J('sync_wait');L('sync_done');R('ld a,(hl)');sa('last_frame');ret()
# Base map selection: ground uses precomputed repeating 8-row scroll window.
L('background');la('mode');cp(4);J('bg_ground','z');R('dec a');lookup('bg_ptrs');J('bg_copy');L('bg_ground');la('tick');andi(7);J('bg_keep','nz');decv('scroll_phase');la('scroll_phase');andi(7);sa('scroll_phase');L('bg_keep');la('scroll_phase');lookup('ground_ptrs');L('bg_copy');ld('base_map');lc(576);R('ldir');ret()
# player: Circo uses edge-triggered discrete positions, Space horizontal only, arena/ground 2D.
L('player_move');la('grace');R('or a');J('pm_grace_end','z');decv('grace');L('pm_grace_end');la('shield');R('or a');J('pm_shield_end','z');decv('shield');L('pm_shield_end');la('shield_cd');R('or a');J('pm_cd_end','z');decv('shield_cd');L('pm_cd_end');la('mode');cp(1);J('pm_not_circo','nz');la('dx');R('or a');J('pm_circo_release','z');la('edge');R('or a');ret('nz');setv('edge',1);J('pm_x');L('pm_circo_release');zero('edge');ret();L('pm_not_circo');la('mode');cp(2);J('pm_not_space','nz');la('dy');cp(1);J('pm_space_release','nz');la('edge');R('or a');J('pm_space_lock','nz');setv('edge',1);la('shield_cd');R('or a');J('pm_space_lock','nz');setv('shield',35);setv('shield_cd',110);J('pm_space_lock');L('pm_space_release');zero('edge');L('pm_space_lock');zero('dy');L('pm_not_space');la('tick');andi(1);ret('nz')
L('pm_x');copyv('px','oldx');copyv('py','oldy');la('dx');R('or a');J('pm_x_face','z');sa('face_x');copyv('dy','face_y');L('pm_x_face');move('px','dx',1,22);la('mode');cp(1);J('pm_check','z');cp(2);J('pm_check','z');la('dy');R('or a');J('pm_y_face','z');sa('face_y');copyv('dx','face_x');L('pm_y_face');move('py','dy',1,22)
L('pm_check');la('mode');cp(4);ret('nz');pos('p');cell();addradd('base_map');R('ld a,(hl)');cp(1);J('pm_revert','z');cp(2);J('pm_revert','z');pos('p');la('powerx');R('cp e');ret('nz');la('powery');R('cp d');ret('nz');setv('tank',1);setv('powery',255);C('beep');ret();L('pm_revert');copyv('oldx','px');copyv('oldy','py');ret()
# player projectile: single reusable slot; arena/ground shoot last direction, shooters up.
L('shoot');la('by');cp(255);ret('nz');la('fire');R('or a');ret('z');copyv('px','bx');copyv('py','by');zero('bvx');setv('bvy',255);la('mode');cp(3);J('shoot_free','z');cp(4);J('shoot_free','nz');L('shoot_free');la('mode');cp(3);J('shoot_dir','z');cp(4);J('shoot_sound','nz');L('shoot_dir');copyv('face_x','bvx');copyv('face_y','bvy');L('shoot_sound');C('beep');ret()
# enemy positions per pattern; no slot reuse until explosion timer expires.
L('enemies');la('tick');andi(3);J('enemy_fire','nz')
for i in range(4):
 n='e'+str(i);la(n+'dead');R('or a');J(n+'_alive','z');decv(n+'dead');J(n+'_next','nz');setv(n+'y',2+i);setv(n+'x',5+i*4);setv(n+'hp',1);la('mode');cp(4);J(n+'_next','nz');setv(n+'x',[8,12,15,10][i]);setv(n+'hp',2 if i%2==0 else 3);J(n+'_next');L(n+'_alive');la('mode');cp(3);J(n+'_arena','z');cp(2);J(n+'_space','z');J(n+'_down')
 L(n+'_arena');la(n+'x');R('ld b,a');la('px');R('cp b');J(n+'_ay','z');J(n+'_axleft','c');incv(n+'x');J(n+'_ay');L(n+'_axleft');decv(n+'x');L(n+'_ay');la(n+'y');R('ld b,a');la('py');R('cp b');J(n+'_next','z');J(n+'_ayup','c');incv(n+'y');J(n+'_next');L(n+'_ayup');decv(n+'y');J(n+'_next')
 L(n+'_space');la('tick');andi(16);J(n+'_sl','z');la(n+'x');cp(22);J(n+'_down','nc');incv(n+'x');J(n+'_down');L(n+'_sl');la(n+'x');cp(1);J(n+'_down','z');decv(n+'x');L(n+'_down');la('mode');cp(4);J(n+'_adv','nz');la('tick');andi(7 if i%2 else 3);J(n+'_next','nz');L(n+'_adv');incv(n+'y');cp(23);J(n+'_next','c');setv(n+'y',2+i);L(n+'_next')
L('enemy_fire');la('e0dead');R('or a');ret('nz');la('mode');cp(1);ret('z');la('ey');cp(255);ret('nz');la('mode');cp(2);J('ef_normal','nz');la('boss_hp');R('or a');J('ef_normal','z');cp(3);J('ef_normal','nc');la('tick');andi(7);ret('nz');J('ef_boss');L('ef_normal');la('tick');andi(15);ret('nz');la('mode');cp(2);J('ef_actor','nz');la('boss_hp');R('or a');J('ef_actor','z');la('tick');andi(16);J('ef_actor','z');L('ef_boss');setv('ex',11);setv('ey',2);J('ef_aim');L('ef_actor');copyv('e0x','ex');copyv('e0y','ey');L('ef_aim');setv('evx',0);setv('evy',1);la('ex');R('ld b,a');la('px');R('cp b');J('enemy_fire_y','z');J('enemy_fire_left','c');setv('evx',1);J('enemy_fire_y');L('enemy_fire_left');setv('evx',255);L('enemy_fire_y');la('ey');R('ld b,a');la('py');R('cp b');ret('nc');setv('evy',255);ret()
# projectile motion and hits. Contact, shield and short grace windows.
L('projectiles');la('by');cp(255);J('proj_enemy','z');la('bvx');R('ld b,a');la('bx');R('add a,b');cp(24);J('bullet_remove','nc');sa('bx');la('bvy');R('ld b,a');la('by');R('add a,b');cp(24);J('bullet_remove','nc');sa('by')
for i in range(4):
 n='e'+str(i);la(n+'dead');R('or a');J(n+'_hit_next','nz');la('bx');R('ld b,a');la(n+'x');R('cp b');J(n+'_hit_next','nz');la('by');R('ld b,a');la(n+'y');R('cp b');J(n+'_hit_next','nz');decv(n+'hp');J('bullet_remove','nz');setv(n+'dead',4);incv('kills');C('boom');J('bullet_remove');L(n+'_hit_next')
# static boss in space mode; hit one of 3 tiles, 5 HP
la('mode');cp(2);J('proj_enemy','nz');la('boss_hp');R('or a');J('proj_enemy','z');la('by');cp(2);J('proj_enemy','nz');la('bx');cp(10);J('proj_enemy','c');cp(14);J('proj_enemy','nc');decv('boss_hp');J('boss_hit_sound','nz');incv('kills');L('boss_hit_sound');C('boom');J('bullet_remove')
L('bullet_remove');setv('by',255)
L('proj_enemy');la('ey');cp(255);J('contact','z');la('evx');R('ld b,a');la('ex');R('add a,b');cp(24);J('enemy_bullet_remove','nc');sa('ex');la('evy');R('ld b,a');la('ey');R('add a,b');cp(24);J('enemy_bullet_remove','nc');sa('ey');la('ex');R('ld b,a');la('px');R('cp b');J('contact','nz');la('ey');R('ld b,a');la('py');R('cp b');J('contact','nz');C('damage');L('enemy_bullet_remove');setv('ey',255)
L('contact')
for i in range(4):
 n='e'+str(i);la(n+'dead');R('or a');J(n+'_contact_next','nz');la(n+'x');R('ld b,a');la('px');R('cp b');J(n+'_contact_next','nz');la(n+'y');R('ld b,a');la('py');R('cp b');J(n+'_contact_next','nz');la('shield');R('or a');J(n+'_contact_kill','nz');la('tank');R('or a');J(n+'_contact_kill','nz');C('damage');J(n+'_contact_next');L(n+'_contact_kill');setv(n+'dead',4);incv('kills');C('boom');L(n+'_contact_next')
ret()
L('damage');la('shield');R('or a');ret('nz');la('grace');R('or a');ret('nz');la('tank');R('or a');J('damage_player','z');zero('tank');J('damage_grace');L('damage_player');setv('px',12);setv('py',20);L('damage_grace');setv('grace',75);C('boom');ret()
# snapshot compose: only changed tiles written to display. no visible erase pass.
L('compose');lh('base_map');ld('new_map');lc(576);R('ldir');la('mode');cp(2);J('compose_noboss','nz');la('boss_hp');R('or a');J('compose_noboss','z')
for x in range(10,14):R(f'ld d,2',f'ld e,{x}');imm(8);C('put_cell')
L('compose_noboss');la('mode');cp(4);J('compose_no_power','nz');sprite('power',9);L('compose_no_power')
for i in range(4):
 n='e'+str(i);la(n+'dead');R('or a');J(n+'_draw_live','z');sprite(n,7);J(n+'_draw_done');L(n+'_draw_live');la('mode');cp(4);J(n+'_draw_air','nz');sprite(n,5 if i%2 else 6);J(n+'_draw_done');L(n+'_draw_air');sprite(n,4);L(n+'_draw_done')
sprite('b',3);sprite('e',10);la('grace');R('or a');J('draw_player','z');la('tick');andi(2);J('draw_player_skip','nz');L('draw_player');la('shield');R('or a');J('draw_not_shield','z');sprite('p',12);J('draw_player_skip');L('draw_not_shield');la('tank');R('or a');J('draw_not_tank','z');sprite('p',5);J('draw_player_skip');L('draw_not_tank');sprite('p',13);L('draw_player_skip');ret()
L('put_cell');R('push af','ld a,d');cp(24);J('put_invalid','nc');R('ld a,e');cp(24);J('put_invalid','nc');cell();addradd('new_map');R('pop af','ld (hl),a');ret();L('put_invalid');R('pop af');ret()
# Presenter uses index LUT and draws changed cells once, never erase/draw separately.
L('present');lh('new_map');ld('old_map');lc(576);L('present_loop');R('ld a,(de)');rr('cp (hl)');J('present_next','z');R('ld a,(hl)','ld (de),a','push bc','push de','push hl','push af');ld('new_map');R('or a','sbc hl,de','add hl,hl');addradd('cell_lut');R('ld e,(hl)','inc hl','ld d,(hl)','ex de,hl','pop af');C('draw_tile');R('pop hl','pop de','pop bc');L('present_next');R('inc hl','inc de');X('dec bc',0x0b);R('ld a,b','or c');J('present_loop','nz');la('mode');R('or a');ret('z');la('kills');R('ld b,a');la('last_score');R('cp b');ret('z');R('ld a,b');sa('last_score');cp(100);J('score_ok','c');imm(99);L('score_ok');R('ld b,a');imm(0);L('digit_tens');R('ld c,a','ld a,b');cp(10);J('digit_done','c');sub(10);R('ld b,a','ld a,c','inc a');J('digit_tens');L('digit_done');R('ld a,c');add(48);R('push bc');lh(screen_addr(9*8,26));C('draw_tile');R('pop bc','ld a,b');add(48);lh(screen_addr(9*8,27));C('draw_tile');ret()
L('draw_tile');R('push hl','ld l,a','ld h,0','add hl,hl','add hl,hl','add hl,hl');addradd('glyphs');R('ex de,hl','pop hl');# DE source, HL screen destination
for i in range(8):
 R('ld a,(de)','ld (hl),a');
 if i<7:R('inc de','inc h')
ret()
# short nonblocking-in-practice event pulse (~0.3ms). 1-bit beeper.
L('beep');imm(16);X('out ($fe),a',0xd3,0xfe);R('ld b,24');L('beep_wait');R('dec b');J('beep_wait','nz');R('xor a');X('out ($fe),a',0xd3,0xfe);ret()
L('boom');R('ld c,4');L('boom_loop');R('push bc');C('beep');R('pop bc','dec c');J('boom_loop','nz');ret()
# variables and data
for n in ['mode','selection','nav_latch','joymode','dx','dy','fire','escape','tick','kills','edge','shield','shield_cd','tank','grace','fire_latch','scroll_phase','px','py','oldx','oldy','face_x','face_y','bx','by','bvx','bvy','ex','ey','evx','evy','powerx','powery','boss_hp','last_frame','last_score']+[f'e{i}{k}' for i in range(4) for k in ['x','y','hp','dead']]:data(n,[0])
data('palette',[71,70,69,71,68]);data('base_map',bytes(576));data('new_map',bytes(576));data('old_map',bytes(576));data('cell_lut',b''.join(struct.pack('<H',screen_addr(y*8,x)) for y in range(24) for x in range(24)))
def grid():return [[0]*24 for _ in range(24)]
def textrow(g,y,x,s):
 for i,ch in enumerate(s):g[y][x+i]=ord(ch)
def flat(g):return bytes(v for row in g for v in row)
g=grid();textrow(g,1,4,'GRIT ENGINE 48K');textrow(g,3,3,'TECHNOLOGY DEMO');
for y,s in [(6,'1 CIRCO'),(8,'2 SPACE SHOOTER'),(10,'3 ARENA'),(12,'4 GROUND COMBAT'),(14,'5 VERTICAL SHMUP'),(17,'Q/A + FIRE / 1-5'),(19,'X: VOLVER AL MENU'),(21,'5: MEDITERRANEO')]:textrow(g,y,3 if y<17 else 2,s)
data('menu_map',flat(g));g=grid()
for x in range(1,23):g[23][x]=1
for x in (4,9,14,19):
 for y in range(4,19,4):g[y][x]=14
textrow(g,0,2,'CIRCO - POR TOQUES');data('bg1',flat(g));g=grid();textrow(g,0,2,'SPACE - ESCUDO A')
for y in range(3,23):g[y][(y*7)%22+1]=14
data('bg2',flat(g));g=grid();textrow(g,0,2,'ARENA - 8 DIRECCIONES')
for y in range(2,23):g[y][0]=g[y][23]=1
data('bg3',flat(g));rows=[]
for y in range(32):
 row=[0]*24
 for x in [0,1,22,23]:row[x]=1
 for x in range(3,6):row[x]=2 if y%8 in (1,2,3,4) else 1
 for x in range(18,21):row[x]=2 if y%8 in (5,6,7,0) else 1
 for x in (7,16):row[x]=14 if y%4==0 else 0
 rows.append(row)
for i in range(8):labels['ground'+str(i)]=ORG+len(b)+24*i
# pointer labels alias offsets into one 32-row bank
# no duplicate labels in generated assembly; explicit alias equ in header
data('ground_bank',flat(rows));L('bg_ptrs');[DW(n) for n in ['bg1','bg2','bg3']];L('ground_ptrs');[DW('ground'+str(i)) for i in range(8)]
# native 8x8 sprite/font bank. 0 blank, 1 wall, 2 building, 3 bullet, 4 enemy etc.
patterns={1:[255,129,189,165,165,189,129,255],2:[126,255,219,219,255,219,219,255],3:[0,24,24,24,24,24,0,0],4:[0,36,126,219,255,90,36,0],5:[60,126,255,219,219,255,126,60],6:[24,24,60,126,24,36,36,66],7:[66,24,165,90,90,165,24,66],8:[255,129,189,255,231,255,129,255],9:[60,66,153,165,165,153,66,60],10:[0,0,24,60,60,24,0,0],11:[0,32,48,248,248,48,32,0],12:[60,66,153,165,165,129,66,60],13:[24,24,60,60,126,255,219,0],14:[0,0,0,16,0,0,0,0]}
# Frozen native 8x8 glyph bank, no system font dependency for rebuilding.
glyph=(P/'glyphs.bin').read_bytes();assert len(glyph)==1024
desc=bytearray()
for y,string in [(1,'GRIT'),(2,'ENGINE'),(4,'TECH'),(5,'DEMO'),(8,'BAJAS'),(12,'X: MENU'),(15,'QAOP'),(16,'SPACE'),(18,'KEMPSTON')]:
 desc+=bytes([len(string)])+struct.pack('<H',screen_addr(y*8,24))+string.encode()
desc+=b'\0';data('hud_descriptors',desc)
# Characters actually referenced by the demo: no need to archive unused glyphs.
used=set(range(15))|set(map(ord,'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-/: +'))
glyph=b''.join(glyph[i*8:i*8+8] if i in used else bytes(8) for i in range(128))
data('glyphs',glyph)
for offset,n in fix:b[offset:offset+2]=struct.pack('<H',labels[n])
assert ORG+len(b)<0xf000,hex(ORG+len(b));assert labels['load_vertical']<0xa200
code=bytes(b);(P/'demo.bin').write_bytes(code);(P/'demo_symbols.json').write_text(json.dumps(labels,indent=2));(P/'demo.asm').write_text('ORG $9000\n'+''.join(f'ground{i} equ ground_bank+{24*i}\n' for i in range(8))+'\n'.join(listing)+'\n')

print(len(code),hex(ORG+len(code)))
