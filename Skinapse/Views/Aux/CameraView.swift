//
//  CameraView.swift
//  Skinapse
//
//  Created by Jake Benton on 8/13/18.
//  Copyright © 2018 skinapse. All rights reserved.
//

import UIKit
import AVFoundation


protocol CameraViewDelegate: class {
    func cameraWillDismiss(otherChanges: [AnimationInfo], dismissCamera: @escaping () -> Void)
    func cameraDidChoose(image: UIImage?)
}

class CameraView: UIView {

    class Layout: MasterLayout {
        static let spinnerSize: CGFloat = 20
        static let settingsFont: UIFont = .main(size: 12)
    }

    weak var delegate: CameraViewDelegate?

    var showSettingsText = false {
        didSet {
            settingsText.isHidden = !showSettingsText
        }
    }

    let circleMask = Layout.view(withColor: .white)
    let controlsView = CameraControlsView()

    private var isPreviewing = false
    private var captureSession: AVCaptureSession?
    private var frontCamera: AVCaptureDevice?
    private var rearCamera: AVCaptureDevice?
    private var currentCameraPosition: CameraPosition?
    private var frontCameraInput: AVCaptureDeviceInput?
    private var rearCameraInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var flashMode: AVCaptureDevice.FlashMode = .off
    private var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?

    private let captureView = CameraCaptureView()
    private let settingsText = Layout.label(
        withColor: .white,
        font: Layout.settingsFont,
        text: "Please enable access to the camera for this app in your settings to use this feature",
        alignment: .center
    )

