//
//  CheckInView.swift
//  Skinapse
//
//  Created by Jake Benton on 8/1/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit

class CheckInView: UIView {
    class Layout: MasterLayout {
        static let cornerRadius: CGFloat = 10
        static let bounceStart: CGFloat = largeSpacing
        static let bounceThreshold: CGFloat = 70
        static let headerHeight: CGFloat = 60
        static let scrollToCameraFont: UIFont = .main(size: 12, weight: .bold)
        static let scaleBump = CGAffineTransform(scaleX: 1.2, y: 1.2)
        static let scaleGrow = CGAffineTransform(scaleX: 75, y: 75)
        static let animatorDuration: TimeInterval = 0.3
    }

    class Constants: MasterConstants {
        static let scrollToCameraText = "SCROLL TO CAMERA"
        static let morningTitle = "MORNING"
        static let eveningTitle = "EVENING"
        static let sleepCellInfo: CheckInSliderCellInfo = (
            title: "HOW RESTFUL WAS YOUR SLEEP LAST NIGHT",
            descriptions: [
                "My sleep was poor",
                "My sleep was fine",
                "My sleep was great",
            ]
        )
        static let stressCellInfo: CheckInSliderCellInfo = (
            title: "WHAT WERE YOUR STRESS LEVELS LIKE TODAY",
            descriptions: [
                "I had little to no stress",
                "I spent some time stressed",
                "I was stressed all day",
            ]
        )
        static let dietInfo: CheckInChecklistCellInfo = (
            title: "TODAY, DID YOU CONSUME...",
            options: [
                "Excess Sugar",
                "Alcohol",
                "Gluten",
                "Soy",
                "Dairy",
            ]
        )
        static let exerciseInfo: CheckInChecklistCellInfo = (
            title: "TODAY, DID YOU...",
            options: [
                "Exercise",
                "Sweat excessively",
                "Get dirty",
                "Touch your face excessively",
            ]
        )
        static let laundryInfo: CheckInChecklistCellInfo = (
            title: "IN THE LAST WEEK, HAVE YOU...",
            options: [
                "Washed your sheets and pillowcases",
                "Washed your bath towels",
            ]
        )
    }

    var doneAction: (() -> Void)?
    var cancelAction: (() -> Void)?

    private var willScrollToCamera = false
    private var isLoadingCamera = false
    private var isCalendarOpen = false
    private var previousBouncePercentage: CGFloat = 0
    private let animator = Animator()
    private let viewModel = CheckInViewModel()

