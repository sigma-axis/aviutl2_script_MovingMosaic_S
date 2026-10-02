Texture2D src : register(t0);
cbuffer constant0 : register(b0) {
	float2 src_size_f, size, origin;
	float seed;
};
static const int2 src_size = int2(src_size_f);

float4 mosaic(float4 pos : SV_Position) : SV_Target
{
	const int2 tile_pos = floor((pos.xy - origin) / size);
	const float2 tile_tl = tile_pos * size + origin,
		tile_br = tile_tl + size;
	const int2 tile_tl_i = floor(tile_tl), tile_br_i = floor(tile_br);
	const uint2 sample_pt = clamp(int2(
		lerp(tile_tl_i.x, tile_br_i.x, ibuki(float4(tile_pos, seed, 7))),
		lerp(tile_tl_i.y, tile_br_i.y, ibuki(float4(tile_pos, seed, 11)))
	), 0, min(src_size, tile_br_i) - 1);
	return src[sample_pt];
}
