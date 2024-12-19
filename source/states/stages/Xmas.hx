package states.stages;

import shaders.RGBPalette;
import backend.BaseStage.Countdown;
import states.stages.objects.Snow;

@:access(states.PlayState)
class Xmas extends BaseStage
{
    public var sky:FlxSprite;
    public var mountainLeft:FlxSprite;
    public var mountainRight:FlxSprite;
    public var town:FlxSprite;
	public var floor:FlxSprite;
    public var backPeeps:FlxSprite;
    public var xmasTree:FlxSprite;
    public var xmasTreeLights:FlxSprite;
    public var leftTreeBGSh:FlxSprite;
    public var rightTreeBGSh:FlxSprite;
    public var leftTreeBG:FlxSprite;
    public var rightTreeBG:FlxSprite;
    public var candyCone:FlxSprite;
    public var segsShop:FlxSprite;
    public var meatBoy:FlxSprite;
    public var leftTree:FlxSprite;
    public var rightTree:FlxSprite;
    public var zone:FlxSprite; // ankha zone :pleading_face:
    public var cops:FlxSprite;
    public var deadLimos:FlxSprite;
    public var gift:FlxSprite;
    public var snow:Snow;
    public var snow2:Snow;
    public var vignette:FlxSprite;

    var treeRGBs:Array<Array<FlxColor>>  = 
	[[0x85ff59, 0x91c95f],
	[0xff9900, 0xfcc46f],
	[0x03a7ff, 0x60baeb],
	[0xf763df, 0xfc95ec],
	[0xf50707, 0xf26d6d]];
    var curLight:Int = -1;
    public var treeRGB:RGBPalette = new RGBPalette();

	override function create()
	{
        if(songName.toLowerCase() == 'eggnog')
            defaultCamZoom = .69;
        PlayState.instance.camZooming = true;
        
		sky = new FlxSprite(-2350, -2810).loadGraphic(Paths.image('xmas/skynight'));
        add(sky);

        mountainLeft = new FlxSprite(-2440, -1160).loadGraphic(Paths.image('xmas/mountain_left'));
        mountainLeft.scrollFactor.x = 0.4;
        add(mountainLeft);

        mountainRight = new FlxSprite(1100, -1160);
        mountainRight.frames = Paths.getSparrowAtlas('xmas/mountain_right');
        mountainRight.animation.addByPrefix('mountain outline', 'mountain glow', 24);
        mountainRight.animation.addByPrefix('mountain', 'mountain static');
        mountainRight.animation.play('mountain', true);
        mountainRight.scrollFactor.x = 0.5;
        add(mountainRight);

        town = new FlxSprite(-918, -684).loadGraphic(Paths.image('xmas/town_back'));
        town.scrollFactor.x = .6;
        add(town);

        leftTreeBGSh = new FlxSprite(-1250, -381).loadGraphic(Paths.image('xmas/tree_left_back_siluet'));
        add(leftTreeBGSh);

        floor = new FlxSprite(-1852, -262).loadGraphic(Paths.image("xmas/shops"));
        add(floor);

        if(PlayState.instance.songName.toLowerCase() == 'eggnog') {
            backPeeps = new FlxSprite(790);
            backPeeps.frames = Paths.getSparrowAtlas('xmas/people_back');
            backPeeps.animation.addByPrefix('idle', 'people back', 24);
            backPeeps.animation.play('idle');
            add(backPeeps);
        }

        xmasTree = new FlxSprite(454, -829).loadGraphic(Paths.image('xmas/xmas_tree'));
        add(xmasTree);
        xmasTreeLights = new FlxSprite(596, -612).loadGraphic(Paths.image('xmas/tree_glow_rgb'));
        xmasTreeLights.shader = treeRGB.shader;
        add(xmasTreeLights);
        treeRGBTween();

        leftTreeBG = new FlxSprite(-1660, -330).loadGraphic(Paths.image('xmas/tree_left_back'));
        add(leftTreeBG);
        rightTreeBGSh = new FlxSprite(2436, -680).loadGraphic(Paths.image('xmas/tree_right_back_siluet'));
        add(rightTreeBGSh);

        meatBoy = new FlxSprite(353, 243);
        meatBoy.frames = Paths.getSparrowAtlas('xmas/supermeatboy');
        meatBoy.animation.addByPrefix('hey', 'meatboy hey', 24, false);
        meatBoy.animation.addByPrefix('bop', 'meatboy idle', 24, false);
        meatBoy.animation.play('bop');
        add(meatBoy);

        zone = new FlxSprite(1441, -265);
        zone.frames = Paths.getSparrowAtlas('xmas/zone');
        zone.animation.addByPrefix('hey', 'ZONE HEY', 24, false);
        zone.animation.addByPrefix('bop', 'ZONE tan', 24, false);
        zone.animation.play('bop');
        add(zone);

        candyCone = new FlxSprite(2120, -600).loadGraphic(Paths.image('xmas/candy_back'));
        add(candyCone);

        segsShop = new FlxSprite(1720, -280);
        segsShop.frames = Paths.getSparrowAtlas('xmas/lmao_shop');
        segsShop.animation.addByPrefix('sexy', 'lmao shop glow', 24);
        segsShop.animation.addByPrefix('sex', 'lmao shop static');
        segsShop.animation.play('sex');
        add(segsShop);

        rightTreeBG = new FlxSprite(2380, -360).loadGraphic(Paths.image('xmas/tree_right_back'));
        add(rightTreeBG);

        cops = new FlxSprite(1750, -8);
        cops.frames = Paths.getSparrowAtlas('xmas/cops');
        cops.animation.addByPrefix('hey', 'cops hey', 24, false);
        cops.animation.addByPrefix('bop', 'cops idle', 24, false);
        cops.animation.play('bop');
        add(cops);
	}

