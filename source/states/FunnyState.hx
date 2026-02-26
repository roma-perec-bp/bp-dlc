package states;

import flixel.addons.text.FlxTypeText;
import objects.VideoSprite;

class FunnyState extends MusicBeatState
{
	override function create()
	{
		var love = new FlxSprite().loadGraphic(Paths.image('telezhka'));
		love.antialiasing = false;
		add(love);
		love.screenCenter();

		FlxG.sound.play(Paths.sound('penis'), 1, false, null, true, function() {
			MusicBeatState.switchState(new EndingState());
		});

		super.create();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("telezhka", null);
		#end
	}
}