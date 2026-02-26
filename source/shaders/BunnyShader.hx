
package shaders;

import lime.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

class BunnyShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(Paths.shaderFragment('bnuy')));
    this.setFloat('iTime', 0);
  }
}