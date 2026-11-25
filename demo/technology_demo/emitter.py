import struct
ORG=0x9000
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
 d={'cp e':[0xbb],'cp d':[0xba],'xor a':[0xaf],'or a':[0xb7],'or b':[0xb0],'or c':[0xb1],'add a,a':[0x87],'and b':[0xa0],'add a,b':[0x80],'sub b':[0x90],'cp b':[0xb8],'cp c':[0xb9],'inc a':[0x3c],'dec a':[0x3d],'inc b':[0x04],'dec b':[0x05],'inc c':[0x0c],'dec c':[0x0d],'inc hl':[0x23],'dec hl':[0x2b],'inc bc':[0x03],'inc de':[0x13],'dec de':[0x1b],'inc h':[0x24],'inc l':[0x2c],'inc d':[0x14],'dec h':[0x25],'add hl,hl':[0x29],'add hl,de':[0x19],'add hl,bc':[0x09],'ex de,hl':[0xeb],'push hl':[0xe5],'pop hl':[0xe1],'push de':[0xd5],'pop de':[0xd1],'push bc':[0xc5],'pop bc':[0xc1],'push af':[0xf5],'pop af':[0xf1],'pop ix':[0xdd,0xe1],'inc ix':[0xdd,0x23],'ld a,(de)':[0x1a],'ld (de),a':[0x12],'rrca':[0x0f],'rlca':[0x07],'ldir':[0xed,0xb0],'ldi':[0xed,0xa0],'halt':[0x76],'di':[0xf3],'ei':[0xfb],'im 1':[0xed,0x56],'in a,(c)':[0xed,0x78],'sbc hl,de':[0xed,0x52],'and (ix+0)':[0xdd,0xa6,0],'or (ix+1)':[0xdd,0xb6,1],'ld a,(ix+0)':[0xdd,0x7e,0]}
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
