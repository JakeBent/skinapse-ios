/*Copyright (c) 2016, Andrew Walz.

 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit

protocol SwiftyDrawViewDelegate {
    func SwiftyDrawDidBeginDrawing(view: DrawView)
    func SwiftyDrawIsDrawing(view: DrawView)
    func SwiftyDrawDidFinishDrawing(view: DrawView)
    func SwiftyDrawDidCancelDrawing(view: DrawView)
}

extension SwiftyDrawViewDelegate {

    func SwiftyDrawDidBeginDrawing(view: DrawView) {
        //optional
    }

    func SwiftyDrawIsDrawing(view: DrawView) {
        //optional
    }

    func SwiftyDrawDidFinishDrawing(view: DrawView) {
        //optional
    }

    func SwiftyDrawDidCancelDrawing(view: DrawView) {
        //optional
    }
}

/// UIView Subclass where touch gestures are translated into Core Graphics drawing

class DrawView: UIView {

    private struct ViewModel {
        class IntensityStack {
            var intense: [Line] = []
            var moderate: [Line] = []
            var light: [Line] = []
            var all: [[Line]] {
                return [intense, moderate, light]
            }

            func add(line: Line) {
                switch line.intensity {
                case .intense: intense.append(line)
                case .moderate: moderate.append(line)
                case .light: light.append(line)
                }
            }

            func remove(line: Line?) {
                guard let line = line else { return }
                switch line.intensity {
                case .intense: intense = intense.filter { $0 == line }
                case .moderate: moderate = moderate.filter { $0 == line }
                case .light: light = light.filter { $0 == line }
                }
            }

            func clear() {
                intense = []
                moderate = []
                light = []
            }
        }

        let acne = IntensityStack()
        let scarring = IntensityStack()
        let irritation = IntensityStack()
        let redness = IntensityStack()
        let oiliness = IntensityStack()
        let dryness = IntensityStack()
        var all: [IntensityStack] {
            return [acne, scarring, irritation, redness, oiliness, dryness]
        }

        func add(line: Line) {
            switch line.type {
            case .acne: acne.add(line: line)
            case .scarring: scarring.add(line: line)
            case .irritation: irritation.add(line: line)
            case .redness: redness.add(line: line)
            case .oiliness: oiliness.add(line: line)
            case .dryness: dryness.add(line: line)
            }
        }

        func remove(line: Line?) {
            guard let line = line else { return }
            switch line.type {
            case .acne: acne.remove(line: line)
            case .scarring: scarring.remove(line: line)
            case .irritation: irritation.remove(line: line)
            case .redness: redness.remove(line: line)
            case .oiliness: oiliness.remove(line: line)
            case .dryness: dryness.remove(line: line)
            }
        }

        func clear() {
            all.forEach { $0.clear() }
        }
        
        func toMap() -> [String: Any] {
            var result: [String: Any] = [:]
            
//            all.forEach { intensityStack in
//                intensityStack.all.forEach { lines in
//                    lines.forEach { line in
//                        result[line.type.rawValue] = [
//                            
//                        ]
//                    }
//                }
//            }
            
            return result
        }
    }

    private class Line: Equatable {
        let id: String
        let type: BrushType
        let intensity: BrushIntensity
        var path: CGMutablePath
        var color: UIColor
        var width: CGFloat
        var opacity: CGFloat

        init(type: BrushType, intensity: BrushIntensity, path: CGMutablePath, color: UIColor, width: CGFloat, opacity: CGFloat) {
            id = UUID().uuidString
            self.type = type
            self.intensity = intensity
            self.path = path
            self.color = color
            self.width = width
            self.opacity = opacity
        }
        
//        func toDictionary() -> [String: String] {
//            return [
//                "id": id,
//                "type": type.rawValue,
//                "intensity": "\(intensity.rawValue)",
//                "path": Pathology.extract(path: path).to,
//                "color": color,
//                "width": width
//                "opacity": opacity
//            ]
//        }

        static func == (lhs: Line, rhs: Line) -> Bool { return lhs.id == rhs.id }
    }

    var type: BrushType = .acne
    var intensity: BrushIntensity = .moderate
    var lineColor: UIColor { return type.color(forIntensity: intensity) }
    var lineWidth: CGFloat = 10.0
    var lineOpacity: CGFloat = 1.0
    var drawingEnabled: Bool = true
    var delegate: SwiftyDrawViewDelegate?

    private var viewModel = ViewModel() {
        didSet {
            print(viewModel)
        }
    }
    private var pathArray: [Line] = []
    private var currentPoint: CGPoint = CGPoint()
    private var previousPoint: CGPoint = CGPoint()
    private var previousPreviousPoint: CGPoint = CGPoint()


    /// Public init(frame:) implementation

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    /// Public init(coder:) implementation

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }

    /// Overriding draw(rect:) to stroke paths

    override open func draw(_ rect: CGRect) {
        let context : CGContext = UIGraphicsGetCurrentContext()!
        context.setLineCap(.round)

        viewModel.all.forEach { stack in
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            stack.all.forEach { lines in
                lines.forEach { line in
                    context.setLineWidth(line.width)
                    context.setAlpha(line.opacity)
                    context.setStrokeColor(line.color.cgColor)
                    context.addPath(line.path)
                }
                context.strokePath()
            }
            context.endTransparencyLayer()
        }

//        for line in pathArray {
//            //            context.setBlendMode(CGBlendMode.)
//            context.setLineWidth(line.width)
//            context.setAlpha(line.opacity)
//            context.setStrokeColor(line.color.cgColor)
//            context.addPath(line.path)
//            context.beginTransparencyLayer(auxiliaryInfo: nil)
//            context.strokePath()
//            context.endTransparencyLayer()
//        }
    }

    /// touchesBegan implementation to capture strokes

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled == true else {
            return
        }

        self.delegate?.SwiftyDrawDidBeginDrawing(view: self)
        if let touch = touches.first {
            setTouchPoints(touch, view: self)
            let newLine = Line(
                type: type,
                intensity: intensity,
                path: CGMutablePath(),
                color: lineColor,
                width: lineWidth,
                opacity: lineOpacity
            )
            newLine.path.addPath(createNewPath())
            pathArray.append(newLine)
            viewModel.add(line: newLine)
        }
    }

    /// touchesMoves implementation to capture strokes


    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled == true else {
            return
        }

        self.delegate?.SwiftyDrawIsDrawing(view: self)
        if let touch = touches.first {
            updateTouchPoints(touch, view: self)
            let newLine = createNewPath()
            if let currentPath = pathArray.last {
                currentPath.path.addPath(newLine)
            }
        }
    }

    /// touchedEnded implementation to capture strokes

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled == true else {
            return
        }

        self.delegate?.SwiftyDrawDidFinishDrawing(view: self)
    }

    /// touchedCancelled implementation

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard drawingEnabled == true else {
            return
        }

        self.delegate?.SwiftyDrawDidCancelDrawing(view: self)
    }

    /// Remove last stroked line

    public func removeLastLine() {
        if pathArray.count > 0 {
            let last = pathArray.popLast()
            viewModel.remove(line: last)
        }
        setNeedsDisplay()
    }

    /// Clear all stroked lines on canvas

    public func clearCanvas() {
        pathArray = []
        viewModel.clear()
        setNeedsDisplay()
    }

    /********************************** Private Functions **********************************/

    private func setTouchPoints(_ touch: UITouch,view: UIView) {
        previousPoint = touch.previousLocation(in: view)
        previousPreviousPoint = touch.previousLocation(in: view)
        currentPoint = touch.location(in: view)
    }

    private func updateTouchPoints(_ touch: UITouch,view: UIView) {
        previousPreviousPoint = previousPoint
        previousPoint = touch.previousLocation(in: view)
        currentPoint = touch.location(in: view)
    }

    private func createNewPath() -> CGMutablePath {
        let midPoints = getMidPoints()
        let subPath = createSubPath(midPoints.0, mid2: midPoints.1)
        let newPath = addSubPathToPath(subPath)
        return newPath
    }

    private func calculateMidPoint(_ p1 : CGPoint, p2 : CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5);
    }

    private func getMidPoints() -> (CGPoint,  CGPoint) {
        let mid1 : CGPoint = calculateMidPoint(previousPoint, p2: previousPreviousPoint)
        let mid2 : CGPoint = calculateMidPoint(currentPoint, p2: previousPoint)
        return (mid1, mid2)
    }

    private func createSubPath(_ mid1: CGPoint, mid2: CGPoint) -> CGMutablePath {
        let subpath : CGMutablePath = CGMutablePath()
        subpath.move(to: CGPoint(x: mid1.x, y: mid1.y))
        subpath.addQuadCurve(to: CGPoint(x: mid2.x, y: mid2.y), control: CGPoint(x: previousPoint.x, y: previousPoint.y))
        return subpath
    }

    private func addSubPathToPath(_ subpath: CGMutablePath) -> CGMutablePath {
        let bounds : CGRect = subpath.boundingBox
        let drawBox : CGRect = bounds.insetBy(dx: -2.0 * lineWidth, dy: -2.0 * lineWidth)
        self.setNeedsDisplay(drawBox)
        return subpath
    }
}
