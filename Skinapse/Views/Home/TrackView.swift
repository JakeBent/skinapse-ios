//
//  TrackView.swift
//  Skinapse
//
//  Created by Jake Benton on 7/24/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

protocol TrackViewDelegate: AnyObject {
    func trackViewDidChangeSection(_ trackView: TrackView, section: Int)
}

class TrackView: UIControl {

    class Layout: MasterLayout {
        static let thumbSize: CGFloat = 30
    }

    weak var delegate: TrackViewDelegate?
    private let silhouette = Layout.imageView(withImage: #imageLiteral(resourceName: "silhouette"), renderingMode: .alwaysOriginal)
    private let track = Layout.imageView(withImage: #imageLiteral(resourceName: "track"), renderingMode: .alwaysOriginal)
    private let thumb = Layout.imageView(withImage: #imageLiteral(resourceName: "thumb"), renderingMode: .alwaysOriginal)
    private var views: [UIView] {
        return [silhouette, track, thumb]
    }

    var currentAngle: Double = 0 {
        didSet {
            updateThumbPosition()
        }
    }
    var currentSection: Int = 0 {
        didSet {
            delegate?.trackViewDidChangeSection(self, section: currentSection)
        }
    }

    var checkIns: [[String: String]] = [] {
        didSet {
            interval = Double(360 / checkIns.count)
            stops = checkIns.enumerated().map { interval * Double($0.offset) }
        }
    }

    var interval: Double = 0
    var stops: [Double] = []

    init(size: CGFloat = Layout.trackSize) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true

        views.forEach { addSubview($0) }

        track.pinToEdges(of: self)
        silhouette.pinToEdges(
            of: self,
            vPadding: (size - (size * Layout.silhouetteRatios.height)) / 2,
            hPadding: (size - (size * Layout.silhouetteRatios.width)) / 2
        )

        thumb.translatesAutoresizingMaskIntoConstraints = true
        thumb.frame = CGRect(
            x: (size / 2) - (Layout.thumbSize / 2),
            y: size - Layout.thumbSize,
            width: Layout.thumbSize,
            height: Layout.thumbSize
        )
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateAngle(from: touch)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateAngle(from: touch)
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        let closestDiff = getCurrentSection()
        let duration = closestDiff.diff > 25 ? 0.2 : 0.1

        moveToAngle(angle: stops[closestDiff.index], duration: duration)
    }

    func moveToAngle(angle: Double, duration: CFTimeInterval) {
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height/2)

        let clockwise: Bool = {
            var diff = angle - currentAngle
            if diff < 0 {
                diff += 360
            }
            return diff < 180
        }()
        let sAngle = degreeToRadian(currentAngle + 90)
        let eAngle = degreeToRadian(angle + 90)

        let path = UIBezierPath(
            arcCenter: center,
            radius: (bounds.size.width - 30) / 2,
            startAngle: CGFloat(sAngle),
            endAngle: CGFloat(eAngle),
            clockwise: clockwise
        )

        CATransaction.begin()
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = duration
        animation.path = path.cgPath
        thumb.layer.add(animation, forKey: "moveToAngle")
        CATransaction.setCompletionBlock { [weak self] in
            self?.currentAngle = angle
        }
        CATransaction.commit()
    }

    private func updateAngle(from touch: UITouch) {
        let location = touch.location(in: self)
        let dx = location.x - (frame.size.width * 0.5)
        let dy = location.y - (frame.size.height * 0.5)

        let angle = Double(atan2(Double(dy), Double(dx)))

        var degreeAngle = radianToDegree(angle) - 90
        if degreeAngle < 0 {
            degreeAngle = 360 - (-degreeAngle)
        }

        currentAngle = degreeAngle
        currentSection = getCurrentSection().index
    }

    private func getCurrentSection() -> (index: Int, diff: Double) {
        var closestDiff: (index: Int, diff: Double) = (0, 500)
        stops.enumerated().forEach { stop in
            var diff = fabs(currentAngle - stop.element)
            if stop.offset == 0 && diff > 360 - interval {
                diff = fabs(diff - 360)
            }
            if diff < closestDiff.diff {
                closestDiff = (stop.offset, diff)
            }
        }
        return closestDiff
    }

    private func updateThumbPosition() {
        let angle = degreeToRadian(currentAngle + 90)
        let radius = (self.frame.size.width - 30) * 0.5
        let center = CGPoint(x: radius, y: radius)
        var rect = thumb.frame

        let finalX = (CGFloat(cos(angle)) * radius) + center.x
        let finalY = (CGFloat(sin(angle)) * radius) + center.y

        rect.origin.x = finalX
        rect.origin.y = finalY

        thumb.frame = rect
    }

    private func degreeToRadian(_ degree: Double) -> Double {
        return degree * (.pi / 180)
    }

    private func radianToDegree(_ radian: Double) -> Double {
        return radian * (180 / .pi)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
