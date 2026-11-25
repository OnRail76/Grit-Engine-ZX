"""Common 48K host-side formats, independent from any memory profile."""
import struct
from functools import reduce
from operator import xor

def screen_addr(y, column=0):
    if not (0<=y<192 and 0<=column<32):raise ValueError('outside screen')
    return 0x4000+((y&0xc0)<<5)+((y&7)<<8)+((y&0x38)<<2)+column

def attribute_addr(y,column):
    if not (0<=y<192 and 0<=column<32):raise ValueError('outside screen')
    return 0x5800+(y//8)*32+column

def tap_block(flag,payload):
    if flag not in (0,255):raise ValueError('invalid flag')
    body=bytes([flag])+bytes(payload)
    if len(body)+1>65535:raise ValueError('block too large')
    return struct.pack('<H',len(body)+1)+body+bytes([reduce(xor,body,0)])

def read_tap(data):
    out=[];i=0
    while i<len(data):
        if len(data)-i<2:raise ValueError('truncated length')
        n=struct.unpack_from('<H',data,i)[0];i+=2
        if n<2 or i+n>len(data):raise ValueError('truncated block')
        block=data[i:i+n];i+=n
        if block[0] not in (0,255) or reduce(xor,block,0):raise ValueError('bad flag/checksum')
        if block[0]==0 and len(block)!=19:raise ValueError('invalid header size')
        out.append((block[0],block[1:-1]))
    return out

def preshift16(bitmap,mask=None):
    """16 px wide, row-major 2 bytes/row. 8 variants; 3 bytes or AND/OR pairs."""
    if len(bitmap)%2 or not bitmap:raise ValueError('invalid bitmap')
    if mask is not None and len(mask)!=len(bitmap):raise ValueError('mask size')
    if mask is not None and any(a&b for a,b in zip(bitmap,mask)):raise ValueError('mask/ink overlap')
    variants=[]
    for shift in range(8):
        variant=bytearray()
        for i in range(0,len(bitmap),2):
            ink=(int.from_bytes(bitmap[i:i+2],'big')<<(8-shift)).to_bytes(3,'big')
            if mask is None:variant.extend(ink);continue
            opaque=((~int.from_bytes(mask[i:i+2],'big'))&0xffff)<<(8-shift)
            keep=((~opaque)&0xffffff).to_bytes(3,'big')
            for a,b in zip(keep,ink):variant.extend((a,b))
        variants.append(bytes(variant))
    return tuple(variants)

def encode_tiles(bitmap,width=192,limit=512):
    """MSB-first linear bitmap; native 8x8 tiles, lossless, 9-bit map IDs."""
    if width%8 or len(bitmap)%(width//8*8):raise ValueError('unaligned image')
    cols=width//8;height=len(bitmap)//cols
    bank=[];ids={};rows=[]
    for y in range(0,height,8):
        row=[]
        for x in range(cols):
            tile=bytes(bitmap[(y+j)*cols+x] for j in range(8))
            if tile not in ids:
                if len(bank)==limit:raise ValueError('tile capacity exceeded; do not substitute')
                ids[tile]=len(bank);bank.append(tile)
            row.append(ids[tile])
        rows.append(row)
    return bank,rows

def decode_tiles(bank,rows):
    return bytes(bank[idx][j] for row in rows for j in range(8) for idx in row)
