
package shaders;

import lime.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

class DesaturateShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(Paths.shaderFragment('desaturate')));
  }
}