    private let vibration = UIImpactFeedbackGenerator(style: .light)
    private let header = CheckInHeader()
    private var headerTopConstraint: NSLayoutConstraint!
    private let calendarView = Layout.view(withColor: .mainOrange)
    private var calendarViewConstraint: NSLayoutConstraint!
    private let calendarAnimator = UIViewPropertyAnimator(duration: Layout.animatorDuration, curve: .easeInOut)
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private var scrollViewTopConstraint: NSLayoutConstraint!
    private var scrollViewBottomConstraint: NSLayoutConstraint!
    private let cameraSpinner = Layout.spinner()
    private let cameraView = CameraView()
    private let scrollToCameraView = Layout.view(withColor: .clear)
    private let scrollToCameraTouchView = Layout.view(withColor: .clear)
    private let scrollToCameraLabel = Layout.label(withColor: .black, font: Layout.scrollToCameraFont, text: Constants.scrollToCameraText)
    private let scrollToCameraCaret = Layout.imageView(withImage: #imageLiteral(resourceName: "down_carat_large"), tint: .black)
    private let morningProductsCell = CheckInProductsCell(title: Constants.morningTitle)
    private let eveningProductsCell = CheckInProductsCell(title: Constants.eveningTitle)
    private let sleepCell = CheckInSliderCell(info: Constants.sleepCellInfo)
    private let stressCell = CheckInSliderCell(info: Constants.stressCellInfo)
    private let dietCell = CheckInChecklistCell(info: Constants.dietInfo)
    private let exerciseCell = CheckInChecklistCell(info: Constants.exerciseInfo)
    private let laundryCell = CheckInChecklistCell(info: Constants.laundryInfo)
    private let spacerCell = CheckInSpacerCell()

    private var topViews: [UIView] {
        return [scrollToCameraView, scrollView, cameraView, calendarView, header]
    }
    private var scrollToCameraViews: [UIView] {
        return [scrollToCameraLabel, scrollToCameraCaret, cameraSpinner, scrollToCameraTouchView]
    }
    private var cells: [CheckInCell] {
        return [morningProductsCell, eveningProductsCell, sleepCell, stressCell, dietCell, exerciseCell, laundryCell, spacerCell]
    }

    init() {
        super.init(frame: .zero)

        initialLayout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckInView {
    private func initialLayout() {
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = Layout.cornerRadius

        topViews.forEach { addSubview($0) }

        headerTopConstraint = header.topAnchor.constraint(equalTo: topAnchor)
        headerTopConstraint.isActive = true
        header.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        header.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: Layout.headerHeight).isActive = true

        calendarView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        calendarView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        calendarView.heightAnchor.constraint(equalToConstant: Layout.smallestSide).isActive = true
        calendarViewConstraint = calendarView.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        calendarViewConstraint.isActive = true

        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollViewTopConstraint = scrollView.topAnchor.constraint(equalTo: header.bottomAnchor)
        scrollViewTopConstraint.isActive = true
        scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        scrollViewBottomConstraint.isActive = true

        scrollToCameraViews.forEach { scrollToCameraView.addSubview($0) }

        scrollToCameraView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollToCameraView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        scrollToCameraCaret.bottomAnchor.constraint(equalTo: scrollToCameraView.bottomAnchor, constant: -Layout.standardSpacing).isActive = true
        scrollToCameraCaret.centerXAnchor.constraint(equalTo: scrollToCameraView.centerXAnchor).isActive = true

        cameraSpinner.centerXAnchor.constraint(equalTo: scrollToCameraCaret.centerXAnchor).isActive = true
        cameraSpinner.centerYAnchor.constraint(equalTo: scrollToCameraCaret.centerYAnchor).isActive = true

        scrollToCameraLabel.topAnchor.constraint(equalTo: scrollToCameraView.topAnchor, constant: Layout.standardSpacing).isActive = true
        scrollToCameraLabel.bottomAnchor.constraint(equalTo: scrollToCameraCaret.topAnchor, constant: -Layout.smallSpacing).isActive = true
        scrollToCameraLabel.centerXAnchor.constraint(equalTo: scrollToCameraView.centerXAnchor).isActive = true

        scrollToCameraTouchView.pinToEdges(of: scrollToCameraView)
        cameraView.pinToEdges(of: self)
        scrollView.layoutAs(checkInCells: cells)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        scrollView.delegate = self
        cameraView.delegate = self

        layout()
        header.titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleCalendar)))
        header.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragHeader(gesture:))))
        calendarView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragCalendar(gesture:))))
        header.cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        header.doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        spacerCell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCamera)))
    }

    func resign() {
        morningProductsCell.entryView.resign()
        eveningProductsCell.entryView.resign()
    }

    @objc private func cancelTapped() {
        cancelAction?()
        layout()
    }

    @objc private func doneTapped() {
        doneAction?()
        layout()
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
    }

    @objc private func toggleCalendar() {
        isCalendarOpen = !isCalendarOpen
        calendarViewConstraint.constant = isCalendarOpen ? Layout.smallestSide : 0
        calendarAnimator.addAnimations { [weak self] in
            self?.header.rotateArrowTo(angle: self?.isCalendarOpen == true ? .pi : 0)
            self?.layoutIfNeeded()
        }
        calendarAnimator.startAnimation()
    }

    @objc private func dragCalendar(gesture: UIPanGestureRecognizer) {
        handleSwipe(
            state: gesture.state,
            velocity: -gesture.velocity(in: self).y,
            translation: -gesture.translation(in: self).y,
            rotation: (.pi, 0),
            constant: (Layout.smallestSide, 0),
            isOpening: false
        )
     }

    @objc private func dragHeader(gesture: UIPanGestureRecognizer) {
        handleSwipe(
            state: gesture.state,
            velocity: gesture.velocity(in: self).y,
            translation: gesture.translation(in: self).y,
            rotation: (0, .pi),
            constant: (0, Layout.smallestSide),
            isOpening: true
        )
    }

    @objc private func showCamera() {
        isLoadingCamera = true
        cameraSpinner.startAnimating()

        animator.queue.append({(
            changes: { [weak self] in
                self?.cameraSpinner.transform = Layout.scaleReset
                self?.scrollToCameraCaret.transform = Layout.scaleShrink
            },
            duration: 0.2,
            delay: 0
        )})

        animator.start()

        let height = scrollView.frame.height + Layout.headerHeight

        cameraView.prepare(animated: true) { [weak self] error in
            do {
                try self?.cameraView.displayPreview()
                self?.cameraView.showSettingsText = false
            } catch {
                print(error)
                self?.cameraView.showSettingsText = true
            }

            self?.animator.queue.append({
                self?.cameraView.isHidden = false
                return (
                    changes: { [weak self] in
                        self?.cameraSpinner.alpha = 0
                        self?.cameraView.alpha = 1
                    },
                    duration: 0.2,
                    delay: 0
                )
            })
            self?.animator.queue.append({
                self?.headerTopConstraint.constant = -height
                self?.scrollViewBottomConstraint.constant = -height
                return (
                    changes: { [weak self] in
                        self?.layoutIfNeeded()
                        self?.cameraView.circleMask.transform = Layout.scaleGrow
                        self?.cameraView.controlsView.alpha = 1
                    },
                    duration: 0.5,
                    delay: 0
                )
            })
            self?.animator.queue.append({
                return (
                    changes: { self?.isLoadingCamera = false },
                    duration: 0,
                    delay: 0
                )
            })
            self?.animator.start()
        }
    }

    private func handleSwipe(state: UIGestureRecognizer.State, velocity: CGFloat, translation: CGFloat, rotation: (start: CGFloat, end: CGFloat), constant: (start: CGFloat, end: CGFloat), isOpening: Bool) {
        let percentage = translation / Layout.smallestSide

        switch state {
        case .began:
            if calendarAnimator.isRunning {
                calendarAnimator.stopAnimation(true)
            }

            calendarViewConstraint.constant = constant.end
            calendarAnimator.addAnimations { [weak self] in
                self?.header.rotateArrowTo(angle: rotation.end)
                self?.layoutIfNeeded()
            }
            calendarAnimator.startAnimation()
            calendarAnimator.pauseAnimation()
        case .changed:
            if percentage < 0 {
                calendarAnimator.fractionComplete = 0
            } else if percentage > 1 {
                calendarAnimator.fractionComplete = 1
            } else {
                calendarAnimator.fractionComplete = percentage
            }
        case .ended, .cancelled, .failed:
            if velocity > 300 || (percentage > 0.35 && velocity > -50) {
                calendarAnimator.addCompletion { [weak self] _ in
                    self?.isCalendarOpen = isOpening
                }
                calendarAnimator.startAnimation()
            } else {
                calendarAnimator.stopAnimation(true)
                calendarViewConstraint.constant = constant.start
                calendarAnimator.addAnimations { [weak self] in
                    self?.header.rotateArrowTo(angle: rotation.start)
                    self?.layoutIfNeeded()
                }
                calendarAnimator.startAnimation()
            }
        default: break
        }
    }

    private func layout() {
        scrollView.setContentOffset(.zero, animated: false)
        scrollViewTopConstraint.constant = 0
        scrollViewBottomConstraint.constant = 0
        scrollToCameraLabel.alpha = 0
        scrollToCameraCaret.alpha = 0
        cameraSpinner.alpha = 1
        cameraSpinner.transform = Layout.scaleShrink
        cameraSpinner.stopAnimating()
        cameraView.alpha = 0
        cameraView.isHidden = true
        cameraView.endSession()
        scrollToCameraCaret.transform = Layout.scaleReset
    }
}

