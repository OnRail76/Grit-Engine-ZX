#!/usr/bin/env python3
"""V1.1 six-profile selector. Two 48K RAM images on one TAP; ROM transfer at crossings."""
from pathlib import Path
import argparse, hashlib, json, shutil, struct, subprocess, sys, tempfile
P=Path(__file__).resolve().parent; ROOT=P.parents[1]; OLD=ROOT/'demo/technology_demo'
sys.path.insert(0,str(OLD))
from formats import read_tap,tap_block
W=lambda n:struct.pack('<H',n)
OLD_HASH='1e8ba440885f76da162da0518e5120b1b16f13d4600b289c1494d19305cdfd31'
SIX_HASH='450e9447ab9e19bd401e828cb4520b0c50f2acfb9e44b31c2caecd6eff44d198'
OLD_STUB=0xff20; SIX_STUB=0x5b00; RUN=0x5000; HDR=0x5780

def patch(text,old,new):
    assert text.count(old)==1,old
    return text.replace(old,new,1)

def loader(origin, dest, length, letter, target):
    # Copy to bitmap, safe from either payload; private stack and IM2 vector.
    b=bytearray(); labels={}; fixes=[]
    def e(*v):b.extend(v)
    def w(op,n):e(op);b.extend(W(n))
    def lab(n):labels[n]=RUN+len(b)
    def j(op,n):
        rel={0xc3:0x18,0xc2:0x20,0xca:0x28,0xd2:0x30}.get(op)
        if rel is not None:e(rel);fixes.append((len(b),n,True));e(0)
        else:e(op);fixes.append((len(b),n,False));e(0,0)
    def fill(a,n,v):w(0x21,a);e(0x36,v);w(0x11,a+1);w(0x01,n-1);e(0xed,0xb0)
    e(0xf3);w(0x31,0x57f0);e(0xaf,0xd3,0xfe)
    fill(0x5800,768,0);fill(0x5800,len(b"REBOBINA Y SPACE"),0x47)
    # Draw text using the Spectrum ROM glyphs at 3C00 + ASCII*8.
    j(0x21,'message');w(0x11,0x4000)
    lab('char');e(0x7e,0xb7);j(0xca,'irq');e(0xe5,0xd5,0x6f,0x26,0,0x29,0x29,0x29);w(0x01,0x3c00);e(0x09,0x06,8)
    lab('row');e(0x7e,0x12,0x23,0x14,0x05);j(0xc2,'row');e(0xd1,0x13,0xe1,0x23);j(0xc3,'char')
    lab('irq');w(0x21,0x5555);e(0x36,0xfb,0x23,0x36,0xed,0x23,0x36,0x4d);fill(0x5600,257,0x55);e(0x3e,0x56,0xed,0x47,0xed,0x5e)
    # Fresh SPACE press AND release: ROM LD-BYTES/SA-LD-RET treats held SPACE as BREAK.
    w(0x01,0x7ffe);lab('release');e(0xed,0x78,0xcb,0x47);j(0xca,'release');lab('press');e(0xed,0x78,0xcb,0x47);j(0xc2,'press');lab('confirm_release');e(0xed,0x78,0xcb,0x47);j(0xca,'confirm_release')
    lab('seek');e(0xf3,0xdd,0x21);b.extend(W(HDR));w(0x11,17);e(0xaf,0x37);w(0xcd,0x0556);j(0xd2,'seek')
    w(0x3a,HDR);e(0xfe,3);j(0xc2,'seek');w(0x3a,HDR+1);e(0xfe,ord(letter));j(0xc2,'seek')
    for off,value in [(11,length),(13,dest)]:
        w(0x2a,HDR+off);w(0x11,value);e(0xb7,0xed,0x52);j(0xc2,'seek')
    e(0xf3,0xdd,0x21);b.extend(W(dest));w(0x11,length);e(0x3e,255,0x37);w(0xcd,0x0556);j(0xd2,'seek');e(0xf3);w(0xc3,target)
    lab('message');b.extend((b'PLAY CINTA SPACE' if letter=='S' else b'REBOBINA Y SPACE')+b'\0')
    for i,n,rel in fixes:
        if rel:
            offset=labels[n]-(RUN+i+1);assert -128<=offset<=127;b[i]=offset&255
        else:b[i:i+2]=W(labels[n])
    # bootstrap executes with no stack, even on exit from a nested call.
    head=b'\xf3\x21'+W(origin+15)+b'\x11'+W(RUN)+b'\x01'+W(len(b))+b'\xed\xb0\xc3'+W(RUN)
    assert len(head)==15
    return head+b,labels

