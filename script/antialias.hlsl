Texture2D src : register(t0);
SamplerState smp : register(s0);
cbuffer constant0 : register(b0) {
	float2 tile_offset_f, tile_size_f, size, origin;
};
static const int2
	tile_offset = int2(tile_offset_f),
	tile_size = int2(tile_size_f);

float4 antialias(float4 pos : SV_Position) : SV_Target
{
	const int2 tile_pos = floor((pos.xy - origin) / size);
	const float2 tile_tl = tile_pos * size + origin,
		tile_br = tile_tl + size;

	return src.SampleLevel(smp, (tile_pos - tile_offset + 0.5
		+ min(pos.xy - tile_tl, 0.5)
		+ max(pos.xy - tile_br, -0.5)) / tile_size, 0);
}
