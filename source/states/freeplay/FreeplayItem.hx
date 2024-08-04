package states.freeplay;

class FreeplayItem extends FlxSprite
{
    public var song:String = '';
	public var targetX:Float = 0;
    public var targetScale:Float = 0.55;
    public var targetAlpha:Float = 0.6;
    public var mainX:Float = 0;
    public var nextX:Float = 0;
    public var isSelected:Bool = false;

    public static var seperator:Float = 1;

	public function new(x:Float, y:Float, perfix:String, song:String)
	{
        super(x, y);
        mainX = nextX = x;
        frames = Paths.getSparrowAtlas('freeplay/song-icons');

        var animFrames = [];
		@:privateAccess
		animation.findByPrefix(animFrames, '$perfix-static');
		if(animFrames.length < 1) perfix = 'none';

        animation.addByPrefix('static', '$perfix-static');
        animation.addByPrefix('select', '$perfix-select');
        this.song = song;
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		x = FlxMath.lerp((targetX * seperator) + nextX, x, Math.exp(-elapsed * 10.2));
        if(isSelected){
            scale.x = scale.y = FlxMath.lerp(0.6667, scale.x, Math.exp(-elapsed * 10.2));
            animation.play('select', true);
            alpha = 1;
        } else {
            animation.play('static', true);
            scale.x = scale.y = FlxMath.lerp(targetScale, scale.x, Math.exp(-elapsed * 10.2));
            alpha = targetAlpha;
            // this ain't working :(
            // scale.x = scale.y = FlxMath.lerp(FlxMath.bound((Math.abs(targetX + 1) / 10), .2, .58), scale.x, Math.exp(-elapsed * 10.2));
            // alpha = FlxMath.bound((Math.abs(targetX + 1) / 10), 0.2, 0.8);
        }
	}
}