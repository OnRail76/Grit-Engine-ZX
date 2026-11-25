from pathlib import Path
import struct, functools, json, zipfile, io
from PIL import Image,ImageDraw
import numpy as np
P=Path(__file__).parent; A=P/'assets'; A.mkdir(exist_ok=True)
ORG=0x6000
b=bytearray(); labels={}; fix=[]; listing=[]
def L(n):
 assert n not in labels,n; labels[n]=ORG+len(b);listing.append(n+':')
def E(s,*v):listing.append('    '+s);b.extend(v)
def W(s,op,n):
 listing.append('    '+s); b.append(op); pos=len(b);b.extend(b'\0\0');
 if isinstance(n,str):fix.append((pos,n))
 else:b[pos:pos+2]=struct.pack('<H',n)
def DW(n):
 pos=len(b);b.extend(b'\0\0');fix.append((pos,n));listing.append('    dw '+n)
def data(n,d):
 L(n);d=bytes(d);b.extend(d)
 for i in range(0,len(d),24):listing.append('    db '+','.join(map(str,d[i:i+24])))
def J(n,c=''):W('jp '+(c+',' if c else '')+n,{'':0xc3,'nz':0xc2,'z':0xca,'nc':0xd2,'c':0xda,'p':0xf2,'m':0xfa}[c],n)
def C(n):W('call '+n,0xcd,n)
def ret(c=''):E('ret '+c,{'':0xc9,'z':0xc8,'nz':0xc0,'c':0xd8,'nc':0xd0,'m':0xf8,'p':0xf0}[c])
def la(n):W('ld a,('+str(n)+')',0x3a,n)
def sa(n):W('ld ('+str(n)+'),a',0x32,n)
def lh(n):W('ld hl,'+str(n),0x21,n)
def ld(n):W('ld de,'+str(n),0x11,n)
def lc(n):W('ld bc,'+str(n),0x01,n)
def lhm(n):W('ld hl,('+str(n)+')',0x2a,n)
def shm(n):W('ld ('+str(n)+'),hl',0x22,n)
def imm(v):E('ld a,'+str(v),0x3e,v&255)
def cp(v):E('cp '+str(v),0xfe,v&255)
def andi(v):E('and '+str(v),0xe6,v)
def add(v):E('add a,'+str(v),0xc6,v&255)
def sub(v):E('sub '+str(v),0xd6,v&255)
def reg(s):
 # fixed register transfers and simple ALU instructions
 if s.startswith('ld ') and ',' in s:
  x,y=s[3:].split(',');rr={'b':0,'c':1,'d':2,'e':3,'h':4,'l':5,'(hl)':6,'a':7}
  if x in rr and y in rr:E(s,0x40+rr[x]*8+rr[y]);return
  if x in rr and y.isdigit():E(s,0x06+rr[x]*8,int(y));return
 d={'xor a':[0xaf],'or a':[0xb7],'or b':[0xb0],'or c':[0xb1],'add a,a':[0x87],'and b':[0xa0],'add a,b':[0x80],'sub b':[0x90],'cp b':[0xb8],'cp c':[0xb9],'inc a':[0x3c],'dec a':[0x3d],'inc b':[0x04],'dec b':[0x05],'inc c':[0x0c],'dec c':[0x0d],'inc hl':[0x23],'dec hl':[0x2b],'inc de':[0x13],'dec de':[0x1b],'inc h':[0x24],'inc l':[0x2c],'inc d':[0x14],'dec h':[0x25],'add hl,hl':[0x29],'add hl,de':[0x19],'add hl,bc':[0x09],'ex de,hl':[0xeb],'push hl':[0xe5],'pop hl':[0xe1],'push de':[0xd5],'pop de':[0xd1],'push bc':[0xc5],'pop bc':[0xc1],'push af':[0xf5],'pop af':[0xf1],'pop ix':[0xdd,0xe1],'inc ix':[0xdd,0x23],'ld a,(de)':[0x1a],'ld (de),a':[0x12],'rrca':[0x0f],'rlca':[0x07],'ldir':[0xed,0xb0],'ldi':[0xed,0xa0],'halt':[0x76],'di':[0xf3],'ei':[0xfb],'im 1':[0xed,0x56],'in a,(c)':[0xed,0x78],'sbc hl,de':[0xed,0x52],'and (ix+0)':[0xdd,0xa6,0],'or (ix+1)':[0xdd,0xb6,1],'ld a,(ix+0)':[0xdd,0x7e,0]}
 E(s,*d[s])
