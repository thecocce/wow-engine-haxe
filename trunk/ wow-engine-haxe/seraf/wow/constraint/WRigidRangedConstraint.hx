/**
 * WOW-Engine AS3 3D Physics Engine, http://www.wow-engine.com
 * Copyright (c) 2007-2008 Seraf ( Jerome Birembaut ) http://seraf.mediabox.fr
 * 
 * Author: Jerome Birembaut
 * Author: Timothy John Watts
 * Date: May 27, 2008
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
package fr.seraf.wow.constraint;
	import fr.seraf.wow.primitive.WParticle;
	import fr.seraf.wow.core.data.WVector;
	import fr.seraf.wow.math.WVectorMath;

	/**
	 * A Rigid constraint that connects two particles 
	 */
	public class WRigidRangedConstraint extends WBaseConstraint {

		private var p1:WParticle;
		private var p2:WParticle;
		private var minDist:Float;
		private var maxDist:Float;
		private var restLen:Float;

		//private var massAffect:Bool;
		private var delta:WVector;
		//private var deltaLength:Float;


	        public var rotation(get_rotation, set_rotation):Float;		
		public var rotationZ(get_rotationZ,null):Float;
		public var rotationY(get_rotationY,null):Float;
		public var rotationX(get_rotationX,null):Float;
		public var center(get_center,null):WVector;
		public var pxp1(get_pxp1,null):Float;
		public var pyp1(get_pyp1,null):Float;
		public var pzp1(get_pzp1,null):Float;
		public var pxp2(get_pxp2,null):Float;
		public var pyp2(get_pyp2,null):Float;
		public var pzp2(get_pzp2,null):Float;
		public var max(get_max,set_max):Float;
		public var min(get_min,set_min):Float;

		/**
		 * @param p1 The first particle this constraint is connected to.
		 * @param p2 The second particle this constraint is connected to.
		 */
		public function WRigidRangedConstraint(
		p1:WParticle, 
		p2:WParticle,
		minDist:Float,
		maxDist:Float) {

			super(0.8);
			this.p1 = p1;
			this.p2 = p2;
			this.minDist = minDist;
			this.maxDist = maxDist
			;
			//massAffect=true;
			checkParticlesLocation();



			delta = WVectorMath.sub(p1.curr,p2.curr);
			//deltaLength = WVectorMath.distance(p1.curr,p2.curr);
			//restLength =  WVectorMath.distance(p1.curr,p2.curr);
		}
		/**
		 * The rotational value created by the positions of the two particles attached to this
		 * SpringConstraint. You can use this property to in your own painting methods, along with the 
		 * center property.
		 * WARNING : 2D property
		*/
		private function get_rotation():Float {
			return Math.atan2(delta.y,delta.x);
		}
		private function get_rotationZ():Float {
			return Math.atan2(delta.x,delta.y);
		}
		private function get_rotationY():Float {
			return Math.atan2(delta.x,delta.z);
		}
		private function get_rotationX():Float {
			return Math.atan2(delta.y,delta.z);
		}
		/**
		 * The center position created by the relative positions of the two particles attached to this
		 * SpringConstraint. You can use this property to in your own painting methods, along with the 
		 * rotation property.
		 * 
		 * @returns A WVector representing the center of this SpringConstraint
		 */
		private function get_center():WVector {

			return WVectorMath.divEquals(WVectorMath.addVector(p1.curr,p2.curr),2);
		}
		/* The x position of this particle 1
		 */
		private function get_pxp1():Float {
			return p1.px;
		}
		/* The y position of this particle 1
		 */
		private function get_pyp1():Float {
			return p1.py;
		}
		/* The z position of this particle 1
		 */
		private function get_pzp1():Float {
			return p1.pz;
		}
		/* The x position of this particle 1
		 */
		private function get_pxp2():Float {
			return p2.px;
		}
		/* The y position of this particle 1
		 */
		private function get_pyp2():Float {
			return p2.py;
		}
		/* The z position of this particle 1
		 */
		private function get_pzp2():Float {
			return p2.pz;
		}
		/**
		 * The <code>restLength</code> property sets the length of SpringConstraint. This value will be
		 * the distance between the two particles unless their position is altered by external forces. The
		 * SpringConstraint will always try to keep the particles this distance apart.
		 */
		private function get_max():Float {
			return maxDist;
		}
		private function set_max(r:Float) {
			maxDist =r ;
		}
		private function get_min():Float {
			return minDist;
		}
		private function set_min(r:Float) {
			minDist =r ;
		}






		/**
		 * Returns true if the passed particle is one of the particles specified in the constructor.
		 */
		public function isConnectedTo(p:WParticle):Bool {
			return (p == p1 || p == p2);
		}
		/**
		 * @private
		 */
		public  override function resolve():Void {
			if (p1.fixed && p2.fixed) {
				return;
			}
			delta = WVectorMath.sub(p1.curr,p2.curr);
			var d:Float=WVectorMath.distance(p1.curr,p2.curr);
			//trace(d,maxDist,minDist);
			if (d>maxDist && d<minDist) {
				if ((d-maxDist)>(minDist-d)) {
					restLen = minDist;
				} else {
					restLen = maxDist;
				}
			} else if (d<minDist) {
				restLen = minDist;
			} else if (d>maxDist) {
				restLen = maxDist;
			} else {
				return;
			}
			var diff:Float=restLen/d;
			if (! p1.fixed && ! p2.fixed) {
				var d2:WVector = WVectorMath.scale(WVectorMath.scale(delta,-diff),.5);
				var c:WVector=center;
				p1.curr=WVectorMath.sub(c,d2);
				p2.curr=WVectorMath.addVector(c,d2);
				return;
			}
			if ( p1.fixed) {
				p2.curr=WVectorMath.sub(p1.curr,WVectorMath.scale(delta,diff));
				return;
			}
			if ( p2.fixed) {
				p1.curr=WVectorMath.addVector(p2.curr,WVectorMath.scale(delta,diff));
			}
		}
		/**
		 * if the two particles are at the same location warn the user
		 */
		private function checkParticlesLocation():Void {
			if (minDist > maxDist) {
				throw new Error("Min cannot be less than the max. Perhaps you should make 2 constraints.");
			}
			if (p1.curr.x == p2.curr.x && p1.curr.y == p2.curr.y&& p1.curr.z == p2.curr.z) {
				throw new Error("The two particles specified for a SpringContraint can't be at the same location");
			}
		}
	}