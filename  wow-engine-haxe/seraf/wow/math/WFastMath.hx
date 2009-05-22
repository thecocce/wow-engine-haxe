/**
 * WOW-Engine AS3 3D Physics Engine, http://www.wow-engine.com
 * Copyright (c) 2007-2008 Seraf ( Jerome Birembaut ) http://seraf.mediabox.fr
 * 
 * Based on APE by Alec Cove , http://www.cove.org/ape/
 *       & Sandy3D by Thomas Pfeiffer, http://www.flashsandy.org/
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
*/

package fr.seraf.wow.math;
import flash.Lib;

	/**
	* 	Fast trigonometry functions using cache table and precalculated data. 
	* 	Based on Michael Kraus implementation.
	* 
	* 	@author	Mirek Mencel	// miras@polychrome.pl
	* 	@date	01.02.2007
	*/

class WFastMath 
{	
	/** Precission. The bigger, the more entries in lookup table so the more accurate results. */
	public static var PRECISION:Int = 0x100000;
	public static var TWO_PI:Float = 2 * Math.PI;
	public static var HALF_PI:Float = Math.PI/2;
	
	/** Precalculated values with given precision */
	private static var sinTable:Array<Float> = new Array();
	private static var tanTable:Array<Float> = new Array();
	
	private static var RAD_SLICE:Float = TWO_PI / PRECISION;
	
	public function new() {	}
	
	public static function initialize()
	{
		var timer:Int = Lib.getTimer();
		var rad:Float = 0;

		for (i in 0...PRECISION) {
			rad = (i * RAD_SLICE);
			sinTable[i] = (Math.sin(rad));
			tanTable[i] = (Math.tan(rad));
		}
		
		trace("FastMath initialization time: " + (Lib.getTimer() - timer)); 
		
	}

	private static function radToIndex(radians:Float):Int 
	{
		//trace((Std.int((radians / TWO_PI) * PRECISION)) & (PRECISION - 1));
		
		return Std.int( (Std.int((radians / TWO_PI) * PRECISION)) & (PRECISION - 1) );
	}

	/**
	 * Returns the sine of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to sine.
	 * @return The approximation of the value's sine.
	 */
	public static function sin(radians:Float):Float 
	{
		return sinTable[ radToIndex(radians) ];
	}

	/**
	 * Returns the cosine of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to cosine.
	 * @return The approximation of the value's cosine.
	 */
	public static function cos(radians:Float ):Float 
	{
		return sinTable[radToIndex(HALF_PI-radians)];
	}

	/**
	 * Returns the tangent of a given value, by looking up it's approximation in a
	 * precomputed table.
	 * @param radians The value to tan.
	 * @return The approximation of the value's tangent.
	 */
	public static function tan(radians:Float):Float 
	{
		return tanTable[radToIndex(radians)];
	}
}
