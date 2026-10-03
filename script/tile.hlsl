Texture2D src : register(t0);
cbuffer constant0 : register(b0) {
	float2 tile_offset_f, tile_size_f, size, origin;
};
static const int2
	tile_offset = int2(tile_offset_f),
	tile_size = int2(tile_size_f);

float4 tile(float4 pos : SV_Position) : SV_Target
{
	const int2 tile_pos = floor((pos.xy - origin) / size);
	const float2 tile_tl = tile_pos * size + origin,
		tile_br = tile_tl + size;
	const int2 tile_tl_i = ceil(tile_tl - 0.5), tile_br_i = ceil(tile_br - 0.5);

	int rate = 0;
	const int2 pos_i = floor(pos.xy);
	if (any(pos_i == tile_tl_i)) rate++;
	if (any(pos_i == tile_br_i - 1)) rate--;

	float4 col = src[uint2(tile_pos - tile_offset)];
	col.rgb *= (1.0 + rate * 0.25);
	col.rgb = clamp(col.rgb, 0.0, col.a);
	return col;
}
