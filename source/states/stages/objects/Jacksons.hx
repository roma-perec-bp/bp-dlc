package states.stages.objects;

import flixel.graphics.frames.FlxAtlasFrames;

class Jacksons extends FlxSprite
{
	public var flipYes:Bool;
	public function new(x:Float, y:Float, flipShit:Bool)
	{
		super(x, y);

		//flipYes = FlxG.random.bool(50);
		flipYes = flipShit;

		//scale.set(2,2);
		frames = Paths.getSparrowAtlas("wave3/jacksonWalk");
		animation.addByPrefix('idle', 'jackson', 30, true);
		animation.play('idle');
		flipX = flipYes;
		antialiasing = ClientPrefs.data.antialiasing;

		if(flipYes)
			velocity.x = -200;
		else
			velocity.x = 200;

		new FlxTimer().start(15, function(timer:FlxTimer)
		{
			kill();
		});
	}
}