package shaders;
import openfl.Lib;
import flixel.system.FlxAssets.FlxShader;
class ChromaticWarp extends FlxShader {
    @:isVar
	public var warpStrength(get, set):Float = 1;

	function get_warpStrength()
	{
		return (warp.value[0]);
	}
	function set_warpStrength(v:Float)
	{
		warp.value = [v, v];
		return v;
	}
	

	@:glFragmentSource('
	#pragma header

	uniform float warp;

	void main()
	{
    	// squared distance from center
    	vec2 uv=openfl_TextureCoordv.xy;
   	 	vec2 dc=abs(.5-uv)*abs(.5-uv);
    
    	// warp the fragment coordinates
    	uv.x-=.5;uv.x*=1.+(dc.y*(.3*warp));uv.x+=.5;
    	uv.y-=.5;uv.y*=1.+(dc.x*(.4*warp));uv.y+=.5;
    
    	// sample inside boundaries, otherwise set to black
    	if(uv.y>1.||uv.x<0.||uv.x>1.||uv.y<0.)
    	gl_FragColor=vec4(0.,0.,0.,1.);
    	else
    	{
      	  	gl_FragColor=flixel_texture2D(bitmap,uv);
    	}
	}

	')
	public function new()
	{
		super();
		this.warp.value = [1,1];
	}
}