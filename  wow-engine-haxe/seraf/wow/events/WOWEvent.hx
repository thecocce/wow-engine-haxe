

package fr.seraf.wow.events;

	import fr.seraf.wow.primitive.WParticle;
	import fr.seraf.wow.core.data.WVector;
	import flash.events.Event;

	class WOWEvent extends Event
	{
		public static var ON_COLLISION:String = "onCollision";
		public var particuleA:WParticle;
		public var particuleB:WParticle;
		public var depth:Float;
		public var normal:WVector;
		public function new(type:String, 			
				bubbles:Bool = false,
			 cancelable:Bool = false)
		{
			
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
	    {
			var e:WOWEvent=new WOWEvent(type, bubbles, cancelable);
			e.particuleA=particuleA;
			e.particuleB=particuleB;
			e.normal=normal;
			e.depth=depth;
	        return e;
	    }
	}