extension CheckInView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let percentage = scrollView.bounceDownAmount(extraOffset: 20) / Layout.bounceThreshold

        if percentage < 1 {
            scrollToCameraLabel.alpha = percentage
            scrollToCameraCaret.alpha = percentage
            willScrollToCamera = false
        }
        if percentage > 1 && previousBouncePercentage < 1 && !isLoadingCamera {
            vibration.impactOccurred()
            willScrollToCamera = true

            animator.queue.append(contentsOf: [
                {(
                    changes: { [weak self] in
                        self?.scrollToCameraCaret.alpha = 1
                        self?.scrollToCameraLabel.alpha = 1
                        self?.scrollToCameraCaret.transform = Layout.scaleBump
                        self?.scrollToCameraLabel.transform = Layout.scaleBump
                    },
                    duration: 0.1,
                    delay: 0
                )},
                {(
                    changes: { [weak self] in
                        self?.scrollToCameraCaret.transform = Layout.scaleReset
                        self?.scrollToCameraLabel.transform = Layout.scaleReset
                    },
                    duration: 0.1,
                    delay: 0
                )},
            ])
            animator.start()
        }

        previousBouncePercentage = percentage
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if willScrollToCamera {
            showCamera()
        }
    }
}

extension CheckInView: CameraViewDelegate {
    func cameraDidChoose(image: UIImage?) {
    }

    func cameraWillDismiss(otherChanges: [AnimationInfo], dismissCamera: @escaping () -> Void) {
        animator.queue.append({ [weak self] in
            self?.headerTopConstraint.constant = 0
            self?.scrollViewBottomConstraint.constant = 0
            return (
                changes: { [weak self] in
                    dismissCamera()
                    self?.layoutIfNeeded()
                },
                duration: 0.5,
                delay: 0
            )
        })
        animator.queue.append({(
            changes: { [weak self] in
                self?.cameraView.alpha = 0
                self?.scrollToCameraCaret.transform = Layout.scaleReset
            },
            duration: 0.2,
            delay: 0
        )})
        animator.queue.append({(
            changes: { [weak self] in
                self?.cameraView.isHidden = true
                self?.cameraSpinner.alpha = 1
                self?.cameraSpinner.transform = Layout.scaleShrink
            },
            duration: 0,
            delay: 0
        )})
        animator.queue.append(contentsOf: otherChanges)

        animator.start()
    }
}

typealias AnimationInfo = () -> (changes: () -> Void, duration: TimeInterval, delay: TimeInterval)

class Animator: NSObject {
    var isAnimating = false
    var queue: [AnimationInfo] = []

    func start() {
        if !isAnimating { animate() }
    }

    private func animate() {
        guard !queue.isEmpty else { isAnimating = false; return }

        let next = queue.removeFirst()()
        isAnimating = true

        if next.duration > 0 {
            UIView.animate(withDuration: next.duration, delay: next.delay, options: [], animations: next.changes) { _ in
                self.animate()
            }
        } else {
            next.changes()
            animate()
        }
    }
}

class CheckInViewModel: NSObject {


}
