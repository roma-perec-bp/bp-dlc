package states;

import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;

class CheatState extends MusicBeatState
{
	var text:FlxText;
	var scary:FlxSprite;
	override function create()
	{
		super.create();

		scary = new FlxSprite().loadGraphic(Paths.image('uh oh'));
		scary.screenCenter();
		scary.alpha = 0;
		add(scary);

        text = new FlxText(0, 0, FlxG.width, '', 32);
		text.setFormat(Paths.font("scary.otf"), 32, FlxColor.RED, CENTER);
		text.x += 10;
		text.screenCenter(Y);
        add(text);

		text.text = 'Warning, modchart was not detected\n\nあなたはクソ雌犬ですか？ 私は理解していませんでした'; //максплей гейс такой: БРОУ ВАТАФАК?
		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			text.text = 'It is illegal to delete modcharts from songs\n\n今、あなたはそのような行動のために猫を得るつもりです、いいですか？';
			new FlxTimer().start(4, function(tmr:FlxTimer)
			{
				text.text = 'Immediately return the script and then continue playing\n\nそのたわごとを戻すか、私はあなたのfuckinおならであなたをレイプします!!!';
				new FlxTimer().start(4, function(tmr:FlxTimer)
				{
					text.text = 'Cheating is really really bad thing buddy, next time be aware\n\nあなたはクソ野郎ではなく、あなたはそのようなたわごとをする必要がないことを知っていますよね？';
					new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						text.text = 'Иди нахуй';
                        FlxG.sound.play(Paths.sound('fuckYou'));
						new FlxTimer().start(0.4, function(tmr:FlxTimer) //хихихиха
						{
							Sys.exit(1);
						});
					});
				});
			});
		});

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			scary.alpha += 0.01;
			tmr.reset(1);
		});
	}
}
// кто читает тот гей так что не пытайтесь удалить это
