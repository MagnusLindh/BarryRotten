package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import js.html.SpanElement;

using flixel.util.FlxSpriteUtil;
#if mobile
import flixel.ui.FlxVirtualPad;
#end


class PlayState extends FlxState
{
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Coin>;
	var airs:FlxTypedGroup<Air>;
	var earths:FlxTypedGroup<Earth>;
	var waters:FlxTypedGroup<Water>;
	var fires:FlxTypedGroup<Fire>;
	var enemies:FlxTypedGroup<Enemy>;

	var hud:HUD;
	var money:Int = 0;
	var health:Int = 3;
	var spell:Int = 0;

	var inCombat:Bool = false;
	var combatHud:CombatHUD;

	var ending:Bool;
	var won:Bool;

	var coinSound:FlxSound;
	var airSound:FlxSound;
	var earthSound:FlxSound;
	var waterSound:FlxSound;
	var fireSound:FlxSound;

	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	override public function create()
	{
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end

		map = new FlxOgmo3Loader("assets/data/world.ogmo", "assets/data/level1.json");
		walls = map.loadTilemap("assets/images/tiles2.png", "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		add(walls);

		coins = new FlxTypedGroup<Coin>();
		add(coins);

		airs = new FlxTypedGroup<Air>();
		add(airs);

		earths = new FlxTypedGroup<Earth>();
		add(earths);

		waters = new FlxTypedGroup<Water>();
		add(waters);

		fires = new FlxTypedGroup<Fire>();
		add(fires);

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

		hud = new HUD();
		add(hud);

		combatHud = new CombatHUD();
		add(combatHud);

		coinSound = FlxG.sound.load("assets/sounds/coin1.wav");
		airSound = FlxG.sound.load("assets/sounds/Air.wav");
		earthSound = FlxG.sound.load("assets/sounds/Earth.wav");
		waterSound = FlxG.sound.load("assets/sounds/Water.wav");
		fireSound = FlxG.sound.load("assets/sounds/Fire.wav");

		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();
	}

	function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				player.setPosition(x, y);

			case "coin":
				coins.add(new Coin(x + 4, y + 4));

			case "air":
				airs.add(new Air(x + 4, y));

			case "earth":
				earths.add(new Earth(x + 4, y));

			case "water":
				waters.add(new Water(x + 4, y));

			case "fire":
				fires.add(new Fire(x + 4, y));

			case "golem":
				enemies.add(new Enemy(x + 4, y, GOLEM));

			case "dragon":
				enemies.add(new Enemy(x + 4, y, DRAGON));

			case "siren":
				enemies.add(new Enemy(x + 4, y, SIREN));

			case "sylph":
				enemies.add(new Enemy(x + 4, y, SYLPH));
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ending)
		{
			return;
		}

		if (inCombat)
		{
			if (!combatHud.visible)
			{
				health = combatHud.playerHealth;
				hud.updateHUD(health, money, spell);
				if (combatHud.outcome == DEFEAT)
				{
					ending = true;
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
				}
				else
				{
					if (combatHud.outcome == VICTORY)
					{
						combatHud.enemy.kill();
						if (combatHud.enemy.type == DRAGON)
						{
							won = true;
							ending = true;
							FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
						}
					}
					else
					{
						combatHud.enemy.flicker();
					}
					inCombat = false;
					player.active = true;
					enemies.active = true;

					#if mobile
					virtualPad.visible = true;
					#end
				}
			}
		}
		else
		{
			FlxG.collide(player, walls);
			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.overlap(player, airs, playerTouchAir);
			FlxG.overlap(player, earths, playerTouchEarth);
			FlxG.overlap(player, waters, playerTouchWater);
			FlxG.overlap(player, fires, playerTouchFire);
			FlxG.collide(enemies, walls);
			enemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(player, enemies, playerTouchEnemy);
		}
	}

	function doneFadeOut()
	{
		FlxG.switchState(() -> new GameOverState(won, money));
	}

	function playerTouchCoin(player:Player, coin:Coin)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			coin.kill();
			money++;
			hud.updateHUD(health, money, spell);
			coinSound.play(true);
		}
	}

	function playerTouchAir(player:Player, air:Air)
	{
		if (player.alive && player.exists && air.alive && air.exists)
		{
			air.kill();
			spell = 1;
			hud.updateHUD(health, money, spell);
			airSound.play(true);
		}
	}

	function playerTouchEarth(player:Player, earth:Earth)
	{
		if (player.alive && player.exists && earth.alive && earth.exists)
		{
			earth.kill();
			spell = 2;
			hud.updateHUD(health, money, spell);
			earthSound.play(true);
		}
	}

	function playerTouchWater(player:Player, water:Water)
	{
		if (player.alive && player.exists && water.alive && water.exists)
		{
			water.kill();
			spell = 3;
			hud.updateHUD(health, money, spell);
			waterSound.play(true);
		}
	}

	function playerTouchFire(player:Player, fire:Fire)
	{
		if (player.alive && player.exists && fire.alive && fire.exists)
		{
			fire.kill();
			spell = 4;
			hud.updateHUD(health, money, spell);
			fireSound.play(true);
		}
	}

	function checkEnemyVision(enemy:Enemy)
	{
		if (walls.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}

	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			startCombat(enemy,spell);
		}
	}

	function startCombat(enemy:Enemy, spell:Int)
	{
		inCombat = true;
		player.active = false;
		enemies.active = false;
		combatHud.initCombat(health, enemy, spell);

		#if mobile
		virtualPad.visible = false;
		#end
	}

}
