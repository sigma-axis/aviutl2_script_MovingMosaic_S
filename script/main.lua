--information:MovingMosaic_S ${PACKAGE_VERSION} by ${AUTHOR}
---$nolang: script_name
---$script_tips:マス内のランダムな位置から色を拾うことで動いているように見えるモザイク．
--label:加工
--filter
--require:${LEAST_AVIUTL_VERSION}
---$track:サイズ, min = 1, max = 2000, step = 0.01, scale = 0.1
local size = 12

---$tips:0 以上だと同じシードでも別オブジェクトだと別の乱数．
---     :負だと同じシードなら別オブジェクトでも同じ乱数．
---$track:シード, min = -65536, max = 65535, step = 1
local seed = 10000

---$checksection:タイル風
local convex = false

--group:追加設定,false
---$tips:正で縦長 / 負で横長
---$track:縦横比, min = -100, max = 100, step = 0.01
local aspect = 0

---$nolang: name
---$track:X, min = -4000, max = 4000, step = 0.01, scale = 0.25
local X = 0

---$nolang: name
---$track:Y, min = -4000, max = 4000, step = 0.01, scale = 0.25
local Y = 0

--trackgroup@X,Y:OriginPos
--group:その他,false
---$nolang: name
---$tips:PI = {
---     :  size: number?,
---     :  seed: number?,
---     :  convex: boolean|number|nil,
---     :  aspect: number?,
---     :  X: number?,
---     :  Y: number?,
---     :}
---$value:PI
local PI = {}

--[[pixelshader@mosaic:
---$include "ibukihash.hlsl"
---$include "mosaic.hlsl"
]]
--[[pixelshader@antialias:
---$include "antialias.hlsl"
]]
--[[pixelshader@tile:
---$include "tile.hlsl"
]]
local obj, math, tonumber, type = obj, math, tonumber, type;

local cx, cy = obj.getvalue("center");
cx, cy = cx + obj.cx, cy + obj.cy;
if obj.getoption("gui") then
	obj.setanchor("X,Y", 0, "line", "offset", cx, cy);
end

--#region PI / normalize parameters.

-- take parameters.
size = tonumber(PI.size) or size;
seed = tonumber(PI.seed) or seed;
if type(PI.convex) == "boolean" then convex = PI.convex;
elseif type(PI.convex) == "number" then convex = PI.convex ~= 0 end
aspect = tonumber(PI.aspect) or aspect;
X = tonumber(PI.X) or X;
Y = tonumber(PI.Y) or Y;

-- normalize parameters.
local size_x, size_y = size, size;
aspect = math.min(math.max(aspect / 100, -1), 1);
if aspect > 0 then size_x = size_x * (1 - aspect) end
if aspect < 0 then size_y = size_y * (1 + aspect) end
size_x, size_y = math.max(size_x, 1), math.max(size_y, 1);
if size_x <= 1 and size_y <= 1 then return end
seed = math.floor(seed); -- not the nearest, but simple floor.
if seed >= 0 then
	seed = seed
		+  2525 * (obj.id % 2 ^ 20)
		+ 13579 * (obj.effect_id % 2 ^ 20)
		+ 54321 * (obj.index % 2 ^ 20);
end
seed = seed % 2 ^ 20;
cx, cy = cx + X + obj.w / 2, cy + Y + obj.h / 2;

--#endregion PI / normalize parameters.

-- further calculations.
local L, R, T, B =
	math.floor(-cx / size_x), math.ceil((obj.w - cx) / size_x),
	math.floor(-cy / size_y), math.ceil((obj.h - cy) / size_y);

-- apply shaders.
local cache_name = "cache:movingmosaic_s/temp";
obj.clearbuffer(cache_name, R - L, B - T);
obj.pixelshader("mosaic", cache_name, "object", {
	L, T; obj.w, obj.h; size_x, size_y; cx, cy; seed;
});

obj.pixelshader(convex and "tile" or "antialias", "object", cache_name, {
	L, T; R - L, B - T; size_x, size_y; cx, cy;
}, "copy", "clamp");
