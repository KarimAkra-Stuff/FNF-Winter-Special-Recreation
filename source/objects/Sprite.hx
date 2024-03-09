package objects;

class Sprite extends FlxSprite {
    public var animOffsets:Map<String, Array<Float>> = new Map<String, Array<Float>>();
    public var defaultOffset:Array<Float> = [0, 0];
	public function new(?x:Float = 0, ?y:Float = 0)
	{
        antialiasing = ClientPrefs.data.antialiasing;
		super(x, y);
	}

	public function playAnim(name:String, forced:Bool = false, ?reverse:Bool = false, ?startFrame:Int = 0)
	{
		animation.play(name, forced, reverse, startFrame);
		
		var daOffset:Array<Float> = animOffsets.exists(name) ? animOffsets.get(name) : defaultOffset;
		offset.set(daOffset[0], daOffset[1]);
	}

	public function addAnimationByPrefix(name:String, prefix:String, fps:Float = 24.0, loop:Bool = false, x:Float = 0, y:Float = 0)
	{
        animation.addByPrefix(name, prefix, fps, loop);
		animOffsets.set(name, [x, y]);
	}

    public function setAnimationOffset(name:String, x:Float, y:Float)
    {
		animOffsets.set(name, [x, y]);
    }
}