package shaders;

// shitty color invert shader that inverts pixels with an alpha of 0.6 or more
class ColorInvert extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    void main(){
        vec2 uv = openfl_TextureCoordv*openfl_TextureSize;
        vec4 color = texture2D(bitmap, uv.xy/openfl_TextureSize.xy);
        if(color.a >= .6)
            gl_FragColor = vec4(1.0-color.rgb,1.0);
        else
            gl_FragColor = color;
    }')
	public function new()
	{
		super();
	}
}