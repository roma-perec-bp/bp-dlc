package states;

class GetALifeState extends MusicBeatState
{
	override function create()
	{
		super.create();

		Achievements.unlock('onehundrec');

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("THEY 100% THIS YOOOOO", null);
		#end

		var text:FlxText = new FlxText(0, 0, FlxG.width, '', 32);
		text.setFormat(Paths.font("mariones.ttf"), 32, FlxColor.WHITE, CENTER);
		text.screenCenter();
        add(text);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			text.text = 'Wow';
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				text.text = 'You actually did it';
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					text.text = 'You 100% this mod!';
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						text.text = 'Why would you do that anyways?';
						new FlxTimer().start(3, function(tmr:FlxTimer)
						{
							text.text = 'There is a lots of mods and you did this one?';
							new FlxTimer().start(3, function(tmr:FlxTimer)
							{
								text.text = 'Uh... idk what to do or even say....';
								new FlxTimer().start(3, function(tmr:FlxTimer)
								{
									text.text = 'So uh.......';
									new FlxTimer().start(3, function(tmr:FlxTimer)
									{
										text.text = 'Thanks for playing!';
										new FlxTimer().start(3, function(tmr:FlxTimer)
										{
											FlxG.sound.playMusic(Paths.music('thankyou'), 1);
										});
									});
								});
							});
						});
					});
				});
			});
		});
	}
}