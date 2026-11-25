"""Build single-load 48K Technology Demo. All switching is RAM-only.
Original Neptuno level 1 kernel/phase, with entry, end and X hooks.
Relocated menu overlays the circular buffer and generated Stack Blast.
"""
from pathlib import Path
import json,struct,hashlib,subprocess,sys
import emitter as e
from codec import compress,decompress
from formats import tap_block,read_tap,screen_addr
P=Path(__file__).resolve().parent
subprocess.run([sys.executable,str(P/'build_demo.py')],check=True)
m=json.loads((P/'demo_symbols.json').read_text());v=json.loads((P/'symbols1.json').read_text())
menu=bytearray((P/'demo.bin').read_bytes());menu[m['cell_lut']-0x9000:m['menu_map']-0x9000]=bytes(1152)
packed=compress(menu);assert decompress(packed)==menu;(P/'menu.lz').write_bytes(packed)
# Controller replaces unused title / tape flow. All archive intervals are exclusive at end.
ranges=[(0x5b00,0x6000),(0x7581,0x7939),(0x7c7a,0x7c8b),(0x7cc4,0x7d81),(0x7df9,0x7e70),(0x8e92,0x8f00),(0xc6a8,0xc700),(0xfbe0,0xfd80),(0xf940,0xfa60),(0xfde0,0xfea0),(0xff00,0x10000),(0x6d2f,0x6d5a)]
chunks=[];i=0
for a,b in ranges:
 n=min(b-a,len(packed)-i)
 if n:chunks.append((a,packed[i:i+n]));i+=n
assert i==len(packed),(i,len(packed));assert len(packed)<6144
# Emit exact machine code at $793E; same emitter as the other profiles.
e.ORG=0x793e
from emitter import L,E,W,R,J,C,ret,lh,ld,lc,la,sa,lhm,shm,imm,andi,add,cp,bit,zero,setv,DW,data
# aliases for references into the existing resident vertical kernel
for n,a in v.items():e.labels['v_'+n]=a
# First instruction is target of menu option 5.
L('vertical_entry');R('di');W('ld sp,$9000',0x31,0x9000);la(m['joymode']);sa(v['joymode']);lh(v['isr_audio']);shm(0x8e8f)
# Rebuild the original two unrolled bands exactly, starting with original screen LUT.
lh(v['screen_lut']);shm('lut_ptr');ld(0xa200);C('make_band');C('make_band')
# Set IM2 (never call ROM once the system workspace is repurposed).
imm(0x7f);E('ld i,a',0xed,0x47);E('im 2',0xed,0x5e);R('xor a');sa(v['cheat_on']);sa(v['carrying']);sa(v['irq_flag']);sa(v['sound']);sa(v['phase_error']);E('out ($fe),a',0xd3,0xfe)
for j in range(6):sa(v['score'+str(j)])
setv(v['lives'],3);C('v_init_level');J('v_main')
# Fresh boot: move first archive chunk from temporary backbuffer to former BASIC workspace.
L('boot_once');R('di');W('ld sp,$8fe0',0x31,0x8fe0);lh(0x9000);ld(0x5b00);lc(len(chunks[0][1]));R('ldir');J('menu_restore')
# Safe return: reset stack, silence beeper, black attributes, gather compressed menu in bitmap.
L('menu_restore');R('di');W('ld sp,$8fe0',0x31,0x8fe0);R('xor a');E('out ($fe),a',0xd3,0xfe);lh(0x5800);R('ld (hl),0');ld(0x5801);lc(767);R('ldir');ld(0x4000)
for a,chunk in chunks:
 lh(a);lc(len(chunk));R('ldir')
