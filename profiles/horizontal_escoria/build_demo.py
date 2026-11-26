#!/usr/bin/env python3
"""Build a standalone single-phase technical demo from pinned Escoria V1.0.
Never writes to the original game tree. Uses its native 48K code generator.
"""
from pathlib import Path
import argparse, hashlib, subprocess, sys, tempfile, shutil, struct, functools, json
ROOT=Path(__file__).resolve().parents[2]
GOLD='250c3210909e3479801fbec8212b2745d588a9035ae2c6b7c4d87c847a8990f2'

def replace(s,old,new):
    if s.count(old)!=1: raise RuntimeError('Unexpected upstream generator: '+old[:90])
    return s.replace(old,new,1)

def split(data):
    blocks=[]; i=0
    while i<len(data):
        n=struct.unpack_from('<H',data,i)[0]; b=data[i+2:i+2+n]
        assert n>=2 and len(b)==n and functools.reduce(int.__xor__,b)==0
        blocks.append(data[i:i+2+n]); i+=n+2
    assert i==len(data)
    return blocks

def build(src,out):
    src=src.resolve(); out=out.resolve(); out.mkdir(parents=True,exist_ok=True)
    if hashlib.sha256((src.parent/'JUEGO/ESCORIA_SIDERAL_V1.0.tap').read_bytes()).hexdigest()!=GOLD: raise RuntimeError('Gold Master distinto')
    with tempfile.TemporaryDirectory(prefix='grit-escoria-') as tmp:
        work=Path(tmp)/'FUENTES'; shutil.copytree(src,work)
        s=(work/'build.py').read_text()
        s=replace(s,"lab('loop');call('sync');call('render_begin')","lab('loop');call('sync');port(0xfefe);bit(2);jp('title','z');call('render_begin')")
        s=replace(s,"lab('title_fire');branch_var('cheat',1,'title_start_release');branch_var('cheat_steps',2,'title_start_release','nz');", "lab('title_fire');jp('title_start_release');")
        s=replace(s,"branch_var('phase',5,'title');jp('next_phase')", "branch_var('phase',5,'title');jp('title')")
        s=replace(s,"title=bytearray(logo.read('logo_color.scr'))", "title=bytearray(6912);title[6144:]=bytes([0x47])*768")
        s=replace(s,"[(128,'PULSA FUEGO',0x46),(144,'Q A O P / SPACE',0x47),(160,'KEMPSTON AUTO',0x45),(184,'TONY C. WARE 2026',0x47)]", "[(32,'GRIT ENGINE ZX V1.1',0x46),(56,'DEMO 6 - RUN AND GUN',0x47),(80,'ESCORIA SIDERAL',0x45),(112,'SPACE / FIRE',0x46),(136,'Q A O P / SPACE',0x47),(152,'KEMPSTON  X: MENU',0x45),(184,'TONY C. WARE 2026',0x47)]")
        s=replace(s,"header(0,'ESCORIA',len(basic),10,len(basic))", "header(0,'GRITDEMO6',len(basic),10,len(basic))")
        (work/'build.py').write_text(s)
        subprocess.run([sys.executable,'build.py'],cwd=work,check=True)
        blocks=split((work/'base_sin_carga.tap').read_bytes()); assert len(blocks)==24
        demo=b''.join(blocks[:6]); assert len(split(demo))==6
        for name in ['escoria.bin','escoria.asm','symbols.json','titulo.scr','fase1.bin']:
            shutil.copy2(work/name,out/name)
        # Use the actual upstream harness with an additional X input bit (32).
        source=(work/'test_cpu.py').read_text(); source=source[:source.index('# Test TAP blocks and payload.')]
        source=replace(source,"(0x7ffe,0,16)]", "(0x7ffe,0,16),(0xfefe,2,32)]")
        ns={'__file__':str(work/'test_cpu.py')};exec(compile(source,'test_cpu.py','exec'),ns)
        CPU,S,boot=ns['CPU'],ns['S'],ns['boot']; c=boot(); assert c.v('phase')==1
        c.step_frame(1); assert c.v('px')>80 or c.v('scroll')>0
        c.keys=32;c.step();c.run_to('title_press');assert c.v('phase')==1
        c.keys=16;c.run_to('title_start_release');c.keys=0;c.run_to('loop');assert c.v('lives')==3
        for label in ('gameover','win'):
            c=boot();c.set('lives',0 if label=='gameover' else 1);c.pc=S[label];c.run_to('press_end');c.keys=16;c.run_to('title');c.keys=0;c.run_to('title_press'); assert c.v('phase')==1
        c=boot();c.joy=1;c.step_frame();assert c.v('px')>80 or c.v('scroll')>0
        # All six actual tape blocks, resident + bank match compiled memory.
        assert blocks[3][3:-1]+blocks[5][3:-1]==(work/'escoria.bin').read_bytes()
        assert S['shadow_end']<=0xfd00
        dest=out/'GRIT_ENGINE_DEMO6_RUN_AND_GUN.tap';dest.write_bytes(demo)
        print('PASS: title, movement, X, replay, game over, victory, Kempston, 6 blocks, memory. SHA256',hashlib.sha256(demo).hexdigest(),len(demo))
        return dest

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--source',type=Path,default=ROOT/'upstream/Escoria-Sideral/FUENTES');p.add_argument('--output',type=Path,default=ROOT/'demo/horizontal_escoria');a=p.parse_args();build(a.source,a.output)
