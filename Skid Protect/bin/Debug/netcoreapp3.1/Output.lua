local e={}local e=function(n,e)return n*(2^e);end
local l=function(n,e)return math.floor(n/(2^e))end
local a=function(e,n,o)local e=l(e,n)return e%(2^o)end
local e=function(n)local e=1
while n>1 do
n=l(n,1)e=e+1
end
return e
end
local function t(d,l)local o=math.max(e(d),e(l))local n={}for e=0,o-1 do
n[o-e]=(a(d,e,1)~=a(l,e,1))and 1 or 0
end
return tonumber(table.concat(n,""),2)end
local function e(n,e)return string.char(t(n,e))end
local function l(a,d,o)if o then
local n=0
local e=0
for o=d,o do
n=n+2^e*l(a,o)e=e+1
end
return n
else
local e=2^(d-1)return(a%(e+e)>=e)and 1 or 0
end
end
local function p(d)local e=1
local n=false
local n;local n;local o,n,a,r,i;do
function o()local n=d:byte(e,e);e=e+1
return n
end
function n()local o,d,n,l=d:byte(e,e+3);e=e+4;return l*16777216+n*65536+d*256+o
end
function a()local l=n();local e=n();return e*4294967296+l;end
function r()local o=n()local e=n()return(-2*l(e,32)+1)*(2^(l(e,21,31)-1023))*((l(e,1,20)*(2^32)+o)/(2^52)+1)end
function i(l)local o;if l then
o=d:sub(e,e+l-1);e=e+l;else
l=n();if l==0 then return;end
o=d:sub(e,e+l-1);e=e+l;end
return o;end
end
local function f(h)local a;local s={};local c={};local t={};local e={lines={};};a={instructions=s;constants=c;prototypes=t;debug=e;};local d;a.upvalues=o();do
d=n();for d=1,d do
local e={};if(h==true)then
e.opcode=(o())end
local o=o()e.type=o;local n=n();e.A=l(n,1,7);if o==1 then
e.B=l(n,8,16);e.C=l(n,17,25);elseif o==2 then
e.Bx=l(n,8,26);elseif o==3 then
e.sBx=l(n,8,26);end
s[d]=e;end
end
do
d=n();for l=1,d do
local e={};local n=o();e.type=n;if n==1 then
e.data=(o()~=0);elseif n==3 then
e.data=r();elseif n==4 then
e.data=i():sub(1,-2);end
c[l-1]=e;end
end
do
d=n();for e=1,d do
t[e-1]=f(true);end
end
return a;end
return f();end
local function i(...)local e=select("#",...)local n={...}return e,n
end
local function C(e,n)local u=e.instructions;local l=e.constants;local e=e.prototypes;local o,d
local r
local e=1;local s,h
local a={[14]=function(n)o[n.A]=n.B~=0
if n.C~=0 then
e=e+1
end
end,[75]=function(n)local l=o[n.A];if(not not l)==(n.C==0)then
e=e+1
end
end,[91]=function(n)e=e+n.sBx
end,[38]=function(e)local n=l[e.Bx].data;o[e.A]=r[n];end,[5]=function(e)o[e.A]=l[e.Bx].data;end,[27]=function(e)local n=e.A;local c=e.B;local t=e.C;local o=o;local f,a;local e,l
f={};if c~=1 then
if c~=0 then
e=n+c-1;else
e=d
end
l=0
for n=n+1,e do
l=l+1
f[l]=o[n];end
e,a=i(o[n](unpack(f,1,e-n)))else
e,a=i(o[n]())end
d=n-1
if t~=1 then
if t~=0 then
e=n+t-2;else
e=e+n
end
l=0;for e=n,e do
l=l+1;o[e]=a[l];end
end
end,[51]=function(e)local a=e.A;local l=e.B;local o=o;local e;local t,n;if l==1 then
return true;end
if l==0 then
e=d
else
e=a+l-2;end
n={};local l=0
for e=a,e do
l=l+1
n[l]=o[e];end
return true,n;end,}local function t()local d=u
local n,l,o
while true do
n=d[e];e=e+1
l,o=a[n.opcode](n);if l then
return o;end
end
end
local function c(...)local a={};local n={};d=-1
o=setmetatable(a,{__index=n;__newindex=function(o,e,l)if e>d and l then
d=e
end
n[e]=l
end;})local n={...};s={}h=select("#",...)-1
for e=0,h do
a[e]=n[e+1];s[e]=n[e+1]end
r=getfenv();e=1;local e=coroutine.create(t)local e,n=coroutine.resume(e)if e then
if n then
return unpack(n);end
return;else
local e=e:gsub("(.-:)","");error(e,0);end
end
return c;end
local function k(e,k)local l=e.instructions;local c=e.constants;local p=e.prototypes;local o,f
local r
local n=1;local A,x
local function b()local t=l
local e,s,s,l,a,d
e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
a=e.B
local s=o[a]for e=a+1,e.C do
s=s..o[e]end
o[e.A]=s
e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local u,B;local s,h
u={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
u[h]=o[e];end
s,B=i(o[l](unpack(u,1,s-l)))else
s,B=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=B[h];end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
d=e.C
d=d>255 and c[d-256].data or o[d]o[e.A]=o[e.B][d];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local u,B;local s,h
u={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
u[h]=o[e];end
s,B=i(o[l](unpack(u,1,s-l)))else
s,B=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=B[h];end
end
e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
l=e.A
o[l]=o[l]-o[l+2]n=n+e.sBx
e=t[n];n=n+1
local h=p[e.Bx]local t=t
local s={}local u=setmetatable({},{__index=function(n,e)local e=s[e]return e.segment[e.offset]end,__newindex=function(l,e,n)local e=s[e]e.segment[e.offset]=n
end})for l=1,h.upvalues do
local e=t[n]if e.opcode==0 then
s[l-1]={segment=o,offset=e.B}elseif t[n].opcode==4 then
s[l-1]={segment=k,offset=e.B}end
n=n+1
end
local h,s=C(h,u)o[e.A]=s
e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local u,B;local s,h
u={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
u[h]=o[e];end
s,B=i(o[l](unpack(u,1,s-l)))else
s,B=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=B[h];end
end
e=t[n];n=n+1
l=e.A
local h=o[l+2]local s=o[l]+h
o[l]=s
if h>0 then
if s<=o[l+1]then
n=n+e.sBx
o[l+3]=s
end
else
if s>=o[l+1]then
n=n+e.sBx
o[l+3]=s
end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
d=e.C
d=d>255 and c[d-256].data or o[d]o[e.A]=o[e.B][d];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local u,B;local s,h
u={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
u[h]=o[e];end
s,B=i(o[l](unpack(u,1,s-l)))else
s,B=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=B[h];end
end
e=t[n];n=n+1
a=e.B;d=e.C;a=a>255 and c[a-256].data or o[a];d=d>255 and c[d-256].data or o[d];o[e.A]=a-d;e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
a=e.B
local s=o[a]for e=a+1,e.C do
s=s..o[e]end
o[e.A]=s
e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
d=e.C
d=d>255 and c[d-256].data or o[d]o[e.A]=o[e.B][d];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
o[e.A]={}e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
l=e.A
o[l]=o[l]-o[l+2]n=n+e.sBx
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local u,B;local s,h
u={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
u[h]=o[e];end
s,B=i(o[l](unpack(u,1,s-l)))else
s,B=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=B[h];end
end
e=t[n];n=n+1
a=e.B
local s=o[a]for e=a+1,e.C do
s=s..o[e]end
o[e.A]=s
e=t[n];n=n+1
a=e.B;d=e.C;a=a>255 and c[a-256].data or o[a];d=d>255 and c[d-256].data or o[d];o[e.A][a]=d
e=t[n];n=n+1
l=e.A
local h=o[l+2]local s=o[l]+h
o[l]=s
if h>0 then
if s<=o[l+1]then
n=n+e.sBx
o[l+3]=s
end
else
if s>=o[l+1]then
n=n+e.sBx
o[l+3]=s
end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
d=e.C
d=d>255 and c[d-256].data or o[d]o[e.A]=o[e.B][d];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
a=e.B;d=e.C;a=a>255 and c[a-256].data or o[a];d=d>255 and c[d-256].data or o[d];o[e.A]=a-d;e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
a=e.B
local s=o[a]for e=a+1,e.C do
s=s..o[e]end
o[e.A]=s
e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
d=e.C
d=d>255 and c[d-256].data or o[d]o[e.A]=o[e.B][d];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local u,B;local s,h
u={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
u[h]=o[e];end
s,B=i(o[l](unpack(u,1,s-l)))else
s,B=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=B[h];end
end
e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
l=e.A
o[l]=o[l]-o[l+2]n=n+e.sBx
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=o[e.B];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
d=e.C
d=d>255 and c[d-256].data or o[d]o[e.A]=o[e.B][d];e=t[n];n=n+1
a=e.B;d=e.C;a=a>255 and c[a-256].data or o[a];d=d>255 and c[d-256].data or o[d];o[e.A][a]=d
e=t[n];n=n+1
l=e.A
local h=o[l+2]local s=o[l]+h
o[l]=s
if h>0 then
if s<=o[l+1]then
n=n+e.sBx
o[l+3]=s
end
else
if s>=o[l+1]then
n=n+e.sBx
o[l+3]=s
end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
d=e.C
d=d>255 and c[d-256].data or o[d]o[e.A]=o[e.B][d];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local B,u;local s,h
B={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
B[h]=o[e];end
s,u=i(o[l](unpack(B,1,s-l)))else
s,u=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=u[h];end
end
e=t[n];n=n+1
a=e.B;d=e.C;a=a>255 and c[a-256].data or o[a];d=d>255 and c[d-256].data or o[d];o[e.A]=a-d;e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
a=e.B
local s=o[a]for e=a+1,e.C do
s=s..o[e]end
o[e.A]=s
e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local u,B;local s,h
u={};if a~=1 then
if a~=0 then
s=l+a-1;else
s=f
end
h=0
for e=l+1,s do
h=h+1
u[h]=o[e];end
s,B=i(o[l](unpack(u,1,s-l)))else
s,B=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
s=l+d-2;else
s=s+l
end
h=0;for e=l,s do
h=h+1;o[e]=B[h];end
end
e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
o[e.A]=r[c[e.Bx].data];e=t[n];n=n+1
d=e.C
d=d>255 and c[d-256].data or o[d]o[e.A]=o[e.B][d];e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local u,h;local r,s
u={};if a~=1 then
if a~=0 then
r=l+a-1;else
r=f
end
s=0
for e=l+1,r do
s=s+1
u[s]=o[e];end
r,h=i(o[l](unpack(u,1,r-l)))else
r,h=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
r=l+d-2;else
r=r+l
end
s=0;for e=l,r do
s=s+1;o[e]=h[s];end
end
e=t[n];n=n+1
a=e.B;d=e.C;a=a>255 and c[a-256].data or o[a];d=d>255 and c[d-256].data or o[d];o[e.A]=a-d;e=t[n];n=n+1
o[e.A]=c[e.Bx].data;e=t[n];n=n+1
a=e.B
local c=o[a]for e=a+1,e.C do
c=c..o[e]end
o[e.A]=c
e=t[n];n=n+1
l=e.A;a=e.B;d=e.C;local s,h;local c,r
s={};if a~=1 then
if a~=0 then
c=l+a-1;else
c=f
end
r=0
for e=l+1,c do
r=r+1
s[r]=o[e];end
c,h=i(o[l](unpack(s,1,c-l)))else
c,h=i(o[l]())end
f=l-1
if d~=1 then
if d~=0 then
c=l+d-2;else
c=c+l
end
r=0;for e=l,c do
r=r+1;o[e]=h[r];end
end
e=t[n];n=n+1
l=e.A;a=e.B;local n;local d,e;if a==1 then
return true;end
if a==0 then
n=f
else
n=l+a-2;end
e={};local d=0
for n=l,n do
d=d+1
e[d]=o[n];end
return true,e;end
local function a(...)local d={};local l={};f=-1
o=setmetatable(d,{__index=l;__newindex=function(o,e,n)if e>f and n then
f=e
end
l[e]=n
end;})local l={...};A={}x=select("#",...)-1
for e=0,x do
d[e]=l[e+1];A[e]=l[e+1]end
r=getfenv();n=1;local e=coroutine.create(b)local l,e,n=coroutine.resume(e)if l and e then
if n then
return unpack(n);end
return;else
local e=e:gsub("(.-:)","");error(e,0);end
end
return a;end
local e=function(e)local e=p(e);return k(e);end;e("\0\98\0\0\0\2\0\0\0\0\2\129\0\0\0\2\2\1\0\0\2\131\1\0\0\1\4\0\0\0\1\3\1\2\0\1\2\1\3\0\1\1\1\1\0\2\129\0\0\0\2\2\2\0\0\1\1\1\1\0\2\129\2\0\0\1\129\0\6\1\1\129\0\2\0\1\130\0\0\0\2\131\3\0\0\1\4\0\0\0\2\133\3\0\0\3\3\0\0\0\2\7\0\0\0\1\135\0\1\0\3\3\0\0\0\2\131\0\0\0\2\4\4\0\0\2\133\2\0\0\1\133\2\6\1\1\133\0\2\0\1\133\2\1\0\2\134\4\0\0\1\133\2\6\0\1\131\1\1\0\2\131\0\0\0\2\4\5\0\0\1\3\1\1\0\2\131\2\0\0\1\131\1\6\1\1\131\0\2\0\1\129\1\0\0\1\3\0\0\0\2\132\3\0\0\1\5\0\0\0\2\134\3\0\0\3\4\0\0\0\2\136\1\0\0\1\137\3\0\0\1\8\1\2\0\2\137\5\0\0\2\138\1\0\0\1\139\3\0\0\1\10\1\2\0\1\137\4\10\0\1\3\4\9\0\3\4\0\0\0\2\132\0\0\0\2\5\4\0\0\2\134\2\0\0\1\6\3\6\1\1\134\0\2\0\1\6\3\1\0\2\135\4\0\0\1\6\3\7\0\1\132\1\1\0\2\132\0\0\0\2\5\6\0\0\1\4\1\1\0\2\132\2\0\0\1\4\2\6\1\1\132\0\2\0\1\1\2\0\0\2\132\3\0\0\1\5\0\0\0\2\134\3\0\0\3\4\0\0\0\2\136\1\0\0\1\137\3\0\0\1\8\1\2\0\1\136\1\8\0\1\131\131\8\0\3\4\0\0\0\2\132\0\0\0\2\5\4\0\0\2\134\2\0\0\1\6\3\6\1\1\134\0\2\0\1\6\3\1\0\2\135\4\0\0\1\6\3\7\0\1\132\1\1\0\2\132\0\0\0\2\133\6\0\0\2\134\2\0\0\1\6\3\6\1\1\134\0\2\0\1\6\3\2\0\2\135\4\0\0\1\6\3\7\0\1\132\1\1\0\1\128\0\0\0\14\0\0\0\3\0\0\0\0\0\106\248\64\4\6\0\0\0\112\114\105\110\116\0\4\13\0\0\0\73\116\101\114\97\116\105\111\110\115\58\32\0\4\9\0\0\0\116\111\115\116\114\105\110\103\0\4\17\0\0\0\67\76\79\83\85\82\69\32\116\101\115\116\105\110\103\46\0\4\3\0\0\0\111\115\0\4\6\0\0\0\99\108\111\99\107\0\3\0\0\0\0\0\0\240\63\4\6\0\0\0\84\105\109\101\58\0\4\2\0\0\0\115\0\4\18\0\0\0\83\69\84\84\65\66\76\69\32\116\101\115\116\105\110\103\46\0\4\12\0\0\0\69\80\73\67\32\71\65\77\69\82\32\0\4\18\0\0\0\71\69\84\84\65\66\76\69\32\116\101\115\116\105\110\103\46\0\4\12\0\0\0\84\111\116\97\108\32\84\105\109\101\58\0\1\0\0\0\0\7\0\0\0\14\1\0\0\0\0\75\1\0\0\0\0\91\3\0\0\0\0\38\2\0\0\0\0\5\2\129\0\0\0\27\1\0\1\1\0\51\1\128\0\0\0\2\0\0\0\4\6\0\0\0\112\114\105\110\116\0\4\11\0\0\0\72\101\121\32\103\97\109\101\114\46\0\0\0\0\0")()