def R(*ss):
 for s in ss:reg(s)
def setv(n,v):imm(v);sa(n)
def zero(n):R('xor a');sa(n)
def bit(i):E('bit '+str(i)+',a',0xcb,0x47+8*i)
def lookup(table): # A index -> HL word
 R('ld l,a','ld h,0','add hl,hl');ld(table);R('add hl,de','ld e,(hl)','inc hl','ld d,(hl)','ex de,hl')
def incv(n):la(n);R('inc a');sa(n)
def decv(n):la(n);R('dec a');sa(n)
def copyv(src,dst):la(src);sa(dst)
# Neptuno Engine: native Z80 machine-code emitter. All addresses resolved below.
import math
ROOT=P
BUF=0x9000; END=0xA200; PHASE=0xA200; CLEAN=0xC700; WORLD=0xD900; SPR=0xF100
STACK=0x9000; IM2TAB=0x7E00; ISR=0x8E8E
# Additional instructions.
def X(s,*v):E(s,*v)
def edword(s,k,n):
 E(s,0xed,k); pos=len(b); b.extend(b'\0\0'); fix.append((pos,n)) if isinstance(n,str) else b.__setitem__(slice(pos,pos+2),struct.pack('<H',n))
def bc_m(n):edword('ld bc,('+str(n)+')',0x4b,n)
def de_m(n):edword('ld de,('+str(n)+')',0x5b,n)
def save_sp(n):edword('ld ('+str(n)+'),sp',0x73,n)
def load_sp(n):edword('ld sp,('+str(n)+')',0x7b,n)
def pad(addr):
 assert ORG+len(b)<=addr,(hex(ORG+len(b)),hex(addr));n=addr-ORG-len(b)
 if n: b.extend(bytes(n));listing.append('    defs '+str(n)+',0')
def jr(n,c=''): # use absolute jp to keep source generator simple
 J(n,c)
