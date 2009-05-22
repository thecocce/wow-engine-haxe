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

package fr.seraf.wow.primitive;

	import fr.seraf.wow.core.data.WPlane;
	import fr.seraf.wow.core.data.WVector;
	import fr.seraf.wow.core.data.WVertex;
	import fr.seraf.wow.core.face.WIPolygon;
	import fr.seraf.wow.core.face.WPolygon;
	import fr.seraf.wow.math.WPlaneMath;
	import fr.seraf.wow.math.WMatrix4Math;
	import fr.seraf.wow.math.WVectorMath;
	import fr.seraf.wow.core.data.WMatrix4;
	import fr.seraf.wow.primitive.WParticle;


	/**
	* VPlane
	*
	* @authorJerome Biremabut - Seraf
	* @authorThomas Pfeiffer - kiroukou
	* @authorTabin Cédric - thecaptain
	* @authorNicolas Coevoet - [ NikO ]
	* @since0.1
	* @version0.2
	* @date 12.01.2006 
	**/

	class WOWPolygon extends WParticle {
		private var _plane:WPlane;
		private var _h:Float;
		private var _lg:Float;
		private var _f:WIPolygon;
		private var _n:WVector;
		private var center:WVertex;
		private var rotation:WVector;
		public var aPoInts:Array<Dynamic>;
		private var _m:WMatrix4;
		private var _mPos:WMatrix4;
		private var _mRot:WMatrix4;
		//
		private var tempVector:WVector;
		private var Normal:WVector;
		private var distance:Float;
		private var penetrateDepth:Float;
		public var rangeFacePenetrateDepth:Float;
		private var collisionRangeFace:Float;
		
		public var verticesPos:Array<Dynamic>;
		public var rangeFaceDis:Array<Dynamic>;
		public var rangeFaceNormal:Array<Dynamic>;
		/**
		* This is the constructor to call when you need to create an unlimited Plane primitive.
		* @param x Float position x of the box
		* @param y Float position y  of the box
		* @param z Float position z  of the box
		* @param rx Float rotation x of the box
		* @param ry Float rotation y of the box
		* @param rz Float rotation z of the box
		*/
		public function new(vertex0:WVertex, vertex1:WVertex, vertex2:WVertex) {
			super(0,0,0,true,10000,0,.1);
			//_f = new WPolygon(this, vertex0, vertex2, vertex1 );
			aPoInts = [vertex0, vertex1, vertex2];
			updateVertexPos(vertex0, vertex1, vertex2);
		}

		
		private function updateVertexPos(vertex0:WVertex, vertex1:WVertex, vertex2:WVertex) {


			_plane=WPlaneMath.computePlaneFromPoints(new WVector(vertex0.x,vertex0.y,vertex0.z),new WVector(vertex2.x,vertex2.y,vertex2.z),new WVector(vertex1.x,vertex1.y,vertex1.z));
			_plane.d=- _plane.d;
			Normal = getNormale();
			distance=WVectorMath.dot(aPoInts[0],Normal);
			
			var border:WVector;
			rangeFaceDis=new Array();
			rangeFaceNormal=new Array();
			
			for(i in 0...aPoInts.length)
			{
				if(i>0)
				{
					border=WVectorMath.sub(aPoInts[i],aPoInts[i-1]);
				}
				else
				{
					border=WVectorMath.sub(aPoInts[i],aPoInts[aPoInts.length-1]);
				}
				rangeFaceNormal[i]=WVectorMath.cross(border,Normal);
				WVectorMath.normalize(rangeFaceNormal[i]);
				rangeFaceDis[i]=WVectorMath.dot(rangeFaceNormal[i],aPoInts[i]);
			}
			
		}
		/**
		* Returns the position of the Object3D as a 3D vector.
		* The returned position in the position in the World frame, not the camera's one.
		* In case you want to get the position to a camera, you'll have to add its position to this vector with VectorMat::add eg.
		* @paramVoid
		* @returnVector the 3D position of the object
		*/
		public function setPlane(p:WPlane) {
			_plane=p;
		}

		public function getPlane():WPlane {
			return _plane;
		}
		public function getVertex():Array<Dynamic> {
			return aPoInts;
		}
		public function getNormale():WVector {
			return new WVector(_plane.a,_plane.b,_plane.c);
		}
	}
