import flixel.tweens.FlxTween;

// by Redar13
// Rolus has an attack animation, so I added that here too.
var dodgeBF:FlxSprite;
var attackOpponent:FlxSprite;
var warnDodgeSpr:FlxSprite;
var dodgeTime:Float = -999*300;
var _timerValidToDodge:FlxTimer = new FlxTimer();
var _timerDodge:FlxTimer = new FlxTimer();
var canDodge:Bool = false;
var isDodge:Bool = false;
var balls;
var arrayOfTweenBalls:Array<FlxTween> = [];
final antialias = ClientPrefs.data.antialiasing;
Paths.sound("gunshot1"); Paths.sound("gunshot2"); Paths.sound("gunshot3"); Paths.sound("gunshot4"); Paths.sound("warningdodge"); Paths.sound("pressdodge");
function onCreatePost() {
	warnDodgeSpr = new FlxSprite();
	warnDodgeSpr.frames = Paths.getSparrowAtlas('dodge_warning');
	warnDodgeSpr.animation.addByPrefix('first', 'warn first', 24);
	warnDodgeSpr.animation.addByPrefix('end', 'warn end', 24, false);
	warnDodgeSpr.animation.getByName('first').loopPoint = 7;
	warnDodgeSpr.animation.finishCallback = (anim) -> if (anim == 'end'){
		warnDodgeSpr.visible = false;
	}
	warnDodgeSpr.screenCenter(0x11);
	warnDodgeSpr.moves = false;
	warnDodgeSpr.scale.set(0.7, 0.7);
	if (ClientPrefs.data.middleScroll) warnDodgeSpr.x += FlxG.height / 2;
	warnDodgeSpr.y += (ClientPrefs.data.downScroll ? -1 : 1) * FlxG.height / 8;
	warnDodgeSpr.cameras = [camHUD];
	add(warnDodgeSpr);
	warnDodgeSpr.visible = false;
	warnDodgeSpr.antialiasing = antialias;
	
	dodgeBF = new FlxSprite(boyfriend.x, boyfriend.y);
	dodgeBF.frames = boyfriend.frames;
	dodgeBF.animation.copyFrom(boyfriend.animation);
	dodgeBF.offset.set(30, -2);
	dodgeBF.color = boyfriend.color;
	if (boyfriend.animOffsets.exists('dodge')){
		final e = boyfriend.animOffsets.get('dodge');
		dodgeBF.offset.set(e[0], e[1]);
	}
	dodgeBF.animation.finishCallback = (anim) -> if (dodgeBF.visible){
		isDodge = false;
		dodgeBF.visible = false;
		boyfriend.visible = true;
	}
	dodgeBF.visible = false;
	dodgeBF.antialiasing = boyfriend.antialiasing;
	game.addBehindBF(dodgeBF);

	attackOpponent = new FlxSprite(dad.x, dad.y);
	attackOpponent.frames = dad.frames;
	attackOpponent.antialiasing = dad.antialiasing;
	attackOpponent.animation.copyFrom(dad.animation);
	if (dad.animOffsets.exists('shoot')){
		final e = dad.animOffsets.get('shoot');
		attackOpponent.offset.set(e[0], e[1]);
	}
	attackOpponent.color = dad.color;
	attackOpponent.animation.finishCallback = (anim) -> if (attackOpponent.visible){
		attackOpponent.visible = false;
		dad.visible = true;
	}
	attackOpponent.visible = false;
	game.addBehindDad(attackOpponent);
	balls = game.stages[0].balls; // 🥎🥎🥎🥎
	balls.forEach((spr) -> spr.origin.y = 10);
	return Function_Continue;
}
function onUpdatePost(e) {
	if (canDodge && FlxG.keys.justPressed.SPACE && !isDodge){
		FlxG.sound.play(Paths.sound('pressdodge'), 0.5);
		isDodge = true;
		dodgeBF.animation.play('dodge', true);
		dodgeBF.visible = true;
		boyfriend.visible = false;
	}
	return Function_Continue;
}
function onEvent(eventName:String, value1:String, value2:String, ?strumTime:Float) {
	if (eventName == 'Dodge Event') {
		if (warnDodgeSpr.visible || dodgeBF.visible || attackOpponent.visible) 
			return Function_Continue;
		var flValue1:Null<Float> = Std.parseFloat(value1);
		if (Math.isNaN(flValue1)) flValue1 = 2;
		dodgeTime = strumTime + Conductor.crochet * flValue1;
		canDodge = true;
		warnDodgeSpr.visible = true;
		warnDodgeSpr.animation.play('first', true);
		FlxG.sound.play(Paths.sound('warningdodge'), 0.5);
		warnDodgeSpr.centerOffsets();
		warnDodgeSpr.centerOrigin();
		_timerValidToDodge.cancel();
		_timerValidToDodge.start(Math.max(1, Conductor.crochet * flValue1 / 1000) / playbackRate, (_) -> {
			canDodge = false;
			_timerDodge.cancel();
			_timerDodge.start(0.02 / playbackRate, (_) -> {
				warnDodgeSpr.animation.play('end', true);
				warnDodgeSpr.centerOffsets();
				warnDodgeSpr.centerOrigin();
				attackOpponent.animation.play('shoot', true);
				FlxG.sound.play(Paths.sound("gunshot" + FlxG.random.int(1, 4)), 0.6);
				attackOpponent.visible = true;
				dad.visible = false;

				// 💀
				var i:Int=0;
				balls.forEach((spr) -> {
					var index = i;
					var deTween = arrayOfTweenBalls[index];
					if (deTween != null){ deTween.active = false; deTween.destroy();}
					arrayOfTweenBalls[i] = FlxTween.num(spr.angle, spr.angle + FlxG.random.int(7, 12) * FlxG.random.sign(), 0.13, {
						onComplete: (_) -> {
							var deTween = arrayOfTweenBalls[index];
							if (deTween != null && deTween.finished){
								final ELASTIC_PERIOD:Float = Math.abs(spr.angle / FlxG.random.int(40, 75));
								arrayOfTweenBalls[index] = FlxTween.num(spr.angle, 0, Math.pow(1.2/ELASTIC_PERIOD, 0.7), {
									ease: (t) -> return (Math.pow(2,
										-10 * t) * Math.sin((t - (ELASTIC_PERIOD / (2 * Math.PI))) * (2 * Math.PI) / ELASTIC_PERIOD)
										+ 1)
								}, spr.set_angle);
							}
						}
					}, spr.set_angle);
					i++;
				});

				FlxG.camera.shake(0.01, 0.15);
				game.camHUD.shake(0.005, 0.15);
				if (!dodgeBF.visible){
					// FlxG.sound.play(Paths.soundRandom('badnoise', 1, 3), 1.2);
					boyfriend.playAnim('hit');
					boyfriend.specialAnim = true;
					game.health -= 0.8;
				}
			});
		});
	}
	return Function_Continue;
}
/*
function onBeatHit() {
	if (FlxG.random.bool(20)){
		onEvent('Dodge Event', '', '', Conductor.songPosition);
	}
	return Function_Continue;
}
*/