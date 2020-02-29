local l={}local l=function(n,l)return n*(2^l);end
local e=function(l,n)return math.floor(l/(2^n))end
local t=function(n,o,l)local n=e(n,o)return n%(2^l)end
local l=function(l)local n=1
while l>1 do
l=e(l,1)n=n+1
end
return n
end
local function a(o,c)local n=math.max(l(o),l(c))local e={}for l=0,n-1 do
e[n-l]=(t(o,l,1)~=t(c,l,1))and 1 or 0
end
return tonumber(table.concat(e,""),2)end
local function l(n,l)return string.char(a(n,l))end
local function e(t,c,o)if o then
local n=0
local l=0
for o=c,o do
n=n+2^l*e(t,o)l=l+1
end
return n
else
local l=2^(c-1)return(t%(l+l)>=l)and 1 or 0
end
end
local function A(c)local l=1
local n=false
local n;local n;local o,n,t,f,i;do
function o()local n=c:byte(l,l);l=l+1
return n
end
function n()local n,e,c,o=c:byte(l,l+3);l=l+4;return o*16777216+c*65536+e*256+n
end
function t()local e=n();local l=n();return l*4294967296+e;end
function f()local o=n()local l=n()return(-2*e(l,32)+1)*(2^(e(l,21,31)-1023))*((e(l,1,20)*(2^32)+o)/(2^52)+1)end
function i(e)local o;if e then
o=c:sub(l,l+e-1);l=l+e;else
e=n();if e==0 then return;end
o=c:sub(l,l+e-1);l=l+e;end
return o;end
end
local function r(s)local t;local u={};local d={};local a={};local l={lines={};};t={instructions=u;constants=d;prototypes=a;debug=l;};local c;t.upvalues=o();do
c=n();for c=1,c do
local l={};if(s==true)then
l.opcode=(o())end
local o=o()l.type=o;local n=n();l.A=e(n,1,7);if o==1 then
l.B=e(n,8,16);l.C=e(n,17,25);elseif o==2 then
l.Bx=e(n,8,26);elseif o==3 then
l.sBx=e(n,8,26);end
u[c]=l;end
end
do
c=n();for e=1,c do
local l={};local n=o();l.type=n;if n==1 then
l.data=(o()~=0);elseif n==3 then
l.data=f();elseif n==4 then
l.data=i():sub(1,-2);end
d[e-1]=l;end
end
do
c=n();for l=1,c do
a[l-1]=r(true);end
end
return t;end
return r();end
local function s(...)local n=select("#",...)local l={...}return n,l
end
local function l(l,n)local o=l.instructions;local n=l.constants;local l=l.prototypes;local r,e
local u
local n=1;local t,c
local a={}local function i()local c=o
local l,e,o
while true do
l=c[n];n=n+1
e,o=a[l.opcode](l);if e then
return o;end
end
end
local function d(...)local a={};local o={};e=-1
r=setmetatable(a,{__index=o;__newindex=function(c,l,n)if l>e and n then
e=l
end
o[l]=n
end;})local e={...};t={}c=select("#",...)-1
for l=0,c do
a[l]=e[l+1];t[l]=e[l+1]end
u=getfenv();n=1;local l=coroutine.create(i)local n,l=coroutine.resume(l)if n then
if l then
return unpack(l);end
return;else
local l=n:gsub("(.-:)","");error(l,0);end
end
return d;end
local function b(l,n)local n=l.instructions;local c=l.constants;local l=l.prototypes;local o,r
local x
local l=1;local p,h
local function B()local t=n
local n,a,a,e,d,u
n=t[l];l=l+1
o[n.A]=c[n.Bx].data;n=t[l];l=l+1
o[n.A]=c[n.Bx].data;n=t[l];l=l+1
o[n.A]=c[n.Bx].data;n=t[l];l=l+1
e=n.A
o[e]=o[e]-o[e+2]l=l+n.sBx
n=t[l];l=l+1
o[n.A]=x[c[n.Bx].data];n=t[l];l=l+1
o[n.A]=c[n.Bx].data;n=t[l];l=l+1
e=n.A;d=n.B;u=n.C;local f,i;local c,a
f={};if d~=1 then
if d~=0 then
c=e+d-1;else
c=r
end
a=0
for l=e+1,c do
a=a+1
f[a]=o[l];end
c,i=s(o[e](unpack(f,1,c-e)))else
c,i=s(o[e]())end
r=e-1
if u~=1 then
if u~=0 then
c=e+u-2;else
c=c+e
end
a=0;for l=e,c do
a=a+1;o[l]=i[a];end
end
n=t[l];l=l+1
e=n.A
local a=o[e+2]local c=o[e]+a
o[e]=c
if a>0 then
if c<=o[e+1]then
l=l+n.sBx
o[e+3]=c
end
else
if c>=o[e+1]then
l=l+n.sBx
o[e+3]=c
end
end
n=t[l];l=l+1
e=n.A;d=n.B;local n;local l,c;if d==1 then
return true;end
if d==0 then
n=r
else
n=e+d-2;end
c={};local l=0
for n=e,n do
l=l+1
c[l]=o[n];end
return true,c;end
local function t(...)local e={};local c={};r=-1
o=setmetatable(e,{__index=c;__newindex=function(e,l,n)if l>r and n then
r=l
end
c[l]=n
end;})local n={...};p={}h=select("#",...)-1
for l=0,h do
e[l]=n[l+1];p[l]=n[l+1]end
x=getfenv();l=1;local l=coroutine.create(B)local e,n,l=coroutine.resume(l)if e and n then
if l then
return unpack(l);end
return;else
local l=n:gsub("(.-:)","");error(l,0);end
end
return t;end
local l=function(l)local l=A(l);return b(l);end;l("\0\9\0\0\0\2\0\0\0\0\2\129\0\0\0\2\2\0\0\0\3\0\0\0\0\2\4\1\0\0\2\133\1\0\0\1\4\1\1\0\3\0\0\0\0\1\128\0\0\0\4\0\0\0\3\0\0\0\0\0\0\240\63\3\0\0\0\0\0\0\36\64\4\6\0\0\0\112\114\105\110\116\0\4\3\0\0\0\120\100\0\0\0\0\0")()