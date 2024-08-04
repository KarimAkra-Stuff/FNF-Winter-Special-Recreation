package states.freeplay;

import backend.Song;
import backend.WeekData;
import backend.Highscore;
import backend.Difficulty;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import shaders.ColorInvert;

using flixel.util.FlxArrayUtil;

class FreeplayState extends MusicBeatState
{
	public var bg:FlxSprite = new FlxSprite(64, 36);
	public var peeps:FlxSprite = new FlxSprite(-320.5, -4);
	public var lovers:FlxSprite = new FlxSprite(191, -125);

	public var songText:FlxSprite = new FlxSprite(157, 9);
	public var songName:Alphabet;

	public var rankTxt:FlxSprite;
	public var ranks:FlxTypedSpriteGroup<RankLetter> = new FlxTypedSpriteGroup<RankLetter>();

	public var difficulty:FlxSprite;
	public var difficulties:FlxTypedSpriteGroup<DifficultyItem> = new FlxTypedSpriteGroup<DifficultyItem>();
	public var addedDifficulties:Array<String> = [];

	public var score:FlxSprite;
	public var scoreTxt:Alphabet;
	public var lerpScore:Int = 0;
	public var intendedScore:Int = 0;

	public var misses:FlxSprite;
	public var missesTxt:Alphabet;
	public var lerpMisses:Int = 0;
	public var intendedMisses:Int = 0;

	public var combo:FlxSprite;
	public var comboTxt:Alphabet;
	public var lerpCombo:Int = 0;
	public var intendedCombo:Int = 0;

	public var gameGroup:FlxSpriteGroup = new FlxSpriteGroup();
	public var songsGrp:FlxTypedSpriteGroup<FreeplayItem> = new FlxTypedSpriteGroup<FreeplayItem>();
	public var arrowsGrp:FlxSpriteGroup = new FlxSpriteGroup();
	public var hudGrp:FlxSpriteGroup = new FlxSpriteGroup();

	public var songs:Array<SongMeta> = [];

	public var curOption:Int = 0;

	private static var lastDifficultyName:String = Difficulty.getDefault();

	public var curDifficulty:Int = 1;
	public var constScale:Float = 0.6667;
	public var colorInvert:ColorInvert = new ColorInvert();

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	override function create()
	{
		WeekData.reloadWeekFiles(false);
		for (num => week in WeekData.weeksList)
		{
			var leWeek:WeekData = WeekData.weeksLoaded.get(week);
			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var metadata:SongMeta = {
					songName: song[0],
					week: num,
					songCharacter: song[1],
					lastDifficulty: null
				}
				songs.push(metadata);
			}
		}

