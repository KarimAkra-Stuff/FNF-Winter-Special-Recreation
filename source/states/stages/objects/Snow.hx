package states.stages.objects;

import haxe.ds.Map;


// shit kinda sucks but idk a better way to do it
// not my fault they didn't use FlxParticle
class Snow extends FlxSpriteGroup
{
	public var snows1:Array<FlxSprite> = [];
	public var snows2:Array<FlxSprite> = [];

    public var defaultStartX(default, null):Float;
    public var defaultStartY(default, null):Float;
    public var defaultLayers(default, null):Int;
    public var defaultLayerLength(default, null):Int;

    private var snowMap:Map<Int, Array<Dynamic>> = new Map();
    private var posMap:Map<Int, Array<Float>> = new Map();

	public function new(startX:Float, startY:Float, layers:Int, layerLength:Int)
	{
		super(0, 0, layerLength * layers);
        defaultStartX = startX;
        defaultStartY = startY;
        defaultLayers = layers;
        defaultLayerLength = layerLength;
		generateSnow(startX, startY, layers, layerLength);
	}

	override function update(elapsed:Float)
	{
        forEachAlive((snow:FlxSprite) -> {
            if(snow.animation.curAnim.finished){
                if(FlxG.random.bool(20))
                    FlxG.random.resetInitialSeed();
                if(FlxG.random.bool())
                    snow.animation.play('normal', false, snow.animation.curAnim.name == 'normal' ? false : FlxG.random.bool(25), FlxG.random.bool(30) ? FlxG.random.int(0, snow.animation.getByName('normal').frames.length) : 0);
                else
                    snow.animation.play('blur', false, snow.animation.curAnim.name == 'blur' ? false : FlxG.random.bool(25), FlxG.random.bool(10) ? FlxG.random.int(0, snow.animation.getByName('blur').frames.length) : 0);
                FlxTween.tween(snow, {alpha: FlxG.random.float(0.2, 0.8, [snow.alpha])}, FlxG.random.float(0.8, 2.2), {ease: FlxG.random.bool(80) ? FlxEase.sineInOut : FlxEase.expoOut});
            }
            if(FlxG.random.bool(10))
                posMap.set(snow.ID, [
                FlxMath.bound(snow.x + FlxG.random.float(-80, 100), snowMap.get(snow.ID)[0], snowMap.get(snow.ID)[0] + 100),
                FlxMath.bound(snow.y + FlxG.random.float(-50, 40), snowMap.get(snow.ID)[1], snowMap.get(snow.ID)[1] - 50)
            ]);
            if(posMap.exists(snow.ID)){
                snow.x = FlxMath.lerp(posMap.get(snow.ID)[0], snow.x, Math.exp(-elapsed * FlxG.random.int(-5, 10) * PlayState.instance.playbackRate));
                snow.y = FlxMath.lerp(posMap.get(snow.ID)[1], snow.y, Math.exp(-elapsed * FlxG.random.int(-5, 10) * PlayState.instance.playbackRate));
            }
        });
        if(FlxG.random.bool(.02))
            resetSnow();
		super.update(elapsed);
	}

    private function generateSnow(startX:Float, startY:Float, layers:Int, layerLength:Int){
        snows1 = [];
        snows2 = [];
        FlxG.log.notice('generated snow!');
        var curX = startX;
		var curY = startY;
        for(layer in 0...layers){
            for(curLayerIndex in 0...layerLength){
                var snow1 = new FlxSprite(curX, curY);
                snow1.frames = Paths.getSparrowAtlas('snow1');
                snow1.animation.addByPrefix('normal', 'snowfall1 normal', 24, false);
                snow1.animation.addByPrefix('blur', 'snowfall1 blur', 24, false);
                snow1.animation.play('normal', false);
                snow1.scale.x = snow1.scale.y = FlxG.random.float(2.5, 4);
                snow1.updateHitbox();
                snow1.alpha = FlxG.random.float(0.4, 0.8);
                snow1.color = 0x9FA4D2;
                snowMap.set(snow1.ID, [snow1.x, snow1.y, snow1.alpha]);
                snows1.push(snow1);
                add(snow1);
    
                var snow2 = new FlxSprite(curX, curY);
                snow2.frames = Paths.getSparrowAtlas('snow2');
                snow2.animation.addByPrefix('normal', 'snowfall2 normal', 24, false);
                snow2.animation.addByPrefix('blur', 'snowfall2 blur', 24, false);
                snow2.animation.play('normal', false);
                snow2.scale.x = snow2.scale.y = FlxG.random.float(2.5, 4);
                snow2.updateHitbox();
                snow2.alpha = FlxG.random.float(0.4, 0.8);
                snow2.color = 0x9FA4D2;
                snowMap.set(snow2.ID, [snow2.x, snow2.y, snow2.alpha]);
                snows2.push(snow2);
                add(snow2);

                curX += Math.max(snow1.width, snow2.width);   
                if(curLayerIndex == layerLength-1){
                    curX = startX;
                    curY += Math.max(snows1[snows1.length-1].height, snows2[snows2.length-1].height); 
                } 
            }
        }
    }

    private function resetSnow() {
        FlxG.log.notice('reseted snow!');
        forEachAlive((snow) -> {
            if(snowMap.exists(snow.ID)){
                var data = snowMap.get(snow.ID);
                posMap.set(snow.ID, [data[0], data[1]]);
                snow.alpha = data[2];
            }
        });
    }
}