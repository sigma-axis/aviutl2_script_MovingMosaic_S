Texture2D src : register(t0);
SamplerState smp : register(s0);
cbuffer constant0 : register(b0) {
	float2 src_size_f, size, origin;
};
static const int2 src_size = int2(src_size_f);

float4 antialias(float4 pos : SV_Position) : SV_Target
{
	const int2 tile_pos = floor((pos.xy - origin) / size);
	const float2 tile_tl = tile_pos * size + origin;
	const int2 tile_tl_i = floor(tile_tl);
	return src.SampleLevel(smp, (pos.xy - tile_tl + tile_tl_i) / src_size, 0);
}
