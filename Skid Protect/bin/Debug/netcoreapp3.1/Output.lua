local function o(n,a,c)if c then
local e=0
local l=0
for c=a,c do
e=e+2^l*o(n,c)l=l+1
end
return e
else
local l=2^(a-1)return(n%(l+l)>=l)and 1 or 0
end
end
local function A(c)local l=1
local e=false
local e;local e;local n,e,t,a,i;do
function n()local e=c:byte(l,l);l=l+1
return e
end
function e()local o,c,e,n=c:byte(l,l+3);l=l+4;return n*16777216+e*65536+c*256+o
end
function t()local n=e();local l=e();return l*4294967296+n;end
function a()local n=e()local l=e()return(-2*o(l,32)+1)*(2^(o(l,21,31)-1023))*((o(l,1,20)*(2^32)+n)/(2^52)+1)end
function i(n)local o;if n then
o=c:sub(l,l+n-1);l=l+n;else
n=e();if n==0 then return;end
o=c:sub(l,l+n-1);l=l+n;end
return o;end
end
local function u(f)local c;local r={};local t={};local d={};local l={lines={};};c={instructions=r;constants=t;prototypes=d;debug=l;};local o;c.upvalues=n();do
o=e();for c=1,o do
local l={};if(f==true)then
l.opcode=(n())end
l.A=n();local o=n()l.type=o;if o==1 then
l.B=n()l.C=n()elseif o==2 then
l.Bx=n()elseif o==3 then
l.sBx=e();end
r[c]=l;end
end
do
o=e();for o=1,o do
local l={};local e=n();l.type=e;if e==1 then
l.data=(n()~=0);elseif e==3 then
l.data=a();elseif e==4 then
l.data=i():sub(1,-2);end
t[o-1]=l;end
end
do
o=e();for l=1,o do
d[l-1]=u(true);end
end
return c;end
return u();end
local function i(...)local l=select("#",...)local e={...}return l,e
end
local function l(l,e)local o=l.instructions;local e=l.constants;local e=l.prototypes;local i,n
local f
local e=1;local a,t
local c={}local function d()local a=o
local l,o,n
while true do
l=a[e];e=e+1
o,n=c[l.opcode](l);if o then
return n;end
end
end
local r={};local function u(...)local o={};local c={};n=-1
i=setmetatable(o,{__index=c;__newindex=function(o,l,e)if l>n and e then
n=l
end
c[l]=e
end;})local n={...};a={}t=select("#",...)-1
for l=0,t do
o[l]=n[l+1];a[l]=n[l+1]end
f=getfenv();e=1;local n=coroutine.create(d)local o,n=coroutine.resume(n)if o then
if n then
return unpack(n);end
return;else
local o=l.name;local e=l.debug.lines[e];local l=n:gsub("(.-:)","");local l="";l=l..(o and o..":"or"");l=l..(e and e..":"or"");l=l..n;error(l,0);end
end
return r,u;end
local function x(u,l)local e=u.instructions;local f=u.constants;local l=u.prototypes;local r,a
local h
local l=1;local b,B
local function A()local t=e
local e,n,n
e=t[l];l=l+1
r[e.A]=f[e.Bx].data;e=t[l];l=l+1
local n=f[e.Bx].data;r[e.A]=h[n];e=t[l];l=l+1
r[e.A]=r[e.B];e=t[l];l=l+1
local o=e.A;local u=e.B;local s=e.C;local d=r;local p,r;local n,c
p={};if u~=1 then
if u~=0 then
n=o+u-1;else
n=a
end
c=0
for l=o+1,n do
c=c+1
p[c]=d[l];end
n,r=i(d[o](unpack(p,1,n-o)))else
n,r=i(d[o]())end
a=o-1
if s~=1 then
if s~=0 then
n=o+s-2;else
n=n+o
end
c=0;for l=o,n do
c=c+1;d[l]=r[c];end
end
e=t[l];l=l+1
local n=f[e.Bx].data;d[e.A]=h[n];e=t[l];l=l+1
d[e.A]=e.B~=0
if e.C~=0 then
l=l+1
end
e=t[l];l=l+1
local o=e.A;local r=e.B;local u=e.C;local d=d;local s,f;local n,c
s={};if r~=1 then
if r~=0 then
n=o+r-1;else
n=a
end
c=0
for l=o+1,n do
c=c+1
s[c]=d[l];end
n,f=i(d[o](unpack(s,1,n-o)))else
n,f=i(d[o]())end
a=o-1
if u~=1 then
if u~=0 then
n=o+u-2;else
n=n+o
end
c=0;for l=o,n do
c=c+1;d[l]=f[c];end
end
e=t[l];l=l+1
local o=e.A;local l=e.B;local c=d;local e;local t,n;if l==1 then
return true;end
if l==0 then
e=a
else
e=o+l-2;end
n={};local l=0
for e=o,e do
l=l+1
n[l]=c[e];end
return true,n;end
local t={};local function c(...)local o={};local e={};a=-1
r=setmetatable(o,{__index=e;__newindex=function(o,l,n)if l>a and n then
a=l
end
e[l]=n
end;})local e={...};b={}B=select("#",...)-1
for l=0,B do
o[l]=e[l+1];b[l]=e[l+1]end
h=getfenv();l=1;local e=coroutine.create(A)local o,n,e=coroutine.resume(e)if o and n then
if e then
return unpack(e);end
return;else
local n=u.name;local o=u.debug.lines[l];local l=e:gsub("(.-:)","");local l="";l=l..(n and n..":"or"");l=l..(o and o..":"or"");l=l..e;error(l,0);end
end
return t,c;end
local l=function(l)local l=A(l);local e,l=x(l);return l;end;l("\0\8\0\0\0\0\2\0\1\2\1\2\1\0\0\1\1\2\1\1\2\1\2\1\1\0\1\1\2\1\0\1\1\0\2\0\0\0\3\0\0\0\0\0\0\240\63\4\6\0\0\0\112\114\105\110\116\0\0\0\0\0")()