    private var views: [UIView] {
        return [controlsView, captureView, settingsText]
    }

    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }

    public enum CameraPosition {
        case front
        case rear
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        initialLayout()

        captureView.cameraView = self
        captureView.backAction = { [weak self] in
            UIView.animate(withDuration: Layout.transitionDuration, animations: { [weak self] in
                self?.captureView.alpha = 0
                self?.captureView.blurView.effect = nil
            }) { [weak self] _ in
                self?.captureView.isHidden = true
                self?.captureView.set(image: nil)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private functions

extension CameraView {
    private func initialLayout() {
        backgroundColor = .gray

        mask = circleMask

        views.forEach { addSubview($0) }

        controlsView.pinToEdges(of: self)
        captureView.pinToEdges(of: self)

        settingsText.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        settingsText.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Layout.standardSpacing).isActive = true
        settingsText.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true

        controlsView.backArrow.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        controlsView.switchCameraButton.addTarget(self, action: #selector(switchCameraTapped), for: .touchUpInside)
        controlsView.shutterButton.addTarget(self, action: #selector(shutterTapped), for: .touchUpInside)
        controlsView.alpha = 0

        settingsText.isHidden = true
        captureView.alpha = 0
        captureView.isHidden = true
    }

    @objc private func backTapped() {
        delegate?.cameraWillDismiss(
            otherChanges: [
                {(
                    changes: { [weak self] in self?.endSession() },
                    duration: 0,
                    delay: 0
                    )}
            ],
            dismissCamera: { [weak self] in
                self?.circleMask.transform = Layout.scaleShrink
                self?.controlsView.alpha = 0
            }
        )
    }

    @objc private func shutterTapped() {
        captureImage { [weak self] image, error in
            self?.captureView.isHidden = false
            self?.captureView.set(image: image, faceFrame: self?.controlsView.faceFrame, cameraPosition: self?.currentCameraPosition)

            UIView.animate(withDuration: Layout.transitionDuration, animations: { [weak self] in
                self?.captureView.alpha = 1
                self?.captureView.blurView.effect = UIBlurEffect(style: .light)
            })
        }
    }

    @objc private func switchCameraTapped() {
        do {
            try switchCameras()
        } catch {
            print(error)
        }
    }

    private func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard
            let captureSession = captureSession,
            captureSession.isRunning
            else { completion(nil, CameraControllerError.captureSessionIsMissing); return }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode

        photoOutput?.capturePhoto(with: settings, delegate: self)
        photoCaptureCompletionBlock = completion
    }

    private func switchCameras() throws {
        guard
            let currentCameraPosition = currentCameraPosition,
            let captureSession = captureSession,
            captureSession.isRunning
            else { throw CameraControllerError.captureSessionIsMissing }

        captureSession.beginConfiguration()

        func switchToCamera(nextPosition: CameraPosition) throws {
            guard
                let currentCameraInput = nextPosition == .rear ? frontCameraInput : rearCameraInput,
                captureSession.inputs.contains(currentCameraInput),
                let nextCamera = nextPosition == .rear ? rearCamera : frontCamera
                else { throw CameraControllerError.invalidOperation }

            let nextInput = try AVCaptureDeviceInput(device: nextCamera)

            if nextPosition == .rear {
                rearCameraInput = nextInput
            } else {
                frontCameraInput = nextInput
            }

            captureSession.removeInput(currentCameraInput)

            if captureSession.canAddInput(nextInput) {
                captureSession.addInput(nextInput)
                self.currentCameraPosition = nextPosition
            } else { throw CameraControllerError.invalidOperation }
        }

        switch currentCameraPosition {
        case .front:
            try switchToCamera(nextPosition: .rear)
        case .rear:
            try switchToCamera(nextPosition: .front)
        }

        captureSession.commitConfiguration()
    }
}

// MARK: Public functions

extension CameraView {

    func endSession() {
        captureSession?.stopRunning()
        captureSession = nil
        previewLayer?.removeFromSuperlayer()
    }

    func displayPreview() throws {
        guard
            let captureSession = captureSession,
            captureSession.isRunning
            else { throw CameraControllerError.captureSessionIsMissing }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait

        layer.insertSublayer(previewLayer!, at: 0)
        previewLayer?.frame = bounds
    }

    func prepare(animated: Bool, done: @escaping (Error?) -> Void) {
        if animated {
            circleMask.transform = Layout.scaleReset
            circleMask.layer.cornerRadius = Layout.spinnerSize / 2
            circleMask.frame = CGRect(
                x: (frame.width / 2) - (Layout.spinnerSize / 2),
                y: frame.height - Layout.spinnerSize - Layout.standardSpacing,
                width: Layout.spinnerSize,
                height: Layout.spinnerSize
            )
        }

        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }

        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera] , mediaType: .video, position: .unspecified)
            let cameras = session.devices.compactMap { $0 }
            guard !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }

            cameras.forEach { camera in
                if camera.deviceType == .builtInWideAngleCamera && camera.position == .front {
                    frontCamera = camera
                }
                if (camera.deviceType == .builtInWideAngleCamera || camera.deviceType == .builtInDualCamera) && camera.position == .back {
                    rearCamera = camera

                    do {
                        try camera.lockForConfiguration()
                    } catch {}
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }

        func configureDeviceInputs() throws {
            guard
                let captureSession = captureSession
                else { throw CameraControllerError.captureSessionIsMissing }

            if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)

                if captureSession.canAddInput(frontCameraInput!) {
                    captureSession.addInput(frontCameraInput!)
                }
                else { throw CameraControllerError.inputsAreInvalid }

                currentCameraPosition = .front
            } else if let rearCamera = rearCamera {
                rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)

                if captureSession.canAddInput(rearCameraInput!) {
                    captureSession.addInput(rearCameraInput!)
                }

                currentCameraPosition = .rear
            } else {
                throw CameraControllerError.noCamerasAvailable
            }
        }

        func configurePhotoOutput() throws {
            guard
                let captureSession = self.captureSession
                else { throw CameraControllerError.captureSessionIsMissing }

            photoOutput = AVCapturePhotoOutput()
            photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])])

            if captureSession.canAddOutput(photoOutput!) {
                captureSession.addOutput(photoOutput!)
            }

            captureSession.startRunning()
        }

        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            } catch { DispatchQueue.main.async { done(error) }; return }

            DispatchQueue.main.async {
                done(nil)
            }
        }
    }
}

extension CameraView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)

        } else if
            let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data) {

            self.photoCaptureCompletionBlock?(image, nil)
        } else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}













class CameraToolStack: UIView {

    class Layout: MasterLayout {
        static let font: UIFont = .main(size: 14)
        static let width: CGFloat = 80
        static let backArrowTransform = CGAffineTransform(rotationAngle: .pi / 2)
    }

