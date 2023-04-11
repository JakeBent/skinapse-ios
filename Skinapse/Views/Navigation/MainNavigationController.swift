//
//  MainNavigationController.swift
//  Skinapse
//
//  Created by Jake Benton on 7/23/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class MainNavigationController: UINavigationController {

    class Layout: MasterLayout {
        static func forcePortrait() {
            UIDevice.current.setValue(UIInterfaceOrientationMask.portrait.rawValue, forKey: "orientation")
        }
        static let checkInScaleSmall = CGAffineTransform(scaleX: 0.7, y: 0.7)
        static let checkInDurations: (Float, Float, Float) = (
            first: 0.5,
            second: 0.5,
            third: 0.5
        )
        static let tabBarSwitchDuration: TimeInterval = 0.2
        static let tabBarFadeDuration: TimeInterval = 0.15
        static let tabBarRightRotation = CGAffineTransform(rotationAngle: -.pi / 2)
        static let tabBarLeftRotation = CGAffineTransform(rotationAngle: -3 * .pi / 2)
        static let alertFadeDuration: TimeInterval = 0.3
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return orientations
    }

    private var orientations: UIInterfaceOrientationMask = .allButUpsideDown
    private let checkInView = CheckInView()
    private var checkInViewLeftConstraint: NSLayoutConstraint!
    private var checkInViewRightConstraint: NSLayoutConstraint!
    private var checkInViewBottomConstraint: NSLayoutConstraint!
    private var checkInViewTopConstraint: NSLayoutConstraint!
    private let blurView = Layout.effectView()
        private let alertView = AlertView()
        private let tabBar = TabBar()
    private var tabBarBottomConstraint: NSLayoutYAxisAnchor!
    private var tabBarSideConstraint: NSLayoutYAxisAnchor!
    private let views = [
        HomeViewController(),
        LogViewController(),
        ViewController(),
        LogViewController()
    ]

    private var staticViews: [UIView] {
        return [tabBar, blurView, checkInView, alertView]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialLayout()

        viewControllers = [views[0]]
        tabBar.selectedIndex = 0
        tabBar.delegate = self

        checkInView.cancelAction = { [unowned self] in
            self.endCheckIn()
        }
        checkInView.doneAction = { [unowned self] in
            self.endCheckIn()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: Layout.tabBarFadeDuration) { [weak self] in
            self?.tabBar.alpha = 1
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let startOrientation = UIApplication.shared.statusBarOrientation
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.tabBar.alpha = 0
            self?.layoutContent()
        }) { [weak self] _ in
            self?.layoutTabBar(for: size, startOrientation: startOrientation)
            UIView.animate(withDuration: Layout.tabBarFadeDuration) { [weak self] in
                self?.tabBar.alpha = 1
            }
        }
    }
}

extension MainNavigationController {
    private func initialLayout() {
        setNavigationBarHidden(true, animated: false)

        staticViews.forEach { view.addSubview($0) }

        checkInViewLeftConstraint = checkInView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
        checkInViewRightConstraint = checkInView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
        checkInViewBottomConstraint = checkInView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        checkInViewTopConstraint = checkInView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)

        blurView.pinToEdges(of: view)

        alertView.rightAnchor.constraint(equalTo: checkInView.rightAnchor).isActive = true
        alertView.topAnchor.constraint(equalTo: checkInView.topAnchor, constant: Layout.standardSpacing).isActive = true

        [
            checkInViewLeftConstraint, checkInViewRightConstraint,
            checkInViewBottomConstraint, checkInViewTopConstraint,
        ].forEach { $0.isActive = true }

        tabBar.alpha = 0
        blurView.isHidden = true
        checkInView.alpha = 0
        checkInView.isHidden = true
        checkInView.transform = Layout.checkInScaleSmall
        alertView.alpha = 0
        alertView.isHidden = true

