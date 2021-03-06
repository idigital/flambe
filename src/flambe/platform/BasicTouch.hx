//
// Flambe - Rapid game development
// https://github.com/aduros/flambe/blob/master/LICENSE.txt

package flambe.platform;

import flambe.input.Touch;
import flambe.input.TouchPoint;
import flambe.util.Signal1;

class BasicTouch
    implements Touch
{
    public var supported (isSupported, null) :Bool;
    public var maxPoints (getMaxPoints, null) :Int;
    public var points (getPoints, null) :Array<TouchPoint>;

    public var down (default, null) :Signal1<TouchPoint>;
    public var move (default, null) :Signal1<TouchPoint>;
    public var up (default, null) :Signal1<TouchPoint>;

    public function new (pointer :BasicPointer, maxPoints :Int = 4)
    {
        _pointer = pointer;
        _maxPoints = maxPoints;
        _pointMap = new IntHash();
        _points = [];

        down = new Signal1();
        move = new Signal1();
        up = new Signal1();
    }

    public function isSupported () :Bool
    {
        return true;
    }

    public function getMaxPoints () :Int
    {
        return _maxPoints;
    }

    public function getPoints () :Array<TouchPoint>
    {
        return _points.copy();
    }

    public function submitDown (id :Int, viewX :Float, viewY :Float)
    {
        if (!_pointMap.exists(id)) {
            var point = new TouchPoint(id);
            point._internal_init(viewX, viewY);
            _pointMap.set(id, point);
            _points.push(point);

            if (_pointerTouch == null) {
                // Make this touch point the tracked pointer
                _pointerTouch = point;
                _pointer.submitDown(viewX, viewY, point._internal_source);
            }
            down.emit(point);
        }
    }

    public function submitMove (id :Int, viewX :Float, viewY :Float)
    {
        var point = _pointMap.get(id);
        if (point != null) {
            point._internal_init(viewX, viewY);

            if (_pointerTouch == point) {
                _pointer.submitMove(viewX, viewY, point._internal_source);
            }
            move.emit(point);
        }
    }

    public function submitUp (id :Int, viewX :Float, viewY :Float)
    {
        var point = _pointMap.get(id);
        if (point != null) {
            point._internal_init(viewX, viewY);
            _pointMap.remove(id);
            _points.remove(point);

            if (_pointerTouch == point) {
                _pointerTouch = null;
                _pointer.submitUp(viewX, viewY, point._internal_source);
            }
            up.emit(point);
        }
    }

    private var _pointer :BasicPointer;
    private var _pointerTouch :TouchPoint;

    private var _maxPoints :Int;
    private var _pointMap :IntHash<TouchPoint>;
    private var _points :Array<TouchPoint>;
}
