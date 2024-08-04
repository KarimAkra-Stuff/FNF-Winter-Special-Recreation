package states.freeplay;

class DifficultyItem extends FlxSprite
{
    public var difficultyName:String = 'Unkown';
    public var targetAlpha:Float = 1;
    public var isSelected:Bool = false;

	public function new(x:Float, y:Float, difficultyName:String)
	{
        super(x, y);
        loadGraphic(Paths.image('freeplay/freeplay-difficulty-${difficultyName.toLowerCase()}'));
		antialiasing = ClientPrefs.data.antialiasing;
        this.difficultyName = difficultyName;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        if(isSelected)
            targetAlpha = 1;
        else 
            targetAlpha = 0;
        alpha = FlxMath.lerp(targetAlpha, alpha, Math.exp(-elapsed * 50));
	}
}