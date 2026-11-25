from test_cpu import EngineCPU,sy as vs
from formats import read_tap,screen_addr
from pathlib import Path
import json, random,struct,hashlib
from PIL import Image
P=Path(__file__).parent;ms=json.loads((P/'demo_symbols.json').read_text());cs=json.loads((P/'controller_symbols.json').read_text());chunks=[(int(a,16),n) for a,n in json.loads((P/'archive_map.json').read_text())['chunks']];original=(P/'phase1.bin').read_bytes();code=(P/'resident.bin').read_bytes()
class DemoCPU(EngineCPU):
 def __init__(self):
  super().__init__();self.m[0x6000:]=code;self.pc=0x6000;self.sp=0x5afe;self.enabled=False;self.romcalls=0
 def step(self):
  pc=self.pc;op=self.m[pc];t=self.cycles
  assert pc>=0x6000 or pc==0x2222,('unexpected PC',hex(pc))
  if op==0xf3:self.enabled=False
  if op==0xfb:self.enabled=True
  if self.m[pc:pc+2]==b'\xed\x78' and self.get16(0) in (0xf7fe,0xfefe):
   port=self.get16(0);a=255
   for i in range(5):
    if port==0xf7fe and str(i+1) in self.keys:a&=~(1<<i)
   if port==0xfefe and 'x' in self.keys:a&=~4
   self.r[7]=a;self.pc+=2;self.cycles+=12
  else:super().step()
  # Original instruction model handles vertical HALT and audio waits.
  # Menu interrupt is a different real handler, model its side effect.
  if self.enabled and self.cycles//69888!=t//69888 and int.from_bytes(self.m[0x8e8f:0x8e91],'little')==cs['menu_irq']:
   self.m[0x8e91]=(self.m[0x8e91]+self.cycles//69888-t//69888)&255
 def next(self,lab,keys=()):
  self.keys=set(keys);self.step();self.rununtil(lab,limit=3000000)
 def rununtil(self,lab,limit=3000000):
  if isinstance(lab,str):lab=ms.get(lab,cs.get(lab,vs.get(lab)))
  for _ in range(limit):
   if self.pc==lab:return
   self.step()
  raise AssertionError(('limit',hex(lab),hex(self.pc)))
 def v(self,n):return self.m[ms[n]]
 def vv(self,n):return self.m[vs[n]]
 def setv(self,n,v):self.m[ms[n]]=v
 def setvv(self,n,v):self.m[vs[n]]=v
 def call(self,name,vertical=False):
  sp=self.sp;self.push(0x2222);self.pc=(vs if vertical else ms)[name];self.rununtil(0x2222);assert self.sp==sp
 def assert_video(self):
  glyph=self.m[ms['glyphs']:ms['glyphs']+1024];tiles=self.m[ms['new_map']:ms['new_map']+576]
  for i,t in enumerate(tiles):
   for y in range(8):assert self.m[screen_addr((i//24)*8+y,i%24)]==glyph[t*8+y],(self.v('mode'),i,t,y)
  assert self.m[ms['new_map']:ms['new_map']+576]==self.m[ms['old_map']:ms['old_map']+576]
 def capture(self,name):
  im=Image.new('RGB',(256,192));p=im.load();rgb=[(0,0,0),(0,0,255),(255,0,0),(255,0,255),(0,255,0),(0,255,255),(255,255,0),(255,255,255)]
  for y in range(192):
   for x in range(256):
    a=self.m[0x5800+y//8*32+x//8];v=self.m[screen_addr(y,x//8)];p[x,y]=rgb[(a&7) if v&(128>>(x%8)) else ((a>>3)&7)]
  im.resize((768,576),Image.Resampling.NEAREST).save(P/name)
 def archive(self):return b''.join(self.m[a:a+n] for a,n in chunks)
 def enter5(self):
  self.next('vertical_entry',['5']);self.keys=set();self.rununtil(vs['init_level']);assert self.m[0xa200:0xa200+9234]==original[:9234],next((i for i in range(9234) if self.m[0xa200+i]!=original[i]),None)
  self.rununtil(vs['main']);assert self.sp==0x9000 and self.vv('lives')==3 and self.vv('game_state')==0;assert self.archive()==archive
 def exit5(self,keys=['x']):
  self.next('menu_loop',keys);assert self.sp==0x8fe0;self.assert_video();assert self.archive()==archive
r=read_tap((P/'GRIT_ENGINE_TECH_DEMO_V1.0.tap').read_bytes());assert len(r)==4 and r[3][1]==code;assert struct.unpack('<HHH',r[2][1][-6:])[:2]==(40960,0x6000)
c=DemoCPU();c.rununtil('menu_loop');c.assert_video();c.capture('menu.png');assert c.sp==0x8fe0;archive=c.archive();assert archive==(P/'menu.lz').read_bytes();print('Boot, exact unpacking and initial menu: PASS',flush=True)
rng=random.Random(2026)
for mode in range(1,5):
 c.next('demo_loop',[str(mode)]);assert c.v('mode')==mode;c.assert_video();c.capture(f'profile{mode}.png');a=bytes(c.m[0x5800:0x5b00]);worst=0
 for i in range(100):
  keys=[rng.choice(['q','a','o','p','space'])] if i%3 else ['q','p','space'];t=c.cycles;c.next('demo_loop',keys);worst=max(worst,c.cycles-t);assert c.sp==0x8fe0;assert bytes(c.m[0x5800:0x5b00])==a;c.assert_video();assert 1<=c.v('px')<=22 and 1<=c.v('py')<=22
 c.capture(f'profile{mode}_action.png');c.next('menu_loop',['x']);c.assert_video();assert c.archive()==archive;print('profile',mode,'100 snapshots, X return PASS',flush=True)
# Entire vertical phase is entered without ROM calls. Original terrain and stack chains checked.
c.enter5();c.capture('profile5.png');print('Direct entry to Mediterranean; regenerated stack chains exact: PASS',flush=True)
# Exercise real scroll, ship and bullets for 100 frames, then X while active.
for i in range(100):
 c.next(vs['main'],['space','p'] if i%50<25 else ['space','o']);assert c.sp==0x9000;assert c.archive()==archive
c.capture('profile5_action.png');c.exit5();print('Vertical 100 frames and X return: PASS',flush=True)
# Re-entry repeatedly, and simulate the actual final-life condition in death routine.
c.enter5();c.setvv('lives',0);c.setvv('death',1);c.setvv('death_timer',1);c.exit5([]);print('Final life / actual death transition to menu: PASS',flush=True)
# Boss defeat transition after its animation (game state 2), not load a second stage.
c.enter5();c.setvv('game_state',2);c.exit5([]);print('Boss defeat state returns to menu: PASS',flush=True)
# Return to a compact profile after multiple vertical re-entries.
c.next('demo_loop',['3']);c.assert_video();c.next('menu_loop',['x']);c.enter5();c.exit5();print('Repeated menu/arena/vertical switching and four tape checksums: PASS',flush=True)
