Texture2D src : register(t0);
cbuffer constant0 : register(b0) {
	float2 src_size_f, size, origin;
};
static const int2 src_size = int2(src_size_f);

float4 tile(float4 pos : SV_Position) : SV_Target
{
	const int2 pos_i = floor(pos.xy);
	const int2 tile_pos = floor((pos.xy - origin) / size);
	const float2 tile_tl = tile_pos * size + origin,
		tile_br = tile_tl + size;
	const int2 tile_tl_i = floor(tile_tl), tile_br_i = floor(tile_br);

	int rate = 0;
	if (any(pos_i == tile_tl_i)) rate++;
	if (any(pos_i == tile_br_i - 1)) rate--;

	float4 col = src[pos_i];
	col.rgb *= (1.0 + rate * 0.25);
	col.rgb = clamp(col.rgb, 0.0, col.a);
	return col;
}