        layout(for: UIScreen.main.bounds.size)
    }

    func startCheckIn() {
        orientations = .portrait
        Layout.forcePortrait()
        checkInView.isHidden = false
        blurView.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0.0, animations: { [unowned self] in
            self.blurView.effect = UIBlurEffect(style: .light)
        })
        UIView.animate(withDuration: 0.3, delay: 0.1, animations: { [unowned self] in
            self.checkInView.alpha = 1
        })
        UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, animations: { [unowned self] in
            self.checkInView.transform = Layout.scaleReset
        })
    }

    func endCheckIn() {
        checkInViewTopConstraint.constant = Layout.screenHeight
        checkInViewBottomConstraint.constant = Layout.screenHeight
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.view.layoutIfNeeded()
            self.checkInView.transform = Layout.checkInScaleSmall
            self.checkInView.resign()
        }
        UIView.animate(withDuration: 0.2, delay: 0.05, animations: { [unowned self] in
            self.checkInView.alpha = 0
        })
        UIView.animate(withDuration: 0.3, delay: 0.15, animations: { [unowned self] in
            self.blurView.effect = nil
        }) { [unowned self] _ in
            self.orientations = .allButUpsideDown
            self.layoutContent()
            self.checkInView.isHidden = true
            self.blurView.isHidden = true
        }
    }

    func showAlert(text: String) {
        alertView.isHidden = false
        alertView.set(text: text)
        UIView.animate(withDuration: Layout.alertFadeDuration) { [weak self] in
            self?.alertView.alpha = 1
        }
    }

    func hideAlert() {
        UIView.animate(withDuration: Layout.alertFadeDuration, animations: { [weak self] in
            self?.alertView.alpha = 0
        }) { [weak self] _ in
            self?.alertView.isHidden = true
        }
    }

    private func layout(for size: CGSize, startOrientation: UIInterfaceOrientation? = nil) {
        layoutContent()
        layoutTabBar(for: size, startOrientation: startOrientation)
    }

    private func layoutContent() {
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            checkInViewLeftConstraint.constant = 0
            checkInViewRightConstraint.constant = -20
            checkInViewBottomConstraint.constant = -20
            checkInViewTopConstraint.constant = 0
        case .landscapeRight:
            checkInViewLeftConstraint.constant = 20
            checkInViewRightConstraint.constant = 0
            checkInViewBottomConstraint.constant = -20
            checkInViewTopConstraint.constant = 0
        default:
            checkInViewLeftConstraint.constant = 10
            checkInViewRightConstraint.constant = -10
            checkInViewBottomConstraint.constant = -20
            checkInViewTopConstraint.constant = 20
        }
    }

    private func layoutTabBar(for size: CGSize, startOrientation: UIInterfaceOrientation? = nil) {
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            tabBar.transform = Layout.tabBarRightRotation
            tabBar.frame = CGRect(
                x: size.width - Layout.tabBarSize,
                y: 0,
                width: Layout.tabBarSize,
                height: size.height
            )
            tabBar.rotateToLeftLandscape()
        case .landscapeLeft:
            tabBar.transform = Layout.tabBarLeftRotation
            tabBar.frame = CGRect(
                x: 0,
                y: 0,
                width: Layout.tabBarSize,
                height: size.height
            )
            tabBar.rotateToRightLandscape()
        case .portrait:
            tabBar.transform = Layout.rotationReset
            tabBar.frame = CGRect(
                x: 0,
                y: size.height - Layout.tabBarSize,
                width: size.width,
                height: Layout.tabBarSize
            )
            tabBar.rotateToPortrait()
        default: break
        }
    }
}

extension MainNavigationController: TabBarDelegate {
    func didChange(index: Int) {
        guard let currentView = topViewController as? ViewController else { return }
        let nextView = views[index]

        var animation: (() -> Void)!

        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            animation = { currentView.moveRight() }
        case .landscapeLeft:
            animation = { currentView.moveLeft() }
        default:
            animation = { currentView.moveDown() }
        }

        UIView.animate(withDuration: Layout.tabBarSwitchDuration, animations: animation) { [weak self] _ in
            self?.viewControllers = [nextView]
        }
    }
}

class AlertView: UIView {

    class Layout: MasterLayout {
        static let infoFont: UIFont = .main(size: 18, weight: .bold)
        static let buttonSize: CGFloat = 74
        static let expandedHeight: CGFloat = 200
        static let animatorDuration: TimeInterval = 0.5
        static let rotationExpand = CGAffineTransform(rotationAngle: .pi).rotated(by: (7 * .pi) / 4)
        static let rotationShrink = CGAffineTransform(rotationAngle: 2 * .pi).rotated(by: 0)
        static let scaleExpand = CGAffineTransform(scaleX: 10, y: 10)
    }

