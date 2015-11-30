# wow-engine-haxe:WOW-Engine 3D Physics Engine for Haxe #

I have translated 3D Physics Engine ( WOW-Engine) to Haxe,my haXe level is so low,would you like to make wow-engine-haxe  well ? please fixe it.
here it is :http://wow-engine-haxe.googlecode.com/files/fr.rar

haxe port : haha123\_0


# wow-engine-haxe: flash 3D物理引擎wow haXe版 #
Hi,各位大侠，我尝试把as3的经典的3维物理引擎WOW移植到了haXe,你可以看下面的演示代码，在这个例子里它可以完美运行，但也许有一些其它模块会有缺陷，如果你知道如何优化和修正，请一起加入移植的工作了，祝生活愉快。

haxe版本转换者: haha123\_0

# 下载地址 #
wow-engine-haxe
http://code.google.com/p/wow-engine-haxe/

AS3原版:
http://seraf.mediabox.fr/wow-engine/as3-3d-physics-engine-wow-engine/

## test code（测试代码） ##

```
/*wow haxe port: haha123_0(老鼠赛跑)*/
package;
//flash engine
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.ui.Keyboard;
//wow engine
import fr.seraf.wow.core.WOWEngine;
import fr.seraf.wow.core.data.WVector;
import fr.seraf.wow.primitive.WBoundArea;
import fr.seraf.wow.primitive.WSphere;
//sandy engine
import sandy.core.Scene3D;
import sandy.core.scenegraph.Camera3D;
import sandy.core.scenegraph.Group;
import sandy.materials.Appearance;
import sandy.materials.attributes.LightAttributes;
import sandy.materials.attributes.MaterialAttributes;
import sandy.materials.attributes.LineAttributes;
import sandy.materials.ColorMaterial;
import sandy.materials.Material;
import sandy.primitive.Box;
import sandy.primitive.Sphere;
import sandy.primitive.PrimitiveMode;
class Example030 extends Sprite
{
    private var wow:WOWEngine;
    private var sphere01:WSphere;
    private var bound:WBoundArea;
    private var sphereS:Sphere;
    private var cube:Box;
    private var scene:Scene3D;
    private var camera:Camera3D;
    static function main()
    {
        new Example030();
    }
    function new()
    {
        super();
        //create an instance of the physic engine
        wow = new  WOWEngine();
        // SELECTIVE is better for dealing with lots of little particles colliding,
        wow.collisionResponseMode = wow.SELECTIVE;
        // gravity -- particles of varying masses are affected the same
        wow.addMasslessForce(new WVector(0 , 2 , 0));
        //create a sphere
        sphere01 = new WSphere(0 , 0 , 0 , 25 , false , 1 , 1 , 1);
        sphere01.elasticity = 1;
        sphere01.friction = 0;
        sphere01.py = - 150;
        wow.addParticle(sphere01);
        bound = new WBoundArea(190 , 200 , 190);
        bound.setPosition(0 , 0 , 0);
        bound.elasticity = 1;
        bound.friction = 0;
        wow.setBoundArea(bound);
        // Sandy code
        camera = new  Camera3D( 600 , 600 );
        camera.z = - 400;
        var root:Group = createScene();
        scene = new  Scene3D( "scene" , this , camera , root );
        Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN , keyPressedHandler);
        Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE , mouseMovedHandler);
        Lib.current.stage.addEventListener( Event.ENTER_FRAME , enterFrameHandler );
        Lib.current.stage.addChild(this);
    }
    private function createScene():Group
    {
        // Create the root Group
        var g:Group = new Group();
        // Create a cube so we have something to show
        sphereS = new Sphere( "theSphere" , 25 , 10 , 10);
        var materialAttr:MaterialAttributes = new  MaterialAttributes(
        [new  LineAttributes( 0.5 , 0x2111BB , 0.4 ) , new  LightAttributes( true , 0.1)]
        );
        var material:Material = new ColorMaterial( 0xFFCC33 , 1 , materialAttr );
        material.lightingEnable = true;
        var app:Appearance = new  Appearance( material );
        sphereS.appearance = app;
        sphereS.useSingleContainer = false;
        sphereS.x = 0;
        sphereS.y = 150;
        sphereS.z = 0;
        // the box
        cube = new Box( "theBox" , 200 , 200 , 180 , PrimitiveMode.QUAD , 1 );
        cube.enableBackFaceCulling = false;
        cube.useSingleContainer = false;
        // We need to add the cube to the group
        g.addChild( sphereS );
        g.addChild(cube);
        return g;
    }
    private function mouseMovedHandler(event:MouseEvent):Void
    {		
        cube.rotateZ = (600 / 2 - event.stageX) / 15;
        cube.rotateX = (600 / 2 - event.stageY) / 15;
        bound.setRotation ( - (600 / 2 - event.stageY) / 15 , 0 , - (600 / 2 - event.stageX) / 15);
    }
    private function keyPressedHandler(event:KeyboardEvent):Void
    {
        switch(event.keyCode)
        {
            case Keyboard.SPACE:
            sphereS.x = 0;
            sphereS.y = 150;
            sphereS.z = 0;
            sphere01.px = 0;
            sphere01.py = - 150;
            sphere01.pz = 0;
        }
    }
    private function enterFrameHandler( event : Event ):Void
    {
        //run the engine once
        wow.step();
        //get the position
        sphereS.x = sphere01.px;
        sphereS.y = - sphere01.py;
        sphereS.z = sphere01.pz;
        scene.render();
    }
}
```