def attr(y):return 0x4000+((y&0xc0)<<5)+((y&7)<<8)+((y&0x38)<<2)
def tabwords(n,vals):data(n,b''.join(struct.pack('<H',v) for v in vals))
# Resident low section: entry, fixed HUD, tables and state.
L('entry');J('boot')
# HUD is fixed native pixel bitmap/attributes; copy at level initialization only.
hud=(ROOT/'HUD.scr').read_bytes();data('hud_bitmap',b''.join(hud[attr(y)-0x4000+24:attr(y)-0x4000+32] for y in range(192)))
data('hud_attrs',b''.join(hud[6144+y*32+24:6144+y*32+32] for y in range(24)))
tabwords('rowptr',[BUF+i*24 for i in range(192)])
tabwords('screen_lut',[attr(y) for y in range(192)])
# Phase-local stack chain address table, fixed 48 bytes/scanline + 9 bytes per band wrapper.
# Each band begins with LD (saved_sp),SP (4), then 96 rows, then LD SP,(saved_sp) + RET (5).
TOP=PHASE; BOTTOM=TOP+4+96*48+5
for name,base in [('top_links',TOP),('bottom_links',BOTTOM)]:tabwords(name,[base+4+i*48+1 for i in range(96)])
# lookup tables for native sprite shift variants, phase layout fixed.
shipbase=SPR; dronebase=shipbase+8*96; fighterbase=dronebase+8*48; bulletbase=fighterbase+8*48; blankbase=bulletbase+8*12
for name,base,step in [('ship_ptr',shipbase,96),('drone_ptr',dronebase,48),('fighter_ptr',fighterbase,48),('bullet_ptr',bulletbase,12),('blank_ptr',blankbase,12)]:tabwords(name,[base+i*step for i in range(8)])
# State: coordinate records x,y. y=255 means inactive for bullets.
for n,v in [('head',0),('world_y',0),('tick',0),('dx',0),('dy',0),('fire',0),('joymode',0),('joyraw',0),('cool',0),('sound',0),('bandrow',0),('patch_on',0),('draw_h',0),('phase_error',0)]:data(n,[v])
for n in ['saved_sp','patch_addr','patch_value','band_table','src_start','sprite_table','sprite_data','tmp_ptr']:data(n,[0,0])
for n,xy in [('player',(88,152)),('e0',(36,16)),('e1',(72,48)),('e2',(112,80)),('e3',(144,112)),('s0',(0,255)),('s1',(0,255)),('s2',(0,255)),('s3',(0,255))]:data(n,xy)
for n in ['player','e0','e1','e2','e3','s0','s1','s2','s3']:data('old_'+n,[0,255])
# Place IM2 vector in resident memory. Every possible interrupt vector resolves to 8E8E.
pad(IM2TAB);data('im2_vectors',[0x8e]*257);pad(0x8000)
L('boot');R('di');W('ld sp,$9000',0x31,STACK);R('im 1');X('ld iy,$5c3a',0xfd,0x21,0x3a,0x5c);R('ei');C('load_level');J('load_failed','nc');C('init_level');J('main')
L('load_failed');imm(2);X('out ($fe),a',0xd3,0xfe);R('halt');J('load_failed')
# ROM loader: carry result preserved, ROM mode and IY restored. Fixed-size raw phase packet.
L('load_level');R('di','im 1');X('ld iy,$5c3a',0xfd,0x21,0x3a,0x5c);R('ei');X('ld ix,$a200',0xdd,0x21,0x00,0xa2);ld(0xFFFF-PHASE+1);imm(255);X('scf',0x37);W('call $0556',0xcd,0x0556);R('di');X('push af',0xf5);imm(0x7e);X('ld i,a',0xed,0x47);X('im 2',0xed,0x5e);X('pop af',0xf1);R('ei');ret()
# Copy approved HUD to screen (setup only). Bitmap addresses from LUT, attributes fixed.
L('init_level');R('di','xor a');X('out ($fe),a',0xd3,0xfe);lh('hud_bitmap');shm('tmp_ptr');lh('screen_lut');shm('sprite_table');R('ld b,192');L('hud_loop');R('push bc');lhm('sprite_table');R('ld e,(hl)','inc hl','ld d,(hl)','inc hl');shm('sprite_table');R('ex de,hl');ld(24);R('add hl,de','ex de,hl');lhm('tmp_ptr');lc(8);R('ldir');shm('tmp_ptr');R('pop bc','dec b');J('hud_loop','nz')
lh(0x5800);ld('hud_attrs');R('ld b,24');L('attrrow');R('push bc','ld b,24');L('attrleft');X('ld (hl),69',0x36,69);R('inc hl','dec b');J('attrleft','nz');R('ld b,8');L('attrright');R('ld a,(de)','ld (hl),a','inc de','inc hl','dec b');J('attrright','nz');R('pop bc','dec b');J('attrrow','nz')
# Fill ring with first 192 world rows, initialize clean ring once.
lh(WORLD);ld(BUF);lc(4608);R('ldir');lh(BUF);ld(CLEAN);lc(4608);R('ldir');zero('head');setv('world_y',0);C('draw_snapshot');C('blit_top');C('blit_bottom');C('restore_snapshot');R('ei');ret()
# Two bands: snapshot composed once per 2 interrupts. Top after beam starts, bottom before beam reaches it.
L('main');R('halt');C('keys');C('logic');C('draw_snapshot');C('top_delay');C('blit_top');R('halt');C('blit_bottom');C('keys');C('logic');C('restore_snapshot');C('scroll_one');J('main')
# Init presents one snapshot and restores the buffer before the first scheduled frame.
L('top_delay');lc(80);L('delay_loop');X('dec bc',0x0b);R('ld a,b','or c');J('delay_loop','nz');ret()
# Phase chain setup. Source row = logical head (+96 for bottom), patch only one wrap link if needed.
L('blit_top');la('head');lh('top_links');ld(TOP);J('blit_setup')
L('blit_bottom');la('head');add(96);J('bottom_carry','c');cp(192);J('bottom_ok','c');sub(192);J('bottom_ok');L('bottom_carry');add(64);L('bottom_ok');lh('bottom_links');ld(BOTTOM)
L('blit_setup');sa('bandrow');shm('band_table');R('ex de,hl');shm('band_entry');R('ld l,a','ld h,0','add hl,hl');ld('rowptr');R('add hl,de','ld e,(hl)','inc hl','ld d,(hl)');lhm('band_table');R('ld a,(hl)','inc hl','ld h,(hl)','ld l,a','ld (hl),e','inc hl','ld (hl),d');zero('patch_on');la('bandrow');cp(97);J('blit_go','c');R('ld c,a');imm(192);X('sub c',0x91);R('ld l,a','ld h,0','add hl,hl');de_m('band_table');R('add hl,de','ld e,(hl)','inc hl','ld d,(hl)','ex de,hl');shm('patch_value');X('ld (hl),0',0x36,0);R('inc hl');X('ld (hl),144',0x36,144);R('dec hl');ld(0xfff3);R('add hl,de');shm('patch_addr');ld('saved_sp_sink');R('ld (hl),e','inc hl','ld (hl),d');setv('patch_on',1)
L('blit_go');R('di');L('band_call');W('call band_entry',0xcd,TOP);R('ei');la('patch_on');R('or a');ret('z');lhm('patch_addr');de_m('patch_value');R('ld (hl),e','inc hl','ld (hl),d');ret()
# `band_entry` aliases the CALL's writable immediate, not another state variable.
labels['band_entry']=labels['band_call']+1
# Input copied from GRIT-style port polling, with Kempston fire auto-selection.
L('keys');R('xor a');sa('dx');sa('dy');sa('fire');lc(0xfbfe);R('in a,(c)');bit(0);J('kq','nz');setv('dy',255)
L('kq');lc(0xfdfe);R('in a,(c)');bit(0);J('ka','nz');setv('dy',1)
L('ka');lc(0xdffe);R('in a,(c)');bit(1);J('ko','nz');setv('dx',255)
L('ko');R('in a,(c)');bit(0);J('kp','nz');setv('dx',1)
L('kp');lc(0x7ffe);R('in a,(c)');bit(0);J('ks','nz');setv('fire',1)
L('ks');lc(31);R('in a,(c)','ld b,a');andi(224);ret('nz');R('ld a,b');sa('joyraw');bit(4);J('kj','z');setv('joymode',1)
L('kj');la('joymode');R('or a');ret('z');la('joyraw');bit(0);J('kj1','z');setv('dx',1)
L('kj1');la('joyraw');bit(1);J('kj2','z');setv('dx',255)
L('kj2');la('joyraw');bit(2);J('kj3','z');setv('dy',1)
L('kj3');la('joyraw');bit(3);J('kj4','z');setv('dy',255)
L('kj4');la('joyraw');bit(4);ret('z');setv('fire',1);ret()
# 50 Hz logic; player speed 1 px/tick, y bound 0..176 and x <=168 so shifted 3-byte sprite fits.
labels['player_y']=labels['player']+1
L('logic');incv('tick');la('dx');R('ld b,a');la('player');R('add a,b');cp(169);J('mx','nc');sa('player');L('mx');la('dy');R('ld b,a');la('player_y');R('add a,b');cp(177);J('my','nc');sa('player_y');L('my')
# Four independent enemies: y advance 1 px/tick, wrap after 176; x moves from triangular table.
for j,(base,off) in enumerate([(36,0),(72,16),(112,32),(144,48)]):
 n=f'e{j}';labels[n+'_y']=labels[n]+1;la(n+'_y');R('inc a');cp(177);J(n+'_yy','c');R('xor a');L(n+'_yy');sa(n+'_y');la('tick');add(off);andi(31);cp(16);J(n+'_xx','c');R('ld b,a');imm(31);R('sub b');L(n+'_xx');add(base);sa(n)
