package shaders;

import flixel.system.FlxAssets.FlxShader;

class HellShader extends FlxShader
{

	@:isVar
	public var amountShit(get, set):Float = 0;

	function get_amountShit()
	{
		return (amount.value[0]);
	}
	function set_amountShit(v:Float)
	{
		amount.value = [v, v];
		return v;
	}

	@:isVar
	public var pixelSize(get, set):Float = 1;

	function get_pixelSize()
	{
		return (shift.value[0] + shift.value[1])/2;
	}
	function set_pixelSize(v:Float)
	{
		shift.value = [v, v];
		return v;
	}


	@:glFragmentSource('
	// glitch shader
	// shader by nayoto
	// first seen in nayotos fail deadly

	#pragma header

	uniform float amount; // strength [-inf : inf]
	uniform vec2 shift; // shift the rgb channels by this much

	uniform float time;

	float rand( vec2 co )
	{
	return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
	}

	void main()
	{
	    vec2 uv = openfl_TextureCoordv;
		vec2 uvn = uv;

		uv.x += rand( vec2(uvn.y / 10.0, time / 10.0) ) * amount;
		uv.x -= rand( vec2(uvn.y * 10.0, time * 10.0) ) * amount;

		vec3 col;
		col.rg = flixel_texture2D(bitmap, mod(uv + shift / openfl_TextureSize, 1.0) ).rg;
		col.gb = flixel_texture2D(bitmap, mod(uv - shift / openfl_TextureSize, 1.0) ).gb;

		gl_FragColor = vec4( col, texture2D(bitmap, uv).a );
	}
	')


	public function new()
	{
		super();
        this.time.value = [0.0];
		amountShit = 0;
		pixelSize = 1;

	}

    public function update(elapsed:Float) {
        this.time.value[0] += elapsed;
    }
}