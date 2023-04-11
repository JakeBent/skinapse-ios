//
//  Layout.swift
//  Skinapse
//
//  Created by Jake Benton on 7/23/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class MasterConstants {

}

class MasterLayout {

    // MARK: Navigation

    static var tabBarSize: CGFloat {
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft, .landscapeRight:
            return 70
        default:
            return isIPhoneX ? 90 : 70
        }
    }

    // MARK: General

    static var largeSpacing: CGFloat = 32
    static var standardSpacing: CGFloat = 20
    static var mediumSpacing: CGFloat = 12
    static var smallSpacing: CGFloat = 4
    static let minButtonSize: CGFloat = 60
    class var transitionDuration: TimeInterval { return 0.35 }

    static var scaleShrink = CGAffineTransform(scaleX: 0.001, y: 0.001)
    static var scaleReset = CGAffineTransform(scaleX: 1, y: 1)
    static var rotationReset = CGAffineTransform(rotationAngle: 0)

    static var safeAreaStandardSpacing: CGFloat = isIPhoneX ? 0 : 20
    static var smallShrinkingSpacing: CGFloat = isSmallPhone ? 0 : 10
    static var shrinkingSpacing: CGFloat = isSmallPhone ? 8 : 16

    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    static var screenSize: CGSize {
        return CGSize(width: screenWidth, height: screenHeight)
    }
    static var contentHeight: CGFloat {
        return UIApplication.shared.statusBarOrientation.isPortrait ?
            screenHeight - safeAreaStandardSpacing - tabBarSize :
            screenHeight
    }
    static var contentWidth: CGFloat {
        return UIApplication.shared.statusBarOrientation.isPortrait ?
            screenWidth:
            screenWidth - safeAreaStandardSpacing - 112
    }
    static var smallestSide: CGFloat {
        return screenWidth > screenHeight ? screenHeight : screenWidth
    }
    static var isIPhoneX: Bool {
        return UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
    }
    static var isSmallPhone: Bool {
        return UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height <= 1334
    }
    static var cellWidth: CGFloat {
        return UIApplication.shared.statusBarOrientation.isPortrait ? contentWidth : contentWidth / 2
    }

    // MARK: Home

    static var trackSize: CGFloat = isSmallPhone ? 250 : 313
    static let silhouetteWidth: CGFloat = 145
    static let silhouetteHeight: CGFloat = 173
    static var silhouetteRatios: (width: CGFloat, height: CGFloat) = (silhouetteWidth / 313, silhouetteHeight / 313)

    // MARK: generators

    static func label(withColor color: UIColor, font: UIFont, numberOfLines: Int = 0, text: String? = nil, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = color
        label.font = font
        label.numberOfLines = numberOfLines
        label.text = text
        label.textAlignment = alignment
        return label
    }

    static func view(withColor color: UIColor = .clear, frame: CGRect = .zero, cornerRadius: CGFloat = 0) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        view.frame = frame
        view.layer.cornerRadius = cornerRadius
        return view
    }

    static func passThroughView(withColor color: UIColor = .clear) -> PassThroughView {
        let view = PassThroughView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = color
        return view
    }

    static func stack(withAxis axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, alignment: UIStackView.Alignment, spacing: CGFloat = 0) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
        return stackView
    }

    static func imageView(withImage image: UIImage?, tint: UIColor = .white, renderingMode: UIImage.RenderingMode = .alwaysTemplate, contentMode: UIView.ContentMode = .scaleToFill) -> UIImageView {
        let imageView = UIImageView(image: image?.withRenderingMode(renderingMode))
        imageView.tintColor = tint
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = contentMode
        return imageView
    }

    static func imageButton(withImage image: UIImage, renderingMode: UIImage.RenderingMode = .alwaysOriginal, tint: UIColor = .mainOrange) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image.withRenderingMode(renderingMode), for: .normal)
        button.imageView?.tintColor = tint
        return button
    }

    static func textButton(withText text: String, color: UIColor, size: CGFloat = 12) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .main(size: size, weight: .bold)
        button.setTitle(text, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        return button
    }

    static func underlineButton(withText text: String, color: UIColor, size: CGFloat = 12) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        let string = NSAttributedString(
            string: text,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single,
                .foregroundColor: color,
                .font: UIFont.main(size: size, weight: .bold)
            ]
        )
        button.setAttributedTitle(string, for: .normal)
        return button
    }

    static func effectView(withEffect effect: UIVisualEffect? = nil) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    static func textField() -> UITextField {
        let field = UITextField()
        field.font = .main(size: 12)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }

    static func spinner(withStyle style: UIActivityIndicatorView.Style = .gray) -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(style: style)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.tintColor = .mainOrange
        spinner.hidesWhenStopped = true
        return spinner
    }
}
