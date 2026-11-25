import unittest, random
from core.formats import *
class Formats(unittest.TestCase):
    def test_ula(self):
        self.assertEqual(set(screen_addr(y,x) for y in range(192) for x in range(32)),set(range(0x4000,0x5800)))
        self.assertEqual(attribute_addr(191,31),0x5aff)
    def test_tap(self):
        hdr=bytes(17);data=b'\x01\x02\x03';raw=tap_block(0,hdr)+tap_block(255,data)
        self.assertEqual(read_tap(raw),[(0,hdr),(255,data)])
        with self.assertRaises(ValueError):read_tap(raw[:-1])
        with self.assertRaises(ValueError):read_tap(raw[:-1]+bytes([raw[-1]^1]))
    def test_preshift(self):
        bitmap=bytes([0xff,0x55])*16;mask=bytes(x^255 for x in bitmap)
        self.assertEqual(len(preshift16(bitmap)),8)
        for s,v in enumerate(preshift16(bitmap,mask)):
            self.assertEqual(len(v),96)
            for i in range(0,96,6):
                self.assertEqual(int.from_bytes(v[i+1:i+6:2],'big'),0xff55<<(8-s))
                self.assertTrue(all(not a&b for a,b in zip(v[i:i+6:2],v[i+1:i+6:2])))
    def test_tiles(self):
        r=random.Random(48);raw=bytes(r.randrange(256) for _ in range(192))
        bank,rows=encode_tiles(raw);self.assertEqual(decode_tiles(bank,rows),raw)
        with self.assertRaises(ValueError):encode_tiles(raw,limit=1)
if __name__=='__main__':unittest.main()