    override function charactersPost() {
        rightTree = new FlxSprite(2533, -748).loadGraphic(Paths.image('xmas/tree_front_right_blur'));
        add(rightTree);
        rightTree.scrollFactor.x = 1.2;
        leftTree = new FlxSprite(-1733, -723).loadGraphic(Paths.image('xmas/tree_front_left_blur'));
        leftTree.scrollFactor.x = 1.2;
        add(leftTree);

        deadLimos = new FlxSprite(120, 670);
        deadLimos.frames = Paths.getSparrowAtlas('xmas/HENCHMAHS');
        deadLimos.animation.addByPrefix('no balls', 'henchmans fall', 24, false);
        deadLimos.animation.addByPrefix('rip :(', 'henchmans static', 24, false);
        deadLimos.animation.play('rip :(');
        add(deadLimos);

        gift = new FlxSprite(-16, 972).loadGraphic(Paths.image('xmas/gift'));
        add(gift);

        vignette = new FlxSprite(-1650, -1380).loadGraphic(Paths.image('xmas/vignette'));
        add(vignette);
    }
	
	override function createPost()
	{
        snow = new Snow(-1500.0, -1200.0, 9, 4);
        add(snow);
        snow2 = new Snow(-1500.0, -1200.0, 9, 4);
        add(snow2);
	}

	override function update(elapsed:Float)
	{

	}

	
	override function countdownTick(count:Countdown, num:Int)
	{
		switch(count)
		{
			case THREE: //num 0
			case TWO: //num 1
			case ONE: //num 2
			case GO: //num 3
			case START: //num 4
		}
	}

