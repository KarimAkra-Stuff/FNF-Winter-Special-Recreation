package backend;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import openfl.text.AntiAliasType;
import openfl.text.GridFitType;
#end

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 */
class SoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 80;

	var _defaultScale:Float = 2.0;

	/**The sound used when increasing the volume.**/
	public var volumeUpSound:String = "flixel/sounds/beep";

	/**The sound used when decreasing the volume.**/
	public var volumeDownSound:String = 'flixel/sounds/beep';

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;
	
	public var tmp:Bitmap;

	public var whiteBG:Bitmap;

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		tmp = new Bitmap(BitmapData.fromFile('assets/shared/images/volume.png'));
		tmp.scaleX = tmp.scaleY = .4;
		tmp.x -= 10;
		screenCenter();

		var width:Int = Std.int(tmp.width - 50);
		var height:Int = Std.int(tmp.height) - 20;

		var transWhite = new Bitmap(new BitmapData(width, height, false, FlxColor.WHITE));
		transWhite.alpha = 0.7;
		addChild(transWhite);

		whiteBG = new Bitmap(new BitmapData(width, height, false, FlxColor.WHITE));
		addChild(whiteBG);

		whiteBG.x = transWhite.x = tmp.x + 25;
		whiteBG.y = transWhite.y = tmp.y;

		addChild(tmp);

		y = -height;
		visible = false;
	}

	/**
	 * This function updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		// Animate sound tray thing
		if (_timer > 0)
		{
			_timer -= (MS / 1000);
		}
		else if (y > -height)
		{
			y -= (MS / 1000) * height * 0.5;

			if (y <= -height)
			{
				visible = false;
				active = false;

				#if FLX_SAVE
				// Save sound preferences
				if (FlxG.save.isBound)
				{
					FlxG.save.data.mute = FlxG.sound.muted;
					FlxG.save.data.volume = FlxG.sound.volume;
					FlxG.save.flush();
				}
				#end
			}
		}
	}

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	up Whether the volume is increasing.
	 */
	public function show(up:Bool = false):Void
	{
		if (!silent)
		{
			var sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 1;
		y = 0;
		visible = true;
		active = true;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}
		// whiteBG.width = globalVolume * 5;
		// I KNOW THIS SUCKS BUT THE THING ABOVE WASN'T DOING WELL AND I'M TRIED SO FUCK OFF
		whiteBG.width = switch(globalVolume){
			case 0: 0;
			case 1 | 2: globalVolume * 5;
			case 3: 17;
			case 4: 22;
			case 5: 28.7;
			case 6: 33;
			case 7: 40;
			case 8: 46;
			case 9: 53;
			default: 60;
		}
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end
