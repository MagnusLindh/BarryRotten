package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite>
{
	var background:FlxSprite;
	var healthCounter:FlxText;
	var moneyCounter:FlxText;
	var healthIcon:FlxSprite;
	var moneyIcon:FlxSprite;
	var spellCounter:FlxText;

	public function new()
	{
		super();
		background = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		background.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);
		healthCounter = new FlxText(16, 2, 0, "3 / 3", 8);
		healthCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		moneyCounter = new FlxText(0, 2, 0, "0", 8);
		moneyCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		healthIcon = new FlxSprite(4, healthCounter.y + (healthCounter.height / 2) - 4, "assets/images/health1.png");
		moneyIcon = new FlxSprite(FlxG.width - 12, moneyCounter.y + (moneyCounter.height / 2) - 4, "assets/images/coin1.png");
		moneyCounter.alignment = RIGHT;
		moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
		spellCounter = new FlxText(0, 2, 0, "0%", 8);
		spellCounter.alignment = CENTER;
		spellCounter.x = 160;
		add(background);
		add(healthIcon);
		add(moneyIcon);
		add(healthCounter);
		add(moneyCounter);
		add(spellCounter);
		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	public function updateHUD(health:Int, money:Int, spell:Int)
	{
		healthCounter.text = health + " / 3";
		moneyCounter.text = Std.string(money);
		moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
		var spellText:Array<String> = ["0%", "Air, 20%", "Earth, 40%","Water, 60%","Fire, 80%"];
		spellCounter.text = spellText[spell];
	}
}
