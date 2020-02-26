local function o(c,n,a)if a then
local l=0
local e=0
for n=n,a do
l=l+2^e*o(c,n)e=e+1
end
return l
else
local l=2^(n-1)return(c%(l+l)>=l)and 1 or 0
end
end
local function y(c)local l=1
local e=false
local e;local e;local n,e,t,d,a;do
function n()local e=c:byte(l,l);l=l+1
return e
end
function e()local n,o,c,e=c:byte(l,l+3);l=l+4;return e*16777216+c*65536+o*256+n
end
function t()local l=e();local e=e();return e*4294967296+l;end
function d()local n=e()local l=e()return(-2*o(l,32)+1)*(2^(o(l,21,31)-1023))*((o(l,1,20)*(2^32)+n)/(2^52)+1)end
function a(n)local o;if n then
o=c:sub(l,l+n-1);l=l+n;else
n=e();if n==0 then return;end
o=c:sub(l,l+n-1);l=l+n;end
return o;end
end
local function r(f)local c;local t={};local i={};local u={};local l={lines={};};c={instructions=t;constants=i;prototypes=u;debug=l;};local o;c.upvalues=n();do
o=e();for c=1,o do
local l={};if(f==true)then
l.opcode=(n())end
l.A=n();local o=n()l.type=o;if o==1 then
l.B=n()l.C=n()elseif o==2 then
l.Bx=n()elseif o==3 then
l.sBx=e();end
t[c]=l;end
end
do
o=e();for o=1,o do
local l={};local e=n();l.type=e;if e==1 then
l.data=(n()~=0);elseif e==3 then
l.data=d();elseif e==4 then
l.data=a():sub(1,-2);end
i[o-1]=l;end
end
do
o=e();for l=1,o do
u[l-1]=r(true);end
end
return c;end
return r();end
local function i(...)local e=select("#",...)local l={...}return e,l
end
local function l(l,e)local c=l.instructions;local e=l.constants;local e=l.prototypes;local d,n
local r
local e=1;local o,t
local a={}local function f()local c=c
local l,n,o
while true do
l=c[e];e=e+1
n,o=a[l.opcode](l);if n then
return o;end
end
end
local i={};local function u(...)local a={};local c={};n=-1
d=setmetatable(a,{__index=c;__newindex=function(o,l,e)if l>n and e then
n=l
end
c[l]=e
end;})local n={...};o={}t=select("#",...)-1
for l=0,t do
a[l]=n[l+1];o[l]=n[l+1]end
r=getfenv();e=1;local n=coroutine.create(f)local o,n=coroutine.resume(n)if o then
if n then
return unpack(n);end
return;else
local o=l.name;local e=l.debug.lines[e];local l=n:gsub("(.-:)","");local l="";l=l..(o and o..":"or"");l=l..(e and e..":"or"");l=l..n;error(l,0);end
end
return i,u;end
local function x(u,l)local e=u.instructions;local s=u.constants;local l=u.prototypes;local r,t
local h
local l=1;local B,b
local function _()local a=e
local e,n,n
e=a[l];l=l+1
r[e.A]=s[e.Bx].data;e=a[l];l=l+1
local n=s[e.Bx].data;r[e.A]=h[n];e=a[l];l=l+1
r[e.A]=r[e.B];e=a[l];l=l+1
local o=e.A;local f=e.B;local u=e.C;local d=r;local r,p;local n,c
r={};if f~=1 then
if f~=0 then
n=o+f-1;else
n=t
end
c=0
for l=o+1,n do
c=c+1
r[c]=d[l];end
n,p=i(d[o](unpack(r,1,n-o)))else
n,p=i(d[o]())end
t=o-1
if u~=1 then
if u~=0 then
n=o+u-2;else
n=n+o
end
c=0;for l=o,n do
c=c+1;d[l]=p[c];end
end
e=a[l];l=l+1
local n=s[e.Bx].data;d[e.A]=h[n];e=a[l];l=l+1
d[e.A]=e.B~=0
if e.C~=0 then
l=l+1
end
e=a[l];l=l+1
local o=e.A;local u=e.B;local f=e.C;local d=d;local r,s;local n,c
r={};if u~=1 then
if u~=0 then
n=o+u-1;else
n=t
end
c=0
for l=o+1,n do
c=c+1
r[c]=d[l];end
n,s=i(d[o](unpack(r,1,n-o)))else
n,s=i(d[o]())end
t=o-1
if f~=1 then
if f~=0 then
n=o+f-2;else
n=n+o
end
c=0;for l=o,n do
c=c+1;d[l]=s[c];end
end
e=a[l];l=l+1
local o=e.A;local e=e.B;local c=d;local l;local a,n;if e==1 then
return true;end
if e==0 then
l=t
else
l=o+e-2;end
n={};local e=0
for l=o,l do
e=e+1
n[e]=c[l];end
return true,n;end
local c={};local function a(...)local n={};local o={};t=-1
r=setmetatable(n,{__index=o;__newindex=function(n,l,e)if l>t and e then
t=l
end
o[l]=e
end;})local e={...};B={}b=select("#",...)-1
for l=0,b do
n[l]=e[l+1];B[l]=e[l+1]end
h=getfenv();l=1;local e=coroutine.create(_)local n,o,e=coroutine.resume(e)if n and o then
if e then
return unpack(e);end
return;else
local n=u.name;local o=u.debug.lines[l];local l=e:gsub("(.-:)","");local l="";l=l..(n and n..":"or"");l=l..(o and o..":"or"");l=l..e;error(l,0);end
end
return c,a;end
load_bytecode=function(l)local l=y(l);local e,l=x(l);return l;end;load_bytecode("\0\8\0\0\0\0\2\0\1\2\1\2\1\0\0\1\1\2\1\1\2\1\2\1\1\0\1\1\2\1\0\1\1\0\2\0\0\0\3\0\0\0\0\0\0\240\63\4\6\0\0\0\112\114\105\110\116\0\0\0\0\0")()