# Move four player projectiles; inactive stays 255.
for j in range(4):
 n=f's{j}';labels[n+'_y']=labels[n]+1;la(n+'_y');cp(255);J(n+'_skip','z');cp(4);J(n+'_move','nc');imm(255);J(n+'_store');L(n+'_move');sub(4);L(n+'_store');sa(n+'_y');L(n+'_skip')
la('cool');R('or a');J('tryfire','z');R('dec a');sa('cool');ret()
L('tryfire');la('fire');R('or a');ret('z');la('player_y');cp(4);ret('c')
for j in range(4):
 la(f's{j}_y');cp(255);J(f'spawn{j}','z')
ret()
for j in range(4):
 L(f'spawn{j}');la('player');add(7);sa(f's{j}');la('player_y');sub(4);sa(f's{j}_y');setv('cool',7);C('beep');ret()
# Short audible pulse: 3 periods (~2.1 ms), no frame wait; border always black.
L('beep');R('ld b,3');L('beep_loop');imm(16);X('out ($fe),a',0xd3,0xfe);R('ld c,24');L('beep_high');R('dec c');J('beep_high','nz');R('xor a');X('out ($fe),a',0xd3,0xfe);R('ld c,24');L('beep_low');R('dec c');J('beep_low','nz');R('dec b');J('beep_loop','nz');ret()
# Pixel ring address: BC = y,x (B=y C=x); HL points to physical row + x/8.
L('ring_addr');R('ld a,b','ld hl,0') if False else None
la('head');R('add a,b'); # sum can exceed 255: need carry-aware mod 192
J('ring_carry','c');cp(192);J('ring_ok','c');sub(192);J('ring_ok');L('ring_carry');add(64);L('ring_ok');R('ld l,a','ld h,0','add hl,hl');ld('rowptr');R('add hl,de','ld e,(hl)','inc hl','ld d,(hl)','ex de,hl','ld a,c','rrca','rrca','rrca');andi(31);R('ld e,a','ld d,0','add hl,de');ret()
# draw_snapshot called only on restored buffer. Save coordinates used for later restoration.
L('draw_snapshot')
for n,table,h,mask in [('player','ship_ptr',16,True)]+[(f'e{i}','drone_ptr' if i%2==0 else 'fighter_ptr',16,False) for i in range(4)]+[(f's{i}','bullet_ptr',4,False) for i in range(4)]:
 bc_m(n);lh(table);imm(h);C('draw_mask' if mask else 'draw_or')
