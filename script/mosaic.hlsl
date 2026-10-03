Texture2D src : register(t0);
cbuffer constant0 : register(b0) {
	float2 tile_offset_f, src_size_f, size, origin;
	float seed;
};
static const int2
	tile_offset = int2(tile_offset_f),
	src_size = int2(src_size_f);

float4 mosaic(float4 pos : SV_Position) : SV_Target
{
	const int2 tile_pos = int2(pos.xy) + tile_offset;
	const float2 tile_tl = tile_pos * size + origin,
		tile_br = tile_tl + size;
	const uint2 sample_pt = clamp(int2(
		floor(lerp(tile_tl, tile_br, float2(
			ibuki(float4((1 << 16) + tile_pos, seed, 7)),
			ibuki(float4((1 << 16) + tile_pos, seed, 11)))))),
		0, src_size - 1);
	return src[sample_pt];
}
