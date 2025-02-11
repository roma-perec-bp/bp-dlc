package shaders;

import openfl.display.Shader;
import openfl.filters.ShaderFilter;

class ShadersHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new shaders.ChromaticAberration());
	public static var radialBlur:ShaderFilter = new ShaderFilter(new shaders.RadialBlur());
	public static var directionalBlur:ShaderFilter = new ShaderFilter(new shaders.DirectionalBlur());

	public static function setChrome(chromeOffset:Float):Void
	{
		chromaticAberration.shader.data.rOffset.value = [chromeOffset];
		chromaticAberration.shader.data.gOffset.value = [0.0];
		chromaticAberration.shader.data.bOffset.value = [chromeOffset * -1];
	}
	public static function setRadialBlur(x:Float=640,y:Float=360,power:Float=0.03):Void
	{
		radialBlur.shader.data.blurWidth.value = [power];
		radialBlur.shader.data.cx.value = [x/2560];
		radialBlur.shader.data.cy.value = [y/1440];
	}

	inline public static function getRadialBlur()
		return radialBlur.shader.data.blurWidth.value;

	public static function setBlur(angle:Float,power:Float=0.1):Void
	{
		radialBlur.shader.data.angle.value = [angle];
		radialBlur.shader.data.strength.value = [power];
	}
}
