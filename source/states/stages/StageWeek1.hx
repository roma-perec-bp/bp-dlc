package states.stages;

import states.stages.objects.*;
import objects.Character;

class StageWeek1 extends BaseStage
{
	override function eventCalled(eventName:String, value1:String, value2:String, value3:String, value4:String, value5:String, flValue1:Null<Float>, flValue2:Null<Float>, flValue3:Null<Float>, flValue4:Null<Float>, flValue5:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Dadbattle Spotlight":
				if(flValue1 == null) flValue1 = 0;
				var val:Int = Math.round(flValue1);
		}
	}
}