package backend;

class Highscore
{
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var songData:Map<String, SongData> = new Map();

	public static var ratingsLetters:Array<String> = ['P', 'S', 'A', 'B', 'C', 'D', 'F', '?'];

	public static function resetSong(song:String, diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);
		setScore(daSong, 0);
		setRating(daSong, 0);
	}

	public static function resetWeek(week:String, diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);
		setWeekScore(daWeek, 0);
	}

	public static function saveScore(song:String, score:Int = 0, ?diff:Int = 0, ?rating:Float = -1):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score)
			{
				setScore(daSong, score);
				if(rating >= 0) setRating(daSong, rating);
			}
		}
		else
		{
			setScore(daSong, score);
			if(rating >= 0) setRating(daSong, rating);
		}
	}

	public static function saveWeekScore(week:String, score:Int = 0, ?diff:Int = 0):Void
	{
		var daWeek:String = formatSong(week, diff);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);
		}
		else setWeekScore(daWeek, score);
	}

	public static function saveSongData(song:String, data:SongData, ?diff:Int = 0):Void
	{
		var daSong:String = formatSong(song, diff);

		if (songData.exists(daSong))
		{
			var oldSongData = songData.get(daSong);
			var newSongData:SongData = {
				ratingLetter: "?",
				score: 0,
				misses: 0,
				combo: 0
			};

			if(ratingsLetters.indexOf(data.ratingLetter) < ratingsLetters.indexOf(oldSongData.ratingLetter))
				newSongData.ratingLetter = data.ratingLetter;
			if(data.score > oldSongData.score)
				newSongData.score = data.score;
			if(data.combo > oldSongData.combo)
				newSongData.combo = data.combo;
			if(oldSongData.misses == null || data.misses < oldSongData.misses)
				newSongData.misses = data.misses;

			setSongData(daSong, newSongData);
		}
		else
		{
			setSongData(daSong, data);
		}
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	static function setSongData(song:String, data:SongData):Void
	{
		songData.set(song, data);
		FlxG.save.data.songData = songData;
		FlxG.save.flush();
	}

	public static function formatSong(song:String, diff:Int):String
	{
		return Paths.formatToSongPath(song) + Difficulty.getFilePath(diff);
	}

	public static function getScore(song:String, diff:Int):Int
	{
		var daSong:String = formatSong(song, diff);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getRating(song:String, diff:Int):Float
	{
		var daSong:String = formatSong(song, diff);
		if (!songRating.exists(daSong))
			setRating(daSong, 0);

		return songRating.get(daSong);
	}

	public static function getWeekScore(week:String, diff:Int):Int
	{
		var daWeek:String = formatSong(week, diff);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function getSongData(song:String, diff:Int):SongData
	{
		var daSong:String = formatSong(song, diff);
		if(!songData.exists(daSong)){
			var leData:SongData = {
				ratingLetter: "?",
				score: 0,
				misses: null,
				combo: 0
			};
			setSongData(daSong, leData);
		}
		return songData.get(daSong);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;

		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.songRating != null)
			songRating = FlxG.save.data.songRating;
		if (FlxG.save.data.songData != null)
			songData = FlxG.save.data.songData;
	}
}

typedef SongData = {
	var ratingLetter:String;
	var score:Int;
	var misses:Null<Int>;
	var combo:Int;
}