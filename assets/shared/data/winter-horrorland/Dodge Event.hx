// by Redar13
import backend.Achievements;

var dodgeBF:FlxSprite;
var attackOpponent:FlxSprite;
var warnDodgeSpr:FlxSprite;
var dodgeTime:Float = -999*300;
var _timerValidToDodge:FlxTimer = new FlxTimer();
var _timerDodge:FlxTimer = new FlxTimer();
var canDodge:Bool = false;
var isDodge:Bool = false;
final antialias = ClientPrefs.data.antialiasing;
Paths.getSparrowAtlas('xmas-horror/slime');
for(i in 0...3) Paths.sound("splat" + i);
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
	attackOpponent.animation.copyFrom(dad.animation);
	attackOpponent.antialiasing = dad.antialiasing;
	if (dad.animOffsets.exists('attack')){
		final e = dad.animOffsets.get('attack');
		attackOpponent.offset.set(e[0], e[1]);
	}
	attackOpponent.color = dad.color;
	attackOpponent.animation.finishCallback = (anim) -> if (attackOpponent.visible){
		attackOpponent.visible = false;
		dad.visible = true;
	}
	attackOpponent.visible = false;
	game.addBehindDad(attackOpponent);
	return Function_Continue;
}
function onUpdatePost(e) {
	if (canDodge && FlxG.keys.justPressed.SPACE && !isDodge){
		FlxG.sound.play(Paths.sound('pressdodge'), 0.7);
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
		FlxG.sound.play(Paths.sound('warningdodge'), 0.7);
		warnDodgeSpr.centerOffsets();
		warnDodgeSpr.centerOrigin();
		_timerValidToDodge.cancel();
		_timerValidToDodge.start(Math.max(1, Conductor.crochet * flValue1 / 1000) / playbackRate, (_) -> {
			canDodge = false;
			_timerDodge.cancel();
			_timerDodge.start(0.05 / playbackRate, (_) -> {
				warnDodgeSpr.animation.play('end', true);
				warnDodgeSpr.centerOffsets();
				warnDodgeSpr.centerOrigin();
				attackOpponent.animation.play('attack', true);
				attackOpponent.visible = true;
				dad.visible = false;
				if (!dodgeBF.visible){
					boyfriend.playAnim('hit');
					boyfriend.specialAnim = true;

					// лютый рандом
					var slime:FlxSprite = new FlxSprite();
					slime.frames = Paths.getSparrowAtlas('xmas-horror/slime');
					slime.animation.addByPrefix('slime', 'slime on screen0', 24);
					slime.animation.play('slime');
					slime.animation.curAnim.loopPoint = 4;
					slime.screenCenter(0x11);
					slime.scale.x = slime.scale.y = FlxG.random.float(0.75, 1.1);
					final factorPos:Float = 0.4;
					slime.x += FlxG.random.float(-0.3, 1) * FlxG.width * factorPos	/ slime.scale.x;
					slime.y += FlxG.random.float(-1, 1) * FlxG.height * factorPos	/ slime.scale.y;
					slime.antialiasing = antialias;
					uiGroup.add(slime);
					slime.angle = FlxG.random.int(-5, 5);
					slime.flipX = FlxG.random.bool();
					FlxTween.tween(slime.scale, {x: slime.scale.x + FlxG.random.float(-0.1, 0.2), y: slime.scale.y + FlxG.random.float(-0.1, 0.2)}, 0.25 / playbackRate, {type: 16, ease: FlxEase.elasticOut});
					
					FlxTween.num(1, 0, FlxG.random.float(3, 5.5) / playbackRate, {
						startDelay: FlxG.random.float(7, 10) * playbackRate,
						ease: FlxEase.quintOut,
						onStart:(_) -> {
							slime.velocity.set(FlxG.random.int(-20, 20) * playbackRate, FlxG.random.int(15, 50) * playbackRate);
							slime.acceleration.y = FlxG.random.int(50, 110) * playbackRate * playbackRate;
							slime.angularVelocity = slime.velocity.x / 80 * playbackRate;
						},
						onComplete:(_) -> {
							slime.destroy();
							uiGroup.remove(slime, true);
						}
					}, (num) -> {
						slime.alpha = num;
						slime.scale.y += slime.velocity.y / 700 * FlxG.elapsed;
					});
					FlxG.sound.play(Paths.soundRandom('badnoise', 1, 3), 0.9);
					// if (!ClientPrefs.data.middleScroll) slime.x += FlxG.height / 2;
					game.health -= FlxMath.roundDecimal(slime.scale.x / 6, 2);
					FlxG.sound.play(Paths.sound("splat" + FlxG.random.int(0, 2)), 0.6);
					Achievements.unlock("milk");
				}
			});
		});
	}
	return Function_Continue;
}
/*
function onStepHit() {
	switch (curStep) 
	{
		case 1: onEvent('Dodge Event', '', '', Conductor.songPosition);
	}
	return Function_Continue;
}
*/