lh(0x4000);ld(0x9000);C('decode')
# Regenerate the menu's 24x24 address LUT from the vertical 192-line screen table.
lh(v['screen_lut']);ld(m['cell_lut']);R('ld b,24');L('lut_row');R('push bc','push hl','ld c,(hl)','inc hl','ld b,(hl)');imm(24);L('lut_col');R('push af','ld a,c','ld (de),a','inc de','ld a,b','ld (de),a','inc de','inc bc','pop af','dec a');J('lut_col','nz');R('pop hl');lc(16);R('add hl,bc','pop bc','dec b');J('lut_row','nz')
# IM2 menu handler increments a private byte instead of relying on ROM FRAMES.
lh('menu_irq');shm(0x8e8f);zero(0x8e91);imm(0x7f);E('ld i,a',0xed,0x47);E('im 2',0xed,0x5e);W('jp menu_entry',0xc3,m['entry'])
L('menu_irq');R('push af','push hl');lh(0x8e91);E('inc (hl)',0x34);R('pop hl','pop af','ei');E('reti',0xed,0x4d)
# Safe at the start of a display cycle, normal stack restored. Exit takes precedence.
L('keys_x');lc(0xfefe);R('in a,(c)');bit(2);J('menu_restore','z');J('v_keys')
# Compact LZ decoder: literal run, short match (distance 1..256), long match.
L('decode');R('ld a,(hl)','inc hl','or a');ret('z');bit(7);J('match','nz');R('ld c,a','ld b,0','ldir');J('decode')
L('match');R('push af');bit(6);J('long_match','nz');R('ld c,(hl)','inc hl','ld b,0','inc bc');J('match_copy');L('long_match');R('ld c,(hl)','inc hl','ld b,(hl)','inc hl');L('match_copy');R('push hl','push de','pop hl','or a');E('sbc hl,bc',0xed,0x42);R('pop bc','pop af','push bc');andi(63);add(3);R('ld c,a','ld b,0','ldir','pop hl');J('decode')
# Generate 96 rows of two stack-copy groups. DE is next code byte on entry/exit.
L('make_band');lh('band_head');lc(4);R('ldir');setv('row_count',96)
L('band_row');lhm('lut_ptr');R('ld c,(hl)','inc hl','ld b,(hl)','inc hl');shm('lut_ptr');R('ld h,b','ld l,c');shm('vram_ptr');setv('group_count',2)
L('band_group');R('push de');lh('group_template');lc(24);R('ldir');R('pop hl','push de');lc(12);R('add hl,bc','push hl');# HL = group +12 (target operand), DE next group
la('row_count');cp(1);J('chain_next','nz');la('group_count');cp(1);J('chain_next','nz');lh(v['saved_sp_sink']);J('chain_target');L('chain_next');R('ld h,d','ld l,e','inc hl');L('chain_target');R('ld b,h','ld c,l','pop hl','ld (hl),c','inc hl','ld (hl),b','inc hl','inc hl','push hl');lhm('vram_ptr');lc(12);R('add hl,bc');shm('vram_ptr');R('ld b,h','ld c,l','pop hl','ld (hl),c','inc hl','ld (hl),b','pop de');la('group_count');R('dec a');sa('group_count');J('band_group','nz');la('row_count');R('dec a');sa('row_count');J('band_row','nz');lh('band_tail');lc(5);R('ldir');ret()
# Constants from original unrolled routines. Operands set dynamically above.
phase=(P/'phase1.bin').read_bytes();data('band_head',phase[:4]);data('group_template',phase[4:28]);data('band_tail',phase[4612:4617]);data('row_count',[0]);data('group_count',[0]);data('lut_ptr',[0,0]);data('vram_ptr',[0,0]);
for pos,n in e.fix:e.b[pos:pos+2]=struct.pack('<H',e.labels[n])
assert e.ORG+len(e.b)<=v['reset_game'],(hex(e.ORG+len(e.b)),len(e.b));print('controller',len(e.b),hex(e.ORG+len(e.b)),'archive',len(packed))
(P/'controller.asm').write_text('ORG $793E\n'+'\n'.join(e.listing)+'\n');(P/'controller.bin').write_bytes(e.b);(P/'controller_symbols.json').write_text(json.dumps({n:a for n,a in e.labels.items() if not n.startswith('v_')},indent=2))
# Build single CODE block. No subsequent tape access. All game data from phase 1 only.
k=(P/'kernel1.bin').read_bytes();mem=bytearray(65536);mem[0x6000:0x9000]=k;mem[0xa200:]=phase
mem[0x793e:0x793e+len(e.b)]=e.b
for a,chunk in chunks:mem[(0x9000 if a==0x5b00 else a):(0x9000 if a==0x5b00 else a)+len(chunk)]=chunk
# Note: stack is 0x8f02..0x8fff; archive never uses it. Patch only entry and two main loop targets.
def jp(addr,target,op=0xc3):mem[addr:addr+3]=bytes([op])+struct.pack('<H',target)
jp(0x6000,e.labels['boot_once']);assert mem[v['frame_a_ready']]==0xcd;jp(v['frame_a_ready'],e.labels['keys_x'],0xcd)
assert mem[v['top_delay']-3:v['top_delay']]==bytes([0xc3])+struct.pack('<H',v['end_game']);jp(v['top_delay']-3,e.labels['menu_restore'])
code=bytes(mem[0x6000:]);(P/'resident.bin').write_bytes(code)
def num(n):return str(n).encode()+bytes([14,0,0,n&255,n>>8,0])
def header(t,n,l,p1,p2):return tap_block(0,bytes([t])+n.encode().ljust(10,b' ')[:10]+struct.pack('<HHH',l,p1,p2))
line=bytes([0xfd])+num(24575)+b':'+bytes([0xef])+b'""'+bytes([0xaf])+b':'+bytes([0xf9,0xc0])+num(24576)+b'\r';program=b'\x00\x0a'+struct.pack('<H',len(line))+line
out=header(0,'GRIT DEMO',len(program),10,len(program))+tap_block(255,program)+header(3,'GRIT CORE',len(code),0x6000,0)+tap_block(255,code)
assert len(read_tap(out))==4
(P/'GRIT_ENGINE_TECH_DEMO_V1.0.tap').write_bytes(out);(P/'archive_map.json').write_text(json.dumps({'chunks':[(hex(a),len(c)) for a,c in chunks],'size':len(packed)},indent=2));print('TAP',len(out),hashlib.sha256(out).hexdigest())
