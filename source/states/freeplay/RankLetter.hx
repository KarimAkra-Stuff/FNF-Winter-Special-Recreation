package states.freeplay;

class RankLetter extends FlxSprite
{
    public static var curLetter(default, set):String = 'none';
    public var letter(default, null):String = 'none';
    public var targetAlpha:Float = 1;

	public function new(x:Float, y:Float, letter:String)
	{
        super(x, y);
        switch(letter){
            case '?':
                letter = 'none';
            default:
                letter = letter.toLowerCase();
        }
        this.letter = letter;
        loadGraphic(Paths.image('freeplay/rank $letter'));
		antialiasing = ClientPrefs.data.antialiasing;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        targetAlpha = curLetter == letter ? 1 : 0;
        alpha = FlxMath.lerp(targetAlpha, alpha, Math.exp(-elapsed * 50));
	}

    private static function set_curLetter(Value:String){
        switch(Value){
            case '?':
                Value = 'none';
            default:
                Value = Value.toLowerCase();
        }
        return curLetter = Value;
    }
}