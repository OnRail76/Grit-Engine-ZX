#!/usr/bin/env python3
"""Exercise actual switch code, with ROM tape transfer and IRQ timing modelled."""
from pathlib import Path
import argparse,json,struct,functools,sys,tempfile,shutil,subprocess
P=Path(__file__).resolve().parent;ROOT=P.parents[1];OLD=ROOT/'demo/technology_demo'
from build import OLD_STUB,SIX_STUB,read_tap

def test(source,out=P,legacy=True):
    out=out.resolve(); source=source.resolve()
    tap=read_tap((out/'GRIT_ENGINE_TECH_DEMO_V1.1.tap').read_bytes()); assert len(tap)==6
    symbols=json.loads((out/'switch_symbols.json').read_text()); ms=json.loads((out/'demo_symbols.json').read_text())
    # Use original five-profile harness in a temporary directory, never overwrite V1.0.
    with tempfile.TemporaryDirectory() as d:
        work=Path(d)
        for p in out.iterdir():
            if p.is_file():shutil.copy2(p,work/p.name)
        for n in ('test_cpu.py','cpu_model.py','formats.py'):shutil.copy2(OLD/n,work/n)
        s=(OLD/'test_demo.py').read_text().replace('GRIT_ENGINE_TECH_DEMO_V1.0.tap','GRIT_ENGINE_TECH_DEMO_V1.1.tap').replace('assert len(r)==4 ','assert len(r)==6 ')
        # Extend only keyboard row decode, not the game emulation.
        s=s.replace('in (0xf7fe,0xfefe)', 'in (0xf7fe,0xfefe,0xeffe)').replace("if port==0xfefe and 'x' in self.keys:a&=~4", "if port==0xfefe and 'x' in self.keys:a&=~4\n   if port==0xeffe and '6' in self.keys:a&=~16")
        if legacy:
            (work/'test_legacy.py').write_text(s);subprocess.run([sys.executable,'-u','test_legacy.py'],cwd=work,check=True)
        # Run in a separate process to avoid importing the Escoria CPU under the same module name.
        probe=s[:s.index('r=read_tap(')]+'''\nc=DemoCPU();c.rununtil('menu_loop');c.assert_video();assert c.v('selection')==1
for n in range(2,7):
 c.next('menu_loop',['a']);assert c.v('selection')==n;c.next('menu_loop',[])
c.next('menu_choose',['space']);c.keys=set();c.rununtil(0xff20);assert c.v('selection')==6
c=DemoCPU();c.rununtil('menu_loop');c.next(0xff20,['6']);assert c.v('selection')==6
(P/'before6.bin').write_bytes(c.m)
print('Common menu: direct 6 and Q/A + FIRE to profile 6 PASS',flush=True)
'''
        (work/'probe.py').write_text(probe);subprocess.run([sys.executable,'probe.py'],cwd=work,check=True)
        before=(work/'before6.bin').read_bytes()
        # Reuse actual Escoria instruction model, add JR and IM2 decoding, mock only ROM LD_BYTES.
        model=(source/'test_cpu.py').read_text().split('# Test TAP blocks and payload.')[0]
        model=model.replace('(0x7ffe,0,16)]','(0x7ffe,0,16),(0xfefe,2,32)]')
        ns={'__file__':str(source/'test_cpu.py')};exec(compile(model,'test_cpu.py','exec'),ns)
        ns['S']=symbols['six'];ns['BIN']=tap[5][1][0x400:]
        ns['blocks']=[bytes([f])+b+bytes([functools.reduce(int.__xor__,bytes([f])+b,0)]) for f,b in tap]
        class CPU(ns['CPU']):
            def step(self):
                pc=self.pc;op=self.m[pc];k=self.m[pc+1] if pc<65535 else 0
                if pc==0x0556:
                    assert not self.keys&16, 'ROM would see BREAK (SPACE held)'
                if op in (0x18,0x20,0x28,0x30,0x38):
                    take=op==0x18 or self.cond((op-0x20)//8);self.pc=(pc+2+(k if k<128 else k-256)*take)&65535;self.t+=12 if take else 7;return
                if op==0xed and k in (0x47,0x5e):self.pc+=2;self.t+=8;return
                super().step()
            def runaddr(self,target,limit=3000000):
                for _ in range(limit):
                    if self.pc==target:return
                    self.step()
                raise AssertionError((hex(target),hex(self.pc)))
        def confirm(c, labels):
            c.runaddr(labels['press']);c.keys=16;c.runaddr(labels['confirm_release']);pos=c.tape_pos
            for _ in range(120):c.step()
            assert c.pc==labels['confirm_release'] and c.tape_pos==pos
            c.keys=0
        for start_pos in (4,0):
            c=CPU();c.m[:]=before;c.pc=OLD_STUB;c.keys=0;c.tape_pos=start_pos
            confirm(c,symbols['to6']);c.runaddr(symbols['entry']);assert c.tape_pos==6 and c.m[0x5b00:0x5b00+len(tap[5][1])]==tap[5][1]
            print('Profile 6 from tape position',start_pos,'held SPACE release PASS',flush=True)
        c.keys=0;c.run_to('loop');assert c.v('phase')==1 and c.v('lives')==3
        c.step_frame(1);assert c.v('px')>80 or c.v('scroll')>0
        snapshot=bytes(c.m);state=(c.t,c.irq,c.sp,c.ie)
        for route in ('x','gameover','win'):
            c=CPU();c.m[:]=snapshot;c.t,c.irq,c.sp,c.ie=state;c.pc=ns['S']['loop'];c.keys=0;c.tape_pos=0
            if route=='x':c.keys=32
            else:
                c.set('lives',0 if route=='gameover' else 1);c.pc=ns['S'][route];c.run_to('press_end');c.keys=16
            c.runaddr(SIX_STUB);c.keys=0;confirm(c,symbols['to5']);c.runaddr(0x6000)
            assert c.tape_pos==4 and c.m[0x6000:]==tap[3][1]
            (work/'returned.bin').write_bytes(c.m)
            resume=s[:s.index('r=read_tap(')]+'''\nc=DemoCPU();c.m[:]=(P/'returned.bin').read_bytes();c.pc=0x6000;c.rununtil('menu_loop');c.assert_video();assert c.v('selection')==1;c.next('demo_loop',['3']);c.assert_video();c.next('menu_loop',['x']);print('Reloaded common selector and entered arena PASS',flush=True)\n'''
            (work/'resume.py').write_text(resume);subprocess.run([sys.executable,'resume.py'],cwd=work,check=True)
            print('Profile 6 -> common menu via',route,'PASS',flush=True)
        print('TAP headers, direct entry, six selector, switch and return PASS (ROM tape and IRQ simulated)',flush=True)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--source',type=Path,default=ROOT/'upstream/Escoria-Sideral/FUENTES');p.add_argument('--output',type=Path,default=P);p.add_argument('--skip-legacy',action='store_true');a=p.parse_args();test(a.source,a.output,not a.skip_legacy)