def make_old(work):
    shutil.copytree(OLD,work)
    p=work/'build_demo.py';s=p.read_text()
    s=patch(s,"L('load_vertical');W('jp $793e',0xc3,0x793e)","L('load_vertical');W('jp $793e',0xc3,0x793e);L('load_six');W('jp six',0xc3,0xff20)")
    s=patch(s,"la('dy');R('or a');J('menu_y_release'", "lc(0xeffe);R('in a,(c)');bit(4);J('menu_not_six','nz');setv('selection',6);J('menu_choose');L('menu_not_six');la('dy');R('or a');J('menu_y_release'")
    s=patch(s,"la('selection');cp(5);J('menu_fire','z')","la('selection');cp(6);J('menu_fire','z')")
    s=patch(s,"la('selection');cp(5);J('load_vertical','z');sa('mode')","la('selection');cp(5);J('load_vertical','z');cp(6);J('load_six','z');sa('mode')")
    s=patch(s,"(14,'5 VERTICAL SHMUP'),(17,'Q/A + FIRE / 1-5'),(19,'X: VOLVER AL MENU'),(21,'5: MEDITERRANEO')","(14,'5 VERTICAL SHMUP'),(16,'6 RUN AND GUN'),(19,'Q/A + FIRE / 1-6'),(21,'X: MENU / 6: CINTA')")
    p.write_text(s)
    p=work/'build.py';s=p.read_text();s=patch(s,'(0xff00,0x10000)','(0xff00,0xff20)');p.write_text(s)
    subprocess.run([sys.executable,'build.py'],cwd=work,check=True)
    return bytearray((work/'resident.bin').read_bytes())

def build(six_dir,out):
    assert hashlib.sha256((OLD/'GRIT_ENGINE_TECH_DEMO_V1.0.tap').read_bytes()).hexdigest()==OLD_HASH
    six_tap=(six_dir/'GRIT_ENGINE_DEMO6_RUN_AND_GUN.tap').read_bytes();assert hashlib.sha256(six_tap).hexdigest()==SIX_HASH
    blocks=read_tap(six_tap);assert len(blocks)==6
    six=bytearray(blocks[3][1]+blocks[5][1]);s=json.loads((six_dir/'symbols.json').read_text());assert len(six)==35707
    # Keep approved gameplay bytes; only entry, X, end routes differ.
    def jp(a,t):six[a-0x5f00:a-0x5f00+3]=b'\xc3'+W(t)
    jp(s['title'],SIX_STUB) # X and both end transitions converge here
    # Direct entry to first phase, private IM2; no dependence on previous BASIC workspace.
    prefix=bytearray(0x400); entry=0x5b00+0x100
    isr=b'\xf5\x3a\x78\x5c\x3c\x32\x78\x5c\xf1\xfb\xed\x4d'
    prefix[0x15c:0x15c+len(isr)]=isr # 5C5C
    prefix[0x200:0x301]=bytes([0x5c])*257
    # entry at 5C00 (outside vector, ISR, FRAMES); direct jump restart.
    init=b'\xf3\x31\xfe\xff\xaf\xd3\xfe\x32\x78\x5c\x3e\x5d\xed\x47\xed\x5e\xfb\xc3'+W(s['restart'])
    prefix[0x100:0x100+len(init)]=init
    six_payload=prefix+six
    old_loader,old_labels=loader(OLD_STUB,0x5b00,len(six_payload),'S',entry)
    six_loader,six_labels=loader(SIX_STUB,0x6000,40960,'G',0x6000)
    print('switch stubs',len(old_loader),len(six_loader));assert OLD_STUB+len(old_loader)<=65536 and len(six_loader)<=0x100
    six_payload[:len(six_loader)]=six_loader
    with tempfile.TemporaryDirectory() as tmp:
        work=Path(tmp)/'old';old=make_old(work);assert len(old)==40960
        old[OLD_STUB-0x6000:OLD_STUB-0x6000+len(old_loader)]=old_loader
        basic=read_tap((work/'GRIT_ENGINE_TECH_DEMO_V1.0.tap').read_bytes())[:2]
        header=lambda name,data,addr:tap_block(0,bytes([3])+name.encode().ljust(10,b' ')+W(len(data))+W(addr)+W(0))
        tap=b''.join(tap_block(f,d) for f,d in basic)+header('GRIT CORE',old,0x6000)+tap_block(255,old)+header('SIX CORE',six_payload,0x5b00)+tap_block(255,six_payload)
        assert len(read_tap(tap))==6
        out.mkdir(parents=True,exist_ok=True)
        for name in ['demo_symbols.json','controller_symbols.json','archive_map.json','menu.lz','demo.bin','phase1.bin','symbols1.json','kernel1.bin']:
            shutil.copy2(work/name,out/name)
        (out/'resident.bin').write_bytes(old);(out/'six.bin').write_bytes(six_payload);(out/'switch_symbols.json').write_text(json.dumps({'to6':old_labels,'to5':six_labels,'six':s,'entry':entry},indent=2))
        dest=out/'GRIT_ENGINE_TECH_DEMO_V1.1.tap';dest.write_bytes(tap);print(dest,len(tap),hashlib.sha256(tap).hexdigest())
        return dest

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--six',type=Path,default=ROOT/'demo/horizontal_escoria');p.add_argument('--output',type=Path,default=P);a=p.parse_args();build(a.six,a.output)
