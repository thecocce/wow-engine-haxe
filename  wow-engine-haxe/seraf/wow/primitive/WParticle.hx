﻿/**
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

package fr.seraf.wow.primitive ;
		import fr.seraf.wow.core.WOWEngine;
		import fr.seraf.wow.core.collision.WCollision;
		import fr.seraf.wow.core.data.WInterval;
		import fr.seraf.wow.core.data.WVector;
		import fr.seraf.wow.math.WVectorMath;
		import fr.seraf.wow.events.WOWEvent;
		import fr.seraf.wow.events.WDispatcher;
	/**
	 * The abstract base class for all particles.
	 * 
	 * <p>
	 * You should not instantiate this class directly -- instead use one of the subclasses.
	 * </p>
	 */
	class WParticle {
		
		// public properties are not hidden from asdoc?
		/** @private */
		public var collisionHandler:WDispatcher;
		/** @private */
		public var curr:WVector;
		/** @private */
		public var prev:WVector;
		/** @private */
		public var samp:WVector;
		/** @private */
		public var isColliding:Bool;
		/** @private */
		public var interval:WInterval;

		public var name:String;
		
		private var forces:WVector;
		private var temp:WVector;
		
		private var _kfr:Float;
		private var _mass:Float;
		private var _invMass:Float;
		private var _fixed:Bool;
		private var _friction:Float;
		private var _collidable:Bool;
		private var collision:WCollision;
		private var _WOWEngine:WOWEngine;
		
		private var _multisample:Int;
		
		private var _storedData:Dynamic;
		public  var MIN_MASS:Float ;
		
		public var storedData(get_storedData, set_storedData):Dynamic;
		public var engine(get_engine, set_engine):WOWEngine;
		public var mass(get_mass, set_mass):Float;
		public var elasticity(get_elasticity, set_elasticity):Float;
		public var multisample(get_multisample, set_multisample):Int;
		public var friction(get_friction, set_friction):Float;
		public var fixed(get_fixed, set_fixed):Bool;
		public var position(get_position, set_position):WVector;
		public var px(get_px, set_px):Float;
		public var py(get_py, set_py):Float;
		public var pz(get_pz, set_pz):Float;
		public var velocity(get_velocity, set_velocity):WVector;
		public var collidable(get_collidable, set_collidable):Bool;
		public var invMass(get_invMass, null):Float;
		
		
		/** 
		 * @private
		 */
		public function new (
				x:Float=0, 
				y:Float=0, 
				z:Float=0, 
				isFixed:Bool=true, 
				mass:Float=1, 
				elasticity:Float=0.3,
				friction:Float=0) {
		
			MIN_MASS = 0.0001;
			interval = new WInterval(0,0);
			collisionHandler = new WDispatcher();
			curr = new WVector(x, y,z);
			prev = new WVector(x, y,z);
			temp = new WVector(0,0,0);
			samp = new WVector(0,0,0);
			fixed = isFixed;
			
			forces = new WVector(0,0,0);
			collision = new WCollision(new WVector(0,0,0), new WVector(0,0,0));
			isColliding = false;
			
			this.mass = mass;
			this.elasticity = elasticity;
			this.friction = friction;
			
			collidable = true;
			_multisample = 0;
		}
		
		public function activCollisionEvent(func:Dynamic):Void {
			trace("Event de collision activer sur cette particule");
		
			collisionHandler.addEventListener(WOWEvent.ON_COLLISION, func);
		}
		
		private function get_storedData():Dynamic{
			return _storedData; 
		}
		
		
		private function set_storedData(obj:Dynamic):Void {
			_storedData = obj;
			return _storedData;
			
		}
		private function get_engine():WOWEngine {
			return _WOWEngine; 
		}
		
		
		private function set_engine(e:WOWEngine):WOWEngine {
			_WOWEngine = e;
			return _WOWEngine;
		}
		/**
		 * The mass of the particle. Valid values are greater than zero. By default, all particles
		 * have a mass of 1. 
		 * 
		 * <p>
		 * The mass property has no relation to the size of the particle. However it can be
		 * easily simulated when creating particles. A simple example would be to set the 
		 * mass and the size of a particle to same value when you instantiate it.
		 * </p>
		 * @throws flash.errors.Error flash.errors.Error if the mass is set less than zero. 
		 */
		private function get_mass():Float {
			return _mass; 
		}
		
		
		/**
		 * @private
		 */
		private function set_mass(m:Float):Float {
			//if (m <= 0) throw new ArgumentError("mass may not be set <= 0"); 
			if (m <= 0) { return 0.1; }
			_mass = m;
			_invMass = 1 / _mass;
			return _mass; 
		}	
	
		
		/**
		 * The elasticity of the particle. Standard values are between 0 and 1. 
		 * The higher the value, the greater the elasticity.
		 * 
		 * <p>
		 * During collisions the elasticity values are combined. If one particle's
		 * elasticity is set to 0.4 and the other is set to 0.4 then the collision will
		 * be have a total elasticity of 0.8. The result will be the same if one particle
		 * has an elasticity of 0 and the other 0.8.
		 * </p>
		 * 
		 * <p>
		 * Setting the elasticity to greater than 1 (of a single particle, or in a combined
		 * collision) will cause particles to bounce with energy greater than naturally 
		 * possible. Setting the elasticity to a value less than zero is allowed but may cause 
		 * unexpected results.
		 * </p>
		 */ 
		private function get_elasticity():Float {
			return _kfr; 
		}
		
		
		/**
		 * @private
		 */
		private function set_elasticity(k:Float):Float {
			_kfr = k;
			return _kfr; 
		}
		
		/**
		 * Determines the Float of intermediate position steps checked for collision each
		 * cycle. Setting this Float higher on fast moving particles can prevent 'tunneling'
		 * -- when a particle moves so fast it misses collision with certain surfaces.
		 */ 
		private function get_multisample():Int {
			return _multisample; 
		}
		
		
		/**
		 * @private
		 */
		private function set_multisample(m:Int):Int {
			_multisample = m;
			return _multisample;
			
		}
				
		/**
		 * The surface friction of the particle. Values must be in the range of 0 to 1.
		 * 
		 * <p>
		 * 0 is no friction (slippery), 1 is full friction (sticky).
		 * </p>
		 * 
		 * <p>
		 * During collisions, the friction values are summed, but are clamped between 1 and 0.
		 * For example, If two particles have 0.7 as their surface friction, then the resulting
		 * friction between the two particles will be 1 (full friction).
		 * </p>
		 * 
		 * <p>
		 * Note: In the current release, only dynamic friction is calculated. Static friction
		 * is planned for a later release.
		 * </p>
		 * 
		 * @throws flash.errors.Error flash.errors.Error if the friction is set less than zero or greater than 1
		 */	
		private function get_friction():Float {
			return _friction; 
		}
	
		
		/**
		 * @private
		 */
		private function set_friction(f:Float):Float {
			//if (f < 0 || f > 1) throw new ArgumentError("Legal friction must be >= 0 and <=1");
			if (f < 0 || f > 1){return 0.0;}
			_friction = Math.max(Math.min(f, 1), 0);
			return _friction;
		}
		

		/**
		 * The fixed state of the particle. If the particle is fixed, it does not move
		 * in response to forces or collisions. Fixed particles are good for surfaces.
		 */
		private function get_fixed():Bool {
			return _fixed;
		}

 
		/**
		 * @private
		 */
		private function set_fixed(f:Bool):Bool {
			_fixed = f;
			return _fixed;
		}
		
		
		/**
		 * The position of the particle. Getting the position of the particle is useful
		 * for drawing it or testing it for some custom purpose. 
		 * 
		 * <p>
		 * When you get the <code>position</code> of a particle you are given a copy of the current
		 * location. Because of this you cannot change the position of a particle by
		 * altering the <code>x</code> and <code>y</code> components of the Vector you have retrieved from the position property.
		 * You have to do something instead like: <code> position = new Vector(100,100)</code>, or
		 * you can use the <code>px</code> and <code>py</code> properties instead.
		 * </p>
		 * 
		 * <p>
		 * You can alter the position of a particle three ways: change its position, set
		 * its velocity, or apply a force to it. Setting the position of a non-fixed particle
		 * is not the same as setting its fixed property to true. A particle held in place by 
		 * its position will behave as if it's attached there by a 0 length sprint constraint. 
		 * </p>
		 */
		private function get_position():WVector {
			return WVectorMath.clone(curr);
		}
		

		/**
		 * @private
		 */
 		private function set_position(p:WVector):WVector {
			curr=WVectorMath.clone(p);
			prev = WVectorMath.clone(p);
			return WVectorMath.clone(p);
		}

	
		/**
		 * The x position of this particle
		 */
		private function get_px():Float {
			return curr.x;
		}

		
		/**
		 * @private
		 */
		private function set_px(x:Float):Float {
			curr.x = x;
			prev.x = x;	
			return x;
		}

		
		/**
		 * The y position of this particle
		 */
		private function get_py():Float {
			return curr.y;
		}


		/**
		 * @private
		 */
		private function set_py(y:Float):Float {
			curr.y = y;
			prev.y = y;	
			return y;
		}
		
		/**
		 * The y position of this particle
		 */
		private function get_pz():Float {
			return curr.z;
		}
		/**
		 * @private
		 */
		private function set_pz(z:Float):Float {
			curr.z = z;
			prev.z = z;	
			return z;
		}
		/**
		 * The velocity of the particle. If you need to change the motion of a particle, 
		 * you should either use this property, or one of the addForce methods. Generally,
		 * the addForce methods are best for slowly altering the motion. The velocity property
		 * is good for instantaneously setting the velocity, e.g., for projectiles.
		 * 
		 */

		private function get_velocity():WVector {
			return WVectorMath.sub(curr,prev);
		}
		
		
		/**
		 * @private
		 */	
		private function set_velocity(v:WVector):WVector {
			prev =WVectorMath.sub(curr,v);
			return prev;
		}
		
		
		/**
		 * Determines if the particle can collide with other particles or constraints.
		 * The default state is true.
		 */
		private function get_collidable():Bool {
			return _collidable;
		}
	
				
		/**
		 * @private
		 */		
		private function set_collidable(b:Bool):Bool {
			_collidable = b;
			return b;
		}
		

			
		// NEED REMOVE FORCES METHODS
		/**
		 * Adds a force to the particle. The mass of the particle is taken into 
		 * account when using this method, so it is useful for adding forces 
		 * that simulate effects like wind. Particles with larger masses will
		 * not be affected as greatly as those with smaller masses. Note that the
		 * size (not to be confused with mass) of the particle has no effect 
		 * on its physical behavior.
		 * 
		 * @param f A Vector represeting the force added.
		 */ 
		public function addForce(f:WVector):Void {

			var f:WVector = WVectorMath.scale(f, invMass);
			forces=WVectorMath.addVector(forces,f);
			//forces.plusEquals(f.multEquals(invMass));
		}
		
		
		/**
		 * Adds a 'massless' force to the particle. The mass of the particle is 
		 * not taken into account when using this method, so it is useful for
		 * adding forces that simulate effects like gravity. Particles with 
		 * larger masses will be affected the same as those with smaller masses.
		 *
		 * @param f A Vector represeting the force added.
		 */ 	
		public function addMasslessForce(f:WVector):Void {
			//forces.plusEquals(f);
			forces=WVectorMath.addVector(forces,f);
		}
		
		
		/**
		 * @private
		 */
		public function update(dt2:Float):Void {
			
			if (fixed) return;
			
			// global forces
			addForce(engine.force);
			addMasslessForce(engine.masslessForce);
	
			// integrate
			//temp.copy(curr);
			temp=WVectorMath.clone(curr);
			forces = WVectorMath.scale(forces, dt2);
			var nv:WVector =WVectorMath.addVector(velocity,forces);
			//var nv:Vector = velocity.plus(forces.multEquals(dt2));
			//nv.multEquals(0.98);
			//nv=WVectorMath.scale(nv,0.98)
			nv = WVectorMath.scale(nv, engine.damping);
			curr=WVectorMath.addVector(curr,nv);
			//curr.plusEquals(nv.multEquals(WOWEngine.damping));
			prev.copy(temp);
			//prev.copy(temp);
		
			// clear the forces
			forces=new WVector(0,0,0);
		}
		
		
		/**
		 * @private
		 */		
		public function getComponents(collisionNormal:WVector):WCollision {
			var vel:WVector =velocity;
			var vdotn:Float = WVectorMath.dot(collisionNormal,vel);
			
			//var vdotn:Float = collisionNormal.dot(vel);
			collision.vn = WVectorMath.scale(collisionNormal,vdotn);
			//collision.vn = collisionNormal.mult(vdotn);
			collision.vt = WVectorMath.sub(vel,collision.vn);
			//collision.vt = vel.minus(collision.vn);	
			return collision;
		}
	
	
		/**
		 * @private
		 */	
		public  function resolveCollision(mtd:WVector, vel:WVector, n:WVector, d:Float, o:Float):Void {
			curr=WVectorMath.addVector(curr,mtd);
			//curr.plusEquals(mtd);
	
			switch (engine.collisionResponseMode) {
				
				case engine.STANDARD:
					velocity = vel;
				
				case engine.SELECTIVE:
					if (! isColliding) velocity = vel;
					isColliding = true;		
					
				case engine.SIMPLE:				
			}
		}
		
		
		/**
		 * @private
		 */		
		private function get_invMass():Float {
				return (fixed) ? 0 : _invMass; 
		}
		
		
		/**
		 * @private
		 */		
		public function getProjection(axis:WVector):WInterval {
			return null;
		}
	}