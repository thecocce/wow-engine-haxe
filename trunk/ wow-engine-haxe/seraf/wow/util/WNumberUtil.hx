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

package fr.seraf.wow.util ;

	class WNumberUtil 
	{
		/**
		 * Constant used pretty much everywhere. Trick of final const keywords use.
		 */
		//inline static var _fABS = Math.abs;	
		
		inline static var __TWO_PI:Float = 2 * Math.PI;
		public  var TWO_PI(get_TWO_PI,null):Float ;
		private function get_TWO_PI():Float { return __TWO_PI; }
		/**
		 * Constant used pretty much everywhere. Trick of final const keywords use.
		 */
		
		inline static var __PI:Float = Math.PI;	
		public var  PI(get_PI,null):Float ;
		private function get_PI():Float { return __PI; }
		/**
		 * Constant used pretty much everywhere. Trick of final const keywords use.
		 */
		
		inline static var __HALF_PI:Float = 0.5 * Math.PI;	
		public  var HALF_PI(get_HALF_PI,null):Float;
		private  function get_HALF_PI():Float { return __HALF_PI; }
		/**
		 * Constant used to convert angle from radians to degress
		 */
		
		inline static var __TO_DREGREE:Float = 180.0 /  Math.PI;
		public  static var TO_DEGREE(get_TO_DEGREE,null):Float;
		private static function get_TO_DEGREE():Float { return __TO_DREGREE; }
		/**
		 * Constant used to convert degress to radians.
		 */
		
		inline static var __TO_RADIAN:Float = Math.PI / 180;
		public static var TO_RADIAN(get_TO_RADIAN,null):Float ;
		public static function get_TO_RADIAN():Float { return __TO_RADIAN; }
		
		/**
		 * Value used to compare a Float and another one. Basically it's used to say if a Float is zero or not.
		 */
		public static var TOL:Float = 0.0001;	
			
		/**
		 * Say if a Float is close enought to zero to ba able to say it's zero. 
		 * Adjust TOL property depending on the precision of your Application
		 * @param n Float The Float to compare with zero
		 * @return Bool true if the Float is comparable to zero, false otherwise.
		 */
		public static function isZero( n:Float ):Bool
		{
			return Math.abs( n ) < TOL ;
		}
		
		/**
		 * Say if a Float is close enought to another to ba able to say they are equal. 
		 * Adjust TOL property depending on the precision of your Application
		 * @param n Float The Float to compare m
		 * @param m Float The Float you want to compare with n
		 * @return Bool true if the Floats are comparable to zero, false otherwise.
		 */
		public static function areEqual( n:Float, m:Float ):Bool
		{
			return Math.abs( n - m ) < TOL ;
		}
		
		/**
		 * Convert an angle from Radians to Degrees unit
		 * @param n  Float Float representing the angle in radian
		 * @return Float The angle in degrees unit
		 */
		public static function toDegree ( n:Float ):Float
		{
			return n * TO_DEGREE;
		}
		
		/**
		 * Convert an angle from Degrees to Radians unit
		 * @param n  Float Float representing the angle in dregrees
		 * @return Float The angle in radian unit
		 */
		public static function toRadian ( n:Float ):Float
		{
			return n * TO_RADIAN;
		}
			
		/**
		 * Add a constrain to the Float which must be between min and max values. Usually name clamp ?
		 * @param n Float The Float to constrain
		 * @param min Float The minimal valid value
		 * @param max Float The maximal valid value
		 * @return Float The Float constrained
		 */
		 public static function constrain( n:Float, min:Float, max:Float ):Float
		 {
			return Math.max( Math.min( n, max ) , min );
		 }
		 
		 
		
	}