	// Steps, Beats and Sections:
	//    curStep, curDecStep
	//    curBeat, curDecBeat
	//    curSection
	override function stepHit()
	{
		// Code here
	}
	override function beatHit()
	{
		for(bopper in [zone, meatBoy, cops]){
            if(bopper.animation.curAnim.name != 'hey' || bopper.animation.curAnim.finished)
                bopper.animation.play('bop', true);
        }
	}
	override function sectionHit()
	{
		// Code here
	}

	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			//timer.active = true;
			//tween.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			//timer.active = false;
			//tween.active = false;
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "My Event":
            case "Blackscreen":
                var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
                black.alpha = 0;
                black.cameras = [camOther];
                add(black);
                FlxTween.tween(black, {alpha: 1}, flValue1, {ease: FlxEase.sineOut});
            case "eggnog ending":
                game.isCameraOnForcedPos = true;
                FlxTween.tween(game.camFollow, {x: 1200, y: -100}, 17, {ease: FlxEase.sineInOut});
            case "fireworks":
                new FlxTimer().start(1.2, function(tmr:FlxTimer) {
                    if(FlxG.random.bool(90))
                    {
                        var firework:FlxSprite = new FlxSprite(FlxG.random.int(-415, 1400), FlxG.random.int(-1200, -1700));
                        firework.frames = Paths.getSparrowAtlas('xmas/firework');
                        firework.animation.addByPrefix('explod', 'blow', 24, false);
                        firework.color = FlxG.random.getObject(treeRGBs)[0];
                        firework.animation.play('explod');
                        insert(game.members.indexOf(town) - 1, firework);
                        firework.animation.finishCallback = (name:String) -> {
                            firework.destroy();
                            remove(firework);
                        };
                    }
                }, FlxG.random.int(20, 25));
		}
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events that doesn't need different assets based on its values
		switch(event.event)
		{
			case "My Event":
				//precacheImage('myImage') //preloads images/myImage.png
				//precacheSound('mySound') //preloads sounds/mySound.ogg
				//precacheMusic('myMusic') //preloads music/myMusic.ogg
		}
	}
	override function eventPushedUnique(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events where its values affect what assets should be preloaded
		switch(event.event)
		{
			case "My Event":
				switch(event.value1)
				{
					// If value 1 is "blah blah", it will preload these assets:
					case 'blah blah':
						//precacheImage('myImageOne') //preloads images/myImageOne.png
						//precacheSound('mySoundOne') //preloads sounds/mySoundOne.ogg
						//precacheMusic('myMusicOne') //preloads music/myMusicOne.ogg

					// If value 1 is "coolswag", it will preload these assets:
					case 'coolswag':
						//precacheImage('myImageTwo') //preloads images/myImageTwo.png
						//precacheSound('mySoundTwo') //preloads sounds/mySoundTwo.ogg
						//precacheMusic('myMusicTwo') //preloads music/myMusicTwo.ogg
					
					// If value 1 is not "blah blah" or "coolswag", it will preload these assets:
					default:
						//precacheImage('myImageThree') //preloads images/myImageThree.png
						//precacheSound('mySoundThree') //preloads sounds/mySoundThree.ogg
						//precacheMusic('myMusicThree') //preloads music/myMusicThree.ogg
				}
		}
	}
	override function eventEarlyTrigger(event:objects.Note.EventNote):Float
	{
		// used for triggering an event few millieseconds earlier
		return switch(event.event)
		{
			case "fireworks": 1200;
            default: 0;
		}
	}

    function treeRGBTween(){
        var prevColor = treeRGBs[curLight == -1 ? 0 : curLight];
        var nextColorIndex = FlxG.random.int(0, treeRGBs.length-1, curLight == -1 ? null : [curLight]);
        var nextColor = treeRGBs[nextColorIndex];
        var duration = FlxG.random.float(0.3, 0.8);
        var tweens = [null, null];
        tweens[0] = FlxTween.color(null, duration, prevColor[0], nextColor[0], {onUpdate: (twn) -> treeRGB.r = tweens[0].color});
        tweens[1] = FlxTween.color(null, duration, prevColor[1], nextColor[1], {onUpdate: (twn) -> treeRGB.g = tweens[1].color, onComplete: (twn) -> treeRGBTween()});
        curLight = nextColorIndex;
    }
}