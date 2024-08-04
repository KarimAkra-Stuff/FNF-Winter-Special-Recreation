package states;

import shaders.RGBPalette;
import flixel.effects.FlxFlicker;
import backend.WeekData;
import backend.Highscore;

import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xD98CF9F9, 0xFFE66AD5];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;

	public static var updateVersion:String = '';

	var lightsRGBs:Array<Array<FlxColor>>  = 
	[[0x85ff59, 0x91c95f],
	[0xff9900, 0xfcc46f],
	[0x03a7ff, 0x60baeb],
	[0xf763df, 0xfc95ec],
	[0xf50707, 0xf26d6d]];

	override public function create():Void
	{
		Paths.clearStoredMemory();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		Mods.loadTopMod();
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		Highscore.load();

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
			MobileData.init();
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			controls.isInSubstate = false; //idfk what's wrong
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var logoLights:FlxSprite;
	var bfHoldingGf:FlxSprite;
	var titleText:FlxSprite;
	var lightsRGB:RGBShaderReference;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			}
		}

		Conductor.bpm = 102;
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		var constScale = [0.67, 0.67];

		logoBl = new FlxSprite(-22, -18);
		logoBl.frames = Paths.getSparrowAtlas('title/LOGO');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bump', 24, false);
		logoBl.animation.play('bump');
		logoBl.scale.set(constScale[0], constScale[1]);
		logoBl.updateHitbox();

		logoLights = new FlxSprite(18, 52);
		logoLights.frames = Paths.getSparrowAtlas('title/logoLight_RPG');
		logoLights.animation.addByPrefix('bump', 'light bump', 24, false);
		logoLights.animation.play('bump');
		logoLights.scale.set(constScale[0], constScale[1]);
		logoLights.updateHitbox();
		lightsRGB = new RGBShaderReference(logoLights,  new RGBPalette());

		if(ClientPrefs.data.shaders) swagShader = new ColorSwap();
		bfHoldingGf = new FlxSprite(579, 227);
		bfHoldingGf.antialiasing = ClientPrefs.data.antialiasing;

		bfHoldingGf.frames = Paths.getSparrowAtlas('title/bf-holding-gf_TITLE');
		bfHoldingGf.animation.addByPrefix('bop', 'bf holding gf bop', 24, false);
		bfHoldingGf.animation.addByPrefix('smile', 'bf holding gf confirm_1', 24, false);
		bfHoldingGf.animation.addByPrefix('dumi', 'bf holding gf confirm_2', 24, false);
		bfHoldingGf.scale.set(constScale[0], constScale[1]);
		bfHoldingGf.updateHitbox();

		add(bfHoldingGf);
		add(logoBl);
		add(logoLights);

		if(swagShader != null)
		{
			bfHoldingGf.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}
		titleText = new FlxSprite(24, 479);
		titleText.frames = Paths.getSparrowAtlas('title/title-Enter');
		titleText.animation.addByPrefix("idle", 'title-text-loop');
		titleText.animation.addByPrefix("press", 'title-text-confirm');
		titleText.animation.play('idle', true);
		titleText.scale.set(constScale[0], constScale[1]);
		titleText.updateHitbox();
		colorTween();
		add(titleText);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		Paths.clearUnusedMemory();
		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt', Paths.getSharedPath());
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split('\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;
	var currentColor:Int = 0;
	override function update(elapsed:Float)
	{
		#if android
		if(FlxG.android.justReleased.BACK)
			SUtil.showPopUp('current working directory: ${Sys.getCwd()}', '');
		#end
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if FLX_TOUCH
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		if(controls.RESET){
			initialized = false;
			FlxG.save.erase();
			FlxG.save.flush();
			forEachOfType(FlxSprite, (spr:FlxSprite) -> spr.visible = false); // stop drawing
			Paths.clearStoredMemory();
			FlxG.resetGame();
		}

		if (initialized && !transitioning && skippedIntro)
		{	
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxFlicker.flicker(titleText, 1.2, 0.05);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
				bfHoldingGf.animation.play(FlxG.random.bool() ? 'dumi' : 'smile', true);
				bfHoldingGf.offset.y += 5;

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(curBeat % 2 == 0){
			var index:Int = FlxG.random.int(0, lightsRGBs.length - 1);
			lightsRGB.r = lightsRGBs[index][0];
			lightsRGB.g = lightsRGBs[index][1];
			lightsRGB.b = FlxColor.TRANSPARENT;
		}

		if(logoBl != null)
			logoBl.animation.play('bump', true);
		if(bfHoldingGf != null && !transitioning)
			bfHoldingGf.animation.play('bop', true);
		if(logoLights != null)
			logoLights.animation.play('bump', true);

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText(['Psych Engine by'], 40);
				case 4:
					addMoreText('Shadow Mario', 40);
					addMoreText('Riveren', 40);
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['Not associated', 'with'], -40);
				case 8:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					createCoolText([curWacky[0]]);
				case 12:
					addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
				case 14:
					addMoreText('Friday');
				case 15:
					addMoreText('Night');
				case 16:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			skippedIntro = true;
		}
	}

	function colorTween(){
		if(!transitioning){
			if(titleText.color == titleTextColors[0])
				FlxTween.color(titleText, FlxG.random.float(0.8, 1.2), titleTextColors[0],  titleTextColors[1], {onComplete: (twn) -> {colorTween();}});
			else
				FlxTween.color(titleText, FlxG.random.float(0.8, 1.2), titleTextColors[1],  titleTextColors[0], {onComplete: (twn) -> {colorTween();}});
		}
		if(transitioning) titleText.color = FlxColor.WHITE;
	}
}