lh('player');ld('old_player');lc(18);R('ldir');ret()
# BC coordinate, HL shift table, A height; DE sprite bytes, HL destination.
L('draw_mask');sa('draw_h');C('sprite_setup');ret('c');la('draw_h');R('ld b,a');L('maskrow')
for _ in range(3):R('ld a,(de)');X('and (hl)',0xa6);R('inc de','ld c,a','ld a,(de)','or c','ld (hl),a','inc de','inc hl')
C('next_row');R('dec b');J('maskrow','nz');ret()
L('draw_or');sa('draw_h');C('sprite_setup');ret('c');la('draw_h');R('ld b,a');L('orrow')
for _ in range(3):R('ld a,(de)');X('or (hl)',0xb6);R('ld (hl),a','inc de','inc hl')
C('next_row');R('dec b');J('orrow','nz');ret()
L('sprite_setup');R('ld a,b');cp(192);ret('nc') if False else None
J('sprite_inactive','nc');R('ld a,c');andi(7);R('add a,a','ld e,a','ld d,0','add hl,de','ld e,(hl)','inc hl','ld d,(hl)','push de');C('ring_addr');R('pop de','or a');ret()
L('sprite_inactive');X('scf',0x37);ret()
L('next_row');R('ld a,l');add(21);R('ld l,a');J('next_noc','nc');R('inc h');L('next_noc');R('ld a,h');cp(0xa2);ret('c');R('ld h,144');ret()
# Restore all old regions using clean ring. No VRAM access and no order dependency.
L('restore_snapshot')
for n,h in [('player',16)]+[(f'e{i}',16) for i in range(4)]+[(f's{i}',4) for i in range(4)]:bc_m('old_'+n);imm(h);C('restore_rect')
ret()
L('restore_rect');sa('draw_h');R('ld a,b');cp(192);ret('nc');C('ring_addr');R('ld e,l','ld a,h');add((CLEAN-BUF)>>8);R('ld d,a');la('draw_h');R('ld b,a');L('restore_row')
for _ in range(3):R('ld a,(de)','ld (hl),a','inc de','inc hl')
C('next_row');R('ld e,l','ld a,h');add((CLEAN-BUF)>>8);R('ld d,a','dec b');J('restore_row','nz');ret()
# One-pixel downward scroll: replace only the new ring head, clean + compositing copy.
L('scroll_one');la('head');R('or a');J('scroll_nz','nz');imm(192);L('scroll_nz');R('dec a');sa('head');R('ld l,a','ld h,0','add hl,hl');ld('rowptr');R('add hl,de','ld e,(hl)','inc hl','ld d,(hl)');X('ld (src_start),de',0xed,0x53,0,0);fix.append((len(b)-2,'src_start'));la('world_y');R('dec a');sa('world_y');R('ld l,a','ld h,0','add hl,hl','add hl,hl','add hl,hl','push hl','add hl,hl','pop de','add hl,de');ld(WORLD);R('add hl,de');de_m('src_start');R('push hl','push de');lc(24);R('ldir','pop hl','pop de','ex de,hl'); # HL world row, DE ring row
R('ld a,d');add((CLEAN-BUF)>>8);R('ld d,a');lc(24);R('ldir');ret()
# Resident interrupt handler and reserved stack.
# IM2 handler preserves registers, no ROM or contended stack accesses during SP transfer.
print('high code ends',hex(ORG+len(b)))
pad(ISR);L('isr');R('ei');X('reti',0xed,0x4d);pad(0x8f00);L('saved_sp_sink');data('sink',[0,0]);pad(0x9000)
# End of resident kernel.
for pos,n in fix:b[pos:pos+2]=struct.pack('<H',labels[n])
kernel=bytes(b);assert len(kernel)==0x3000
# Phase pack: two unrolled stack chains; group saves source SP into next LD SP operand.
phase=bytearray(0x10000-PHASE)
phase_asm=[]
def emit_phase(addr,s):phase[addr-PHASE:addr-PHASE+len(s)]=s
for band,base in enumerate([TOP,BOTTOM]):
 emit_phase(base,bytes([0xed,0x73])+struct.pack('<H',labels['saved_sp']));phase_asm.append(f'ORG ${base:04X}\n    ld (saved_sp),sp')
 for row in range(96):
  y=band*96+row; dst=attr(y)
  for group in range(2):
   here=base+4+row*48+group*24
   target=here+25 if not(row==95 and group==1) else labels['saved_sp_sink']
   code=bytes([0x31,0,0,0xc1,0xd1,0xe1,0xd9,0xc1,0xd1,0xe1,0xed,0x73])+struct.pack('<H',target)+bytes([0x31])+struct.pack('<H',dst+(group+1)*12)+bytes([0xe5,0xd5,0xc5,0xd9,0xe5,0xd5,0xc5]);assert len(code)==24
   emit_phase(here,code)
   phase_asm.append(f'row_{y}_{group}:\n    ld sp,0\n    pop bc\n    pop de\n    pop hl\n    exx\n    pop bc\n    pop de\n    pop hl\n    ld (${target:04X}),sp\n    ld sp,${dst+(group+1)*12:04X}\n    push hl\n    push de\n    push bc\n    exx\n    push hl\n    push de\n    push bc')
 end=base+4+96*48;emit_phase(end,bytes([0xed,0x7b])+struct.pack('<H',labels['saved_sp'])+bytes([0xc9]));phase_asm.append('    ld sp,(saved_sp)\n    ret')
