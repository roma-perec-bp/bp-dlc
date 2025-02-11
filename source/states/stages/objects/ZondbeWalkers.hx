package states.stages.objects;

import flixel.graphics.frames.FlxAtlasFrames;

class ZondbeWalkers extends FlxSprite
{
	var lifeTime:Float = 0;
	public var who:Int;
	public var flipYes:Bool;
	public function new(x:Float, y:Float, flipShit:Bool)
	{
		super(x, y);

		//flipYes = FlxG.random.bool(50);
		flipYes = flipShit;
		who = FlxG.random.int(0, 5);

		scale.set(2,2);
		frames = Paths.getSparrowAtlas("wave2/walkers");
		animation.addByPrefix('default', 'default', 24, true);
		animation.addByPrefix('conehead', 'cone', 24, true);
		animation.addByPrefix('buckethead', 'bucket', 24, true);
		animation.addByPrefix('pole', 'pole', 40, true);
		animation.addByPrefix('newspaper', 'news', 18, true);
		animation.addByPrefix('football', 'football', 30, true);
		animation.addByPrefix('yeti', 'yeti', 16, true);
		animation.addByPrefix('easter', 'dance', 24, true);
		scrollFactor.set(0.6, 0.6);
		flipX = !flipYes;
		antialiasing = ClientPrefs.data.antialiasing;

		if (FlxG.random.bool(1))
			who = 7;
		if (FlxG.random.bool(0.1))
			who = 6;

		switch(who)
		{
			case 0:
				animation.play('default');

				if(flipYes)
					velocity.x = -30;
				else
					velocity.x = 30;
			case 1:
				animation.play('conehead');

				if(flipYes)
					velocity.x = -40;
				else
					velocity.x = 40;
			case 2:
				animation.play('buckethead');

				if(flipYes)
					velocity.x = -30;
				else
					velocity.x = 30;
			case 3:
				animation.play('pole');

				if(flipYes)
					velocity.x = -60;
				else
					velocity.x = 60;
			case 4:
				animation.play('newspaper');

				if(flipYes)
					velocity.x = -40;
				else
					velocity.x = 40;
			case 5:
				animation.play('football');

				if(flipYes)
					velocity.x = -70;
				else
					velocity.x = 70;
			case 6:
				animation.play('yeti');

				if(flipYes)
					velocity.x = -70;
				else
					velocity.x = 70;
			case 7:
				animation.play('easter');

				if(flipYes)
					velocity.x = -70;
				else
					velocity.x = 70;
		}
	}
}