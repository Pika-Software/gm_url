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
local istable, isnumber, isstring, tostring, tonumber, rawget, rawset, getmetatable = _G.istable, _G.isnumber, _G.isstring, _G.tostring, _G.tonumber, _G.rawget, _G.rawset, _G.getmetatable -- 24
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
		if isnumber(item) then -- 44
			ret[item] = true -- 45
		else -- 47
			for j = item[1], item[2] do -- 47
				ret[j] = true -- 48
			end -- 48
		end -- 44
	end -- 48
	return ret -- 50
end -- 41
local containsCharacter -- 52
containsCharacter = function(str, char1, fromIndex, stopCharacterTable) -- 52
	for i = fromIndex, #str do -- 53
		local ch = byte(str, i) -- 54
		if ch == char1 then -- 55
			return true -- 56
		end -- 55
		if stopCharacterTable[ch] then -- 58
			return false -- 59
		end -- 58
	end -- 59
	return false -- 61
end -- 52
local containsCharacter2 -- 63
containsCharacter2 = function(str, char1, char2) -- 63
	for i = 1, #str do -- 64
		local ch = byte(str, i) -- 65
		if ch == char1 or ch == char2 then -- 66
			return true -- 67
		end -- 66
	end -- 67
	return false -- 69
end -- 63
local isSlash -- 71
isSlash = function(str, pos) -- 71
	local ch = byte(str, pos) -- 72
	return ch == 0x2F or ch == 0x5C -- 73
end -- 71
-- Lookup table for decoding percent-encoded characters and encoding special characters
-- Using HEX_TABLE will result in a double speedup compared to using functions
local HEX_TABLE = { } -- 77
for i = 0x00, 0xFF do -- 78
	local hex = bit.tohex(i, 2) -- 79
	HEX_TABLE[hex] = char(i) -- 80
	HEX_TABLE[hex:upper()] = char(i) -- 81
	HEX_TABLE[char(i)] = "%" .. hex:upper() -- 82
end -- 82
-- Special characters
HEX_TABLE["\r\n"] = "\n" -- 85
HEX_TABLE[" "] = "+" -- 86
HEX_TABLE["-"] = "-" -- 87
HEX_TABLE["."] = "." -- 88
HEX_TABLE["_"] = "_" -- 89
HEX_TABLE["~"] = "~" -- 90
HEX_TABLE["!"] = "!" -- 91
HEX_TABLE["*"] = "*" -- 92
HEX_TABLE["'"] = "'" -- 93
HEX_TABLE["("] = "(" -- 94
HEX_TABLE[")"] = ")" -- 95
local decodeURI -- 97
decodeURI = function(s) -- 97
	s = gsub(gsub(s, "%%(%x%x)", HEX_TABLE), "+", " ") -- 98
	return s -- 99
end -- 97
_module_0["decodeURI"] = decodeURI -- 99
local encodeURI -- 101
encodeURI = function(s) -- 101
	s = gsub(s, "%W", HEX_TABLE) -- 102
	return s -- 103
end -- 101
_module_0["encodeURI"] = encodeURI -- 103
local autoEscape = { -- 105
	"<", -- 105
	">", -- 105
	"\"", -- 105
	"`", -- 105
	" ", -- 105
	"\r", -- 105
	"\n", -- 105
	"\t", -- 106
	"{", -- 106
	"}", -- 106
	"|", -- 106
	"\\", -- 106
	"^", -- 106
	"`", -- 106
	"'" -- 106
} -- 105
local autoEscapeMap = { } -- 108
for _index_0 = 1, #autoEscape do -- 110
	local c = autoEscape[_index_0] -- 110
	local esc = encodeURI(c) -- 111
	if esc == c then -- 112
		esc = "%" .. bit.tohex(byte(c), 2):upper() -- 113
	end -- 112
	autoEscapeMap[byte(c)] = esc -- 115
end -- 115
local afterQueryAutoEscapeMap = { } -- 117
for k, v in pairs(autoEscapeMap) do -- 119
	afterQueryAutoEscapeMap[k] = v -- 120
