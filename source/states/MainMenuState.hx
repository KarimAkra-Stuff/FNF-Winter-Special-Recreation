package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import objects.Sprite;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<Sprite>;

	var optionShit:Array<String> = [
		'story',
		'freeplay',
		'options',
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits'
	];

	var magenta:FlxSprite;
	var pointer:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		menuItems = new FlxTypedGroup<Sprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:Sprite = new Sprite(60, 30 + (i * 175));
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('just selected', optionShit[i] + " select", 24, false);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " select loop", 24);
			menuItem.scale.set(0.6, 0.6);
			menuItem.updateHitbox();
			menuItem.defaultOffset = [menuItem.offset.x, menuItem.offset.y];
			if(optionShit[i] == 'credits'){
				menuItem.setAnimationOffset('just selected', 115, 58);
				menuItem.setAnimationOffset('selected', 115, 58);
				menuItem.setAnimationOffset('idle', 50.2, 16.8);
			} else {
				menuItem.setAnimationOffset('just selected', menuItem.defaultOffset[0] + 40, menuItem.defaultOffset[1] + 20);
				menuItem.setAnimationOffset('selected', menuItem.defaultOffset[0] + 40, menuItem.defaultOffset[1] + 20);
			}
			menuItem.playAnim('idle');
			menuItem.animation.finishCallback = (name:String) -> {if(name == 'just selected') menuItem.playAnim('selected', true);};
			menuItems.add(menuItem);
			if(optionShit[i] == 'credits')
				menuItem.setPosition((FlxG.width - menuItem.width) + 4, (FlxG.height - menuItem.height) + 2);
		}

		pointer = new FlxSprite();
		pointer.frames = Paths.getSparrowAtlas('mainmenu/arrow-main-menu');
		pointer.animation.addByPrefix('idle', 'anim', 24, true);
		pointer.animation.play('idle', true);
		pointer.scale.set(0.6, 0.6);
		pointer.updateHitbox();
		add(pointer);

		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');

		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end

		addVirtualPad('UP_DOWN', 'MAIN_MENU');

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
				changeItem(-1);

			if (controls.UI_DOWN_P)
				changeItem(1);

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;

					if (optionShit[curSelected] == 'credits')
						MusicBeatState.switchState(new CreditsState());
					else {
						if(ClientPrefs.data.flashing)
							FlxFlicker.flicker(magenta, 1.1, 0.15, false);
						FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							switch (optionShit[curSelected])
							{
								case 'story':
									MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayState());

								#if MODS_ALLOWED
								case 'mods':
									MusicBeatState.switchState(new ModsMenuState());
								#end

								#if ACHIEVEMENTS_ALLOWED
								case 'awards':
									MusicBeatState.switchState(new AchievementsMenuState());
								#end
								case 'options':
									MusicBeatState.switchState(new OptionsState());
									OptionsState.onPlayState = false;
									if (PlayState.SONG != null)
									{
										PlayState.SONG.arrowSkin = null;
										PlayState.SONG.splashSkin = null;
										PlayState.stageUI = 'normal';
									}
							}
						});
					}
					for (i in 0...menuItems.members.length)
					{
						if(menuItems.members[i] != menuItems.members[4]){
							if(i == curSelected)
								continue;
							FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									menuItems.members[i].kill();
								}
							});
						}
					}
				}
			}
			else if (controls.justPressed('debug_1') || virtualPad.buttonSeven.justPressed)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].playAnim('idle', true);
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		menuItems.members[curSelected].playAnim('just selected', true);
		// FOR FUCK SAKE I'M TIRED OF THIS MAKE FUN ALL U WANT IDC
		pointer.visible = true;
		switch (optionShit[curSelected]){
			case 'story': pointer.setPosition(620, 90);
			case 'freeplay': pointer.setPosition(540, 250);
			case 'options': pointer.setPosition(500, 400);
			#if ACHIEVEMENTS_ALLOWED
			case 'awards': pointer.setPosition(580, 560);
			#end
			default: pointer.visible = false;
		}
	}
}
