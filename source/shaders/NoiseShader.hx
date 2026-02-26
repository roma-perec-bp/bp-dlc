
package shaders;

import lime.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

class NoiseShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(Paths.shaderFragment('1bitnoise')));
    this.setFloat('iTime', 0);
  }
}