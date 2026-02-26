
package states.stages.objects;

import flixel.graphics.frames.FlxAtlasFrames;

class ZombieDancers extends FlxSprite
{
	var alt:Bool = false;
	var danced:Bool = false;

	var nane:String = 'default';
	public function new(x:Float, y:Float)
	{
		super(x, y);
		alt = FlxG.random.bool(50);

		if (FlxG.random.bool(25))
			nane = 'conehead';

		if (FlxG.random.bool(10))
			nane = 'buckethead';

		if (FlxG.random.bool(1))
			nane = 'purple';

		frames = Paths.getSparrowAtlas("zombie_" + nane);
		animation.addByPrefix('idle', 'dance0', 24, false);
		animation.addByIndices('danceLeft', 'dance_alt', [0,1,2,3,4,5,6,7,8], "", 24, false);
		animation.addByIndices('danceRight', 'dance_alt', [10,11,12,13,14,15,16,17], "", 24, false);
		scrollFactor.set(0.9, 0.9);
		antialiasing = ClientPrefs.data.antialiasing;
        animation.play('idle');

		if (nane == 'conehead')
			offset.set(0, 75);

		if (nane == 'buckethead')
			offset.set(0, 75);
	}

	public function dance()
	{
		/*centerOffsets();
		centerOrigin();*/

		if(alt)
		{
			if(danced)
				animation.play('danceLeft', true);
			else
				animation.play('danceRight', true);

			danced = !danced;
		}
		else animation.play('idle', true);
	}
}