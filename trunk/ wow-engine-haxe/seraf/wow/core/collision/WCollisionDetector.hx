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
package fr.seraf.wow.core.collision;
	import fr.seraf.wow.core.data.WPlane;
	import fr.seraf.wow.primitive.WOWPlane;
	import fr.seraf.wow.primitive.WSphere;
	import fr.seraf.wow.primitive.WOWPolygon;
	import fr.seraf.wow.primitive.WParticle;
	import fr.seraf.wow.core.data.WInterval;
	import fr.seraf.wow.core.data.WVector;
	import fr.seraf.wow.math.WVectorMath;
	import fr.seraf.wow.math.WPlaneMath;
	
class WCollisionDetector {
	//public function new(){}

		/**
		 * Tests the collision between two objects. If there is a collision it is passed off
		 * to the CollisionResolver class to resolve the collision.
		 */
		public static function test(objA:WParticle, objB:WParticle):Void {

			if (objA.fixed && objB.fixed) {				
			return;
			}
			
			if (objA.multisample == 0 && objB.multisample == 0) {
				normVsNorm(objA, objB);		
							
			} else if (objA.multisample > 0 && objB.multisample == 0) {
				sampVsNorm(objA, objB);				
				
			} else if (objB.multisample > 0 && objA.multisample == 0) {
				sampVsNorm(objB, objA);

			} else if (objA.multisample == objB.multisample) {
				sampVsSamp(objA, objB);

			} else {
				normVsNorm(objA, objB);
				
			}

		}
				
		/**
		 * default test for two non-multisampled particles
		 */
		private static function normVsNorm(objA:WParticle, objB:WParticle):Void {
			objA.samp.copy(objA.curr);
			objB.samp.copy(objB.curr);			
			testTypes(objA, objB);			
		}
		
		
		/**
		 * Tests two particles where one is multisampled and the other is not. Let objectA
		 * be the multisampled particle.
		 */
		private static function sampVsNorm(objA:WParticle, objB:WParticle):Void {
		
			var s:Float = 1 / (objA.multisample + 1); 
			var t:Float = s;
		
			objB.samp.copy(objB.curr);
			
			for (i in 0...(objA.multisample+1)) {
				objA.samp.setTo(objA.prev.x + t * (objA.curr.x - objA.prev.x), 
								objA.prev.y + t * (objA.curr.y - objA.prev.y),
								objA.prev.z + t * (objA.curr.z - objA.prev.z));
		
				if (testTypes(objA, objB)) return;
				t += s;
			}
		}


