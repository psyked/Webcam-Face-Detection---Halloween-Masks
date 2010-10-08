package
{
    import com.quasimondo.bitmapdata.CameraBitmap;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.geom.Matrix;
    import flash.geom.Rectangle;
    import flash.media.Camera;
    import flash.text.TextField;

    import jp.maaash.ObjectDetection.ObjectDetector;
    import jp.maaash.ObjectDetection.ObjectDetectorEvent;
    import jp.maaash.ObjectDetection.ObjectDetectorOptions;

    import mx.core.BitmapAsset;

    //[SWF( width='640',height='480',backgroundColor='#333333',frameRate='30' )]
    [SWF( width='500',height='375',backgroundColor='#333333',frameRate='30' )]

    public class FaceDetector_Camera extends Sprite
    {

        private var detector:ObjectDetector;
        private var options:ObjectDetectorOptions;

        private var view:Sprite;
        private var faceRectContainer:Sprite;
        private var tf:TextField;

        private var camera:CameraBitmap;
        private var detectionMap:BitmapData;
        private var drawMatrix:Matrix;
        private var scaleFactor:int = 6;
        private var w:int = 640;
        private var h:int = 480;

        private var lastTimer:int = 0;

        //[Embed( 'mask.png' )]
        [Embed( 'mask.png' )]
        private var maskSrc:Class;

        [Embed( 'webcam-message.gif' )]
        private var messageSrc:Class;

        [Embed( 'webcam-error.gif' )]
        private var webcamErrorSrc:Class;

        private var error:BitmapAsset;

        private var maskGfx:BitmapAsset; // = new maskSrc();

        private var masksArray:Array = new Array();

        public function FaceDetector_Camera()
        {
            initUI();
            initDetector();

            //maskGfx.visible = false;
            //addChild( maskGfx );
        }

        private function initUI():void
        {
            stage.scaleMode = StageScaleMode.EXACT_FIT;
            stage.align = StageAlign.TOP_LEFT;

            view = new Sprite;
            addChild( view );

            error = new webcamErrorSrc();
            error.visible = false;
            error.width = 488;
            error.height = 366;
            addChild( error );

            if ( Camera.getCamera())
            {
                camera = new CameraBitmap( 488, 366, 30, w, h );
                camera.addEventListener( Event.RENDER, cameraReadyHandler );
                view.addChild( new Bitmap( camera.bitmapData ));

                detectionMap = new BitmapData( w / scaleFactor, h / scaleFactor, false, 0 );
                drawMatrix = new Matrix( 1 / scaleFactor, 0, 0, 1 / scaleFactor );

                faceRectContainer = new Sprite;
                view.addChild( faceRectContainer );
            }
            else
            {
                var a:BitmapAsset = new messageSrc();
                a.width = 488;
                a.height = 366;
                view.addChild( a );
            }
        }

        private function cameraReadyHandler( event:Event ):void
        {
            detectionMap.draw( camera.bitmapData, drawMatrix, null, "normal", null, true );
            detector.detect( detectionMap );

            var rect:Rectangle = camera.bitmapData.getColorBoundsRect( 0xffffff, 0x000000, true );
            if ( rect.width == 488 )
            {
                error.visible = true;
            }
            else
            {
                error.visible = false;
            }
        }

        private function initDetector():void
        {
            detector = new ObjectDetector();

            var options:ObjectDetectorOptions = new ObjectDetectorOptions();
            //options.min_size=30;
            detector.options = options;
            detector.addEventListener( ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );
        }



        private function detectionHandler( e:ObjectDetectorEvent ):void
        {
            var g:Graphics = faceRectContainer.graphics;
            g.clear();

            for ( var i:int = masksArray.length - 1; i > -1; i-- )
            {
                masksArray[ i ].visible = false;
            }
            //maskGfx.visible = false;
            if ( e.rects )
            {
                //g.lineStyle( 2 ); // black 2pix
                e.rects.forEach( function( r:Rectangle, idx:int, arr:Array ):void
                    {
                        //trace(idx);
                        if ( !masksArray[ idx ])
                        {
                            masksArray[ idx ] = new maskSrc();
                            addChild( masksArray[ idx ]);
                        }
                        //g.drawRect( r.x * scaleFactor, r.y * scaleFactor, r.width * scaleFactor, r.height * scaleFactor );
                        masksArray[ idx ].visible = true;
                        masksArray[ idx ].alpha = 0.8;
                        masksArray[ idx ].width = r.width * scaleFactor;
                        masksArray[ idx ].scaleY = masksArray[ idx ].scaleX;
                        masksArray[ idx ].x = r.x * scaleFactor;
                        //maskGfx.y = ( r.y + ( r.height / 2 )) * scaleFactor;
                        masksArray[ idx ].y = ( r.y - ( r.height / 3 )) * scaleFactor;
                    });

            }

        }




    }
}
