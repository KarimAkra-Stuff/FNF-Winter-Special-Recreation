package backend;

import mobile.backend.TouchFunctions;
import flixel.FlxState;
import mobile.states.CopyState;

class NewgroundsSplash extends FlxState {
	final nextState:Class<FlxState> = #if (mobile && MODS_ALLOWED) CopyState.checkExistingFiles() ? Main.game.initialState : CopyState #else Main.game.initialState #end;
    var ng:FlxSprite;

    override function create(){
        if(Main.game.skipSplash){
            FlxG.switchState(Type.createInstance(nextState, []));
            return;
        }
        ng = new FlxSprite();
        ng.alpha = 0.0001;
        ng.frames = Paths.getSparrowAtlas('NEWGROUNDS');
        ng.animation.addByIndices('land', 'ng full', [0, 1, 2, 3, 4], '', 24, false);
        ng.animation.addByIndices('move', 'ng full', [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23], '', 24);
        ng.animation.finishCallback = (name:String) -> {if(name == 'land') ng.animation.play('move', true);};
        ng.scale.set(0.5, 0.5);
        ng.updateHitbox();
        ng.screenCenter();
        add(ng);

        var black = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        black.alpha = 0;
        add(black);

        new FlxTimer().start(0.2, (tmr) -> {
            var sound:FlxSound;
            new FlxTimer().start(0.2, (tmrrr) -> sound = FlxG.sound.play(Paths.sound('newgrounds')));
            ng.alpha = 1;
            ng.animation.play('land');

            new FlxTimer().start(0.3, (tmrr) -> {
                FlxTween.tween(black, {alpha: 1}, sound.length / 1000,  {onComplete: (twn)->{
                    FlxG.switchState(Type.createInstance(nextState, []));
                    FlxG.bitmap.remove(ng.graphic);
                    ng.destroy();
                }});
            });
        });
        super.create();
    }

    override function update(elapsed:Float){
        super.update(elapsed);
        if(FlxG.keys.justPressed.ENTER #if android || FlxG.android.justPressed.BACK #end){
            FlxG.bitmap.remove(ng.graphic);
            ng.destroy();
            FlxG.switchState(Type.createInstance(nextState, []));
        }
    }
}