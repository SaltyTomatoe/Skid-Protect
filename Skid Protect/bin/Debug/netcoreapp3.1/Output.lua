local function o(n,a,c)if c then
local l=0
local e=0
for c=a,c do
l=l+2^e*o(n,c)e=e+1
end
return l
else
local l=2^(a-1)return(n%(l+l)>=l)and 1 or 0
end
end
local function x(c)local l=1
local e=false
local e;local e;local n,e,t,a,u;do
function n()local e=c:byte(l,l);l=l+1
return e
end
function e()local n,e,c,o=c:byte(l,l+3);l=l+4;return o*16777216+c*65536+e*256+n
end
function t()local n=e();local l=e();return l*4294967296+n;end
function a()local n=e()local l=e()return(-2*o(l,32)+1)*(2^(o(l,21,31)-1023))*((o(l,1,20)*(2^32)+n)/(2^52)+1)end
function u(n)local o;if n then
o=c:sub(l,l+n-1);l=l+n;else
n=e();if n==0 then return;end
o=c:sub(l,l+n-1);l=l+n;end
return o;end
end
local function t(i)local c;local f={};local r={};local d={};local l={lines={};};c={instructions=f;constants=r;prototypes=d;debug=l;};local o;c.upvalues=n();do
o=e();for c=1,o do
local l={};if(i==true)then
l.opcode=(n())end
l.A=n();local o=n()l.type=o;if o==1 then
l.B=n()l.C=n()elseif o==2 then
l.Bx=n()elseif o==3 then
l.sBx=e();end
f[c]=l;end
end
do
o=e();for o=1,o do
local l={};local e=n();l.type=e;if e==1 then
l.data=(n()~=0);elseif e==3 then
l.data=a();elseif e==4 then
l.data=u():sub(1,-2);end
r[o-1]=l;end
end
do
o=e();for l=1,o do
d[l-1]=t(true);end
end
return c;end
return t();end
local function d(...)local e=select("#",...)local l={...}return e,l
end
local function A(a,l)local h=a.instructions;local e=a.constants;local l=a.prototypes;local t,o
local u
local c=1;local s,i
local d={[5]=function(l)local e=e[l.Bx].data;t[l.A]=u[e];end,[1]=function(l)t[l.A]=e[l.Bx].data;end,[28]=function(l)local e=l.A;local f=l.B;local r=l.C;local c=t;local a,t;local l,n
a={};if f~=1 then
if f~=0 then
l=e+f-1;else
l=o
end
n=0
for e=e+1,l do
n=n+1
a[n]=c[e];end
l,t=d(c[e](unpack(a,1,l-e)))else
l,t=d(c[e]())end
o=e-1
if r~=1 then
if r~=0 then
l=e+r-2;else
l=l+e
end
n=0;for l=e,l do
n=n+1;c[l]=t[n];end
end
end,[30]=function(l)local c=l.A;local e=l.B;local a=t;local n;local t,l;if e==1 then
return true;end
if e==0 then
n=o
else
n=c+e-2;end
l={};local e=0
for n=c,n do
e=e+1
l[e]=a[n];end
return true,l;end,}local function r()local o=h
local l,n,e
while true do
l=o[c];c=c+1
n,e=d[l.opcode](l);if n then
return e;end
end
end
local f={};local function h(...)local n={};local d={};o=-1
t=setmetatable(n,{__index=d;__newindex=function(n,l,e)if l>o and e then
o=l
end
d[l]=e
end;})local e={...};s={}i=select("#",...)-1
for l=0,i do
n[l]=e[l+1];s[l]=e[l+1]end
u=getfenv();c=1;local l=coroutine.create(r)local l,e=coroutine.resume(l)if l then
if e then
return unpack(e);end
return;else
local n=a.name;local o=a.debug.lines[c];local l=e:gsub("(.-:)","");local l="";l=l..(n and n..":"or"");l=l..(o and o..":"or"");l=l..e;error(l,0);end
end
return f,h;end
local function _(f,x)local e=f.instructions;local i=f.constants;local _=f.prototypes;local u,c
local s
local l=1;local b,B
local function g()local t=e
local e,n,n
e=t[l];l=l+1
local n=i[e.Bx].data;u[e.A]=s[n];e=t[l];l=l+1
u[e.A]=i[e.Bx].data;e=t[l];l=l+1
local o=e.A;local f=e.B;local p=e.C;local r=u;local h,u;local n,a
h={};if f~=1 then
if f~=0 then
n=o+f-1;else
n=c
end
a=0
for l=o+1,n do
a=a+1
h[a]=r[l];end
n,u=d(r[o](unpack(h,1,n-o)))else
n,u=d(r[o]())end
c=o-1
if p~=1 then
if p~=0 then
n=o+p-2;else
n=n+o
end
a=0;for l=o,n do
a=a+1;r[l]=u[a];end
end
e=t[l];l=l+1
local a=_[e.Bx]local t=t
local n=r
local o={}local r=setmetatable({},{__index=function(e,l)local l=o[l]return l.segment[l.offset]end,__newindex=function(n,l,e)local l=o[l]l.segment[l.offset]=e
end})for c=1,a.upvalues do
local e=t[l]if e.opcode==0 then
o[c-1]={segment=n,offset=e.B}elseif t[l].opcode==4 then
o[c-1]={segment=x,offset=e.B}end
l=l+1
end
local a,o=A(a,r)n[e.A]=o
e=t[l];l=l+1
local o=i[e.Bx].data;s[o]=n[e.A];e=t[l];l=l+1
local o=i[e.Bx].data;n[e.A]=s[o];e=t[l];l=l+1
local o=e.A;local u=e.B;local f=e.C;local r=n;local s,i;local n,a
s={};if u~=1 then
if u~=0 then
n=o+u-1;else
n=c
end
a=0
for l=o+1,n do
a=a+1
s[a]=r[l];end
n,i=d(r[o](unpack(s,1,n-o)))else
n,i=d(r[o]())end
c=o-1
if f~=1 then
if f~=0 then
n=o+f-2;else
n=n+o
end
a=0;for l=o,n do
a=a+1;r[l]=i[a];end
end
e=t[l];l=l+1
local o=e.A;local e=e.B;local a=r;local n;local t,l;if e==1 then
return true;end
if e==0 then
n=c
else
n=o+e-2;end
l={};local e=0
for n=o,n do
e=e+1
l[e]=a[n];end
return true,l;end
local t={};local function a(...)local e={};local n={};c=-1
u=setmetatable(e,{__index=n;__newindex=function(o,l,e)if l>c and e then
c=l
end
n[l]=e
end;})local n={...};b={}B=select("#",...)-1
for l=0,B do
e[l]=n[l+1];b[l]=n[l+1]end
s=getfenv();l=1;local e=coroutine.create(g)local n,o,e=coroutine.resume(e)if n and o then
if e then
return unpack(e);end
return;else
local o=f.name;local n=f.debug.lines[l];local l=e:gsub("(.-:)","");local l="";l=l..(o and o..":"or"");l=l..(n and n..":"or"");l=l..e;error(l,0);end
end
return t,a;end
load_bytecode=function(l)local l=x(l);local e,l=_(l);return l;end;load_bytecode("\0\b\0\0\0\0\2\0\1\2\1\0\1\2\1\0\2\0\0\2\2\0\2\2\0\1\1\1\0\1\1\0\3\0\0\0\4\6\0\0\0print\0\4\3\0\0\0xd\0\4\2\0\0\0d\0\1\0\0\0\0\4\0\0\0\5\0\2\0\1\1\2\1\28\0\1\2\1\30\0\1\1\0\2\0\0\0\4\6\0\0\0print\0\4\4\0\0\0lol\0\0\0\0\0")()