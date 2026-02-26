
package shaders;

import lime.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

class VignetteShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(Paths.shaderFragment('vignette')));
    this.setFloat('u_intensity', 2);
  }
}