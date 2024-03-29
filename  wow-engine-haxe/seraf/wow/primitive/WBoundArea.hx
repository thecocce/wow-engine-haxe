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

package fr.seraf.wow.primitive;

	import fr.seraf.wow.core.data.WPlane;
	import fr.seraf.wow.core.data.WVector;
	import fr.seraf.wow.core.data.WVertex;
	import fr.seraf.wow.math.WPlaneMath;
	import fr.seraf.wow.math.WMatrix4Math;
	import fr.seraf.wow.math.WVectorMath;
	import fr.seraf.wow.core.data.WMatrix4;
	import fr.seraf.wow.primitive.WParticle;
	import fr.seraf.wow.primitive.WOWPlane;

	/**
	* BoundArea
	*  
	* @authorJerome Birembaut - Seraf
	* @since0.1
	* @version0.2
	* @date 12.01.2006 
	**/

	class WBoundArea extends WParticle {

		private var _wplane0:WOWPlane;
		private var _wplane1:WOWPlane;
		private var _wplane2:WOWPlane;
		private var _wplane3:WOWPlane;
		private var _wplane4:WOWPlane;
		private var _wplane5:WOWPlane;

		private var _h:Float;
		private var _w:Float;
		private var _d:Float;
		private var _lg:Float;

		private var _n:WVector;
		private var center:WVertex;
		private var rotation:WVector;
		private static var aPoints:Array<WVertex>=new Array();
		private static var aPlanes:Array<WOWPlane>=new Array();
		private var _m:WMatrix4;
		private var _mPos:WMatrix4;
		private var _mRot:WMatrix4;
		
				

		/**
		* This is the constructor to call when you nedd to create a boundArea primitive.
		* @param w Float width of the box
		* @param h Float height of the box
		* @param d Float depth of the box
		* @param x Float position x of the box
		* @param y Float position y  of the box
		* @param z Float position z  of the box
		* @param rx Float rotation x of the box
		* @param ry Float rotation y of the box
		* @param rz Float rotation z of the box
		*/
		public function new(w:Float=600,h:Float=600,d:Float=600,x:Float =0, y:Float =0, z:Float = 0, rx:Float = 0, ry:Float = 0, rz:Float = 0) {
			_w=w;
			_h=h;
			_d=d;
			super(0,0,0,true,10000,0,.1);
			generate();
			_mRot = WMatrix4.createIdentity();			
			_mPos= WMatrix4.createIdentity();
			setRotation(rx,ry,rz);
			setPosition(x, y, z);		

		}
override public function activCollisionEvent(func:Dynamic):Void {
			trace("Event de collision activer sur Bound area ");
		_wplane0.activCollisionEvent(func);
		_wplane1.activCollisionEvent(func);
		_wplane2.activCollisionEvent(func);
		_wplane3.activCollisionEvent(func);
		_wplane4.activCollisionEvent(func);
		_wplane5.activCollisionEvent(func);			
		}
		

		/**
		 * Returns the primitive rotation vector containing the eulers angles
		 * @return WVector the vector of euler angles
		 */
		public function getRotation():WVector
		{
			return rotation;
		}
		
		public function generate():Void {
			var p:WVertex;
			var wd:Float=_w/2;
			var hd:Float=_h/2;
			var dd:Float=_d/2;
			p = new WVertex(-wd,-hd,-dd);
			aPoints.push(p);
			p = new WVertex(wd,-hd,-dd);
			aPoints.push(p);
			p = new WVertex(wd,hd,-dd);
			aPoints.push(p);
			p = new WVertex(-wd,hd,-dd);
			aPoints.push(p);
			p = new WVertex(-wd,-hd,dd);
			aPoints.push(p);
			p = new WVertex(wd,-hd,dd);
			aPoints.push(p);
			p = new WVertex(wd,hd,dd);
			aPoints.push(p);
			p = new WVertex(-wd,hd,dd);
			aPoints.push(p);
			_wplane0=new WOWPlane();
			_wplane1=new WOWPlane();
			_wplane2=new WOWPlane();
			_wplane3=new WOWPlane();
			_wplane4=new WOWPlane();
			_wplane5=new WOWPlane();

		}
		public function setRotation(rx:Float,ry:Float,rz:Float):Void {
			rx = ( rx + 360 ) % 360;
			ry = ( ry + 360 ) % 360;
			rz = ( rz + 360 ) % 360;
			//
			rotation=new WVector(rx,ry,rz);
			_mRot = WMatrix4Math.eulerRotation( rx, ry, rz );
			
			updateVertexPos();
		}
		public function setPosition(tx:Float,ty:Float,tz:Float):Void {
			position=new WVector(tx,ty,tz);
			_mPos = WMatrix4Math.translation( tx, ty, tz );
			updateVertexPos();
		}
		private function updateVertexPos():Void {

			var m11:Float,m21:Float,m31:Float,m41:Float,m12:Float,m22:Float,m32:Float,m42:Float,m13:Float,m23:Float,m33:Float,m43:Float,m14:Float,m24:Float,m34:Float,m44:Float;

			var m:WMatrix4 = _mRot;
			
			m = WMatrix4Math.multiply(_mPos , m);			
			//
			m11 = m.n11;
			m21 = m.n21;
			m31 = m.n31;
			m41 = m.n41;
			m12 = m.n12;
			m22 = m.n22;
			m32 = m.n32;
			m42 = m.n42;
			m13 = m.n13;
			m23 = m.n23;
			m33 = m.n33;
			m43 = m.n43;
			m14 = m.n14;
			m24 = m.n24;
			m34 = m.n34;
			m44 = m.n44;

			var v:WVertex;
			var lp:Int = aPoints.length;
			while ( --lp > -1 ) {				
				v = aPoints[lp];
				v.wx = v.x * m11 + v.y * m12 + v.z * m13 + m14;
				v.wy = v.x * m21 + v.y * m22 + v.z * m23 + m24;
				v.wz = v.x * m31 + v.y * m32 + v.z * m33 + m34;			
				
			}	
			
			aPlanes = new Array();			
			var _plane:WPlane=WPlaneMath.computePlaneFromPoints(new WVector(aPoints[0].wx,aPoints[0].wy,aPoints[0].wz),new WVector(aPoints[1].wx,aPoints[1].wy,aPoints[1].wz),new WVector(aPoints[2].wx,aPoints[2].wy,aPoints[2].wz));
			_plane.d=- _plane.d;
			
			_wplane0.setPlane(_plane);
			aPlanes.push(_wplane0);

			_plane=WPlaneMath.computePlaneFromPoints(new WVector(aPoints[1].wx,aPoints[1].wy,aPoints[1].wz),new WVector(aPoints[5].wx,aPoints[5].wy,aPoints[5].wz),new WVector(aPoints[6].wx,aPoints[6].wy,aPoints[6].wz));
			_plane.d=- _plane.d;

			_wplane1.setPlane(_plane);
			aPlanes.push(_wplane1);

			_plane=WPlaneMath.computePlaneFromPoints(new WVector(aPoints[5].wx,aPoints[5].wy,aPoints[5].wz),new WVector(aPoints[4].wx,aPoints[4].wy,aPoints[4].wz),new WVector(aPoints[7].wx,aPoints[7].wy,aPoints[7].wz));
			_plane.d=- _plane.d;

			_wplane2.setPlane(_plane);
			aPlanes.push(_wplane2);

			_plane=WPlaneMath.computePlaneFromPoints(new WVector(aPoints[4].wx,aPoints[4].wy,aPoints[4].wz),new WVector(aPoints[0].wx,aPoints[0].wy,aPoints[0].wz),new WVector(aPoints[3].wx,aPoints[3].wy,aPoints[3].wz));
			_plane.d=- _plane.d;

			_wplane3.setPlane(_plane);
			aPlanes.push(_wplane3);

			_plane=WPlaneMath.computePlaneFromPoints(new WVector(aPoints[2].wx,aPoints[2].wy,aPoints[2].wz),new WVector(aPoints[6].wx,aPoints[6].wy,aPoints[6].wz),new WVector(aPoints[7].wx,aPoints[7].wy,aPoints[7].wz));
			_plane.d=- _plane.d;

			_wplane4.setPlane(_plane);
			aPlanes.push(_wplane4);

			_plane=WPlaneMath.computePlaneFromPoints(new WVector(aPoints[0].wx,aPoints[0].wy,aPoints[0].wz),new WVector(aPoints[5].wx,aPoints[5].wy,aPoints[5].wz),new WVector(aPoints[1].wx,aPoints[1].wy,aPoints[1].wz));
			_plane.d=- _plane.d;

			_wplane5.setPlane(_plane);
			aPlanes.push(_wplane5);
		}
		public function getPlanes():Array<WOWPlane> {
			return aPlanes;
		}
		public function getVertex():Array<WVertex> {
			return aPoints;
		}

	}
