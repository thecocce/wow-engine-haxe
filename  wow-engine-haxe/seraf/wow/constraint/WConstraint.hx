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
package fr.seraf.wow.constraint;
	import fr.seraf.wow.primitive.WParticle;
	import fr.seraf.wow.core.data.WVector;
	import fr.seraf.wow.math.WVectorMath;

	/**
	 * A dynamic constraint class. 
	 * 
	 */
	class WConstraint extends WBaseConstraint {

		//these should be private, but i am still testing it :)
		public var cType:String;
		public var p1:WParticle;
		public var p2:WParticle;
		public var minDist:Float;
		public var maxDist:Float;

		public var _breakpoint:Float;
		public var _broken:Bool;
		public var restLen:Float;
		public var diff:Float;
		public var massAffect:Bool;
		public var delta:WVector;
		public var deltaLength:Float;
		public var _stiffness:Float;



	        public var rotation(get_rotation, set_rotation):Float;
		public var contraintType(get_contraintType, set_contraintType):String;
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
		public var stiffness(get_stiffness,set_stiffness):Float;
		public var breakpoint(get_breakpoint,set_breakpoint):Float;
		public var broken(get_broken,set_broken):Bool;
		public var massAffected(get_massAffected,set_massAffected):Bool;


		/** 
		 *  WConstraint(type,p1:WParticles,p2:WParticles,ranges:Array)
		 *@param type valid values are ['rigid'|'spring'|'sticky'|'brakable']
		 *'rigid' uses params 'minDist' and 'maxDist' or simply 'dist'(which assisis to both min and max dist),
		  *
		 *note: the bigger rest distance will always be the max and the smaller the min
		 *
		 *WConstraint("spring",p1:WParticles,p2:WParticles,distance1:Float=currentdist, distance2:Float = distance1,stiffness:Float=.5)
		 *@param distance1 the rest distance
		 *@param distance2 the 2nd rest distance
		 *@param stiffness The strength of the spring. Valid values are between 0 and 1. Lower values
		 * result in softer springs. Higher values result in stiffer, stronger springs.
		 *note: the bigger distance will always be the max and the smaller the min
		*
		 *note: use swap() to swap out the WParticles, may be usefull in the future.
		 *
		 */
		public function WConstraint(type:String,p1:WParticle,p2:WParticle) {
			this.p1=p1;
			this.p2=p2;
			this.cType = type;
			super(.5);

			/*
			switch (type) {
			case "rigid" :
			_stiffness = 1;
			break;
			case "spring" :
			_stiffness = .5;
			break;
			case "breakable" :
			_stiffness = .8;
			break;
			case "sticky" :
			_stiffness = .5;
			break;
			default :
			type="rigid";
			_stiffness = 1;
			}
			*/
			this.deltaLength=WVectorMath.distance(p1.curr,p2.curr);
			this.minDist=deltaLength;
			this.maxDist=deltaLength;
			this.massAffect = false;
			//the break point is 1/10 of the current distance because it had to be something and this seemed good enough
			this._breakpoint=10000000000;
			this._broken=false;
			this.delta=WVectorMath.sub(p1.curr,p2.curr);
			this.deltaLength=deltaLength;
			checkParticlesLocation();
		}

		/**
		 * The stiffness of the constraint. Higher values result in result in 
		 * stiffer constraints. Values should be greater than 0 and less than or 
		 * equal to 1. Depending on the situation, setting constraints to very high 
		 * values may result in instability or unwanted energy.
		 */
		private function get_rotation():Float {
			return Math.atan2(delta.y,delta.x);
		}
		private function get_rotationZ():Float {
			return Math.atan2(delta.x,delta.y);
		}
		private function get_contraintType(){
			return cType;
		}
		private function set_contraintType(t:String){
			cType = t;
			if (cType == 'rigid' ||cType == 'spring') {
				_broken = false;
			}
			return cType;
		}
		private function get_rotationY(){
			return Math.atan2(delta.x,delta.z);
		}
		private function get_rotationX():Float {
			return Math.atan2(delta.y,delta.z);
		}
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
			return this.maxDist;
		}
		private function set_max(r:Float) {
			// saftey feature to swap min and max distances

			if (r < minDist) {
				maxDist = minDist;
				minDist = r;
			} else {
				maxDist=r;
			}
			return maxDist;
		}
		private function get_min():Float {
			return this.minDist;
		}
		private function set_min(r:Float) {

			// saftey feature to swap min and max distances

			if (r > maxDist) {
				minDist = maxDist;
				maxDist = r;
			} else {
				minDist=r;
			}
			return minDist;
		}
		public override function get_stiffness():Float {
			return this._stiffness;
		}

		public override function set_stiffness(s:Float):Void {
			this._stiffness=s;
			return this._stiffness;
		}

		private function get_breakpoint():Float {
			return this._breakpoint;
		}
		private function set_breakpoint(s:Float){
			this._breakpoint=s;
			return this._breakpoint;
		}
		private function get_broken():Bool {
			return this._broken;
		}
		private function set_broken(s:Bool) {
			this._broken=s;
			return this._broken;
		}
		/**
		 */
		private function get_massAffected() {
			return this.massAffect;
		}
		/**
		 */
		private function set_massAffected(r:Bool):Bool {
			this.massAffect=r;
			return this.massAffect;
		}
		/**
		 * Returns true if the passed particle is one of the particles specified in the constructor.
		 */
		public function isConnectedTo(p:WParticle):Bool {
			return (p == p1 || p == p2);
		}

		public function swap():Void {
			var t=p1;
			p1=p2;
			p2=t;
		}
		public override function resolve():Void {
			if (p1.fixed && p2.fixed) {
				return;
			}
			if (_broken && this.cType != "sticky") {
				return;
			}
			delta=WVectorMath.sub(p1.curr,p2.curr);
			deltaLength=WVectorMath.distance(p1.curr,p2.curr);

			if (deltaLength > maxDist) {
				restLen=maxDist;
			} else if (deltaLength < minDist) {
				restLen=minDist;
			} else {
				return;
			}
			if (this.cType == "breakable" || this.cType == "sticky" ) {
				if (Math.abs(deltaLength-restLen) > _breakpoint) {
					_broken = true;
					return;
				} else if (this.cType == "sticky") {
					_broken = false;
				}
			}
			//var d2: Float = stiffness * ( d1 - restLength ) / d1;
			if (cType != "rigid") {
				diff  =_stiffness * ( deltaLength - restLen ) / deltaLength;

				//dx *= d2;
				//dy *= d2;
				var dmd:WVector=WVectorMath.scale(delta,diff);
				var invM1:Float=p1.invMass;
				var invM2:Float=p2.invMass;
				var sumInvMass:Float=invM1 + invM2;
				if (! p1.fixed) {
					if (massAffect) {
						dmd=WVectorMath.scale(dmd,invM1 / sumInvMass);
					}
					p1.curr=WVectorMath.sub(p1.curr,dmd);
				}
				if (! p2.fixed ) {
					if (massAffect) {
						dmd=WVectorMath.scale(dmd,invM2 / sumInvMass);
					}
					p2.curr=WVectorMath.addVector(p2.curr,dmd);
				}
			} else {
				delta = WVectorMath.sub(p1.curr,p2.curr);
				var d:Float=WVectorMath.distance(p1.curr,p2.curr);
				diff=restLen/d;
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
		}
		private function checkParticlesLocation():Void {
			if (minDist > maxDist) {
				throw new Error("Min cannot be less than the max. Perhaps you should make 2 constraints.");
			}
			if (p1.curr.x == p2.curr.x && p1.curr.y == p2.curr.y&& p1.curr.z == p2.curr.z) {
				if (minDist > 0) {
					throw new Error("The two particles specified for a SpringContraint can't be at the same location AND a minDist > 0");
				}
			}
		}

	}