		/**
		 * Tests two particles where both are of equal multisample rate
		 */		
		private static function sampVsSamp(objA:WParticle, objB:WParticle):Void {
			
			var s:Float = 1 / (objA.multisample + 1); 
			var t:Float = s;
			
			for (i in  0...objA.multisample+1) {
				
				objA.samp.setTo(objA.prev.x + t * (objA.curr.x - objA.prev.x), 
								objA.prev.y + t * (objA.curr.y - objA.prev.y),
								objA.prev.z + t * (objA.curr.z - objA.prev.z));
				
				objB.samp.setTo(objB.prev.x + t * (objB.curr.x - objB.prev.x), 
								objB.prev.y + t * (objB.curr.y - objB.prev.y),
								objB.prev.z + t * (objB.curr.z - objB.prev.z));
				
				if (testTypes(objA, objB)) return;
				t += s;
			}
		}
		private static function testTypes(objA:WParticle, objB:WParticle):Bool {	
			// circle to circle
			if (Std.is(objA , WSphere) && Std.is(objB , WSphere)) {
				//trace("testSpherevsSphere");
					return testSpherevsSphere(cast(objA,WSphere), cast(objB,WSphere));
			}
			// plan to circle
			if (Std.is(objA , WOWPlane) && Std.is(objB , WSphere)) {
				//trace("testPlanevsSphere");					    
					return testPlanevsSphere(cast(objA, WOWPlane), cast(objB,WSphere));
			}
			// plan to circle
			if (Std.is(objA , WSphere) && Std.is(objB , WOWPlane)) {
			//	trace("testPlanevsSphere");
					return testPlanevsSphere(cast(objB,WOWPlane), cast(objA,WSphere));
			}
			// plan to circle
			if (Std.is(objA , WOWPolygon) && Std.is(objB , WSphere)) {
				//trace("testPolyvsSphere");
					return testPolyvsSphere(cast(objA,WOWPolygon), cast(objB,WSphere));
			}
			// plan to circle
			if (Std.is(objA , WSphere) && Std.is(objB , WOWPolygon)) {
			//	trace("testPolyvsSphere");
				return testPolyvsSphere(cast(objB,WOWPolygon), cast(objA,WSphere));
			}
			return false;
		}
		private static function bounds(ra:WOWPolygon,pos:WVector):Bool
		{
			for(i in ra.rangeFaceNormal)
			{
				ra.rangeFacePenetrateDepth=WVectorMath.dot(ra.rangeFaceNormal[i],pos)-ra.rangeFaceDis[i];
			
				if(ra.rangeFacePenetrateDepth<0)
				{
					//collisionRangeFace=i;
					return true;
				}
			}
			return false;
		}
		private static function testPolyvsSphere(ra:WOWPolygon, ca:WSphere):Bool {

			var collisionNormal:WVector;
			var collisionDepth:Float = Math.POSITIVE_INFINITY;

			var depth:Float=WPlaneMath.distanceToPoint(ra.getPlane(),ca.samp);
			//if (depth == 0) {
			var r:Float = ca.radius;
			if (depth == r) {
				return false;
			}
			//if (Math.abs(depth) < Math.abs(collisionDepth)) {
			
			collisionNormal = ra.getNormale();
			collisionDepth = depth;

			var mag:Float = WVectorMath.getNorm(collisionNormal);
			collisionDepth = r - collisionDepth;

			if (collisionDepth > 0) {
				if (bounds(ra,ca.samp)) {
					return false;
				}
				WVectorMath.divEquals(collisionNormal,mag);
				WCollisionResolver.resolveParticleParticle(ra, ca, WVectorMath.negate(collisionNormal), collisionDepth);
				return true;
			} 
			
			return false;			
		}
		private static function testPlanevsSphere(ra:WOWPlane, ca:WSphere):Bool {

			var collisionNormal:WVector=new WVector();
			var collisionDepth:Float = Math.POSITIVE_INFINITY;				
			
			var depth:Float = WPlaneMath.distanceToPoint(ra.getPlane(), ca.samp);
			
			if (depth == 0) {				
				return false;
			}
			

			if (Math.abs(depth) < collisionDepth) {
				collisionNormal = ra.getNormale();
				collisionDepth = depth;
				
			}
			//}
			// determine if the sphere's center is in a vertex region

			var r:Float = ca.radius;
			

			/*if (Math.abs(depth) > r ) {
			return;
			}*/
			var mag:Float = WVectorMath.getNorm(collisionNormal);
			
			collisionDepth = r - collisionDepth;

			if (collisionDepth > 0) {
				WVectorMath.divEquals(collisionNormal, mag);				
				WCollisionResolver.resolveParticleParticle(ra, ca, WVectorMath.negate(collisionNormal), collisionDepth);					
				return true;
			} 
			
			return false;			
		}

		/**
		 * Tests the collision between two Spheres. If there is a collision it 
		 * determines its axis and depth, and then passes it off to the CollisionResolver
		 * for handling.
		 */
		private static function testSpherevsSphere(ca:WSphere, cb:WSphere):Bool {

			var depthX:Float = testIntervals(ca.getIntervalX(), cb.getIntervalX());
			
			if (depthX == 0) return false;

			var depthY:Float = testIntervals(ca.getIntervalY(), cb.getIntervalY());
			
			if (depthY == 0) return false;

			var depthZ:Float = testIntervals(ca.getIntervalZ(), cb.getIntervalZ());
			
			if (depthZ == 0) return false;
		
			var collisionNormal:WVector = WVectorMath.sub(ca.samp,cb.samp);
			var mag:Float = WVectorMath.getNorm(collisionNormal);
			var collisionDepth:Float = (ca.radius + cb.radius) - mag;

			if (collisionDepth > 0) {

				collisionNormal=WVectorMath.divEquals(collisionNormal,mag);
				WCollisionResolver.resolveParticleParticle(ca, cb, collisionNormal, collisionDepth);
				return true;
			}
			return false;
		}
		/**
		 * Returns 0 if intervals do not overlap. Returns smallest depth if they do.
		 */
		private static function testIntervals(intervalA:WInterval, intervalB:WInterval):Float {


			if (intervalA.max < intervalB.min) return 0;

			if (intervalB.max < intervalA.min) return 0;

			var lenA:Float = intervalB.max - intervalA.min;
			var lenB:Float = intervalB.min - intervalA.max;

			return Math.abs(lenA) < Math.abs(lenB)?lenA:lenB;
		}
	}