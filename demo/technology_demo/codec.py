"""LZ with short/long distances, optimal parse for this byte-oriented format."""
from collections import defaultdict
import bisect

def compress(raw):
 raw=bytes(raw);n=len(raw);cost=[10**9]*(n+1);cost[n]=0;opts=[None]*n;idx=defaultdict(list)
 for i in range(n-2):idx[raw[i:i+3]].append(i)
 for i in range(n-1,-1,-1):
  for l in range(1,min(127,n-i)+1):
   c=1+l+cost[i+l]
   if c<cost[i]:cost[i]=c;opts[i]=('l',l,0)
  pos=idx[raw[i:i+3]];k=bisect.bisect_left(pos,i)
  for lo,hi,c0 in [(1,256,2),(257,65535,3)]:
   best=2
   for j in reversed(pos[bisect.bisect_left(pos,i-hi):bisect.bisect_right(pos,i-lo,0,k)]):
    l=3
    while l<66 and i+l<n and raw[j+l]==raw[i+l]:l+=1
    if l>best:
     for m in range(best+1,l+1):
      c=c0+cost[i+m]
      if c<cost[i]:cost[i]=c;opts[i]=('s' if c0==2 else 'b',m,i-j)
     best=l
    if best==66:break
 out=bytearray();i=0
 while i<n:
  t,l,d=opts[i]
  if t=='l':out.append(l);out.extend(raw[i:i+l])
  elif t=='s':out.extend((128+l-3,d-1))
  else:out.append(192+l-3);out.extend(d.to_bytes(2,'little'))
  i+=l
 out.append(0);return bytes(out)

def decompress(data):
 out=bytearray();i=0
 while data[i]:
  n=data[i];i+=1
  if n<128:out.extend(data[i:i+n]);i+=n;continue
  if n<192:d=data[i]+1;i+=1
  else:d=int.from_bytes(data[i:i+2],'little');i+=2
  for _ in range((n&63)+3):out.append(out[-d])
 return bytes(out)