assert BOTTOM+4617<=CLEAN
# Repeating continuous test terrain, native 1bpp, sparse water and coast silhouette.
img=Image.new('1',(192,256));d=ImageDraw.Draw(img)
for y in range(256):
 left=15+int(9*math.sin(y*2*math.pi/256)+5*math.sin(y*4*math.pi/256));right=176+int(8*math.sin((y+60)*2*math.pi/256))
 d.point((left,y),fill=1);d.point((left-2,y),fill=1);d.point((right,y),fill=1);d.point((right+2,y),fill=1)
 for x in range(0,left-3):
  if (x+y*3)%11==0:d.point((x,y),fill=1)
 for x in range(right+3,192):
  if (x+y*3)%11==0:d.point((x,y),fill=1)
 if y%13==3:
  for x in range(36+(y%5)*3,155,41):d.line((x,y,x+2,y),fill=1)
emit_phase(WORLD,img.tobytes());img.save(ROOT/'terrain.png')
# Exact 8 shift variants, 3 bytes/line, player's original 16x24 adapted to 16x16 for this benchmark.
def shifted(raw,mask,h,base):
 a=np.unpackbits(np.frombuffer(raw,dtype=np.uint8)).reshape(h,-1);m=np.unpackbits(np.frombuffer(mask,dtype=np.uint8)).reshape(h,-1) if mask is not None else None
 for shift in range(8):
  x=np.zeros((h,24),np.uint8);x[:,shift:shift+a.shape[1]]=a;packed=np.packbits(x,axis=1)
  if m is not None:
   mm=np.ones((h,24),np.uint8);mm[:,shift:shift+a.shape[1]]=m;mp=np.packbits(mm,axis=1);assert not (mp&packed).any();z=np.empty((h,6),np.uint8);z[:,::2]=mp;z[:,1::2]=packed;packed=z
  emit_phase(base+shift*packed.size,packed.tobytes())
