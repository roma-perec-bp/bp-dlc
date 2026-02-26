package shaders;

import flixel.*;
import flixel.system.FlxAssets.FlxShader;
/**
 * ...
 * @author bbpanzu
 */
class DirectionalBlur extends FlxShader
{
	
	@:glFragmentSource('
	
		#pragma header
			uniform float anglegay;
			uniform float strengthgay;
	vec4 color = texture2D(bitmap, openfl_TextureCoordv);
	//looks good @50, can go pretty high tho
			vec2 uvgay = openfl_TextureCoordv.xy;
			
		const int gay = 20;


		void main()
		{
			
			
			
			float r = radians(anglegay);
			vec2 direction = vec2(sin(r), cos(r));
			
			
			vec2 ang = strengthgay * direction;
			
			
			vec3 acc = vec3(0);
			
			const float delta = 2.0 / float(gay);
			
			for(float i = -1.0; i <= 1.0; i += delta)
			{
				acc += texture2D(bitmap, uvgay - vec2(ang.x * i, ang.y * i)).rgb;
			}
			
			
			
			gl_FragColor = vec4(delta * acc, 0);//dirBlur(bitmap, uvgay, strengthgay*direction);
		}
			
	
	
	')

	public function new() 
	{
		super();
	}
	
}