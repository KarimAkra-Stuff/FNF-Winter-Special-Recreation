var lastCombo = 0;
function onUpdate(elapsed:Float)
{
	if (combo < lastCombo && lastCombo > 5)
	{
		dad.playAnim("laugh");
		dad.specialAnim = true;
	}

	lastCombo = combo;
	return Function_Continue;
}