		curDifficulty = Std.int(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));
		Conductor.bpm = 102;

		// cameras? nah that's bullshit we use sprite groups!!!!
		add(gameGroup);
		add(songsGrp);
		add(hudGrp);
		add(arrowsGrp);
		hudGrp.add(difficulties);
		hudGrp.add(ranks);

		var posShit:Array<Float> = [115, 468];
		for (i in 0...2)
		{
			var arrow:FlxSprite = new FlxSprite(posShit[i], 190, Paths.image('freeplay/leftArrow'));
			arrow.flipX = i == 1;
			arrowsGrp.add(arrow);
		}

		for (i => songMetadata in songs)
		{
			var songItem:FreeplayItem = new FreeplayItem(240, 154, songMetadata.songCharacter, songMetadata.songName);
			songItem.targetX = i;
			songItem.scale.set(constScale, constScale);
			songItem.updateHitbox();
			songsGrp.add(songItem);
		}

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);

		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		addVirtualPad('LEFT_FULL', 'A_B');

		bg.loadGraphic(Paths.image('freeplay/freeplay stage bg'));
		bg.scale.set(constScale, constScale);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		gameGroup.add(bg);

		peeps.frames = Paths.getSparrowAtlas('freeplay/crowd');
		peeps.animation.addByPrefix('idle', 'crowd', 24, true);
		peeps.animation.play('idle');
		peeps.scale.set(constScale, constScale);
		peeps.antialiasing = ClientPrefs.data.antialiasing;
		gameGroup.add(peeps);

		lovers.frames = Paths.getSparrowAtlas('freeplay/goobers');
		lovers.animation.addByPrefix('bop', 'idle', 24, false);
		lovers.animation.addByPrefix('hey', 'confirm', 24, false);
		lovers.animation.play('bop', true);
		lovers.scale.set(constScale, constScale);
		lovers.antialiasing = ClientPrefs.data.antialiasing;
		gameGroup.add(lovers);

		songText.loadGraphic(Paths.image('freeplay/song'));
		songText.scale.set(constScale, constScale);
		songText.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(songText);

		songName = new Alphabet(480, 9, '', false);
		songName.setScale(.8, .8);
		songName.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(songName);

		rankTxt = new FlxSprite(6, 379).loadGraphic(Paths.image('freeplay/rank'));
		rankTxt.scale.set(constScale, constScale);
		rankTxt.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(rankTxt);

		for (rankLetter in Highscore.ratingsLetters)
		{
			if (rankLetter == '?')
				rankLetter = 'none';
			var rank = new RankLetter(269, 369, rankLetter);
			rank.scale.set(constScale, constScale);
			rank.antialiasing = ClientPrefs.data.antialiasing;
			ranks.add(rank);
		}

		difficulty = new FlxSprite(45, 462);
		difficulty.scale.set(.75, .75);
		difficulty.frames = Paths.getSparrowAtlas('freeplay/statistika-assets');
		difficulty.animation.addByPrefix('bop', 'difficulty', 24, false);
		difficulty.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(difficulty);

		score = new FlxSprite(36, 518);
		score.frames = difficulty.frames;
		score.scale.set(.66, .66);
		score.animation.addByPrefix('bop', 'score', 24, false);
		score.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(score);

		scoreTxt = new Alphabet(213, 550, '', true);
		scoreTxt.setScale(.5);
		scoreTxt.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(scoreTxt);

		misses = new FlxSprite(35, 575);
		misses.frames = difficulty.frames;
		misses.scale.set(.65, .65);
		misses.animation.addByPrefix('bop', 'misses', 24, false);
		misses.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(misses);

		missesTxt = new Alphabet(213, 606, '', true);
		missesTxt.setScale(.5);
		hudGrp.add(missesTxt);

		combo = new FlxSprite(37, 631);
		combo.frames = difficulty.frames;
		combo.scale.set(.667, .667);
		combo.animation.addByPrefix('bop', 'combo', 24, false);
		combo.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(combo);

		comboTxt = new Alphabet(213, 659, '', true);
		comboTxt.setScale(.5);
		comboTxt.antialiasing = ClientPrefs.data.antialiasing;
		hudGrp.add(comboTxt);

		changeSong();
	}

	var holdTime:Float = 0;
	var leftTween:FlxTween = null;
	var rightTween:FlxTween = null;
	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (controls.UI_LEFT_P && !transitioning)
		{
			holdTime = 0;
			changeSong(-1);
			var arrow:FlxSprite = arrowsGrp.members[0];
			if (leftTween != null)
				leftTween.cancel();
			arrow.scale.set(.7, .7);
			leftTween = FlxTween.tween(arrow.scale, {x: 1, y: 1}, .2, {onComplete: (twn) -> leftTween = null});
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if (controls.UI_RIGHT_P && !transitioning)
		{
			holdTime = 0;
			changeSong(1);
			var arrow:FlxSprite = arrowsGrp.members[1];
			if (rightTween != null)
				rightTween.cancel();
			arrow.scale.set(.7, .7);
			rightTween = FlxTween.tween(arrow.scale, {x: 1, y: 1}, .2, {onComplete: (twn) -> rightTween = null});
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		if ((controls.UI_LEFT || controls.UI_RIGHT) && !transitioning)
		{
			var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
			holdTime += elapsed;
			var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

			if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				changeSong((checkNewHold - checkLastHold) * (controls.UI_LEFT ? -1 : 1));
		}
		if (!transitioning)
		{
			if (controls.UI_UP_P)
				changeDiff(-1);
			else if (controls.UI_DOWN_P)
				changeDiff(1);
		}

		if (controls.BACK && !transitioning)
		{
			transitioning = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT && !transitioning)
		{
			var songLowercase:String = Paths.formatToSongPath(songs[curOption].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			}
			catch (e:Dynamic)
			{
				// Hnadle missing chart
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if (errorStr.startsWith('[lime.utils.Assets] ERROR:'))
					errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length - 1);

				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				super.update(elapsed);
				return;
			}
			transitioning = true;
			lovers.animation.play('hey', true);
			var sound = FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.camera.flash(FlxColor.WHITE, (sound.length / 1000) - 0.8);
			FlxG.sound.music.stop();
			songsGrp.forEachAlive((songObj:FreeplayItem) ->
			{
				songObj.visible = false;
				if (songsGrp.members.indexOf(songObj) == curOption)
				{
					songObj.visible = true;
					FlxFlicker.flicker(songObj, (sound.length / 1000) - 0.4, .06, true, true, (flck:FlxFlicker) ->
					{
						LoadingState.prepareToSong();
						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
			});
		}

		if (FlxG.sound.music != null && !transitioning)
			Conductor.songPosition = FlxG.sound.music.time;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		scoreTxt.text = '' + lerpScore;

		lerpMisses = Std.int(FlxMath.lerp(intendedMisses, lerpMisses, Math.exp(-elapsed * 24)));
		if (Math.abs(lerpMisses - intendedMisses) <= 5)
			lerpMisses = intendedMisses;
		missesTxt.text = '' + lerpMisses;

		lerpCombo = Std.int(FlxMath.lerp(intendedCombo, lerpCombo, Math.exp(-elapsed * 24)));
		if (Math.abs(lerpCombo - intendedCombo) <= 5)
			lerpCombo = intendedCombo;
		comboTxt.text = '' + lerpCombo;

		super.update(elapsed);
	}

	override function beatHit()
	{
		if (lovers != null && !transitioning)
			lovers.animation.play('bop', true);
		super.beatHit();
	}

	public function changeSong(change:Int = 0)
	{
		curOption += change;

		if (curOption >= songsGrp.members.length)
			curOption = 0;
		if (curOption < 0)
			curOption = songsGrp.members.length - 1;

		for (num => item in songsGrp.members)
		{
			item.targetX = (num - curOption);
			if (songsGrp.members.indexOf(item) == curOption)
			{
				item.nextX = (item.targetX + 1) * (FreeplayItem.seperator + item.mainX);
				item.targetAlpha = 1;
				item.targetScale = constScale;
				songName.text = item.song;
				songName.forEachAlive((letter) ->
				{
					letter.shader = colorInvert;
				});
			}
			else if (songsGrp.members.indexOf(item) > curOption)
			{
				item.nextX = (item.targetX + 1) * (FreeplayItem.seperator + item.mainX) - 35;
				item.targetAlpha = .55;
				item.targetScale = .55;
				// i give up on this :/
				// item.targetAlpha = (item.targetX - 1) - FlxMath.bound(shitVal * Math.abs(item.targetX), 0.2, 0.6);
				// item.targetScale = item.targetX - FlxMath.bound(shitVal * Math.abs(item.targetX), 0.3, 0.55);
			}
			else
			{
				item.targetAlpha = .55;
				item.targetScale = .55;
				item.nextX = (item.targetX + 1) * (FreeplayItem.seperator + item.mainX) + 35;
				// item.targetAlpha = (item.targetX - 1) - FlxMath.bound(shitVal * Math.abs(item.targetX), 0.2, 0.6);
				// item.targetScale = (item.targetX - 1) - FlxMath.bound(shitVal * Math.abs(item.targetX), 0.3, 0.55);
			}
			item.isSelected = songsGrp.members.indexOf(item) == curOption;

			var savedDiff:String = songs[curOption].lastDifficulty;
			var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
			if (savedDiff != null && !Difficulty.list.contains(savedDiff) && Difficulty.list.contains(savedDiff))
				curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
			else if (lastDiff > -1)
				curDifficulty = lastDiff;
			else if (Difficulty.list.contains(Difficulty.getDefault()))
				curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
			else
				curDifficulty = 0;
			changeDiff();
		}
	}

	function changeDiff(change:Int = 0)
	{
		Difficulty.loadFromWeek();
		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, Difficulty.list.length - 1);

		lastDifficultyName = Difficulty.getString(curDifficulty);
		// if the array is empty, create a new DifficultyItem object
		if (addedDifficulties.last() == null)
		{
			var diffItem:DifficultyItem = new DifficultyItem(225, 472, lastDifficultyName);
			diffItem.scale.set(.56, .56);
			difficulties.add(diffItem);
			addedDifficulties.push(lastDifficultyName);
			diffItem.isSelected = true;
		}
		else
		{
			difficulties.forEachAlive((diffObject:DifficultyItem) ->
			{
				if (!addedDifficulties.contains(lastDifficultyName))
				{
					var diffItem:DifficultyItem = new DifficultyItem(225, 472, lastDifficultyName);
					diffItem.scale.set(.56, .56);
					diffItem.isSelected = true;
					difficulties.add(diffItem);
					addedDifficulties.push(lastDifficultyName);
				}
				diffObject.isSelected = diffObject.difficultyName == lastDifficultyName;
			});
		}
		difficulty.animation.play('bop', true);
		songs[curOption].lastDifficulty = Difficulty.getString(curDifficulty);

		missingText.visible = false;
		missingTextBG.visible = false;
		reloadScore();
	}

	public function reloadScore()
	{
		var scoreData = Highscore.getSongData(songs[curOption].songName, curDifficulty);

		RankLetter.curLetter = scoreData.ratingLetter;
		intendedScore = scoreData.score;
		intendedMisses = Std.int(scoreData.misses);
		intendedCombo = scoreData.combo;

		for (obj in [score, misses, combo])
			obj.animation.play('bop', true);
		/*
        if(rank != null){
				rank.destroy();
				if(hudGrp.members.contains(rank))
					hudGrp.remove(rank);
			}
			var rankPerfix = '';
			rank = new FlxSprite(269, 369).loadGraphic(Paths.image('freeplay/rank $rankPerfix'));
			rank.scale.set(constScale, constScale);
			hudGrp.add(rank);
        */
	}
}

// why does psych use a class for song meta data and not a simple typedef? guh...
typedef SongMeta =
{
	var week:Int;
	var songName:String;
	var songCharacter:String;
	var lastDifficulty:String;
}
