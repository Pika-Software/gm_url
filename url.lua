-- [yue]: url.yue
local _module_0 = { } -- 1
--[[
    MIT License

    Copyright (c) 2024 Pika Software

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]
local type, tostring, tonumber, string, table = _G.type, _G.tostring, _G.tonumber, _G.string, _G.table -- 24
local byte, char, sub, gsub, match, find, lower, Split = string.byte, string.char, string.sub, string.gsub, string.match, string.find, string.lower, string.Split -- 25
local concat, insert, remove = table.concat, table.insert, table.remove -- 26
local CERTAINLY_NOT_NESTED = false -- 28
local MIGHT_BE_NESTED = true -- 29
local COMMA = 0x2C -- 31
local EQUALS = 0x3D -- 32
local PCT = 0x25 -- 33
local LEFT = 0x5B -- 34
local RIGHT = 0x5D -- 35
local AMP = 0x26 -- 36
local PLUS = 0x2B -- 37
local INT_START = 0x30 -- 38
local INT_END = 0x39 -- 39
local makeAsciiTable -- 41
makeAsciiTable = function(spec) -- 41
	local ret = { } -- 42
	for _index_0 = 1, #spec do -- 43
		local item = spec[_index_0] -- 43
		if type(item) == "number" then -- 44
			ret[item] = true -- 45
		else -- 47
			for j = item[1], item[2] do -- 47
				ret[j] = true -- 48
			end -- 48
		end -- 44
	end -- 48
	return ret -- 49
end -- 41
local containsCharacter -- 51
containsCharacter = function(string, char1, fromIndex, stopCharacterTable) -- 51
	local len = #string -- 52
	for i = fromIndex, len do -- 53
		local ch = byte(string, i) -- 54
		if ch == char1 then -- 55
			return true -- 56
		end -- 55
		if stopCharacterTable[ch] then -- 57
			return false -- 58
		end -- 57
	end -- 58
	return false -- 59
end -- 51
local containsCharacter2 -- 61
containsCharacter2 = function(string, char1, char2) -- 61
	local len = #string -- 62
	for i = 1, len do -- 63
		local ch = byte(string, i) -- 64
		if ch == char1 or ch == char2 then -- 65
			return true -- 66
		end -- 65
	end -- 66
	return false -- 67
end -- 61
-- Lookup table for decoding percent-encoded characters and encoding special characters
-- Using HEX_TABLE will result in a double speedup compared to using functions
local HEX_TABLE = { } -- 71
for i = 0x00, 0xFF do -- 72
	local hex = bit.tohex(i, 2) -- 73
	HEX_TABLE[hex] = char(i) -- 74
	HEX_TABLE[hex:upper()] = char(i) -- 75
	HEX_TABLE[char(i)] = "%" .. hex:upper() -- 76
end -- 76
-- Special characters
HEX_TABLE["\r\n"] = "\n" -- 78
HEX_TABLE[" "] = "+" -- 79
HEX_TABLE["-"] = "-" -- 80
HEX_TABLE["."] = "." -- 81
HEX_TABLE["_"] = "_" -- 82
HEX_TABLE["~"] = "~" -- 83
HEX_TABLE["!"] = "!" -- 84
HEX_TABLE["*"] = "*" -- 85
HEX_TABLE["'"] = "'" -- 86
HEX_TABLE["("] = "(" -- 87
HEX_TABLE[")"] = ")" -- 88
local decodeURI -- 90
decodeURI = function(s) -- 90
	s = gsub(gsub(s, "%%(%x%x)", HEX_TABLE), "+", " ") -- 91
	return s -- 92
end -- 90
_module_0["decodeURI"] = decodeURI -- 92
local encodeURI -- 94
encodeURI = function(s) -- 94
	s = gsub(s, "%W", HEX_TABLE) -- 95
	return s -- 96
end -- 94
_module_0["encodeURI"] = encodeURI -- 96
local autoEscape = { -- 98
	"<", -- 98
	">", -- 98
	"\"", -- 98
	"`", -- 98
	" ", -- 98
	"\r", -- 98
	"\n", -- 98
	"\t", -- 99
	"{", -- 99
	"}", -- 99
	"|", -- 99
	"\\", -- 99
	"^", -- 99
	"`", -- 99
	"'" -- 99
} -- 98
local autoEscapeMap = { } -- 101
for _index_0 = 1, #autoEscape do -- 103
	local c = autoEscape[_index_0] -- 103
	local esc = encodeURI(c) -- 104
	if esc == c then -- 105
		esc = "%" .. bit.tohex(byte(c), 2):upper() -- 106
	end -- 105
	autoEscapeMap[byte(c)] = esc -- 107
end -- 107
local afterQueryAutoEscapeMap = table.Copy(autoEscapeMap) -- 109
autoEscapeMap[0x5C] = "/" -- 110
-- https://github.com/petkaantonov/querystringparser
local QueryStringParser -- 113
do -- 113
	local _class_0 -- 113
	local _base_0 = { -- 113
		maxLength = 32768, -- 115
		maxDepth = 4, -- 116
		maxKeys = 256, -- 118
		parse = function(self, str) -- 118
			self.containsSparse = false -- 119
			self.cacheKey = "" -- 120
			self.cacheVal = nil -- 121
			if type(str) == "string" then -- 123
				if #str > self.maxLength then -- 124
					error("str is too large (QueryStringParser.maxLength=" .. tostring(self.maxLength) .. ")") -- 125
				end -- 124
				return self:parseString(str, false) -- 127
			else -- 128
				if type(str) == "table" then -- 128
					error("not implemented") -- 129
				end -- 128
			end -- 123
			return { } -- 130
		end, -- 132
		stringify = function(self, obj) -- 132
			if type(obj) ~= "table" then -- 133
				error("obj must be a table") -- 134
			end -- 133
			local keyPrefix = "" -- 136
			local cur = obj -- 137
			local key = nil -- 138
			local value = nil -- 139
			local isArray = false -- 140
			local stack = { } -- 141
			local stackLen = 0 -- 142
			local ret = { } -- 143
			-- spooky spooky while true loop :)
			while true do -- 146
				if isArray then -- 147
					key = key + 1 -- 148
					value = cur[key] -- 149
					if not value then -- 150
						key = nil -- 151
					end -- 150
				else -- 153
					key, value = next(cur, key) -- 153
				end -- 147
				if key ~= nil then -- 155
					local serializedKey = encodeURI(isArray and tostring(key - 1) or tostring(key)) -- 156
					if type(value) == "table" then -- 157
						stack[stackLen + 1] = keyPrefix -- 158
						stack[stackLen + 2] = cur -- 159
						stack[stackLen + 3] = key -- 160
						stack[stackLen + 4] = isArray -- 161
						stackLen = stackLen + 4 -- 162
						keyPrefix = keyPrefix == "" and serializedKey or keyPrefix .. "[" .. serializedKey .. "]" -- 164
						isArray = value[1] and true or false -- 165
						key = isArray and 0 or nil -- 166
						cur = value -- 167
					else -- 169
						serializedKey = keyPrefix == "" and serializedKey or keyPrefix .. "[" .. serializedKey .. "]" -- 169
						ret[#ret + 1] = serializedKey .. "=" .. encodeURI(value) -- 170
					end -- 157
				else -- 171
					if stackLen ~= 0 then -- 171
						keyPrefix = stack[stackLen - 3] -- 172
						cur = stack[stackLen - 2] -- 173
						key = stack[stackLen - 1] -- 174
						isArray = stack[stackLen] -- 175
						stackLen = stackLen - 4 -- 176
					else -- 178
						break -- 178
					end -- 171
				end -- 155
			end -- 178
			return concat(ret, "&") -- 180
		end, -- 183
		decode = function(self, str, shouldDecode, containsPlus) -- 183
			if not shouldDecode then -- 184
				return str -- 185
			end -- 184
			if containsPlus then -- 186
				str = gsub(str, "%+", " ") -- 187
			end -- 186
			return decodeURI(str) -- 188
		end, -- 190
		maybeArrayIndex = function(self, str, arrayLength) -- 190
			local len = #str -- 191
			-- Empty string I.E. direct brackets [] means index will be .length
			if len == 0 then -- 193
				return arrayLength -- 194
			end -- 193
			local ch = byte(str, 1) -- 196
			-- "0" is only valid index if it's the only character in the string
			-- "00", "001", are not valid array indices
			if ch == INT_START then -- 200
				return len > 1 and -1 or 1 -- 201
			else -- 202
				if INT_START <= ch and ch <= INT_END then -- 202
					-- Single digit number 1-9
					if len == 1 then -- 204
						return ch - INT_START + 1 -- 205
					else -- 206
						if match(str, "^%d+$") then -- 206
							return tonumber(str) + 1 -- 207
						end -- 206
					end -- 204
				end -- 202
			end -- 200
			return -1 -- 208
		end, -- 210
		getSlot = function(self, dictonary, prevKey, curKey) -- 210
			if not dictonary[prevKey] then -- 211
				dictonary[prevKey] = { } -- 212
			end -- 211
			return dictonary[prevKey] -- 213
		end, -- 215
		placeNestedValue = function(self, dictonary, key, value, i, prevKey, curKey) -- 215
			local slot = self:getSlot(dictonary, prevKey, curKey) -- 216
			local index = self:maybeArrayIndex(curKey, #slot) -- 217
			local len = #key -- 219
			local depth = 2 -- 220
			local maxDepth = self.maxDepth -- 221
			local start = -1 -- 222
			while (i <= len) do -- 223
				local ch = byte(key, i) -- 224
				if ch == LEFT then -- 225
					start = i + 1 -- 226
				else -- 227
					if ch == RIGHT and start ~= -1 then -- 227
						prevKey = curKey -- 228
						curKey = start == i and "" or sub(key, start, i - 1) -- 229
						start = -1 -- 230
						depth = depth + 1 -- 231
						if depth > maxDepth then -- 232
							error("too deep (QueryStringParser.maxDepth=" .. tostring(maxDepth) .. ")") -- 233
						end -- 232
						slot = self:getSlot(slot, prevKey, curKey) -- 234
						index = self:maybeArrayIndex(curKey, #slot) -- 235
					end -- 227
				end -- 225
				i = i + 1 -- 236
			end -- 236
			if index ~= -1 then -- 238
				if value ~= "" then -- 239
					if index == (#slot + 1) then -- 240
						slot[#slot + 1] = value -- 241
					else -- 243
						self.containsSparse = true -- 243
						slot[index] = value -- 244
					end -- 240
				end -- 239
			else -- 246
				return self:insert(slot, curKey, value) -- 246
			end -- 238
		end, -- 248
		insert = function(self, dictonary, key, value) -- 248
			local prev = dictonary[key] -- 249
			if prev then -- 249
				if type(prev) == "table" then -- 250
					prev[#prev + 1] = value -- 251
					return prev -- 252
				else -- 254
					local new = { -- 254
						prev, -- 254
						value -- 254
					} -- 254
					dictonary[key] = new -- 255
					return new -- 256
				end -- 250
			else -- 258
				dictonary[key] = value -- 258
			end -- 249
		end, -- 260
		push = function(self, dictonary, key, value) -- 260
			do -- 261
				local prev = dictonary[key] -- 261
				if prev then -- 261
					prev[#prev + 1] = value -- 262
					return prev -- 263
				end -- 261
			end -- 261
			local new = { -- 264
				value -- 264
			} -- 264
			dictonary[key] = new -- 265
			return new -- 266
		end, -- 268
		maybePlaceNestedValue = function(self, dictonary, key, value) -- 268
			local len = #key -- 269
			if byte(key, len) ~= RIGHT then -- 270
				self:placeValue(dictonary, key, value, CERTAINLY_NOT_NESTED) -- 271
				return -- 272
			end -- 270
			local start = -1 -- 274
			local i = 1 -- 275
			local curKey = nil -- 276
			local prevKey = nil -- 277
			while i <= len do -- 279
				local ch = byte(key, i) -- 280
				if ch == LEFT then -- 281
					start = i + 1 -- 282
					prevKey = sub(key, 1, i - 1) -- 283
				else -- 284
					if ch == RIGHT then -- 284
						if start == -1 then -- 285
							self:placeValue(dictonary, key, value, CERTAINLY_NOT_NESTED) -- 286
							return -- 287
						end -- 285
						curKey = start == i and "" or sub(key, start, i - 1) -- 288
						i = i + 1 -- 289
						break -- 290
					end -- 284
				end -- 281
				i = i + 1 -- 291
			end -- 291
			if curKey == nil then -- 293
				self:placeValue(dictonary, key, value, CERTAINLY_NOT_NESTED) -- 294
				return -- 295
			end -- 293
			if curKey == "" and value ~= "" and i == len then -- 297
				if key == self.cacheKey then -- 298
					local _obj_0 = self.cacheValue -- 299
					_obj_0[#_obj_0 + 1] = value -- 299
				else -- 301
					self.cacheKey = key -- 301
					self.cacheValue = self:push(dictonary, prevKey, value) -- 302
				end -- 298
			else -- 304
				return self:placeNestedValue(dictonary, key, value, i, prevKey, curKey) -- 304
			end -- 297
		end, -- 306
		placeValue = function(self, dictonary, key, value, possiblyNested) -- 306
			if possiblyNested == MIGHT_BE_NESTED then -- 307
				self:maybePlaceNestedValue(dictonary, key, value) -- 308
				return -- 309
			end -- 307
			if key == self.cacheKey then -- 310
				do -- 311
					local _obj_0 = self.cacheValue -- 311
					_obj_0[#_obj_0 + 1] = value -- 311
				end -- 311
				return -- 312
			end -- 310
			local cache = self:insert(dictonary, key, value) -- 313
			if cache then -- 313
				self.cacheKey = key -- 314
				self.cacheValue = cache -- 315
			end -- 313
		end, -- 317
		compact = function(self, obj) -- 317
			if type(obj) ~= "table" then -- 318
				return obj -- 319
			end -- 318
			if obj[1] then -- 321
				local ret = { } -- 322
				for _, v in pairs(obj) do -- 323
					ret[#ret + 1] = v -- 324
				end -- 324
				return ret -- 325
			else -- 327
				for k, v in pairs(obj) do -- 327
					obj[k] = self:compact(v) -- 328
				end -- 328
				return obj -- 329
			end -- 321
		end, -- 332
		parseString = function(self, str, noDecode) -- 332
			local keys = 0 -- 333
			local decodeKey = false -- 334
			local decodeValue = false -- 335
			local possiblyNested = CERTAINLY_NOT_NESTED -- 336
			local len = #str -- 337
			local i = 1 -- 338
			local dictonary = { } -- 339
			local keyStart = 1 -- 340
			local keyEnd = 1 -- 341
			local valueStart = 1 -- 342
			local valueEnd = 1 -- 343
			local left = 0 -- 344
			local containsPlus = false -- 345
			while i <= len do -- 347
				local ch = byte(str, i) -- 348
				if ch == LEFT then -- 350
					left = left + 1 -- 351
				else -- 352
					if left > 0 and ch == RIGHT then -- 352
						possiblyNested = MIGHT_BE_NESTED -- 353
						left = left - 1 -- 354
					else -- 355
						if left == 0 and ch == EQUALS then -- 355
							keyEnd = i - 1 -- 356
							valueEnd = i + 1 -- 357
							valueStart = valueEnd -- 357
							local key = sub(str, keyStart, keyEnd) -- 358
							key = self:decode(key, decodeKey, containsPlus) -- 359
							decodeKey = false -- 360
							for j = valueStart, len do -- 362
								ch = byte(str, j) -- 363
								if (ch == PLUS or ch == PCT) and not noDecode then -- 365
									if (ch == PLUS) then -- 366
										containsPlus = true -- 366
									end -- 366
									decodeValue = true -- 367
								end -- 365
								if ch == AMP or j == len then -- 368
									valueEnd = j -- 369
									i = j -- 370
									if ch == AMP then -- 371
										valueEnd = valueEnd - 1 -- 372
									end -- 371
									local value = sub(str, valueStart, valueEnd) -- 374
									value = self:decode(value, decodeValue, containsPlus) -- 375
									-- Place value
									self:placeValue(dictonary, key, value, possiblyNested) -- 378
									containsPlus = false -- 380
									decodeValue = false -- 380
									possiblyNested = CERTAINLY_NOT_NESTED -- 381
									keyStart = j + 1 -- 383
									keys = keys + 1 -- 384
									if (keys > self.maxKeys) then -- 385
										error("too many keys (QueryStringParser.maxKeys=" .. tostring(self.maxKeys) .. ")") -- 386
									end -- 385
									break -- 387
								end -- 368
							end -- 387
						else -- 388
							if (ch == PLUS or ch == PCT) and not noDecode then -- 388
								if ch == PLUS then -- 389
									containsPlus = true -- 389
								end -- 389
								decodeKey = true -- 390
							end -- 388
						end -- 355
					end -- 352
				end -- 350
				i = i + 1 -- 391
			end -- 391
			if keyStart < len then -- 393
				local key = sub(str, keyStart, len) -- 394
				key = self:decode(key, decodeKey, containsPlus) -- 395
				self:placeValue(dictonary, key, "", possiblyNested) -- 396
			end -- 393
			if self.containsSparse then -- 398
				-- original developer once said 
				-- This behavior is pretty stupid but what you gonna do
				self:compact(dictonary) -- 401
			end -- 398
			return dictonary -- 403
		end -- 113
	} -- 113
	if _base_0.__index == nil then -- 113
		_base_0.__index = _base_0 -- 113
	end -- 403
	_class_0 = setmetatable({ -- 113
		__init = function() end, -- 113
		__base = _base_0, -- 113
		__name = "QueryStringParser" -- 113
	}, { -- 113
		__index = _base_0, -- 113
		__call = function(cls, ...) -- 113
			local _self_0 = setmetatable({ }, _base_0) -- 113
			cls.__init(_self_0, ...) -- 113
			return _self_0 -- 113
		end -- 113
	}) -- 113
	_base_0.__class = _class_0 -- 113
	QueryStringParser = _class_0 -- 113
end -- 403
_module_0["QueryStringParser"] = QueryStringParser -- 113
-- https://github.com/petkaantonov/urlparser
local URL -- 406
local _class_0 -- 406
local _base_0 = { -- 406
	queryString = QueryStringParser(), -- 409
	_protocolCharacters = makeAsciiTable({ -- 410
		{ -- 410
			0x61, -- 410
			0x7A -- 410
		}, -- 410
		{ -- 411
			0x41, -- 411
			0x5A -- 411
		}, -- 411
		0x2E, -- 412
		0x2B, -- 412
		0x2D -- 412
	}), -- 414
	_hostEndingCharacters = makeAsciiTable({ -- 414
		0x23, -- 414
		0x3F, -- 414
		0x2F, -- 414
		0x5C -- 414
	}), -- 416
	_noPrependSlashHostEnders = makeAsciiTable((function() -- 416
		local _accum_0 = { } -- 416
		local _len_0 = 1 -- 416
		local _list_0 = { -- 417
			"<", -- 417
			">", -- 417
			"'", -- 417
			"`", -- 417
			" ", -- 417
			"\r", -- 417
			"\n", -- 418
			"\t", -- 418
			"{", -- 418
			"}", -- 418
			"|", -- 418
			"^", -- 419
			"`", -- 419
			"\"", -- 419
			"%", -- 419
			";" -- 419
		} -- 416
		for _index_0 = 1, #_list_0 do -- 420
			local s = _list_0[_index_0] -- 416
			_accum_0[_len_0] = byte(s) -- 416
			_len_0 = _len_0 + 1 -- 416
		end -- 416
		return _accum_0 -- 420
	end)()), -- 421
	_autoEscapeCharacters = makeAsciiTable((function() -- 421
		local _accum_0 = { } -- 421
		local _len_0 = 1 -- 421
		for _index_0 = 1, #autoEscape do -- 421
			local s = autoEscape[_index_0] -- 421
			_accum_0[_len_0] = byte(s) -- 421
			_len_0 = _len_0 + 1 -- 421
		end -- 421
		return _accum_0 -- 421
	end)()), -- 423
	_autoEscapeMap = autoEscapeMap, -- 424
	_afterQueryAutoEscapeMap = afterQueryAutoEscapeMap, -- 426
	_slashProtocols = { -- 427
		http = true, -- 427
		https = true, -- 428
		gopher = true, -- 429
		file = true, -- 430
		ftp = true, -- 431
		["http:"] = true, -- 432
		["https:"] = true, -- 433
		["gopher:"] = true, -- 434
		["file:"] = true, -- 435
		["ftp:"] = true -- 436
	}, -- 458
	parse = function(self, str, parseStringQuery, hostDenotesSlash, disableAutoEscapeChars) -- 458
		if type(str) ~= "string" then -- 459
			error("Parameter 'url' must be a string, not " .. type(str)) -- 460
		end -- 459
		local startPos = 1 -- 462
		local endPos = #str -- 463
		-- Trim leading and trailing whitespaces
		while byte(str, startPos) <= 0x20 do -- 466
			startPos = startPos + 1 -- 466
		end -- 466
		while byte(str, endPos) <= 0x20 do -- 467
			endPos = endPos - 1 -- 467
		end -- 467
		startPos = self:_parseProtocol(str, startPos, endPos) -- 469
		-- Javascript does not have host
		if self._protocol ~= "javascript" then -- 472
			startPos = self:_parseHost(str, startPos, endPos, hostDenotesSlash) -- 473
			local proto = self._protocol -- 474
			if not self.hostname and (self.slashes and (proto and not self._slashProtocols[proto])) then -- 475
				do -- 476
					local _tmp_0 = "" -- 476
					self.hostname = _tmp_0 -- 476
					self.host = _tmp_0 -- 476
				end -- 476
			end -- 475
		end -- 472
		if startPos <= endPos then -- 478
			local ch = byte(str, startPos) -- 479
			if ch == 0x2F or ch == 0x5C then -- 480
				self:_parsePath(str, startPos, endPos, disableAutoEscapeChars) -- 481
			else -- 482
				if ch == 0x3F then -- 482
					self:_parseQuery(str, startPos, endPos, disableAutoEscapeChars) -- 483
				else -- 484
					if ch == 0x23 then -- 484
						self:_parseHash(str, startPos, endPos, disableAutoEscapeChars) -- 485
					else -- 486
						if self._protocol ~= "javascript" then -- 486
							self:_parsePath(str, startPos, endPos, disableAutoEscapeChars) -- 487
						else -- 489
							self.pathname = sub(str, startPos, endPos) -- 489
						end -- 486
					end -- 484
				end -- 482
			end -- 480
		end -- 478
		if not self.pathname and self.hostname and self._slashProtocols[self._protocol] then -- 491
			self.pathname = "/" -- 492
		end -- 491
		if parseStringQuery then -- 494
			local search = self.search -- 495
			if not search then -- 496
				search = "" -- 497
				self.search = search -- 497
			end -- 496
			if byte(search, 0) == 0x3F then -- 498
				search = sub(search, 2) -- 499
			end -- 498
			-- TODO: This calls a setter function, there is no .query data property
			self.query = self.queryString:parse(search) -- 501
		end -- 494
	end, -- 503
	resolve = function(self, relative) -- 503
		return self:resolveObject(URL.parse(relative, false, true)):format() -- 503
	end, -- 505
	_escapePathname = function(self, pathname) -- 505
		return gsub(pathname, "[%?#]", HEX_TABLE) -- 505
	end, -- 506
	_escapeSearch = function(self, search) -- 506
		return gsub(search, "#", HEX_TABLE) -- 506
	end, -- 508
	format = function(self) -- 508
		local auth = self.auth or "" -- 509
		if auth ~= "" then -- 510
			auth = encodeURI(auth) -- 511
			auth = gsub(auth, "%%3A", ":") -- 512
			auth = auth .. "@" -- 513
		end -- 510
		local protocol = self._protocol or "" -- 515
		local pathname = self.pathname or "" -- 516
		local hash = self.hash or "" -- 517
		local search = self.search or "" -- 518
		local query = self.query or "" -- 519
		local hostname = self.hostname or "" -- 520
		local port = self._port or "" -- 521
		local host = false -- 522
		local scheme = "" -- 523
		local q = self.query -- 525
		if type(q) == "table" then -- 526
			query = self.queryString:stringify(q) -- 527
		end -- 526
		if search == "" then -- 529
			search = query ~= "" and "?" .. query or "" -- 530
		end -- 529
		if protocol ~= "" and byte(protocol, -1) ~= 0x3A then -- 532
			protocol = protocol .. ":" -- 533
		end -- 532
		if self.host then -- 535
			host = auth .. self.host -- 536
		else -- 537
			if hostname ~= "" then -- 537
				local ip6 = find(hostname, ":", 1, true) -- 538
				if ip6 then -- 539
					hostname = "[" .. hostname .. "]" -- 540
				end -- 539
				host = auth .. hostname .. (port ~= "" and ":" .. port or "") -- 541
			end -- 537
		end -- 535
		local slashes = self.slashes or ((protocol == "" or self._slashProtocols[protocol]) and host ~= false) -- 543
		if protocol ~= "" then -- 544
			scheme = protocol .. (slashes and "//" or "/") -- 545
		else -- 546
			if slashes then -- 546
				scheme = "//" -- 547
			end -- 546
		end -- 544
		if slashes and pathname ~= "" and byte(pathname, 1) ~= 0x2F then -- 549
			pathname = "/" .. pathname -- 550
		end -- 549
		if search ~= "" and byte(search, 1) ~= 0x3F then -- 551
			search = "?" .. search -- 552
		end -- 551
		if hash ~= "" and byte(hash, 1) ~= 0x23 then -- 553
			hash = "#" .. hash -- 554
		end -- 553
		pathname = self:_escapePathname(pathname) -- 556
		search = self:_escapeSearch(search) -- 557
		return concat({ -- 559
			scheme, -- 559
			host == false and "" or host, -- 559
			pathname, -- 559
			search, -- 559
			hash -- 559
		}) -- 559
	end, -- 561
	resolveObject = function(self, relative) -- 561
		if type(relative) == "string" then -- 562
			relative = URL.parse(relative, false, true) -- 563
		end -- 562
		local result = self:_clone() -- 565
		-- hash is always overridden, no matter what.
		-- even href="" will remove it.
		result.hash = relative.hash -- 569
		-- if the relative url is empty, then there"s nothing left to do here.
		if relative.href == "" then -- 572
			result.href = "" -- 573
			return result -- 574
		end -- 572
		-- hrefs like //foo/bar always cut to the protocol.
		if relative.slashes and not relative._protocol then -- 577
			relative:_copyPropsTo(result, true) -- 578
			if self._slashProtocols[result._protocol] and result.hostname and not result.pathname then -- 579
				result.pathname = "/" -- 580
			end -- 579
			result._href = "" -- 581
			return result -- 582
		end -- 577
		if relative._protocol and relative._protocol ~= result._protocol then -- 584
			-- if it"s a known url protocol, then changing
			-- the protocol does weird things
			-- first, if it"s not file:, then we MUST have a host,
			-- and if there was a path
			-- to begin with, then we MUST have a path.
			-- if it is file:, then the host is dropped,
			-- because that"s known to be hostless.
			-- anything else is assumed to be absolute.
			if self._slashProtocols[relative._protocol] then -- 593
				relative:_copyPropsTo(result, false) -- 594
				result._href = "" -- 595
				return result -- 596
			end -- 593
			result._protocol = relative._protocol -- 597
			if not relative.host and relative._protocol ~= "javascript" then -- 598
				local relPath = Split(relative.pathname or "", "/") -- 599
				while #relPath ~= 0 do -- 600
					local host = remove(relPath, 1) -- 601
					if host and host ~= "" then -- 602
						relative.host = host -- 603
						break -- 604
					end -- 602
				end -- 604
				if not relative.host then -- 605
					relative.host = "" -- 606
				end -- 605
				if not relative.hostname then -- 607
					relative.hostname = "" -- 608
				end -- 607
				if relPath[1] ~= "" then -- 609
					insert(relPath, 1, "") -- 610
				end -- 609
				if #relPath < 2 then -- 611
					insert(relPath, 1, "") -- 612
				end -- 611
				result.pathname = concat(relPath, "/") -- 613
			else -- 615
				result.pathname = relative.pathname -- 615
			end -- 598
			result.search = relative.search -- 617
			result.host = relative.host or "" -- 618
			result.auth = relative.auth -- 619
			result.hostname = relative.hostname or result.hostname -- 620
			result._port = relative._port -- 621
			result.slashes = relative.slashes -- 622
			result._href = "" -- 623
			return result -- 624
		end -- 584
		local isSourceAbs = result.pathname and byte(result.pathname, 1) == 0x2F -- 626
		local isRelAbs = not not relative.host or relative.pathname and byte(relative.pathname, 1) == 0x2F -- 627
		local mustEndAbs = isRelAbs or isSourceAbs or (result.host and relative.pathname) -- 628
		local removeAllDots = mustEndAbs -- 629
		local srcPath = result.pathname and Split(result.pathname, "/") or { } -- 631
		local relPath = relative.pathname and Split(relative.pathname, "/") or { } -- 632
		local psychotic = result._protocol and not self._slashProtocols[result._protocol] -- 633
		-- if the url is a non-slashed url, then relative
		-- links like ../.. should be able
		-- to crawl up to the hostname, as well.  This is strange.
		-- result.protocol has already been set by now.
		-- Later on, put the first path part into the host field.
		if psychotic then -- 640
			result.hostname = "" -- 641
			result._port = -1 -- 642
			if result.host then -- 643
				if srcPath[1] == "" then -- 644
					srcPath[1] = result.host -- 645
				else -- 647
					insert(srcPath, 1, result.host) -- 647
				end -- 644
			end -- 643
			result.host = "" -- 648
			if relative._protocol then -- 649
				relative.hostname = "" -- 650
				relative._port = -1 -- 651
				if relative.host then -- 652
					if relPath[1] == "" then -- 653
						relPath[1] = relative.host -- 654
					else -- 656
						insert(relPath, 1, relative.host) -- 656
					end -- 653
				end -- 652
				relative.host = "" -- 657
			end -- 649
			mustEndAbs = mustEndAbs and (relPath[1] == "" or srcPath[1] == "") -- 658
		end -- 640
		if isRelAbs then -- 660
			-- it's absolute.
			result.host = relative.host or result.host -- 662
			result.hostname = relative.hostname or result.hostname -- 663
			result.search = relative.search -- 664
			srcPath = relPath -- 665
		else -- 667
			if #relPath ~= 0 then -- 667
				-- it's relative
				-- throw away the existing file, and take the new path instead.
				if not srcPath then -- 670
					srcPath = { } -- 671
				end -- 670
				srcPath[#srcPath] = nil -- 672
				table.Add(srcPath, relPath) -- 673
				result.search = relative.search -- 674
			else -- 675
				if relative.search then -- 675
					-- just pull out the search.
					-- like href="?foo".
					-- Put this after the other two cases because it simplifies the booleans
					if psychotic then -- 679
						do -- 680
							local _tmp_0 = remove(srcPath, 1) -- 680
							result.hostname = _tmp_0 -- 680
							result.host = _tmp_0 -- 680
						end -- 680
						-- occationaly the auth can get stuck only in host
						-- this especialy happens in cases like
						-- url.resolveObject("mailto:local1@domain1", "local2@domain2")
						local authInHost = (result.host and (find(result.host, "@", 1, true) or -1) > 0) and Split(Split(result.host)) or false -- 684
						if authInHost then -- 685
							result.auth = authInHost[1] -- 686
							do -- 687
								local _tmp_0 = authInHost[2] -- 687
								result.host = _tmp_0 -- 687
								result.hostname = _tmp_0 -- 687
							end -- 687
						end -- 685
					end -- 679
					result.search = relative.search -- 688
					result._href = "" -- 689
					return result -- 690
				end -- 675
			end -- 667
		end -- 660
		if #srcPath == 0 then -- 692
			-- no path at all.  easy.
			-- we"ve already handled the other stuff above.
			result.pathname = nil -- 695
			result._href = "" -- 696
			return result -- 697
		end -- 692
		-- if a url ENDs in . or .., then it must get a trailing slash.
		-- however, if it ends in anything else non-slashy,
		-- then it must NOT get a trailing slash.
		local last = srcPath[#srcPath] -- 702
		local hasTrailingSlash = (result.host or relative.host) or (last == "." or last == "..") or last == "" -- 703
		-- strip single dots, resolve double dots to parent dir
		-- if the path tries to go above the root, `up` ends up > 0
		local up = 0 -- 707
		for i = #srcPath, 1, -1 do -- 708
			last = srcPath[i] -- 709
			if last == "." then -- 710
				remove(srcPath, i) -- 711
			else -- 712
				if last == ".." then -- 712
					remove(srcPath, i) -- 713
					up = up + 1 -- 714
				else -- 715
					if up > 0 then -- 715
						remove(srcPath, i) -- 716
						up = up - 1 -- 717
					end -- 715
				end -- 712
			end -- 710
		end -- 718
		-- if the path is allowed to go above the root, restore leading ..s
		if not mustEndAbs and not removeAllDots then -- 720
			while up > 0 do -- 721
				insert(srcPath, 1, "..") -- 722
				up = up - 1 -- 723
			end -- 724
		end -- 720
		if mustEndAbs and srcPath[1] ~= "" and (not srcPath[0] or byte(srcPath[1], 1) ~= 0x2F) then -- 725
			insert(srcPath, 1, "") -- 726
		end -- 725
		if hasTrailingSlash and (byte(concat(srcPath, "/"), 1) ~= 0x2F) then -- 727
			srcPath[#srcPath + 1] = "" -- 728
		end -- 727
		local isAbsolute = srcPath[1] == "" or (srcPath[0] and byte(srcPath[1], 1) == 0x2F) -- 730
		-- put the host back
		if psychotic then -- 733
			do -- 734
				local _tmp_0 = isAbsolute and "" or #srcPath > 0 and remove(srcPath, 1) or "" -- 734
				result.hostname = _tmp_0 -- 734
				result.host = _tmp_0 -- 734
			end -- 734
			-- occationaly the auth can get stuck only in host
			-- this especialy happens in cases like
			-- url.resolveObject("mailto:local1@domain1", "local2@domain2")
			local authInHost = result.host and (find(result.host, "@", 1, true) or -1) > 0 and Split(Split(result.host)) or false -- 738
			if authInHost then -- 739
				result.auth = authInHost[1] -- 740
				do -- 741
					local _tmp_0 = authInHost[2] -- 741
					result.host = _tmp_0 -- 741
					result.hostname = _tmp_0 -- 741
				end -- 741
			end -- 739
		end -- 733
		mustEndAbs = mustEndAbs or (result.host and #srcPath > 0) -- 743
		if not mustEndAbs and not isAbsolute then -- 745
			insert(srcPath, 1, "") -- 746
		end -- 745
		result.pathname = srcPath ~= 0 and concat(srcPath, "/") or nil -- 748
		result.auth = relative.auth or result.auth -- 749
		result.slashes = result.slashes or relative.slashes -- 750
		result._href = "" -- 751
		return result -- 752
	end, -- 755
	_hostIdna = function(self, hostname) -- 755
		-- TODO: Implement punycode and convert Idna to punycode
		return encodeURI(hostname) -- 757
	end, -- 759
	_parseProtocol = function(self, str, startPos, endPos) -- 759
		local doLowerCase = false -- 760
		local protocolCharacters = self._protocolCharacters -- 761
		for i = startPos, endPos do -- 762
			local ch = byte(str, i) -- 763
			if ch == 0x3A then -- 764
				local protocol = sub(str, startPos, i - 1) -- 765
				if doLowerCase then -- 766
					protocol = lower(protocol) -- 767
				end -- 766
				self._protocol = protocol -- 768
				return i + 1 -- 769
			else -- 770
				if protocolCharacters[ch] then -- 770
					if ch < 0x61 then -- 771
						doLowerCase = true -- 772
					end -- 771
				else -- 774
					break -- 774
				end -- 770
			end -- 764
		end -- 774
		return startPos -- 775
	end, -- 777
	_parseAuth = function(self, str, startPos, endPos, decode) -- 777
		local auth = sub(str, startPos, endPos) -- 778
		if decode then -- 779
			auth = decodeURI(auth) -- 780
		end -- 779
		self.auth = auth -- 781
	end, -- 783
	_parsePort = function(self, str, startPos, endPos) -- 783
		-- Internal format is integer for more efficient parsing
		-- and for efficient trimming of leading zeros
		local port = 0 -- 786
		-- Distinguish between :0 and : (no port number at all)
		local hadChars = false -- 788
		local validPort = true -- 789
		local i = startPos -- 790
		while i <= endPos do -- 792
			local ch = byte(str, i) -- 793
			if 0x30 <= ch and ch <= 0x39 then -- 794
				port = (10 * port) + (ch - 0x30) -- 795
				hadChars = true -- 796
			else -- 798
				validPort = false -- 798
				if ch == 0x5C or ch == 0x2F then -- 799
					validPort = true -- 800
				end -- 799
				break -- 801
			end -- 794
			i = i + 1 -- 802
		end -- 803
		if (port == 0 or not hadChars) or not validPort then -- 804
			if not validPort then -- 805
				self._port = -2 -- 806
			end -- 805
			return 0 -- 807
		end -- 804
		self._port = port -- 809
		return i - startPos -- 810
	end, -- 812
	_parseHost = function(self, str, startPos, endPos, slashesDenoteHost) -- 812
		local hostEndingCharacters = self._hostEndingCharacters -- 813
		local first = byte(str, startPos) -- 814
		local second = byte(str, startPos + 1) -- 815
		if (first == 0x2F or first == 0x5C) and (second == 0x2F or second == 0x5C) then -- 816
			self.slashes = true -- 817
			-- The string starts with //
			if startPos == 0 then -- 820
				-- The string is just "//"
				if endPos < 2 then -- 822
					return startPos -- 823
				end -- 822
				-- If slashes do not denote host and there is no auth,
				-- there is no host when the string starts with //
				local hasAuth = containsCharacter(str, 0x40, 3, hostEndingCharacters) -- 826
				if not slashesDenoteHost and not hasAuth then -- 827
					self.slashes = nil -- 828
					return startPos -- 829
				end -- 827
			end -- 820
			startPos = startPos + 2 -- 831
		else -- 836
			if not self._protocol or self._slashProtocols[self._protocol] then -- 836
				return startPos -- 837
			end -- 836
		end -- 816
		local doLowerCase = true -- 839
		local idna = false -- 840
		local hostNameStart = startPos -- 841
		local hostNameEnd = endPos -- 842
		local lastCh = -1 -- 843
		local portLength = 0 -- 844
		local charsAfterDot = 0 -- 845
		local authNeedsDecoding = false -- 846
		local j = -1 -- 847
		-- Find the last occurrence of an @-sign until hostending character is met
		-- also mark if decoding is needed for the auth portion
		for i = startPos, endPos do -- 851
			local ch = byte(str, i) -- 852
			if ch == 0x40 then -- 853
				j = i -- 854
			else -- 855
				if ch == 0x25 then -- 855
					authNeedsDecoding = true -- 856
				else -- 857
					if hostEndingCharacters[ch] then -- 857
						break -- 858
					end -- 857
				end -- 855
			end -- 853
		end -- 858
		-- @-sign was found at index j, everything to the left from it is auth part
		if j > -1 then -- 861
			self:_parseAuth(str, startPos, j - 1, authNeedsDecoding) -- 862
			startPos = j + 1 -- 863
			hostNameStart = startPos -- 863
		end -- 861
		-- Host name is starting with a [
		if byte(str, startPos) == 0x5B then -- 866
			for i = startPos + 1, endPos do -- 867
				local ch = byte(str, i) -- 868
				-- Assume valid IP6 is between the brackets
				if ch == 0x5D then -- 870
					if byte(str, i + 1) == 0x3A then -- 871
						portLength = self:_parsePort(str, i + 2, endPos) -- 872
					end -- 871
					local hostname = lower(sub(str, startPos + 1, i - 1)) -- 873
					self.hostname = hostname -- 874
					self.host = self._port > 0 and ("[" .. hostname .. "]:" .. self._port) or ("[" .. hostname .. "]") -- 875
					self.pathname = "/" -- 876
					return i + portLength + 1 -- 877
				end -- 870
			end -- 877
			-- Empty hostname, [ starts a path
			return startPos -- 879
		end -- 866
		for i = startPos, endPos do -- 881
			if charsAfterDot > 62 then -- 882
				do -- 883
					local _tmp_0 = sub(str, startPos, i) -- 883
					self.hostname = _tmp_0 -- 883
					self.host = _tmp_0 -- 883
				end -- 883
				return i -- 884
			end -- 882
			local ch = byte(str, i) -- 886
			if ch == 0x3A then -- 887
				portLength = self:_parsePort(str, i + 1, endPos) + 1 -- 888
				hostNameEnd = i - 1 -- 889
				break -- 890
			else -- 891
				if ch < 0x61 then -- 891
					if ch == 0x2E then -- 892
						charsAfterDot = -1 -- 893
					else -- 894
						if 0x41 <= ch and ch <= 0x5A then -- 894
							doLowerCase = false -- 895
						else -- 897
							if not (ch == 0x2D or ch == 0x5F or ch == 0x2B or (0x30 <= ch and ch <= 0x39)) then -- 897
								if not hostEndingCharacters[ch] and not self._noPrependSlashHostEnders[ch] then -- 898
									self._prependSlash = true -- 899
								end -- 898
								hostNameEnd = i - 1 -- 900
								break -- 901
							end -- 897
						end -- 894
					end -- 892
				else -- 902
					if ch >= 0x7B then -- 902
						if ch <= 0x7E then -- 903
							if not self._noPrependSlashHostEnders[ch] then -- 904
								self._prependSlash = true -- 905
							end -- 904
							hostNameEnd = i - 1 -- 906
							break -- 907
						end -- 903
						idna = true -- 908
					end -- 902
				end -- 891
			end -- 887
			lastCh = ch -- 909
			charsAfterDot = charsAfterDot + 1 -- 910
		end -- 910
		if (hostNameEnd + 1) ~= startPos and (hostNameEnd - hostNameStart) <= 256 then -- 912
			local hostname = sub(str, hostNameStart, hostNameEnd) -- 913
			if doLowerCase then -- 914
				hostname = lower(hostname) -- 915
			end -- 914
			if idna then -- 916
				hostname = self:_hostIdna(hostname) -- 917
			end -- 916
			self.hostname = hostname -- 918
			self.host = self._port > 0 and (hostname .. ":" .. self._port) or hostname -- 919
		end -- 912
		return hostNameEnd + 1 + portLength -- 920
	end, -- 922
	_copyPropsTo = function(self, input, noProtocol) -- 922
		if not noProtocol then -- 923
			input._protocol = self._protocol -- 924
		end -- 923
		input._href = self._href -- 925
		input._port = self._port -- 926
		input._prependSlash = self._prependSlash -- 927
		input.auth = self.auth -- 928
		input.slashes = self.slashes -- 929
		input.host = self.host -- 930
		input.hostname = self.hostname -- 931
		input.hash = self.hash -- 932
		input.search = self.search -- 933
		input.pathname = self.pathname -- 934
	end, -- 936
	_clone = function(self) -- 936
		local ret = URL() -- 937
		ret._protocol = self._protocol -- 938
		ret._href = self._href -- 939
		ret._port = self._port -- 940
		ret._prependSlash = self._prependSlash -- 941
		ret.auth = self.auth -- 942
		ret.slashes = self.slashes -- 943
		ret.host = self.host -- 944
		ret.hostname = self.hostname -- 945
		ret.hash = self.hash -- 946
		ret.search = self.search -- 947
		ret.pathname = self.pathname -- 948
		return ret -- 949
	end, -- 951
	_getComponentEscaped = function(self, str, startPos, endPos, isAfterQuery) -- 951
		local cur = startPos -- 952
		local i = startPos -- 953
		local ret = { } -- 954
		autoEscapeMap = isAfterQuery and self._afterQueryAutoEscapeMap or self._autoEscapeMap -- 955
		while i <= endPos do -- 956
			local ch = byte(str, i) -- 957
			local escaped = autoEscapeMap[ch] -- 958
			if escaped then -- 959
				if cur < i then -- 960
					ret[#ret + 1] = sub(str, cur, i - 1) -- 961
				end -- 960
				ret[#ret + 1] = escaped -- 962
				cur = i + 1 -- 963
			end -- 959
			i = i + 1 -- 964
		end -- 964
		if cur < i + 1 then -- 965
			ret[#ret + 1] = sub(str, cur, i) -- 966
		end -- 965
		return concat(ret) -- 967
	end, -- 969
	_parsePath = function(self, str, startPos, endPos, disableAutoEscapeChars) -- 969
		local pathStart = startPos -- 970
		local pathEnd = endPos -- 971
		local escape = false -- 972
		local autoEscapeCharacters = self._autoEscapeCharacters -- 973
		local prePath = self._port == -2 and "/:" or "" -- 974
		for i = startPos, endPos do -- 976
			local ch = byte(str, i) -- 977
			if ch == 0x23 then -- 978
				self:_parseHash(str, i, endPos, disableAutoEscapeChars) -- 979
				pathEnd = i - 1 -- 980
				break -- 981
			else -- 982
				if ch == 0x3F then -- 982
					self:_parseQuery(str, i, endPos, disableAutoEscapeChars) -- 983
					pathEnd = i - 1 -- 984
					break -- 985
				else -- 986
					if not disableAutoEscapeChars and not escape and autoEscapeCharacters[ch] then -- 986
						escape = true -- 987
					end -- 986
				end -- 982
			end -- 978
		end -- 988
		if pathStart > pathEnd then -- 989
			self.pathname = prePath == "" and "/" or prePath -- 990
			return -- 991
		end -- 989
		local path = nil -- 993
		if escape then -- 994
			path = self:_getComponentEscaped(str, pathStart, pathEnd, false) -- 995
		else -- 997
			path = sub(str, pathStart, pathEnd) -- 997
		end -- 994
		self.pathname = prePath == "" and (self._prependSlash and "/" .. path or path) or prePath .. path -- 998
	end, -- 1000
	_parseQuery = function(self, str, startPos, endPos, disableAutoEscapeChars) -- 1000
		local queryStart = startPos -- 1001
		local queryEnd = endPos -- 1002
		local escape = false -- 1003
		local autoEscapeCharacters = self._autoEscapeCharacters -- 1004
		for i = startPos, endPos do -- 1006
			local ch = byte(str, i) -- 1007
			if ch == 0x23 then -- 1008
				self:_parseHash(str, i, endPos, disableAutoEscapeChars) -- 1009
				queryEnd = i - 1 -- 1010
				break -- 1011
			else -- 1012
				if not disableAutoEscapeChars and not escape and autoEscapeCharacters[ch] then -- 1012
					escape = true -- 1013
				end -- 1012
			end -- 1008
		end -- 1014
		if queryStart > queryEnd then -- 1015
			self.search = "" -- 1016
			return -- 1017
		end -- 1015
		local query = nil -- 1019
		if escape then -- 1020
			query = self:_getComponentEscaped(str, queryStart, queryEnd, true) -- 1021
		else -- 1023
			query = sub(str, queryStart, queryEnd) -- 1023
		end -- 1020
		self.search = query -- 1024
	end, -- 1026
	_parseHash = function(self, str, startPos, endPos, disableAutoEscapeChars) -- 1026
		if startPos > endPos then -- 1027
			self.hash = "" -- 1028
			return -- 1029
		end -- 1027
		self.hash = disableAutoEscapeChars and sub(str, startPos, endPos) or self:_getComponentEscaped(str, startPos, endPos, false) -- 1031
	end, -- 1034
	__index = function(self, key) -- 1034
		if "port" == key then -- 1036
			return self:getPort() -- 1036
		elseif "query" == key then -- 1037
			return self:getQuery() -- 1037
		elseif "path" == key then -- 1038
			return self:getPath() -- 1038
		elseif "protocol" == key then -- 1039
			return self:getProtocol() -- 1039
		elseif "href" == key then -- 1040
			return self:getHref() -- 1040
		end -- 1040
	end, -- 1042
	__newindex = function(self, key, value) -- 1042
		if "port" == key then -- 1044
			return self:setPort(value) -- 1044
		elseif "query" == key then -- 1045
			return self:setQuery(value) -- 1045
		elseif "path" == key then -- 1046
			return self:setPath(value) -- 1046
		elseif "protocol" == key then -- 1047
			return self:setProtocol(value) -- 1047
		elseif "href" == key then -- 1048
			return self:setHref(value) -- 1048
		end -- 1048
	end, -- 1050
	getPort = function(self) -- 1050
		if self._port >= 0 then -- 1050
			return tostring(self._port) -- 1050
		end -- 1050
	end, -- 1051
	setPort = function(self, value) -- 1051
		if value == nil then -- 1052
			self._port = -1 -- 1052
		else -- 1053
			self._port = tonumber(value) -- 1053
		end -- 1052
	end, -- 1055
	getQuery = function(self) -- 1055
		do -- 1056
			local query = self._query -- 1056
			if query then -- 1056
				return query -- 1057
			end -- 1056
		end -- 1056
		local search = self.search -- 1059
		if search then -- 1060
			if byte(search, 1) == 0x3f then -- 1061
				search = sub(search, 2) -- 1062
			end -- 1061
			if search ~= "" then -- 1063
				self._query = search -- 1064
				return search -- 1065
			end -- 1063
		end -- 1060
		return search -- 1066
	end, -- 1067
	setQuery = function(self, value) -- 1067
		self._query = value -- 1067
	end, -- 1069
	getPath = function(self) -- 1069
		local p = self.pathname or "" -- 1070
		local s = self.search or "" -- 1071
		return p .. s -- 1072
	end, -- 1073
	setPath = function() end, -- 1075
	getProtocol = function(self) -- 1075
		local proto = self._protocol or "" -- 1076
		return proto ~= "" and proto .. ":" or "" -- 1077
	end, -- 1078
	setProtocol = function(self, value) -- 1078
		if type(value) == "string" then -- 1079
			if byte(value, -1) == 0x3A then -- 1080
				value = sub(value, 1, -2) -- 1081
			else -- 1083
				value = value -- 1083
			end -- 1080
		else -- 1084
			if not value then -- 1084
				self._protocol = nil -- 1085
			end -- 1084
		end -- 1079
	end, -- 1087
	getHref = function(self) -- 1087
		local href = self._href -- 1088
		if not href then -- 1089
			href = self:format() -- 1090
			self._href = href -- 1090
		end -- 1089
		return href -- 1091
	end, -- 1092
	setHref = function(self, value) -- 1092
		self._href = value -- 1092
	end -- 406
} -- 406
if _base_0.__index == nil then -- 406
	_base_0.__index = _base_0 -- 406
end -- 1113
_class_0 = setmetatable({ -- 406
	__init = function(self) -- 438
		-- For more efficient internal representation and laziness.
		-- The non-underscore versions of these properties are accessor functions
		-- defined on the prototype.
		self._protocol = nil -- 442
		self._href = "" -- 443
		self._port = -1 -- 444
		self._query = nil -- 445
		-- Probably just should remove these properties
		self.auth = nil -- 448
		self.slashes = false -- 449
		self.host = nil -- 450
		self.hostname = nil -- 451
		self.hash = nil -- 452
		self.search = nil -- 453
		self.pathname = nil -- 454
		self._prependSlash = false -- 456
	end, -- 406
	__base = _base_0, -- 406
	__name = "URL" -- 406
}, { -- 406
	__index = _base_0, -- 406
	__call = function(cls, ...) -- 406
		local _self_0 = setmetatable({ }, _base_0) -- 406
		cls.__init(_self_0, ...) -- 406
		return _self_0 -- 406
	end -- 406
}) -- 406
_base_0.__class = _class_0 -- 406
local self = _class_0; -- 406
self.parse = function(str, parseStringQuery, hostDenotesSlash, disableAutoEscapeChars) -- 1094
	if type(str) == "table" and str.__name == URL.__name then -- 1095
		return str -- 1096
	end -- 1095
	local ret = URL() -- 1097
	ret:parse(str, not not parseStringQuery, not not hostDenotesSlash, not not disableAutoEscapeChars) -- 1098
	return ret -- 1099
end -- 1094
self.format = function(obj) -- 1101
	if type(obj) == "string" then -- 1102
		obj = URL.parse(obj) -- 1103
	end -- 1102
	if type(obj) ~= "table" or obj.__name ~= URL.__name then -- 1104
		return URL.__base.format(obj) -- 1105
	end -- 1104
	return obj:format() -- 1106
end -- 1101
self.resolve = function(source, relative) -- 1108
	return URL.parse(source):resolve(relative) -- 1108
end -- 1108
self.resolveObject = function(source, relative) -- 1110
	if not source then -- 1111
		return relative -- 1112
	end -- 1111
	return URL.parse(source, false, true):resolveObject(relative) -- 1113
end -- 1110
URL = _class_0 -- 406
_module_0["URL"] = URL -- 406
return _module_0 -- 1113
