--[[
	EasyCrypt2 by Esther
	"Value" in Encrypt() stands for the string that is intended to be encrypted
	"Key" in Encrypt() stands for the key that will be used to encrypt the value.
	
	"Value" in Decrypt() stands for the string that is intended to be decrypted (Numbers between a "")
	"Key" in Decrypt() stands for the key that will be used to decrypt the value

--]]
local function Encrypt(Value,Key)
	local _V = {}
	local _K = {}
	local encv = {}
	
	for i = 1,#Value do
		table.insert(_V,string.byte(Value:sub(i,i)))
	end 
	for i = 1,#Key do
		table.insert(_K,string.byte(Key:sub(i,i))^4)
	end 
	
	local _I = 1
	for i,v in pairs(_V) do
		if _K[i] then
			table.insert(encv,v+_K[i])
		else
			if _I ~= #_K then
				table.insert(encv,v+_K[_I])
				_I = _I + 1
			else
				table.insert(encv,v+_K[1])
				_I = 1
			end
		end
	end
	
	return encv
end

print(unpack(Encrypt("Test123","TestKey")))


local function Decrypt(Value, Key)
	local _A = Value
	local _B = 1
	Value = {}
	for i = 1,#_A do
		if _A:sub(i,i) == " " then
			table.insert(Value,_A:sub(_B,i-1))
			_B = i+1
		elseif i == #_A then
			table.insert(Value,_A:sub(_B))
		end
	end
	
	
	local _V = ""
	local _K = {}
	
	for i = 1,#Key do
		table.insert(_K,string.byte(Key:sub(i,i))^4)
	end
	
	local _I = 1
	local A, B = pcall(function()
		for i,v in pairs(Value) do
			if _K[i] then
				_V = _V..string.char(v-_K[i])
			else
				if _I ~= #_K then
					_V = _V..string.char(v-_K[_I])
					_I = _I + 1
				else
					_V = _V..string.char(v-_K[1])
					_I = 1
				end
			end
		end
	end)
	
	
	if A then
		return _V
	else
		print("An error occured while decrypting. Please check your key")
		return false
	end
	
end

print(Decrypt("49787220 104060502 174900740 181064052 31640674 104060451 214358932","TestKey"))