    var navController: MainNavigationController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let nav = parentResponder as? MainNavigationController {
                return nav
            }
        }
        return nil
    }

    var isExpanded = false {
        didSet {
            actionButton.removeTarget(self, action: isExpanded ? #selector(expand) : #selector(dismiss), for: .touchUpInside)
            actionButton.addTarget(self, action: isExpanded ? #selector(dismiss) : #selector(expand), for: .touchUpInside)

            heightConstraint.constant = isExpanded ? Layout.expandedHeight : Layout.buttonSize
            widthConstraint.constant = isExpanded ? Layout.smallestSide - (Layout.standardSpacing * 2) : Layout.buttonSize
            circleMaskView.frame = CGRect(
                x: isExpanded ? widthConstraint.constant - Layout.buttonSize : 0,
                y: 0,
                width: Layout.buttonSize,
                height: Layout.buttonSize
            )
            layoutIfNeeded()

            infoLabel.alpha = isExpanded ? 1 : 0
        }
    }

    let animator = UIViewPropertyAnimator(duration: Layout.animatorDuration, curve: .easeInOut)

    let actionButton = Layout.imageButton(withImage: #imageLiteral(resourceName: "check_in"))
    let circleMaskView = Layout.view(withColor: .white)
    let infoLabel = Layout.label(withColor: .white, font: Layout.infoFont)
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!

    private var views: [UIView] {
        return [infoLabel, actionButton]
    }

    init() {
        super.init(frame: .zero)
        initialLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AlertView {
    private func initialLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        views.forEach {
            addSubview($0)
        }

        layer.cornerRadius = Layout.buttonSize / 2

        backgroundColor = .mainOrange
        mask = circleMaskView

        actionButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        actionButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        actionButton.heightAnchor.constraint(equalToConstant: Layout.buttonSize).isActive = true
        actionButton.widthAnchor.constraint(equalTo: actionButton.heightAnchor).isActive = true

        infoLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        infoLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        circleMaskView.layer.cornerRadius = Layout.buttonSize / 2
        circleMaskView.frame = CGRect(
            x: 0,
            y: 0,
            width: Layout.buttonSize,
            height: Layout.buttonSize
        )

        heightConstraint = heightAnchor.constraint(equalToConstant: Layout.buttonSize)
        widthConstraint = widthAnchor.constraint(equalToConstant: Layout.buttonSize)

        heightConstraint.isActive = true
        widthConstraint.isActive = true

        infoLabel.alpha = 0
        actionButton.addTarget(self, action: #selector(expand), for: .touchUpInside)
        actionButton.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(swipeButton(gesture:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(swipeView(gesture:))))
    }

    func set(text: String) {
        infoLabel.text = text
    }

    @objc private func expand() {
        isExpanded = true

        UIView.animate(withDuration: Layout.animatorDuration) { [weak self] in
            self?.circleMaskView.transform = Layout.scaleExpand
            self?.actionButton.transform = Layout.rotationExpand
        }
    }

    @objc private func dismiss() {
        if isExpanded {
            UIView.animate(withDuration: Layout.animatorDuration, animations: { [weak self] in
                self?.circleMaskView.transform = Layout.scaleReset
                self?.actionButton.transform = Layout.rotationShrink
            }) { [weak self] _ in
                self?.isExpanded = false
                self?.navController?.hideAlert()
            }
        }
    }

    @objc func swipeButton(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self)
        let translation = gesture.translation(in: self)
        handleSwipe(
            state: gesture.state,
            velocity: CGPoint(x: -velocity.x, y: velocity.y),
            translation: CGPoint(x: -translation.x, y: translation.y),
            scale: (start: Layout.scaleReset, end: Layout.scaleExpand),
            rotation: (start: Layout.rotationShrink, end: Layout.rotationExpand),
            isOpening: true
        )
    }

    @objc func swipeView(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self)
        let translation = gesture.translation(in: self)
        handleSwipe(
            state: gesture.state,
            velocity: CGPoint(x: velocity.x, y: -velocity.y),
            translation: CGPoint(x: translation.x, y: -translation.y),
            scale: (start: Layout.scaleExpand, end: Layout.scaleReset),
            rotation: (start: Layout.rotationExpand, end: Layout.rotationShrink),
            isOpening: false
        )
    }

    private func handleSwipe(
        state: UIGestureRecognizerState,
        velocity: CGPoint,
        translation: CGPoint,
        scale: (start: CGAffineTransform, end: CGAffineTransform),
        rotation: (start: CGAffineTransform, end: CGAffineTransform),
        isOpening: Bool
        ) {

        let distance = sqrt(pow(translation.x, 2) + pow(translation.y, 2))
        let percentage = min(distance / Layout.expandedHeight, 1)

        func shouldFinish() -> Bool {
            let combined = velocity.x + velocity.y
            let shouldForPercentage = percentage > 0.35 && combined > -50
            return combined > 300 || shouldForPercentage
        }

        switch state {
        case .began:
            if animator.isRunning { animator.stopAnimation(true) }
            if isOpening { isExpanded = true }

            animator.addAnimations { [weak self] in
                self?.circleMaskView.transform = scale.end
                self?.actionButton.transform = rotation.end
            }
            animator.startAnimation()
            animator.pauseAnimation()

        case .changed:
            animator.fractionComplete = percentage < 0 ? 0 : percentage

        case .ended, .cancelled, .failed:
            if shouldFinish() {
                animator.addCompletion { [weak self] _ in
                    if !isOpening {
                        self?.isExpanded = false
                        self?.navController?.hideAlert()
                    }
                }
                animator.startAnimation()
            } else {
                animator.stopAnimation(true)
                animator.addAnimations { [weak self] in
                    self?.circleMaskView.transform = scale.start
                    self?.actionButton.transform = rotation.start
                }
                animator.addCompletion { [weak self] _ in
                    if isOpening { self?.isExpanded = false }
                }
                animator.startAnimation()
            }
        default: break
        }
    }
}
