
package shaders;

import lime.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

class HypnoShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(Paths.shaderFragment('hypno')));
    this.setFloat('iTime', 0);
    this.setFloat('alphaShitLmao', .3);
  }
}