ship=Image.frombytes('1',(16,24),(ROOT/'cielo_rojo_0.bitmap.bin').read_bytes()).resize((16,16),Image.Resampling.NEAREST);mk=Image.frombytes('1',(16,24),(ROOT/'cielo_rojo_0.mask.bin').read_bytes()).resize((16,16),Image.Resampling.NEAREST);shifted(ship.tobytes(),mk.tobytes(),16,shipbase)
shifted((ROOT/'DRON_bitmap.bin').read_bytes()[:32],None,16,dronebase);shifted((ROOT/'NAVE_VERTICAL_bitmap.bin').read_bytes()[4*32:5*32],None,16,fighterbase);shifted(bytes([0xc0]*4),None,4,bulletbase)
# TAP BASIC loader then CODE block then raw phase data (LD-BYTES).
def block(flag,p):q=bytes([flag])+p;return struct.pack('<H',len(q)+1)+q+bytes([functools.reduce(int.__xor__,q,0)])
def header(t,n,l,p1,p2):return block(0,bytes([t])+n.encode().ljust(10,b' ')[:10]+struct.pack('<HHH',l,p1,p2))
def num(n):return str(n).encode()+bytes([14,0,0,n&255,n>>8,0])
line=bytes([0xfd])+num(24575)+b':'+bytes([0xef])+b'""'+bytes([0xaf])+b':'+bytes([0xf9,0xc0])+num(24576)+b'\r';program=b'\x00\x0a'+struct.pack('<H',len(line))+line
out=header(0,'NEPTUNO',len(program),10,len(program))+block(255,program)+header(3,'ENGINE',len(kernel),ORG,0)+block(255,kernel)+block(255,phase)
(ROOT/'Neptuno_Engine.tap').write_bytes(out);(ROOT/'kernel.bin').write_bytes(kernel);(ROOT/'phase.bin').write_bytes(phase);(ROOT/'symbols.json').write_text(json.dumps(labels,indent=2));(ROOT/'kernel.asm').write_text('ORG $6000\n'+''.join(f'{k} equ ${v:04X}\n' for k,v in labels.items() if k=='band_entry' or k.endswith('_y') and k!='world_y')+'\n'.join(listing).replace('call band_entry','call $A200'));(ROOT/'stack_blaster.asm').write_text(f'saved_sp equ ${labels["saved_sp"]:04X}\n'+'\n'.join(phase_asm));print('TAP',len(out),'kernel',len(kernel),'phase',len(phase),'top/bottom',hex(TOP),hex(BOTTOM),'sprite end',hex(bulletbase+96))
