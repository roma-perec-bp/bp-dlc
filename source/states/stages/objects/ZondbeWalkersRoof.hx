package states.stages.objects;

import flixel.graphics.frames.FlxAtlasFrames;

class ZondbeWalkersRoof extends FlxSprite
{
	public var flipYes:Bool;
	public function new(x:Float, y:Float, flipShit:Bool, whoIs:Int)
	{
		super(x, y);

		//flipYes = FlxG.random.bool(50);
		flipYes = flipShit;

		scale.set(2,2);
		frames = Paths.getSparrowAtlas("wave3/walkersROOF");
		animation.addByPrefix('default', 'balloon', 16, true);
		animation.addByPrefix('box', 'box', 24, true);
		animation.addByPrefix('digger', 'digger', 16, true);
		animation.addByPrefix('gargantuar', 'gargantuar', 16, true);
		scrollFactor.set(0.6, 0.6);
		flipX = !flipYes;
		antialiasing = ClientPrefs.data.antialiasing;

		switch(whoIs)
		{
			case 0:
				animation.play('default');

				if(flipYes)
					velocity.x = -200;
				else
					velocity.x = 200;
			case 1:
				animation.play('box');
				blend = ADD;

				if(flipYes)
					velocity.x = -40;
				else
					velocity.x = 40;
			case 2:
				animation.play('digger');

				if(flipYes)
					velocity.x = -200;
				else
					velocity.x = 200;
			case 3:
				animation.play('gargantuar');

				if(flipYes)
					velocity.x = -25;
				else
					velocity.x = 25;
		}
	}
}