end -- 120
autoEscapeMap[0x5C] = "/" -- 122
-- https://github.com/petkaantonov/querystringparser
local QueryStringParser -- 125
do -- 125
	local _class_0 -- 125
	local _base_0 = { -- 125
		maxLength = 32768, -- 127
		maxDepth = 4, -- 128
		maxKeys = 256, -- 130
		parse = function(self, str) -- 130
			self.containsSparse = false -- 131
			self.cacheKey = "" -- 132
			self.cacheVal = nil -- 133
			if isstring(str) then -- 135
				if #str > self.maxLength then -- 136
					error("str is too large (QueryStringParser.maxLength=" .. self.maxLength .. ")") -- 137
				end -- 136
				return self:parseString(str, false) -- 139
			elseif istable(str) then -- 140
				error("not implemented") -- 141
			end -- 135
			return { } -- 143
		end, -- 145
		stringify = function(self, obj) -- 145
			if not istable(obj) then -- 146
				error("obj must be a table") -- 147
			end -- 146
			local keyPrefix = "" -- 149
			local cur = obj -- 150
			local key = nil -- 151
			local value = nil -- 152
			local isArray = false -- 153
			local stack = { } -- 154
			local stackLen = 0 -- 155
			local ret, length = { }, 0 -- 156
			-- spooky spooky while true loop :)
			while true do -- 159
				if isArray then -- 160
					key = key + 1 -- 161
					value = cur[key] -- 162
					if not value then -- 163
						key = nil -- 164
					end -- 163
				else -- 166
					key, value = next(cur, key) -- 166
				end -- 160
				if key ~= nil then -- 168
					local serializedKey = encodeURI(isArray and tostring(key - 1) or tostring(key)) -- 169
					if istable(value) then -- 170
						stack[stackLen + 1] = keyPrefix -- 171
						stack[stackLen + 2] = cur -- 172
						stack[stackLen + 3] = key -- 173
						stack[stackLen + 4] = isArray -- 174
						stackLen = stackLen + 4 -- 175
						keyPrefix = keyPrefix == "" and serializedKey or keyPrefix .. "[" .. serializedKey .. "]" -- 177
						isArray = value[1] and true or false -- 178
						key = isArray and 0 or nil -- 179
						cur = value -- 180
					else -- 182
						serializedKey = keyPrefix == "" and serializedKey or keyPrefix .. "[" .. serializedKey .. "]" -- 182
						length = length + 1 -- 183
						ret[length] = serializedKey .. "=" .. encodeURI(value) -- 184
					end -- 170
				elseif stackLen ~= 0 then -- 185
					keyPrefix = stack[stackLen - 3] -- 186
					cur = stack[stackLen - 2] -- 187
					key = stack[stackLen - 1] -- 188
					isArray = stack[stackLen] -- 189
					stackLen = stackLen - 4 -- 190
				else -- 192
					break -- 192
				end -- 168
			end -- 192
			return concat(ret, "&", 1, length) -- 194
		end, -- 197
		decode = function(self, str, shouldDecode, containsPlus) -- 197
			if not shouldDecode then -- 198
				return str -- 199
			end -- 198
			if containsPlus then -- 201
				str = gsub(str, "%+", " ") -- 202
			end -- 201
			return decodeURI(str) -- 204
		end, -- 206
		maybeArrayIndex = function(self, str, arrayLength) -- 206
			local length = #str -- 207
			-- Empty string I.E. direct brackets [] means index will be .length
			if length == 0 then -- 209
				return arrayLength -- 210
			end -- 209
			local ch = byte(str, 1) -- 212
			-- "0" is only valid index if it's the only character in the string
			-- "00", "001", are not valid array indices
			if ch == INT_START then -- 216
				return length > 1 and -1 or 1 -- 217
			end -- 216
			if INT_START <= ch and ch <= INT_END then -- 219
				-- Single digit number 1-9
				if length == 1 then -- 221
					return ch - INT_START + 1 -- 222
				elseif match(str, "^%d+$") then -- 223
					return tonumber(str) + 1 -- 224
				end -- 221
			end -- 219
			return -1 -- 226
		end, -- 228
		getSlot = function(self, dictonary, prevKey, curKey) -- 228
			if not dictonary[prevKey] then -- 229
				dictonary[prevKey] = { } -- 230
			end -- 229
			return dictonary[prevKey] -- 232
		end, -- 234
		placeNestedValue = function(self, dictonary, key, value, i, prevKey, curKey) -- 234
			local slot = self:getSlot(dictonary, prevKey, curKey) -- 235
			local index = self:maybeArrayIndex(curKey, #slot) -- 236
			local length = #key -- 238
			local depth = 2 -- 239
			local maxDepth = self.maxDepth -- 240
			local start = -1 -- 241
			while (i <= length) do -- 243
				local ch = byte(key, i) -- 244
				if ch == LEFT then -- 245
					start = i + 1 -- 246
				elseif ch == RIGHT and start ~= -1 then -- 247
					prevKey = curKey -- 248
					curKey = start == i and "" or sub(key, start, i - 1) -- 249
					start = -1 -- 250
					depth = depth + 1 -- 251
					if depth > maxDepth then -- 253
						error("too deep (QueryStringParser.maxDepth=" .. maxDepth .. ")") -- 254
					end -- 253
					slot = self:getSlot(slot, prevKey, curKey) -- 256
					index = self:maybeArrayIndex(curKey, #slot) -- 257
				end -- 245
				i = i + 1 -- 259
			end -- 259
			if index ~= -1 then -- 261
				if value ~= "" then -- 262
					local nextIndex = #slot + 1 -- 263
					if index == nextIndex then -- 264
						slot[nextIndex] = value -- 265
					else -- 267
						self.containsSparse = true -- 267
						slot[index] = value -- 268
					end -- 264
				end -- 262
			else -- 270
				return self:insert(slot, curKey, value) -- 270
			end -- 261
		end, -- 272
		insert = function(self, dictonary, key, value) -- 272
			do -- 273
				local prev = dictonary[key] -- 273
				if prev then -- 273
					if istable(prev) then -- 274
						prev[#prev + 1] = value -- 275
						return prev -- 276
					end -- 274
					local new = { -- 278
						prev, -- 278
						value -- 278
					} -- 278
					dictonary[key] = new -- 279
					return new -- 280
				end -- 273
			end -- 273
			dictonary[key] = value -- 282
		end, -- 284
		push = function(self, dictonary, key, value) -- 284
			do -- 285
				local prev = dictonary[key] -- 285
				if prev then -- 285
					prev[#prev + 1] = value -- 286
					return prev -- 287
				end -- 285
			end -- 285
			local new = { -- 289
				value -- 289
			} -- 289
			dictonary[key] = new -- 290
			return new -- 291
		end, -- 293
		maybePlaceNestedValue = function(self, dictonary, key, value) -- 293
			local len = #key -- 294
			if byte(key, len) ~= RIGHT then -- 295
				self:placeValue(dictonary, key, value, CERTAINLY_NOT_NESTED) -- 296
				return -- 297
			end -- 295
			local start = -1 -- 299
			local i = 1 -- 300
			local curKey = nil -- 301
			local prevKey = nil -- 302
			while i <= len do -- 304
				local ch = byte(key, i) -- 305
				if ch == LEFT then -- 306
					start = i + 1 -- 307
					prevKey = sub(key, 1, i - 1) -- 308
				elseif ch == RIGHT then -- 309
					if start == -1 then -- 310
						self:placeValue(dictonary, key, value, CERTAINLY_NOT_NESTED) -- 311
						return -- 312
					end -- 310
					curKey = start == i and "" or sub(key, start, i - 1) -- 314
					i = i + 1 -- 315
					break -- 316
				end -- 306
				i = i + 1 -- 318
			end -- 318
			if curKey == nil then -- 320
				self:placeValue(dictonary, key, value, CERTAINLY_NOT_NESTED) -- 321
				return -- 322
			end -- 320
			if curKey == "" and value ~= "" and i == len then -- 324
				if key == self.cacheKey then -- 325
					local _obj_0 = self.cacheValue -- 326
					_obj_0[#_obj_0 + 1] = value -- 326
				else -- 328
					self.cacheKey = key -- 328
					self.cacheValue = self:push(dictonary, prevKey, value) -- 329
				end -- 325
			else -- 331
				return self:placeNestedValue(dictonary, key, value, i, prevKey, curKey) -- 331
			end -- 324
		end, -- 333
		placeValue = function(self, dictonary, key, value, possiblyNested) -- 333
			if possiblyNested == MIGHT_BE_NESTED then -- 334
				self:maybePlaceNestedValue(dictonary, key, value) -- 335
				return -- 336
			end -- 334
			if key == self.cacheKey then -- 338
				do -- 339
					local _obj_0 = self.cacheValue -- 339
					_obj_0[#_obj_0 + 1] = value -- 339
				end -- 339
				return -- 340
			end -- 338
			local cache = self:insert(dictonary, key, value) -- 342
			if cache then -- 342
				self.cacheKey = key -- 343
				self.cacheValue = cache -- 344
			end -- 342
		end, -- 346
		compact = function(self, obj) -- 346
			if not istable(obj) then -- 347
				return obj -- 348
			end -- 347
			if obj[1] then -- 350
				local ret, length = { }, 0 -- 351
				for _, v in pairs(obj) do -- 352
					length = length + 1 -- 353
					ret[length] = v -- 354
				end -- 354
				return ret -- 356
			end -- 350
			for k, v in pairs(obj) do -- 358
				obj[k] = self:compact(v) -- 359
			end -- 359
			return obj -- 361
		end, -- 364
		parseString = function(self, str, noDecode) -- 364
			local keys = 0 -- 365
			local decodeKey = false -- 366
			local decodeValue = false -- 367
			local possiblyNested = CERTAINLY_NOT_NESTED -- 368
			local len = #str -- 369
			local i = 1 -- 370
			local dictonary = { } -- 371
			local keyStart = 1 -- 372
			local keyEnd = 1 -- 373
			local valueStart = 1 -- 374
			local valueEnd = 1 -- 375
			local left = 0 -- 376
			local containsPlus = false -- 377
			while i <= len do -- 379
				local ch = byte(str, i) -- 380
				if ch == LEFT then -- 382
					left = left + 1 -- 383
				elseif left > 0 and ch == RIGHT then -- 384
					possiblyNested = MIGHT_BE_NESTED -- 385
					left = left - 1 -- 386
				elseif left == 0 and ch == EQUALS then -- 387
					keyEnd = i - 1 -- 388
					valueEnd = i + 1 -- 389
					valueStart = valueEnd -- 389
					local key = self:decode(sub(str, keyStart, keyEnd), decodeKey, containsPlus) -- 390
					decodeKey = false -- 391
					for j = valueStart, len do -- 393
						ch = byte(str, j) -- 394
						if (ch == PLUS or ch == PCT) and not noDecode then -- 396
							if ch == PLUS then -- 397
								containsPlus = true -- 397
							end -- 397
							decodeValue = true -- 398
						end -- 396
						if ch == AMP or j == len then -- 400
							valueEnd = j -- 401
							i = j -- 402
							if ch == AMP then -- 404
								valueEnd = valueEnd - 1 -- 405
							end -- 404
							local value = sub(str, valueStart, valueEnd) -- 407
							value = self:decode(value, decodeValue, containsPlus) -- 408
							-- Place value
							self:placeValue(dictonary, key, value, possiblyNested) -- 411
							containsPlus = false -- 413
							decodeValue = false -- 413
							possiblyNested = CERTAINLY_NOT_NESTED -- 414
							keyStart = j + 1 -- 416
							keys = keys + 1 -- 417
							if (keys > self.maxKeys) then -- 419
								error("too many keys (QueryStringParser.maxKeys=" .. self.maxKeys .. ")") -- 420
							end -- 419
							break -- 422
						end -- 400
					end -- 422
				elseif (ch == PLUS or ch == PCT) and not noDecode then -- 424
					if ch == PLUS then -- 425
						containsPlus = true -- 425
					end -- 425
					decodeKey = true -- 426
				end -- 382
				i = i + 1 -- 428
			end -- 428
			if keyStart < len then -- 430
				local key = self:decode(sub(str, keyStart, len), decodeKey, containsPlus) -- 431
				self:placeValue(dictonary, key, "", possiblyNested) -- 432
			end -- 430
			if self.containsSparse then -- 434
				-- original developer once said
				-- This behavior is pretty stupid but what you gonna do
				self:compact(dictonary) -- 437
			end -- 434
			return dictonary -- 439
		end -- 125
	} -- 125
	if _base_0.__index == nil then -- 125
		_base_0.__index = _base_0 -- 125
	end -- 439
	_class_0 = setmetatable({ -- 125
		__init = function() end, -- 125
		__base = _base_0, -- 125
		__name = "QueryStringParser" -- 125
	}, { -- 125
		__index = _base_0, -- 125
		__call = function(cls, ...) -- 125
			local _self_0 = setmetatable({ }, _base_0) -- 125
			cls.__init(_self_0, ...) -- 125
			return _self_0 -- 125
		end -- 125
	}) -- 125
	_base_0.__class = _class_0 -- 125
	QueryStringParser = _class_0 -- 125
end -- 439
_module_0["QueryStringParser"] = QueryStringParser -- 125
-- https://github.com/petkaantonov/urlparser
local URL -- 442
do -- 442
	local _class_0 -- 442
	local _base_0 = { -- 442
		queryString = QueryStringParser(), -- 445
		_protocolCharacters = makeAsciiTable({ -- 446
			{ -- 446
				0x61, -- 446
				0x7A -- 446
			}, -- 446
			{ -- 447
				0x41, -- 447
				0x5A -- 447
			}, -- 447
			0x2E, -- 448
			0x2B, -- 449
			0x2D -- 450
		}), -- 453
		_hostEndingCharacters = makeAsciiTable({ -- 454
			0x23, -- 454
			0x3F, -- 455
			0x2F, -- 456
			0x5C -- 457
		}), -- 461
		_noPrependSlashHostEnders = makeAsciiTable((function() -- 461
			local _accum_0 = { } -- 461
			local _len_0 = 1 -- 461
			local _list_0 = { -- 462
				"<", -- 462
				">", -- 462
				"'", -- 462
				"`", -- 462
				" ", -- 462
				"\r", -- 462
				"\n", -- 463
				"\t", -- 463
				"{", -- 463
				"}", -- 463
				"|", -- 463
				"^", -- 464
				"`", -- 464
				"\"", -- 464
				"%", -- 464
				";" -- 464
			} -- 461
			for _index_0 = 1, #_list_0 do -- 465
				local s = _list_0[_index_0] -- 461
				_accum_0[_len_0] = byte(s) -- 461
				_len_0 = _len_0 + 1 -- 461
			end -- 461
			return _accum_0 -- 465
		end)()), -- 467
		_autoEscapeCharacters = makeAsciiTable((function() -- 467
			local _accum_0 = { } -- 467
			local _len_0 = 1 -- 467
			for _index_0 = 1, #autoEscape do -- 467
				local s = autoEscape[_index_0] -- 467
				_accum_0[_len_0] = byte(s) -- 467
				_len_0 = _len_0 + 1 -- 467
			end -- 467
			return _accum_0 -- 467
		end)()), -- 469
		_autoEscapeMap = autoEscapeMap, -- 470
		_afterQueryAutoEscapeMap = afterQueryAutoEscapeMap, -- 472
		_specialSchemes = { -- 473
			["ftp"] = 21, -- 473
			["file"] = true, -- 474
			["http"] = 80, -- 475
			["https"] = 443, -- 476
			["ws"] = 80, -- 477
			["wss"] = 443 -- 478
		}, -- 500
		parse = function(self, str, parseStringQuery, disableAutoEscapeChars) -- 500
			if not isstring(str) then -- 501
				error("Parameter 'url' must be a string, not " .. type(str)) -- 502
			end -- 501
			local startPos = 1 -- 504
			local endPos = #str -- 505
			-- Trim leading and trailing whitespaces
			while byte(str, startPos) <= 0x20 do -- 508
				startPos = startPos + 1 -- 508
			end -- 508
			while byte(str, endPos) <= 0x20 do -- 509
				endPos = endPos - 1 -- 509
			end -- 509
			startPos = self:_parseProtocol(str, startPos, endPos) -- 511
			-- If after protocol there is //, then we must parse the host
			local hasFollowingSolidus = byte(str, startPos) == 0x2F and byte(str, startPos + 1) == 0x2F and byte(str, startPos + 2) ~= 0x2F -- 514
			local protocol = self._protocol -- 516
			local isSpecial = protocol and self._specialSchemes[protocol] -- 517
			if (isSpecial and protocol ~= "file") or hasFollowingSolidus then -- 518
				startPos = self:_parseHost(str, startPos, endPos) -- 519
				if not self.hostname and self.slashes and isSpecial then -- 521
					do -- 522
						local _tmp_0 = "" -- 522
						self.hostname = _tmp_0 -- 522
						self.host = _tmp_0 -- 522
					end -- 522
				end -- 521
			end -- 518
			if startPos <= endPos then -- 524
				local ch = byte(str, startPos) -- 525
				if ch == 0x3F then -- 526
					self:_parseQuery(str, startPos, endPos, disableAutoEscapeChars) -- 527
				elseif ch == 0x23 then -- 528
					self:_parseHash(str, startPos, endPos, disableAutoEscapeChars) -- 529
				else -- 531
					self:_parsePath(str, startPos, endPos, disableAutoEscapeChars) -- 531
				end -- 526
			end -- 524
			if not self.pathname and self.hostname and isSpecial then -- 533
				self.pathname = "/" -- 534
			end -- 533
			if parseStringQuery then -- 536
				local search = self.search -- 537
				if not search then -- 538
					search = "" -- 539
					self.search = search -- 539
				end -- 538
				if byte(search, 0) == 0x3F then -- 541
					search = sub(search, 2) -- 542
				end -- 541
				-- TODO: This calls a setter function, there is no .query data property
				self.query = self.queryString:parse(search) -- 545
			end -- 536
		end, -- 547
		resolve = function(self, relative) -- 547
			return self:resolveObject(URL.parse(relative, false, true)):format() -- 548
		end, -- 550
		_escapePathname = function(self, pathname) -- 550
			return gsub(pathname, "[%?#]", HEX_TABLE) -- 551
		end, -- 553
		_escapeSearch = function(self, search) -- 553
			return gsub(search, "#", HEX_TABLE) -- 554
		end, -- 556
		format = function(self) -- 556
			local query = self.query or "" -- 557
			if istable(query) then -- 558
				query = self.queryString:stringify(query) -- 559
			end -- 558
			local search = self.search or "" -- 561
			if search == "" then -- 562
				search = query ~= "" and ("?" .. query) or "" -- 563
			end -- 562
			local protocol = self._protocol or "" -- 565
			if protocol ~= "" and byte(protocol, -1) ~= 0x3A then -- 566
				protocol = protocol .. ":" -- 567
			end -- 566
			local hostname = self.hostname or "" -- 569
			local port = self._port or "" -- 570
			local host = false -- 571
			local auth = self.auth or "" -- 573
			if auth ~= "" then -- 574
				auth = gsub(encodeURI(auth), "%%3A", ":") .. "@" -- 575
			end -- 574
			if self.host then -- 577
				host = auth .. self.host -- 578
			elseif hostname ~= "" then -- 579
				local ip6 = find(hostname, ":", 1, true) -- 580
				if ip6 then -- 581
					hostname = "[" .. hostname .. "]" -- 582
				end -- 581
				host = auth .. hostname .. (port ~= "" and ":" .. port or "") -- 584
			end -- 577
			local slashes = self.slashes or ((protocol == "" or self._specialSchemes[protocol]) and host ~= false) -- 586
			local scheme -- 588
			scheme = protocol -- 588
			if slashes then -- 589
				scheme = scheme .. "//" -- 590
			end -- 589
			local pathname = self.pathname or "" -- 592
			if pathname ~= "" then -- 593
				if slashes and byte(pathname, 1) ~= 0x2F then -- 594
					pathname = "/" .. pathname -- 595
				end -- 594
				pathname = self:_escapePathname(pathname) -- 597
			end -- 593
			if search ~= "" then -- 599
				if byte(search, 1) ~= 0x3F then -- 600
					search = "?" .. search -- 601
				end -- 600
				search = self:_escapeSearch(search) -- 603
			end -- 599
			local hash = self.hash or "" -- 605
			if hash ~= "" and byte(hash, 1) ~= 0x23 then -- 606
				hash = "#" .. hash -- 607
			end -- 606
			host = host or "" -- 609
			return scheme .. host .. pathname .. search .. hash -- 611
		end, -- 613
		resolveObject = function(self, relative) -- 613
			if isstring(relative) then -- 614
				relative = URL.parse(relative, false, true) -- 615
			end -- 614
			-- if the relative url is empty, then there"s nothing left to do here.
			if relative.href == "" then -- 618
				return URL() -- 619
			end -- 618
			local result = self:_clone() -- 621
			-- hash is always overridden, no matter what.
			-- even href="" will remove it.
			result.hash = relative.hash -- 625
			-- hrefs like //foo/bar always cut to the protocol.
			if relative.slashes and not relative._protocol then -- 628
				relative:_copyPropsTo(result, true) -- 629
				if self._specialSchemes[result._protocol] and result.hostname and not result.pathname then -- 631
					result.pathname = "/" -- 632
				end -- 631
				result._href = "" -- 634
				return result -- 635
			end -- 628
			if relative._protocol and relative._protocol ~= result._protocol then -- 637
				-- if it"s a known url protocol, then changing
				-- the protocol does weird things
				-- first, if it"s not file:, then we MUST have a host,
				-- and if there was a path
				-- to begin with, then we MUST have a path.
				-- if it is file:, then the host is dropped,
				-- because that"s known to be hostless.
				-- anything else is assumed to be absolute.
				if self._specialSchemes[relative._protocol] then -- 646
					relative:_copyPropsTo(result, false) -- 647
					result._href = "" -- 648
					return result -- 649
				end -- 646
				result._protocol = relative._protocol -- 651
				if not relative.host and relative._protocol ~= "javascript" then -- 653
					local relPath = relative.pathname and Split(relative.pathname, "/") or { } -- 654
					while #relPath ~= 0 do -- 656
						local host = remove(relPath, 1) -- 657
						if host and host ~= "" then -- 658
							relative.host = host -- 659
							break -- 660
						end -- 658
					end -- 660
					if not relative.host then -- 662
						relative.host = "" -- 663
					end -- 662
					if not relative.hostname then -- 665
						relative.hostname = "" -- 666
					end -- 665
					if relPath[1] ~= "" then -- 668
						insert(relPath, 1, "") -- 669
					end -- 668
					if #relPath < 2 then -- 671
						insert(relPath, 1, "") -- 672
					end -- 671
					result.pathname = concat(relPath, "/") -- 674
				else -- 676
					result.pathname = relative.pathname -- 676
				end -- 653
				result.search = relative.search -- 678
				result.host = relative.host or "" -- 679
				result.auth = relative.auth -- 680
				result.hostname = relative.hostname or result.hostname -- 681
				result._port = relative._port -- 682
				result.slashes = relative.slashes -- 683
				result._href = "" -- 684
				return result -- 685
			end -- 637
			local isSourceAbs = result.pathname and byte(result.pathname, 1) == 0x2F -- 687
			local isRelAbs = not not relative.host or relative.pathname and byte(relative.pathname, 1) == 0x2F -- 688
			local mustEndAbs = isRelAbs or isSourceAbs or (result.host and relative.pathname) -- 689
			local removeAllDots = mustEndAbs -- 690
			local srcPath = result.pathname and Split(result.pathname, "/") or { } -- 692
			local relPath = relative.pathname and Split(relative.pathname, "/") or { } -- 693
			if isRelAbs then -- 725
				-- it's absolute.
				result.host = relative.host or result.host -- 727
				result.hostname = relative.hostname or result.hostname -- 728
				result.search = relative.search -- 729
				srcPath = relPath -- 730
			elseif #relPath ~= 0 then -- 732
				-- it's relative
				-- throw away the existing file, and take the new path instead.
				if not srcPath then -- 735
					srcPath = { } -- 736
				end -- 735
				srcPath[#srcPath] = nil -- 738
				local length = #srcPath -- 740
				for i = 1, #relPath do -- 741
					length = length + 1 -- 742
					srcPath[length] = relPath[i] -- 743
				end -- 743
				result.search = relative.search -- 745
			elseif relative.search then -- 746
				result.search = relative.search -- 760
				result._href = "" -- 761
				return result -- 762
			end -- 725
			-- TODO: Make this faster
			local srcLength = #srcPath -- 765
			if srcLength == 0 then -- 766
				-- no path at all.  easy.
				-- we"ve already handled the other stuff above.
				result.pathname = nil -- 769
				result._href = "" -- 770
				return result -- 771
			end -- 766
			-- if a url ENDs in . or .., then it must get a trailing slash.
			-- however, if it ends in anything else non-slashy,
			-- then it must NOT get a trailing slash.
			local last = srcPath[srcLength] -- 776
			local hasTrailingSlash = (result.host or relative.host) or (last == "." or last == "..") or last == "" -- 777
			-- strip single dots, resolve double dots to parent dir
			-- if the path tries to go above the root, `up` ends up > 0
			local up = 0 -- 781
			for i = srcLength, 1, -1 do -- 782
				last = srcPath[i] -- 783
				if last == "." then -- 784
					remove(srcPath, i) -- 785
				elseif last == ".." then -- 786
					remove(srcPath, i) -- 787
					up = up + 1 -- 788
				elseif up > 0 then -- 789
					remove(srcPath, i) -- 790
					up = up - 1 -- 791
				end -- 784
			end -- 791
			-- if the path is allowed to go above the root, restore leading ..s
			if not mustEndAbs and not removeAllDots then -- 794
				while up > 0 do -- 795
					insert(srcPath, 1, "..") -- 796
					up = up - 1 -- 797
				end -- 797
			end -- 794
			if mustEndAbs and srcPath[1] ~= "" and (not srcPath[1] or byte(srcPath[1], 1) ~= 0x2F) then -- 799
				insert(srcPath, 1, "") -- 800
			end -- 799
			-- isAbsolute = srcPath[1] == "" or (srcPath[1] and byte(srcPath[1], 1) == 0x2F --[['/']])
			local isAbsolute = true -- 807
			mustEndAbs = mustEndAbs or (result.host and #srcPath > 0) -- 820
			if not mustEndAbs and not isAbsolute then -- 822
				insert(srcPath, 1, "") -- 823
			end -- 822
			result.pathname = #srcPath ~= 0 and concat(srcPath, "/") or nil -- 825
			result.auth = relative.auth or result.auth -- 826
			result.slashes = result.slashes or relative.slashes -- 827
			result._href = "" -- 828
			return result -- 829
		end, -- 832
		_hostIdna = function(self, hostname) -- 832
			-- TODO: Implement punycode and convert Idna to punycode
			return encodeURI(hostname) -- 834
		end, -- 836
		_parseProtocol = function(self, str, startPos, endPos) -- 836
			local doLowerCase = false -- 837
			local protocolCharacters = self._protocolCharacters -- 838
			for i = startPos, endPos do -- 839
				local ch = byte(str, i) -- 840
				if ch == 0x3A then -- 841
					local protocol = sub(str, startPos, i - 1) -- 842
					if doLowerCase then -- 843
						protocol = lower(protocol) -- 844
					end -- 843
					self._protocol = protocol -- 845
					return i + 1 -- 846
				elseif protocolCharacters[ch] then -- 847
					if ch < 0x61 then -- 848
						doLowerCase = true -- 849
					end -- 848
				else -- 851
					break -- 851
				end -- 841
			end -- 851
			return startPos -- 853
		end, -- 855
		_parseAuth = function(self, str, startPos, endPos, decode) -- 855
			local auth = sub(str, startPos, endPos) -- 856
			if decode then -- 857
				auth = decodeURI(auth) -- 858
			end -- 857
			self.auth = auth -- 859
		end, -- 861
		_parsePort = function(self, str, startPos, endPos) -- 861
			-- Internal format is integer for more efficient parsing
			-- and for efficient trimming of leading zeros
			local port = 0 -- 864
			-- Distinguish between :0 and : (no port number at all)
			local hadChars = false -- 866
			local validPort = true -- 867
			local i = startPos -- 868
			while i <= endPos do -- 870
				local ch = byte(str, i) -- 871
				if 0x30 <= ch and ch <= 0x39 then -- 872
					port = (10 * port) + (ch - 0x30) -- 873
					hadChars = true -- 874
				else -- 876
					validPort = false -- 876
					if ch == 0x5C or ch == 0x2F then -- 877
						validPort = true -- 878
					end -- 877
					break -- 879
				end -- 872
				i = i + 1 -- 880
			end -- 880
			if (port == 0 or not hadChars) or not validPort then -- 882
				if not validPort then -- 883
					self._port = -2 -- 884
				end -- 883
				return 0 -- 885
			end -- 882
			local protocol = self._protocol -- 887
			if not (protocol and self._specialSchemes[protocol] == port) then -- 888
				self._port = port -- 889
			end -- 888
			return i - startPos -- 890
		end, -- 892
		_parseHost = function(self, str, startPos, endPos) -- 892
			local hostEndingCharacters = self._hostEndingCharacters -- 893
			local first = byte(str, startPos) -- 894
			local second = byte(str, startPos + 1) -- 895
			if (first == 0x2F or first == 0x5C) and (second == 0x2F or second == 0x5C) then -- 896
				self.slashes = true -- 897
				-- The string starts with //
				if startPos == 0 then -- 900
					-- The string is just "//"
					if endPos < 2 then -- 902
						return startPos -- 903
					end -- 902
				end -- 900
				startPos = startPos + 2 -- 905
			elseif not self._protocol or self._specialSchemes[self._protocol] then -- 910
				return startPos -- 911
			end -- 896
			local doLowerCase = true -- 913
			local idna = false -- 914
			local hostNameStart = startPos -- 915
			local hostNameEnd = endPos -- 916
			local lastCh = -1 -- 917
			local portLength = 0 -- 918
			local charsAfterDot = 0 -- 919
			local authNeedsDecoding = false -- 920
			local j = -1 -- 921
			-- Find the last occurrence of an @-sign until hostending character is met
			-- also mark if decoding is needed for the auth portion
			for i = startPos, endPos do -- 925
				local ch = byte(str, i) -- 926
				if ch == 0x40 then -- 927
					j = i -- 928
				elseif ch == 0x25 then -- 929
					authNeedsDecoding = true -- 930
				elseif hostEndingCharacters[ch] then -- 931
					break -- 932
				end -- 927
			end -- 932
			-- @-sign was found at index j, everything to the left from it is auth part
			if j > -1 then -- 935
				self:_parseAuth(str, startPos, j - 1, authNeedsDecoding) -- 936
				startPos = j + 1 -- 937
				hostNameStart = startPos -- 937
			end -- 935
			-- Host name is starting with a [
			if byte(str, startPos) == 0x5B then -- 940
				for i = startPos + 1, endPos do -- 941
					local ch = byte(str, i) -- 942
					-- Assume valid IP6 is between the brackets
					if ch == 0x5D then -- 944
						if byte(str, i + 1) == 0x3A then -- 945
							portLength = self:_parsePort(str, i + 2, endPos) -- 946
						end -- 945
						local hostname = lower(sub(str, startPos + 1, i - 1)) -- 948
						self.hostname = hostname -- 949
						self.host = self._port > 0 and ("[" .. hostname .. "]:" .. self._port) or ("[" .. hostname .. "]") -- 950
						self.pathname = "/" -- 951
						return i + portLength + 1 -- 953
					end -- 944
				end -- 953
				-- Empty hostname, [ starts a path
				return startPos -- 956
			end -- 940
			for i = startPos, endPos do -- 958
				if charsAfterDot > 62 then -- 959
					do -- 960
						local _tmp_0 = sub(str, startPos, i) -- 960
						self.hostname = _tmp_0 -- 960
						self.host = _tmp_0 -- 960
					end -- 960
					return i -- 961
				end -- 959
				local ch = byte(str, i) -- 963
				if ch == 0x3A then -- 964
					portLength = self:_parsePort(str, i + 1, endPos) + 1 -- 965
					hostNameEnd = i - 1 -- 966
					break -- 967
				elseif ch < 0x61 then -- 968
					if ch == 0x2E then -- 969
						charsAfterDot = -1 -- 970
					elseif 0x41 <= ch and ch <= 0x5A then -- 971
						doLowerCase = false -- 972
					elseif not (ch == 0x2D or ch == 0x5F or ch == 0x2B or (0x30 <= ch and ch <= 0x39)) then -- 974
						if not (hostEndingCharacters[ch] or self._noPrependSlashHostEnders[ch]) then -- 975
							self._prependSlash = true -- 976
						end -- 975
						hostNameEnd = i - 1 -- 978
						break -- 979
					end -- 969
				elseif ch >= 0x7B then -- 980
					if ch <= 0x7E then -- 981
						if not self._noPrependSlashHostEnders[ch] then -- 982
							self._prependSlash = true -- 983
						end -- 982
						hostNameEnd = i - 1 -- 985
						break -- 986
					end -- 981
					idna = true -- 988
				end -- 964
				lastCh = ch -- 990
				charsAfterDot = charsAfterDot + 1 -- 991
			end -- 991
			if (hostNameEnd + 1) ~= startPos and (hostNameEnd - hostNameStart) <= 256 then -- 993
				local hostname = sub(str, hostNameStart, hostNameEnd) -- 994
				if doLowerCase then -- 995
					hostname = lower(hostname) -- 996
				end -- 995
				if idna then -- 997
					hostname = self:_hostIdna(hostname) -- 998
				end -- 997
				self.hostname = hostname -- 1000
				self.host = self._port > 0 and (hostname .. ":" .. self._port) or hostname -- 1001
			end -- 993
			return hostNameEnd + 1 + portLength -- 1003
		end, -- 1005
		_copyPropsTo = function(self, input, noProtocol) -- 1005
			if not noProtocol then -- 1006
				input._protocol = self._protocol -- 1007
			end -- 1006
			input._href = self._href -- 1008
			input._port = self._port -- 1009
			input._prependSlash = self._prependSlash -- 1010
			input.auth = self.auth -- 1011
			input.slashes = self.slashes -- 1012
			input.host = self.host -- 1013
			input.hostname = self.hostname -- 1014
			input.hash = self.hash -- 1015
			input.search = self.search -- 1016
			input.pathname = self.pathname -- 1017
		end, -- 1019
		_clone = function(self) -- 1019
			local url = URL() -- 1020
			url._protocol = self._protocol -- 1021
			url._href = self._href -- 1022
			url._port = self._port -- 1023
			url._prependSlash = self._prependSlash -- 1024
			url.auth = self.auth -- 1025
			url.slashes = self.slashes -- 1026
			url.host = self.host -- 1027
			url.hostname = self.hostname -- 1028
			url.hash = self.hash -- 1029
			url.search = self.search -- 1030
			url.pathname = self.pathname -- 1031
			return url -- 1032
		end, -- 1034
		_getComponentEscaped = function(self, str, startPos, endPos, isAfterQuery) -- 1034
			local cur = startPos -- 1035
			local i = startPos -- 1036
			local ret, length = { }, 0 -- 1037
			autoEscapeMap = isAfterQuery and self._afterQueryAutoEscapeMap or self._autoEscapeMap -- 1038
			while i <= endPos do -- 1040
				local ch = byte(str, i) -- 1041
				local escaped = autoEscapeMap[ch] -- 1042
				if escaped then -- 1043
					length = length + 1 -- 1044
					if cur < i then -- 1045
						ret[length] = sub(str, cur, i - 1) -- 1046
					end -- 1045
					ret[length] = escaped -- 1048
					cur = i + 1 -- 1049
				end -- 1043
				i = i + 1 -- 1051
			end -- 1051
			if cur < i + 1 then -- 1053
				length = length + 1 -- 1054
				ret[length] = sub(str, cur, i) -- 1055
			end -- 1053
			return concat(ret, "", 1, length) -- 1057
		end, -- 1059
		_parsePath = function(self, str, startPos, endPos, disableAutoEscapeChars) -- 1059
			local pathStart = startPos -- 1060
			local pathEnd = endPos -- 1061
			local escape = false -- 1062
			local autoEscapeCharacters = self._autoEscapeCharacters -- 1063
			local prePath = self._port == -2 and "/:" or "" -- 1064
			for i = startPos, endPos do -- 1066
				local ch = byte(str, i) -- 1067
				if ch == 0x23 then -- 1068
					self:_parseHash(str, i, endPos, disableAutoEscapeChars) -- 1069
					pathEnd = i - 1 -- 1070
					break -- 1071
				elseif ch == 0x3F then -- 1072
					self:_parseQuery(str, i, endPos, disableAutoEscapeChars) -- 1073
					pathEnd = i - 1 -- 1074
					break -- 1075
				elseif not disableAutoEscapeChars and not escape and autoEscapeCharacters[ch] then -- 1076
					escape = true -- 1077
				end -- 1068
			end -- 1077
			if pathStart > pathEnd then -- 1079
				self.pathname = prePath == "" and "/" or prePath -- 1080
				return -- 1081
			end -- 1079
			local path -- 1083
			if escape then -- 1084
				path = self:_getComponentEscaped(str, pathStart, pathEnd, false) -- 1085
			else -- 1087
				path = sub(str, pathStart, pathEnd) -- 1087
			end -- 1084
			self.pathname = prePath == "" and (self._prependSlash and "/" .. path or path) or (prePath .. path) -- 1089
		end, -- 1091
		_parseQuery = function(self, str, startPos, endPos, disableAutoEscapeChars) -- 1091
			local queryStart = startPos -- 1092
			local queryEnd = endPos -- 1093
			local escape = false -- 1094
			local autoEscapeCharacters = self._autoEscapeCharacters -- 1095
			for i = startPos, endPos do -- 1097
				local ch = byte(str, i) -- 1098
				if ch == 0x23 then -- 1099
					self:_parseHash(str, i, endPos, disableAutoEscapeChars) -- 1100
					queryEnd = i - 1 -- 1101
					break -- 1102
				elseif not disableAutoEscapeChars and not escape and autoEscapeCharacters[ch] then -- 1103
					escape = true -- 1104
				end -- 1099
			end -- 1104
			if queryStart > queryEnd then -- 1106
				self.search = "" -- 1107
				return -- 1108
			end -- 1106
			if escape then -- 1110
				self.search = self:_getComponentEscaped(str, queryStart, queryEnd, true) -- 1111
			else -- 1113
				self.search = sub(str, queryStart, queryEnd) -- 1113
			end -- 1110
		end, -- 1115
		_parseHash = function(self, str, startPos, endPos, disableAutoEscapeChars) -- 1115
			if startPos > endPos then -- 1116
				self.hash = "" -- 1117
				return -- 1118
			end -- 1116
			self.hash = disableAutoEscapeChars and sub(str, startPos, endPos) or self:_getComponentEscaped(str, startPos, endPos, false) -- 1120
		end, -- 1123
		__index = function(self, key) -- 1123
			if "port" == key then -- 1125
				return self:getPort() -- 1125
			elseif "query" == key then -- 1126
				return self:getQuery() -- 1126
			elseif "path" == key then -- 1127
				return self:getPath() -- 1127
			elseif "protocol" == key then -- 1128
				return self:getProtocol() -- 1128
			elseif "scheme" == key then -- 1129
				return self:getScheme() -- 1129
			elseif "href" == key then -- 1130
				return self:getHref() -- 1130
			else -- 1131
				return rawget(URL.__base, key) -- 1131
			end -- 1131
		end, -- 1133
		__newindex = function(self, key, value) -- 1133
			if "port" == key then -- 1135
				return self:setPort(value) -- 1135
			elseif "query" == key then -- 1136
				return self:setQuery(value) -- 1136
			elseif "path" == key then -- 1137
				return self:setPath(value) -- 1137
			elseif "protocol" == key then -- 1138
				return self:setProtocol(value) -- 1138
			elseif "scheme" == key then -- 1139
				return self:setProtocol(value) -- 1139
			elseif "href" == key then -- 1140
				return self:setHref(value) -- 1140
			else -- 1141
				return rawset(self, key, value) -- 1141
			end -- 1141
		end, -- 1144
		getPort = function(self) -- 1144
			local port = self._port -- 1145
			if port >= 0 then -- 1146
				return tostring(port) -- 1147
			end -- 1146
		end, -- 1149
		setPort = function(self, value) -- 1149
			if value == nil then -- 1150
				self._port = -1 -- 1151
			else -- 1153
				self._port = tonumber(value) -- 1153
			end -- 1150
		end, -- 1156
		getQuery = function(self) -- 1156
			do -- 1157
				local query = self._query -- 1157
				if query then -- 1157
					return query -- 1158
				end -- 1157
			end -- 1157
			local search = self.search -- 1160
			if search then -- 1161
				if byte(search, 1) == 0x3f then -- 1162
					search = sub(search, 2) -- 1163
				end -- 1162
				if search ~= "" then -- 1165
					self._query = search -- 1166
					return search -- 1167
				end -- 1165
			end -- 1161
			return search -- 1169
		end, -- 1171
		setQuery = function(self, value) -- 1171
			self._query = value -- 1172
		end, -- 1175
		getPath = function(self) -- 1175
			return (self.pathname or "") .. (self.search or "") -- 1176
		end, -- 1178
		setPath = function() end, -- 1181
		getProtocol = function(self) -- 1181
			local protocol = self._protocol or "" -- 1182
			return protocol ~= "" and (protocol .. ":") or "" -- 1183
		end, -- 1185
		setProtocol = function(self, value) -- 1185
			if isstring(value) then -- 1186
				if byte(value, -1) == 0x3A then -- 1187
					self._protocol = sub(value, 1, -2) -- 1188
				else -- 1190
					self._protocol = value -- 1190
				end -- 1187
			elseif not value then -- 1191
				self._protocol = nil -- 1192
			end -- 1186
		end, -- 1195
		getScheme = function(self) -- 1195
			return self._protocol -- 1196
		end, -- 1199
		getHref = function(self) -- 1199
			local href = self._href -- 1200
			if not href or href == "" then -- 1201
				href = self:format() -- 1202
				self._href = href -- 1202
			end -- 1201
			return href -- 1204
		end, -- 1206
		setHref = function(self, value) -- 1206
			self._href = value -- 1207
		end -- 442
	} -- 442
	if _base_0.__index == nil then -- 442
		_base_0.__index = _base_0 -- 442
	end -- 1236
	_class_0 = setmetatable({ -- 442
		__init = function(self) -- 480
			-- For more efficient internal representation and laziness.
			-- The non-underscore versions of these properties are accessor functions
			-- defined on the prototype.
			self._protocol = nil -- 484
			self._href = "" -- 485
			self._port = -1 -- 486
			self._query = nil -- 487
			-- Probably just should remove these properties
			self.auth = nil -- 490
			self.slashes = false -- 491
			self.host = nil -- 492
			self.hostname = nil -- 493
			self.hash = nil -- 494
			self.search = nil -- 495
			self.pathname = nil -- 496
			self._prependSlash = false -- 498
		end, -- 442
		__base = _base_0, -- 442
		__name = "URL" -- 442
	}, { -- 442
		__index = _base_0, -- 442
		__call = function(cls, ...) -- 442
			local _self_0 = setmetatable({ }, _base_0) -- 442
			cls.__init(_self_0, ...) -- 442
			return _self_0 -- 442
		end -- 442
	}) -- 442
	_base_0.__class = _class_0 -- 442
	local self = _class_0; -- 442
	self.parse = function(str, parseStringQuery, hostDenotesSlash, disableAutoEscapeChars) -- 1209
		if istable(str) and str.__name == URL.__name then -- 1210
			return str -- 1211
		end -- 1210
		local url = URL() -- 1213
		url:parse(str, not not parseStringQuery, not not hostDenotesSlash, not not disableAutoEscapeChars) -- 1214
		return url -- 1215
	end -- 1209
	self.format = function(obj) -- 1217
		if isstring(obj) then -- 1218
			obj = URL.parse(obj) -- 1219
		end -- 1218
		if not istable(obj) or obj.__name ~= URL.__name then -- 1221
			return URL.__base.format(obj) -- 1222
		end -- 1221
		return obj:format() -- 1224
	end -- 1217
	self.resolve = function(source, relative) -- 1226
		return URL.parse(source):resolve(relative) -- 1227
	end -- 1226
	self.resolveObject = function(source, relative) -- 1229
		if source then -- 1230
			return URL.parse(source, false, true):resolveObject(relative) -- 1231
		end -- 1230
		return relative -- 1233
	end -- 1229
	self.__base.setScheme = self.__base.setProtocol -- 1235
	self.__base.__tostring = self.__base.format -- 1236
	URL = _class_0 -- 442
end -- 1236
_module_0["URL"] = URL -- 442
local IsQueryStringParser -- 1238
IsQueryStringParser = function(any) -- 1238
	local metatable = getmetatable(any) -- 1239
	return metatable and metatable.__class == QueryStringParser -- 1240
end -- 1238
_module_0["IsQueryStringParser"] = IsQueryStringParser -- 1240
local IsURL -- 1242
IsURL = function(any) -- 1242
	local metatable = getmetatable(any) -- 1243
	return metatable and metatable.__class == URL -- 1244
end -- 1242
_module_0["IsURL"] = IsURL -- 1244
return _module_0 -- 1244
