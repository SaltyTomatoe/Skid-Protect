local function o(a,n,c)if c then
local e=0
local l=0
for n=n,c do
e=e+2^l*o(a,n)l=l+1
end
return e
else
local l=2^(n-1)return(a%(l+l)>=l)and 1 or 0
end
end
local function x(a)local l=1
local e=false
local e;local e;local n,e,t,c,d;do
function n()local e=a:byte(l,l);l=l+1
return e
end
function e()local a,o,e,n=a:byte(l,l+3);l=l+4;return n*16777216+e*65536+o*256+a
end
function t()local l=e();local e=e();return e*4294967296+l;end
function c()local n=e()local l=e()return(-2*o(l,32)+1)*(2^(o(l,21,31)-1023))*((o(l,1,20)*(2^32)+n)/(2^52)+1)end
function d(n)local o;if n then
o=a:sub(l,l+n-1);l=l+n;else
n=e();if n==0 then return;end
o=a:sub(l,l+n-1);l=l+n;end
return o;end
end
local function t(u)local a;local f={};local r={};local i={};local l={lines={};};a={instructions=f;constants=r;prototypes=i;debug=l;};local o;a.upvalues=n();do
o=e();for a=1,o do
local l={};if(u==true)then
l.opcode=(n())end
l.A=n();local o=n()l.type=o;if o==1 then
l.B=n()l.C=n()elseif o==2 then
l.Bx=n()elseif o==3 then
l.sBx=e();end
f[a]=l;end
end
do
o=e();for o=1,o do
local l={};local e=n();l.type=e;if e==1 then
l.data=(n()~=0);elseif e==3 then
l.data=c();elseif e==4 then
l.data=d():sub(1,-2);end
r[o-1]=l;end
end
do
o=e();for l=1,o do
i[l-1]=t(true);end
end
return a;end
return t();end
local function a(...)local e=select("#",...)local l={...}return e,l
end
local function _(c,l)local h=c.instructions;local e=c.constants;local l=c.prototypes;local d,o
local i
local t=1;local u,s
local a={[68]=function(l)local e=e[l.Bx].data;d[l.A]=i[e];end,[98]=function(l)d[l.A]=e[l.Bx].data;end,[8]=function(l)local e=l.A;local r=l.B;local t=l.C;local c=d;local d,f;local l,n
d={};if r~=1 then
if r~=0 then
l=e+r-1;else
l=o
end
n=0
for e=e+1,l do
n=n+1
d[n]=c[e];end
l,f=a(c[e](unpack(d,1,l-e)))else
l,f=a(c[e]())end
o=e-1
if t~=1 then
if t~=0 then
l=e+t-2;else
l=l+e
end
n=0;for l=e,l do
n=n+1;c[l]=f[n];end
end
end,[21]=function(l)local a=l.A;local l=l.B;local c=d;local n;local t,e;if l==1 then
return true;end
if l==0 then
n=o
else
n=a+l-2;end
e={};local l=0
for n=a,n do
l=l+1
e[l]=c[n];end
return true,e;end,}local function B()local o=h
local l,n,e
while true do
l=o[t];t=t+1
n,e=a[l.opcode](l);if n then
return e;end
end
end
local r={};local function f(...)local a={};local n={};o=-1
d=setmetatable(a,{__index=n;__newindex=function(a,l,e)if l>o and e then
o=l
end
n[l]=e
end;})local e={...};u={}s=select("#",...)-1
for l=0,s do
a[l]=e[l+1];u[l]=e[l+1]end
i=getfenv();t=1;local l=coroutine.create(B)local l,e=coroutine.resume(l)if l then
if e then
return unpack(e);end
return;else
local o=c.name;local n=c.debug.lines[t];local l=e:gsub("(.-:)","");local l="";l=l..(o and o..":"or"");l=l..(n and n..":"or"");l=l..e;error(l,0);end
end
return r,f;end
local function b(u,x)local e=u.instructions;local d=u.constants;local b=u.prototypes;local s,o
local r
local l=1;local p,A
local function g()local n=e
local e,c,c
e=n[l];l=l+1
s[e.A]=r[d[e.Bx].data];e=n[l];l=l+1
s[e.A]=d[e.Bx].data;e=n[l];l=l+1
local t=e.A;local u=e.B;local h=e.C;local i=s;local s,B;local c,f
s={};if u~=1 then
if u~=0 then
c=t+u-1;else
c=o
end
f=0
for l=t+1,c do
f=f+1
s[f]=i[l];end
c,B=a(i[t](unpack(s,1,c-t)))else
c,B=a(i[t]())end
o=t-1
if h~=1 then
if h~=0 then
c=t+h-2;else
c=c+t
end
f=0;for l=t,c do
f=f+1;i[l]=B[f];end
end
e=n[l];l=l+1
local c=i
for l=e.A,e.B do
c[l]=nil
end
e=n[l];l=l+1
r[d[e.Bx].data]=c[e.A];e=n[l];l=l+1
c[e.A]=r[d[e.Bx].data];e=n[l];l=l+1
c[e.A]=d[e.Bx].data;e=n[l];l=l+1
c[e.A]=r[d[e.Bx].data];e=n[l];l=l+1
c[e.A]=r[d[e.Bx].data];e=n[l];l=l+1
local t=e.A;local B=e.B;local s=e.C;local i=c;local h,u;local c,f
h={};if B~=1 then
if B~=0 then
c=t+B-1;else
c=o
end
f=0
for l=t+1,c do
f=f+1
h[f]=i[l];end
c,u=a(i[t](unpack(h,1,c-t)))else
c,u=a(i[t]())end
o=t-1
if s~=1 then
if s~=0 then
c=t+s-2;else
c=c+t
end
f=0;for l=t,c do
f=f+1;i[l]=u[f];end
end
e=n[l];l=l+1
local t=e.A;local h=e.B;local s=e.C;local i=i;local u,B;local c,f
u={};if h~=1 then
if h~=0 then
c=t+h-1;else
c=o
end
f=0
for l=t+1,c do
f=f+1
u[f]=i[l];end
c,B=a(i[t](unpack(u,1,c-t)))else
c,B=a(i[t]())end
o=t-1
if s~=1 then
if s~=0 then
c=t+s-2;else
c=c+t
end
f=0;for l=t,c do
f=f+1;i[l]=B[f];end
end
e=n[l];l=l+1
i[e.A]=r[d[e.Bx].data];e=n[l];l=l+1
i[e.A]=d[e.Bx].data;e=n[l];l=l+1
local t=e.A;local s=e.B;local u=e.C;local f=i;local i,r;local c,d
i={};if s~=1 then
if s~=0 then
c=t+s-1;else
c=o
end
d=0
for l=t+1,c do
d=d+1
i[d]=f[l];end
c,r=a(f[t](unpack(i,1,c-t)))else
c,r=a(f[t]())end
o=t-1
if u~=1 then
if u~=0 then
c=t+u-2;else
c=c+t
end
d=0;for l=t,c do
d=d+1;f[l]=r[d];end
end
e=n[l];l=l+1
local t=b[e.Bx]local r=n
local n=f
local c={}local d=setmetatable({},{__index=function(e,l)local l=c[l]return l.segment[l.offset]end,__newindex=function(n,l,e)local l=c[l]l.segment[l.offset]=e
end})for o=1,t.upvalues do
local e=r[l]if e.opcode==0 then
c[o-1]={segment=n,offset=e.B}elseif r[l].opcode==4 then
c[o-1]={segment=x,offset=e.B}end
l=l+1
end
local t,c=_(t,d)n[e.A]=c
e=r[l];l=l+1
n[e.A]=n[e.B];e=r[l];l=l+1
local c=e.A;local s=e.B;local i=e.C;local d=n;local f,u;local n,t
f={};if s~=1 then
if s~=0 then
n=c+s-1;else
n=o
end
t=0
for l=c+1,n do
t=t+1
f[t]=d[l];end
n,u=a(d[c](unpack(f,1,n-c)))else
n,u=a(d[c]())end
o=c-1
if i~=1 then
if i~=0 then
n=c+i-2;else
n=n+c
end
t=0;for l=c,n do
t=t+1;d[l]=u[t];end
end
e=r[l];l=l+1
local a=e.A;local n=e.B;local c=d;local e;local t,l;if n==1 then
return true;end
if n==0 then
e=o
else
e=a+n-2;end
l={};local n=0
for e=a,e do
n=n+1
l[n]=c[e];end
return true,l;end
local c={};local function a(...)local n={};local e={};o=-1
s=setmetatable(n,{__index=e;__newindex=function(a,l,n)if l>o and n then
o=l
end
e[l]=n
end;})local e={...};p={}A=select("#",...)-1
for l=0,A do
n[l]=e[l+1];p[l]=e[l+1]end
r=getfenv();l=1;local e=coroutine.create(g)local o,n,e=coroutine.resume(e)if o and n then
if e then
return unpack(e);end
return;else
local n=u.name;local o=u.debug.lines[l];local l=e:gsub("(.-:)","");local l="";l=l..(n and n..":"or"");l=l..(o and o..":"or"");l=l..e;error(l,0);end
end
return c,a;end
local l=function(l)local l=x(l);local e,l=b(l);return l;end;l("\0\18\0\0\0\0\2\0\1\2\1\0\1\2\1\0\1\0\0\0\2\2\0\2\0\1\2\3\2\2\4\3\2\2\2\1\2\0\0\1\0\1\0\2\0\1\2\5\0\1\2\1\0\2\0\1\1\0\0\1\1\1\1\0\1\1\0\6\0\0\0\4\6\0\0\0\112\114\105\110\116\0\4\3\0\0\0\120\100\0\4\11\0\0\0\108\111\97\100\115\116\114\105\110\103\0\4\5\0\0\0\69\82\82\58\0\4\6\0\0\0\112\99\97\108\108\0\4\3\0\0\0\58\41\0\1\0\0\0\0\4\0\0\0\68\0\2\0\98\1\2\1\8\0\1\2\1\21\0\1\1\0\2\0\0\0\4\6\0\0\0\112\114\105\110\116\0\4\3\0\0\0\120\100\0\0\0\0\0")()