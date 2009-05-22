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
package fr.seraf.wow.core ;

	import flash.sampler.NewObjectSample;
	import fr.seraf.wow.core.data.WVertex;
	import fr.seraf.wow.math.WFastMath;
	
	import fr.seraf.wow.primitive.WOWPlane;
	import haxe.Log;
	
	import fr.seraf.wow.constraint.WBaseConstraint;
	import fr.seraf.wow.core.collision.WCollisionDetector;
	import fr.seraf.wow.core.data.WVector;
	import fr.seraf.wow.math.WVectorMath;
	import fr.seraf.wow.primitive.WBoundArea;
	import fr.seraf.wow.primitive.WParticle;
	import fr.seraf.wow.structure.ConstraintList;
	import fr.seraf.wow.structure.ConstraintNode;
	import fr.seraf.wow.structure.ParticleList;
	import fr.seraf.wow.structure.ParticleNode;
	
	/**
	 * The main engine class. All particles and constraints should be added and removed
	 * through this class.
	 * 
	 */
	class WOWEngine {

		public  var STANDARD:Float ;
		public  var SELECTIVE:Float ;
		public  var SIMPLE:Float ;
		
		/**@private */
		public var force:WVector;
		/**@private */
		public var masslessForce:WVector;
			
		private var timeStep:Float;
		private var particles:ParticleList;
		private var constraints:ConstraintList;
		
		private var _damping:Float;
		private var _collisionResponseMode:Float ;
		
		public var damping(get_damping, set_damping):Float; 
		public var collisionResponseMode(get_collisionResponseMode, set_collisionResponseMode):Float;
		
		
		
		/**
		 * Initializes the engine. You must call this method prior to adding
		 * any particles or constraints.
		 * 
		 * @param dt The delta time value for the engine. This parameter can be used -- in 
		 * conjunction with speed at which <code>WOWEngine.step()</code> is called -- to change the speed
		 * of the simulation. Typical values are 1/3 or 1/4. Lower values result in slower,
		 * but more accurate simulations, and higher ones result in faster, less accurate ones.
		 * Note that this only applies to the forces added to particles. If you do not add any
		 * forces, the <code>dt</code> value won't matter.
		 */
		public function new(dt:Float = 0.3):Void {
			STANDARD = 100;
			SELECTIVE = 200;
			SIMPLE = 300;
			_collisionResponseMode = STANDARD;
		
			timeStep = dt * dt;
			
			particles = new ParticleList();
			constraints = new ConstraintList();
			
			force = new WVector(0,0,0);
			masslessForce = new WVector(0,0,0);
			
			damping = 1;
			
			WFastMath.initialize();
		}


		/**
		 * The global damping. Values should be between 0 and 1. Higher numbers
		 * result in less damping. A value of 1 is no damping. A value of 0 will
		 * not allow any particles to move. The default is 1.
		 * 
		 * <p>
		 * Damping will slow down your simulation and make it more stable. If you find
		 * that your sim is "blowing up', try applying more damping. 
		 * </p>
		 * 
		 * @param d The damping value. Values should be >=0 and <=1.
		 */
		private function get_damping():Float {
			return _damping;
		}
		
		
		/**
		 * @private
		 */
		private function set_damping(d:Float):Float {
			_damping = d;
			return _damping;
		}
		
		
	
		
		
		/**
		 * The collision response mode for the engine. The engine has three different possible
		 * settings for the collisionResponseMode property. Valid values are WOWngine.STANDARD, 
		 * WOWngine.SELECTIVE, and WOWngine.SIMPLE. Those settings go in order from slower and
		 * more accurate to faster and less accurate. In all cases it's worth experimenting to
		 * see what mode suits your sim best.  
		 *
		 * <ul>
		 * <li>
		 * <b>WOWngine.STANDARD</b>&mdash;Particles are moved out of collision and then velocity is 
		 * applied. Momentum is conserved and the mass of the particles is properly calculated. This
		 * is the default and most physically accurate setting.<br/><br/>
		 * </li>
		 * 
		 * <li>
		 * <b>WOWngine.SELECTIVE</b>&mdash;Similar to the WOWngine.STANDARD setting, except only 
		 * previously non-colliding particles have their velocity set. In otherwords, if there are 
		 * multiple collisions on a particle, only the first collision on that particle causes a 
		 * change in its velocity. Both this and the WOWngine.SIMPLE setting may give better results
		 * than WOWngine.STANDARD when using a large Float of colliding particles.<br/><br/>
		 * </li>
		 * 
		 * <li>
		 * <b>WOWngine.SIMPLE</b>&mdash;Particles do not have their velocity set after colliding. This
		 * is faster than the other two modes but is the least accurate. Mass is not calculated, and 
		 * there is no conservation of momentum. <br/><br/>
		 * </li>
		 * </ul>
		 */
		private function get_collisionResponseMode():Float {
			return _collisionResponseMode;
		}
		
		
		/**
		 * @private
		 */			
		private function set_collisionResponseMode(m:Float):Float {
			_collisionResponseMode = m;	
			return _collisionResponseMode;
		}
		
			
		// NEED REMOVE FORCE METHODS, AND A WAY TO ALTER ADDED FORCES
		/**
		 * Adds a force to all particles in the system. The mass of the particle is taken into 
		 * account when using this method, so it is useful for adding forces that simulate effects
		 * like wind. Particles with larger masses will not be affected as greatly as those with
		 * smaller masses. Note that the size (not to be confused with mass) of the particle has
		 * no effect on its physical behavior.
		 * 
		 * @param f A Vector represeting the force added.
		 */ 
		public function addForce(v:WVector):Void {
			force=WVectorMath.addVector(force,v);
		}
		 
		/**
		 * Adds a 'massless' force to all particles in the system. The mass of the particle is 
		 * not taken into account when using this method, so it is useful for adding forces that
		 * simulate effects like gravity. Particles with larger masses will be affected the same
		 * as those with smaller masses. Note that the size (not to be confused with mass) of 
		 * the particle has no effect on its physical behavior.
		 * 
		 * @param f A Vector represeting the force added.
		 */ 	
		public function addMasslessForce(v:WVector):Void {
			masslessForce=WVectorMath.addVector(masslessForce,v);
		}
		
		/**
		 * Adds a particle to the engine.
		 * 
		 * @param p The particle to be added.
		 */
		public function addParticle(p:WParticle):ParticleNode {
			p.engine = this;
			return particles.add(p);
		}
		
		
		/**
		 * Removes a particle to the engine.
		 * 
		 * @param p The particle to be removed.
		 */
		public function removeParticleNode(p:ParticleNode):Bool 
		{
			return particles.removeNode(p);
		}
		
		public function removeParticle(p:WParticle):Bool 
		{
			return particles.removeValue(p);
		}
		
		/**
		 * Adds a constraint to the engine.
		 * 
		 * @param c The constraint to be added.
		 */
		public function addConstraint(c:WBaseConstraint):ConstraintNode 
		{
			return constraints.add(c);
		}
		/**
		 * defini une zone de contrainte centré pour toutes les particules du moteur
		 * @param w longueur de la zone
		 * @param h hauteur de la zone
		 * @param d largeur de la zone
		 */	
		public function setBoundArea(area:WBoundArea):Void {
			var plane:WParticle=new WParticle();
			var ab:Array<WOWPlane>=area.getPlanes();
			var lp:Int = ab.length;

			while ( --lp > -1 ) {
				plane = ab[lp];
				addParticle(plane);				
			}
		}

		/**
		 * Removes a constraint from the engine.
		 * 
		 * @param c The constraint to be removed.
		 */
		public function removeConstraintNode(c:ConstraintNode):Bool 
		{
			return constraints.removeNode(c);
		}
	
		public function removeConstraint(c:WBaseConstraint):Bool 
		{
			return constraints.removeValue(c);
		}
	
		/**
		 * Returns an array of every item added to the engine. This includes all particles and
		 * constraints.
		 */
		public function getAll():Array<Dynamic> {
			return particles.toArray().concat(constraints.toArray());
		}	
	
		
		/**
		 * Returns an array of every particle added to the engine.
		 */
		public function getAllParticles():Array<Dynamic> {
			return particles.toArray();
		}	
		
	
		/**
		 * Returns an array of every custom particle added to the engine. A custom
		 * particle is defined as one that is not an instance of the included particle
		 * classes. If you create subclasses of any of the included particle classes, and
		 * add them to the engine using <code>addParticle(...)</code> then they will be
		 * returned by this method. This way you can keep a list of particles you have
		 * created, if you need to distinguish them from the built in particles.
		 */	
		/*public function getCustomParticles():Array {
			var customParticles:Array = new Array();
			for (var i:int = 0; i < particles.length; i++) {
				var p:WParticle = particles[i];
				if (isCustomParticle(p)) customParticles.push(p);		
			}
			return customParticles;
		}*/
		
		
		/**
		 * Returns an array of particles added to the engine whose type is one of the built-in
		 * particle types in the WOW. This includes the Sphere, WheelParticle, and
		 * RectangleParticle.
		 */			
		/*public function getWOWParticles():Array {
			var WOWParticles:Array = new Array();
			for (var i:int = 0; i < particles.length; i++) {
				var p:WParticle = particles[i];
				if (! isCustomParticle(p)) WOWParticles.push(p);		
			}
			return WOWParticles;
		}*/
		
	
		/**
		 * Returns an array of all the constraints added to the engine
		 */						
		public function getAllConstraints():Array<Dynamic> {
			return constraints.toArray();
		}	
	

		/**
		 * The main step function of the engine. This method should be called
		 * continously to advance the simulation. The faster this method is 
		 * called, the faster the simulation will run. Usually you would call
		 * this in your main program loop. 
		 */			
		public function step():Void {
			integrate();
			satisfyConstraints();
			checkCollisions();
		}

		private function isCustomParticle(p:WParticle):Bool {
			var className:String = Type.getClassName(WParticle);// getQualifiedClassName(p);
			trace(className);
			//var isAP:Bool = (className == "net.seraf.wow::WAdvSphere");
			var isSP:Bool = (className == "fr.seraf.wow.primitive::WSphere");
			var isPP:Bool = (className ==  "fr.seraf.wow.primitive::WOWPlane");
			var isAP:Bool = (className == "fr.seraf.wow.primitive::WAdvSphere");
			if (!(isAP || isSP  || isPP) ) return true;
			return false;		
		}


		private function integrate():Void 
		{
			var walker:ParticleNode = particles.head;
			while (walker!=null)
			{
				walker.particle.update(timeStep);	
				walker = walker.next;
			}
		}
	
		
		private function satisfyConstraints():Void 
		{
			var node:ConstraintNode = constraints.head;
			while (node!=null)
			{
				node.constraint.resolve();	
				node = node.next;
			}
		}
	
	
		/**
		 * Checks all collisions between particles and constraints. The following rules apply: 
		 * Particles vs Particles are tested unless either collidable property is set to false.
		 * Particles vs Constraints are not tested by default unless collidable is true.
		 * is called on a SpringConstraint. AngularConstraints are not tested for collision,
		 * but their component SpringConstraints are -- with the previous rule in effect. If
		 * a Particle is attached to a SpringConstraint it is never tested against that 
		 * SpringConstraint for collision
		 */
		private function checkCollisions():Void 
		{
			var node:ParticleNode = particles.head;
			while (node!=null)
			{
				//Quick note: leaving pa & pb untyped is surprisingly a lot faster than strongly typed.
				var pa:WParticle = node.particle;
				var node2:ParticleNode =  node.next;
				while (node2!=null)
				{
					var pb:WParticle = node2.particle;
					//trace("碰撞检测"+pb.collidable);
					if (pa.collidable && pb.collidable) 
					{
						WCollisionDetector.test(pa, pb);						
						//trace("碰撞检测"+pa.collidable);
					}
					node2 = node2.next;					
				}
				pa.isColliding = false;	
				node = node.next;				
			}
			
			
			/*for (var j:Float = 0; j < particles.length; j++) {
				
				var pa:WParticle = particles[j];
				
				for (var i:Float = j + 1; i < particles.length; i++) {
					var pb:WParticle = particles[i];
					if (pa.collidable && pb.collidable) {
						WCollisionDetector.test(pa, pb);
					}
				}
				pa.isColliding = false;	
			}*/
		}
	}