    class Constants: MasterConstants {
        static let intenseText = "intense"
        static let moderateText = "moderate"
        static let lightText = "light"
    }

    weak var delegate: CameraToolViewDelegate?
    weak var scrollView: UIScrollView?
    var isExpanded = false
    private let brushType: BrushType
    private var closedTap: UIGestureRecognizer!
    private var brushTaps: [UITapGestureRecognizer] = []

    private let backButton = Layout.imageButton(withImage: #imageLiteral(resourceName: "down_carat_large"), renderingMode: .alwaysTemplate, tint: .black)
    private let intenseContainer = Layout.view(withColor: .clear)
    private var intenseContainerConstraint: NSLayoutConstraint!
    private let intenseCircle = Layout.imageView(withImage: #imageLiteral(resourceName: "circle"))
    private let intenseLabel = Layout.label(withColor: .black, font: Layout.font)
    private let moderateContainer = Layout.view(withColor: .clear)
    private var moderateContainerConstraint: NSLayoutConstraint!
    private let moderateCircle = Layout.imageView(withImage: #imageLiteral(resourceName: "circle"))
    private let moderateLabel = Layout.label(withColor: .black, font: Layout.font, text: Constants.moderateText)
    private let lightContainer = Layout.view(withColor: .clear)
    private var lightContainerConstraint: NSLayoutConstraint!
    private let lightCircle = Layout.imageView(withImage: #imageLiteral(resourceName: "circle"))
    private let lightLabel = Layout.label(withColor: .black, font: Layout.font, text: Constants.lightText)
    private var widthConstraint: NSLayoutConstraint!

    private var views: [UIView] {
        return [lightContainer, moderateContainer, intenseContainer]
    }

    init(brushType: BrushType) {
        self.brushType = brushType
        super.init(frame: .zero)

        initialLayout()

        closedTap = UITapGestureRecognizer(target: self, action: #selector(expand))
        addGestureRecognizer(closedTap)
        backButton.addTarget(self, action: #selector(shrink), for: .touchUpInside)

        let intenseTap = UITapGestureRecognizer(target: self, action: #selector(intenseSelected))
        let moderateTap = UITapGestureRecognizer(target: self, action: #selector(moderateSelected))
        let lightTap = UITapGestureRecognizer(target: self, action: #selector(lightSelected))
        brushTaps = [intenseTap, moderateTap, lightTap]
        brushTaps.forEach { $0.isEnabled = false }

        intenseContainer.addGestureRecognizer(intenseTap)
        moderateContainer.addGestureRecognizer(moderateTap)
        lightContainer.addGestureRecognizer(lightTap)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraToolStack {
    private func initialLayout () {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(backButton)
        backButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true
        backButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backButton.transform = Layout.backArrowTransform

        views.forEach { view in
            addSubview(view)
            view.topAnchor.constraint(equalTo: topAnchor, constant: Layout.smallSpacing).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.smallSpacing).isActive = true
            view.widthAnchor.constraint(equalToConstant: Layout.width).isActive = true
            view.layer.cornerRadius = 10
        }

        [intenseCircle, intenseLabel].forEach { view in
            intenseContainer.addSubview(view)
            view.centerXAnchor.constraint(equalTo: intenseContainer.centerXAnchor).isActive = true
        }
        [moderateCircle, moderateLabel].forEach { view in
            moderateContainer.addSubview(view)
            view.centerXAnchor.constraint(equalTo: moderateContainer.centerXAnchor).isActive = true
        }
        [lightCircle, lightLabel].forEach { view in
            lightContainer.addSubview(view)
            view.centerXAnchor.constraint(equalTo: lightContainer.centerXAnchor).isActive = true
        }

        backButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        moderateContainerConstraint = moderateContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
        intenseContainerConstraint = intenseContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
        lightContainerConstraint = lightContainer.centerXAnchor.constraint(equalTo: centerXAnchor)
        [intenseContainerConstraint, lightContainerConstraint, moderateContainerConstraint].forEach { $0.isActive = true }

        intenseCircle.bottomAnchor.constraint(equalTo: intenseContainer.centerYAnchor, constant: Layout.smallSpacing).isActive = true
        intenseLabel.topAnchor.constraint(equalTo: intenseCircle.bottomAnchor, constant: Layout.smallSpacing).isActive = true
        moderateCircle.bottomAnchor.constraint(equalTo: moderateContainer.centerYAnchor, constant: Layout.smallSpacing).isActive = true
        moderateLabel.topAnchor.constraint(equalTo: moderateCircle.bottomAnchor, constant: Layout.smallSpacing).isActive = true
        lightCircle.bottomAnchor.constraint(equalTo: lightContainer.centerYAnchor, constant: Layout.smallSpacing).isActive = true
        lightLabel.topAnchor.constraint(equalTo: lightCircle.bottomAnchor, constant: Layout.smallSpacing).isActive = true

        widthConstraint = widthAnchor.constraint(equalToConstant: Layout.width)
        widthConstraint.isActive = true

        intenseLabel.text = brushType.rawValue
        intenseCircle.tintColor = brushType.color(forIntensity: .intense)
        moderateCircle.tintColor = brushType.color(forIntensity: .moderate)
        lightCircle.tintColor = brushType.color(forIntensity: .light)

        moderateLabel.alpha = 0
        lightLabel.alpha = 0
        backButton.alpha = 0
    }

    private func clear() {
        [intenseContainer, moderateContainer, lightContainer].forEach { $0.backgroundColor = .clear }
        delegate?.disableDrawing()
    }

    private func select(intensity: BrushIntensity) {
        intenseContainer.backgroundColor = intensity == .intense ? .selectedGrey : .clear
        moderateContainer.backgroundColor = intensity == .moderate ? .selectedGrey : .clear
        lightContainer.backgroundColor = intensity == .light ? .selectedGrey : .clear

        delegate?.didSelectBrush(type: brushType, intensity: intensity)
    }

    @objc private func intenseSelected() {
        select(intensity: .intense)
    }

    @objc private func moderateSelected() {
        select(intensity: .moderate)
    }

    @objc private func lightSelected() {
        select(intensity: .light)
    }

    @objc func shrink() {
        guard let scrollView = scrollView else { return }

        isExpanded = false
        widthConstraint.constant = Layout.width
        lightContainerConstraint.constant = 0
        moderateContainerConstraint.constant = 0
        intenseContainerConstraint.constant = 0
        brushTaps.forEach { $0.isEnabled = false }
        UIView.animate(withDuration: Layout.transitionDuration, animations: { [weak self] in
            self?.clear()
            scrollView.layoutIfNeeded()
            scrollView.isScrollEnabled = true
            self?.lightLabel.alpha = 0
            self?.moderateLabel.alpha = 0
            self?.backButton.alpha = 0
            self?.intenseLabel.text = self?.brushType.rawValue
        }) { [weak self] _ in
            self?.closedTap.isEnabled = true
        }
    }

    @objc private func expand() {
        guard let scrollView = scrollView else { return }

        isExpanded = true
        scrollView.isScrollEnabled = false
        widthConstraint.constant = scrollView.frame.width
        lightContainerConstraint.constant = -80
        moderateContainerConstraint.constant = 20
        intenseContainerConstraint.constant = 120
        brushTaps.forEach { $0.isEnabled = true }
        UIView.animate(withDuration: Layout.transitionDuration, animations: { [weak self] in
            scrollView.layoutIfNeeded()
            scrollView.setContentOffset(CGPoint(x: self?.frame.origin.x ?? 0, y: 0), animated: true)
            self?.lightLabel.alpha = 1
            self?.moderateLabel.alpha = 1
            self?.backButton.alpha = 1
            self?.intenseLabel.text = Constants.intenseText
            self?.moderateSelected()
        }) { [weak self] _ in
            self?.closedTap.isEnabled = false
        }
    }
}







enum BrushIntensity: CGFloat {
    case light = 0.2
    case moderate = 0.5
    case intense = 0.75
}

enum BrushType: String {
    case acne
    case scarring
    case irritation
    case redness
    case oiliness
    case dryness

    func color(forIntensity intensity: BrushIntensity) -> UIColor {
        switch self {
        case .acne: return .indigo(alpha: intensity.rawValue)
        case .scarring: return .lilac(alpha: intensity.rawValue)
        case .irritation: return .yellow(alpha: intensity.rawValue)
        case .redness: return .peach(alpha: intensity.rawValue)
        case .oiliness: return .aquamarine(alpha: intensity.rawValue)
        case .dryness: return .seafoam(alpha: intensity.rawValue)
        }
    }

    var all: [BrushType] {
        return [.acne, .scarring, .irritation, .redness, .oiliness, .dryness]
    }
}

protocol CameraToolViewDelegate: class {
    func didSelectBrush(type: BrushType, intensity: BrushIntensity)
    func disableDrawing()
    func didMoveSlider(to value: CGFloat)
}

class CameraToolView: UIView {

    class Layout: MasterLayout {

    }

    weak var delegate: CameraToolViewDelegate? {
        didSet {
            brushes.forEach { $0.delegate = delegate }
        }
    }

    var color: UIColor = .gray {
        didSet {
            slider.tintColor = color
            smallBrushIcon.tintColor = color
            largeBrushIcon.tintColor = color
        }
    }

    let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 5
        slider.maximumValue = 50
        slider.isContinuous = true
        slider.tintColor = .white
        slider.value = 27.5
        return slider
    }()
    private let smallBrushIcon = Layout.imageView(withImage: #imageLiteral(resourceName: "circle_small"))
    private let largeBrushIcon = Layout.imageView(withImage: #imageLiteral(resourceName: "circle"))
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let acneBrush = CameraToolStack(brushType: .acne)
    private let scarringBrush = CameraToolStack(brushType: .scarring)
    private let irritationBrush = CameraToolStack(brushType: .irritation)
    private let rednessBrush = CameraToolStack(brushType: .redness)
    private let oilinessBrush = CameraToolStack(brushType: .oiliness)
    private let drynessBrush = CameraToolStack(brushType: .dryness)

    private var views: [UIView] {
        return [smallBrushIcon, largeBrushIcon, slider, scrollView]
    }
    private var brushes: [CameraToolStack] {
        return [acneBrush, scarringBrush, irritationBrush, rednessBrush, oilinessBrush, drynessBrush]
    }

    init() {
        super.init(frame: .zero)

        initialLayout()

        slider.addTarget(self, action: #selector(sliderChanged(slider:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraToolView {
    private func initialLayout() {
        translatesAutoresizingMaskIntoConstraints = false

        views.forEach { addSubview($0) }
        scrollView.layoutAs(brushes: brushes)

        brushes.forEach { $0.scrollView = scrollView }

        scrollView.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        smallBrushIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
        smallBrushIcon.bottomAnchor.constraint(equalTo: scrollView.topAnchor, constant: -Layout.largeSpacing).isActive = true

        largeBrushIcon.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.standardSpacing).isActive = true
        largeBrushIcon.centerYAnchor.constraint(equalTo: smallBrushIcon.centerYAnchor).isActive = true

        slider.leftAnchor.constraint(equalTo: smallBrushIcon.rightAnchor, constant: Layout.standardSpacing).isActive = true
        slider.rightAnchor.constraint(equalTo: largeBrushIcon.leftAnchor, constant: -Layout.standardSpacing).isActive = true
        slider.centerYAnchor.constraint(equalTo: smallBrushIcon.centerYAnchor).isActive = true
    }

    func reset() {
        brushes.forEach { brush in
            if brush.isExpanded {
                brush.shrink()
            }
        }
    }

    @objc private func sliderChanged(slider: UISlider) {
        delegate?.didMoveSlider(to: CGFloat(slider.value))
    }
}











class CameraCaptureView: UIView {

    class Layout: MasterLayout {
        static let shortTransitionDuration: TimeInterval = 0.2
        static let toolViewHeight: CGFloat = 200
        static let titleFont: UIFont = .main(size: 18, weight: .bold)
        static let buttonFontSize: CGFloat = 21
        static let retakeWidth: CGFloat = 150
        static let nextWidth: CGFloat = 120
    }

    class Constants: MasterConstants {
        static let initialTitle = "Did you get a good shot?"
        static let unsureTitle = "Not sure about this one?"
        static let editingTitle = "Mark up your skin status"
        static let retakeText = "RETAKE"
        static let nextText = "NEXT"
    }

    enum CaptureState {
        case previewing
        case editing
    }

    weak var cameraView: CameraView?
    var backAction: (() -> Void)?

    private var captureState: CaptureState = .previewing {
        didSet {
            let changes = layout(forState: captureState)

            if captureState == .editing {
                UIView.animate(
                    withDuration: Layout.transitionDuration,
                    animations: { changes() }
                ) { [weak self] _ in
                    self?.cameraView?.endSession()
                }
            } else if captureState == .previewing {
                spinner.startAnimating()
                UIView.animate(withDuration: Layout.shortTransitionDuration, animations: { [weak self] in
                    self?.spinner.transform = Layout.scaleReset
                    self?.backButton.transform = Layout.scaleShrink
                }) { [weak self] _ in
                    self?.cameraView?.prepare(animated: false) { [weak self] err in
                        do {
                            try self?.cameraView?.displayPreview()
                        } catch {
                            print(error)
                        }
                        UIView.animate(withDuration: Layout.transitionDuration, animations: {
                            changes()
                        }) { [weak self] _ in
                            self?.spinner.alpha = 1
                            self?.spinner.stopAnimating()
                            self?.spinner.transform = Layout.scaleShrink
                            self?.backButton.transform = Layout.scaleReset
                        }
                    }
                }
            }
        }
    }

    let blurView = Layout.effectView()
    private let drawView = DrawView(frame: .zero)
    private let titleLabel = Layout.label(withColor: .white, font: Layout.titleFont)
    private let faceMaskView = Layout.imageView(withImage: #imageLiteral(resourceName: "face_filled"))
    private let drawMaskView = Layout.imageView(withImage: #imageLiteral(resourceName: "face_filled"))
    private let topImageView = Layout.imageView(withImage: nil, renderingMode: .alwaysOriginal, contentMode: .scaleAspectFill)
    private let bottomImageView = Layout.imageView(withImage: nil, renderingMode: .alwaysOriginal, contentMode: .scaleAspectFill)
    private let retakeButton = Layout.textButton(withText: Constants.retakeText, color: .white, size: Layout.buttonFontSize)
    private let nextButton = Layout.textButton(withText: Constants.nextText, color: .white, size: Layout.buttonFontSize)
    private let backButton = Layout.imageButton(withImage: #imageLiteral(resourceName: "down_carat_large"), renderingMode: .alwaysTemplate, tint: .white)
    private let spinner = Layout.spinner(withStyle: .white)
    private let toolView = CameraToolView()
    private var toolViewConstraint: NSLayoutConstraint!

    private var views: [UIView] {
        return [bottomImageView, blurView, titleLabel, retakeButton, nextButton, topImageView, drawView, spinner, backButton, toolView]
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        initialLayout()

        retakeButton.addTarget(self, action: #selector(retakeTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        toolView.delegate = self
        drawView.drawingEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraCaptureView: CameraToolViewDelegate {
    func disableDrawing() {
        drawView.drawingEnabled = false
        toolView.color = .white
    }

    func didSelectBrush(type: BrushType, intensity: BrushIntensity) {
        let color = type.color(forIntensity: intensity)
        drawView.drawingEnabled = true
        drawView.type = type
        drawView.intensity = intensity
        UIView.animate(withDuration: Layout.transitionDuration) { [weak self] in
            self?.toolView.color = color
        }
    }

    func didMoveSlider(to value: CGFloat) {
        drawView.lineWidth = value
    }
}

extension CameraCaptureView {
    private func initialLayout() {
        views.forEach { addSubview($0) }

        bottomImageView.pinToEdges(of: self)
        topImageView.pinToEdges(of: self)
        blurView.pinToEdges(of: self)

        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Layout.largeSpacing).isActive = true

        backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.mediumSpacing).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true

        spinner.centerXAnchor.constraint(equalTo: backButton.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: backButton.centerYAnchor).isActive = true

        retakeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.largeSpacing).isActive = true
        retakeButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.standardSpacing).isActive = true
        retakeButton.heightAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true
        retakeButton.widthAnchor.constraint(equalToConstant: Layout.retakeWidth).isActive = true

        nextButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.largeSpacing).isActive = true
        nextButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Layout.standardSpacing).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: Layout.nextWidth).isActive = true

        toolView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        toolView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        toolView.heightAnchor.constraint(equalToConstant: Layout.toolViewHeight).isActive = true
        toolViewConstraint = toolView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Layout.toolViewHeight)
        toolViewConstraint.isActive = true

        topImageView.mask = faceMaskView
        drawView.mask = drawMaskView

        titleLabel.addShadow()
        retakeButton.addShadow()
        nextButton.addShadow()
        backButton.addShadow()
        spinner.addShadow()

        spinner.transform = Layout.scaleShrink
        bottomImageView.alpha = 0
        backButton.alpha = 0
    }

    func set(image: UIImage?, faceFrame: CGRect? = nil, cameraPosition: CameraView.CameraPosition? = .front) {
        topImageView.image = image
        bottomImageView.image = image
        topImageView.transform = CGAffineTransform(scaleX: cameraPosition == .front ? -1 : 1, y: 1)
        bottomImageView.transform = CGAffineTransform(scaleX: cameraPosition == .front ? -1 : 1, y: 1)
        faceMaskView.frame = faceFrame ?? faceMaskView.frame
        drawView.frame = faceFrame ?? faceMaskView.frame
        drawMaskView.frame = CGRect(origin: .zero, size: faceFrame?.size ?? faceMaskView.frame.size)
        titleLabel.text = Constants.initialTitle
    }

    func layout(forState state: CaptureState) -> () -> Void {
        switch state {
        case .previewing:
            toolView.reset()
            return { [weak self] in
                self?.titleLabel.text = Constants.unsureTitle
                self?.toolViewConstraint.constant = Layout.toolViewHeight
                self?.backButton.alpha = 0
                self?.drawView.clearCanvas()
                self?.bottomImageView.alpha = 0
                self?.spinner.alpha = 0
                self?.layoutIfNeeded()
            }
        case .editing:
            return { [weak self] in
                self?.titleLabel.text = Constants.editingTitle
                self?.toolViewConstraint.constant = 0
                self?.backButton.alpha = 1
                self?.bottomImageView.alpha = 1
                self?.layoutIfNeeded()
            }
        }
    }

    @objc private func retakeTapped() {
        backAction?()
    }

    @objc private func nextTapped() {
        captureState = .editing
    }

    @objc private func backTapped() {
        captureState = .previewing
    }
}










class CameraControlsView: UIView {

    class Layout: MasterLayout {
        static let titleFont: UIFont = .main(size: 18, weight: .bold)
        static let faceOffset: CGFloat = 48
    }

    class Constants: MasterConstants {
        static let title = "Line up your face"
    }

    var faceFrame: CGRect {
        return faceOutline.frame
    }

    let backArrow = Layout.imageButton(withImage: #imageLiteral(resourceName: "down_carat_large"), renderingMode: .alwaysTemplate, tint: .white)
    let shutterButton = Layout.imageButton(withImage: #imageLiteral(resourceName: "camera_button"))
    let switchCameraButton = Layout.imageButton(withImage: #imageLiteral(resourceName: "switch_camera"))
    private let titleLabel = Layout.label(withColor: .white, font: Layout.titleFont, text: Constants.title)
    private let faceOutline = Layout.imageView(withImage: #imageLiteral(resourceName: "face_outline"))


    private var views: [UIView] {
        return [titleLabel, backArrow, faceOutline, shutterButton, switchCameraButton]
    }

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        views.forEach { addSubview($0); $0.addShadow() }

        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Layout.largeSpacing).isActive = true

        backArrow.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        backArrow.leftAnchor.constraint(equalTo: leftAnchor, constant: Layout.mediumSpacing).isActive = true
        backArrow.heightAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true
        backArrow.widthAnchor.constraint(equalToConstant: Layout.minButtonSize).isActive = true

        faceOutline.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        faceOutline.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Layout.faceOffset).isActive = true

        shutterButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        shutterButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.largeSpacing).isActive = true

        switchCameraButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor).isActive = true
        switchCameraButton.leftAnchor.constraint(equalTo: shutterButton.rightAnchor, constant: Layout.largeSpacing).isActive = true

        backArrow.transform = CGAffineTransform(rotationAngle: .pi)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
