//
//  MainViewController.swift
//  ConnectorRecognition
//
//  Created by Рыжков Артем on 18.11.2020.
//

import UIKit
import Lottie

final class MainViewController: UIViewController {
    
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var blankImageViewPlaceholder: BlankImageViewPlaceholder!
    
    private let popupOffset: CGFloat = 240
    private var bottomConstraint = NSLayoutConstraint()
    private var currentState: State = .closed
    private var runningAnimators = [UIViewPropertyAnimator]()
    private var animationProgress = [CGFloat]()
    
    private let recognitionMLService: ServiceProtocol = CoreMLRecognitionService()
    private let recognitionWatsonService: ServiceProtocol = WatsonRecognitionService()
    
    let recognitionInfoViewController = RecognitionInfoViewController()
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var spinnerView: UIView = {
        let spinView = UIView()
        spinView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.95)
        spinView.layer.cornerRadius = 12
        spinView.clipsToBounds = true
        return spinView
    }()
    
    private lazy var spinnerInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var animationView: AnimationView = {
        let animation = Animation.named("spinner")
        let animView = AnimationView(animation: animation)
        animView.loopMode = .loop
        animView.contentMode = .scaleAspectFit
        return animView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Connector Recognition"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera,
                                                            target: self,
                                                            action: #selector(pickImage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash,
                                                            target: self,
                                                            action: #selector(deleteImage))
        setupLayout()
        setupPopupView()
        popupView.addGestureRecognizer(panRecognizer)
        setupAnimationView()
        
        // Обработка Watson Модели
        // prepareWatsonModel()
    }
    
    private func prepareWatsonModel() {
        performSpinnerAnimation(text: "Подготовка модели...")
        stopSpinnerAnimation()
    }
    
    private func setupAnimationView() {
        view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: view.center.x - 130,
                                   y: view.center.y - 125,
                                   width: 250,
                                   height: 250)
        
        spinnerView.addSubview(animationView)
        animationView.frame = CGRect(x: 20, y: 0, width: 200, height: 200)
        
        spinnerView.addSubview(spinnerInfoLabel)
        spinnerInfoLabel.text = "Изображение обрабатывается..."
        spinnerInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinnerInfoLabel.centerXAnchor.constraint(equalTo: spinnerView.centerXAnchor),
            spinnerInfoLabel.bottomAnchor.constraint(equalTo: spinnerView.bottomAnchor, constant: -20),
            spinnerInfoLabel.leadingAnchor.constraint(equalTo: spinnerView.leadingAnchor, constant: 30),
            spinnerInfoLabel.trailingAnchor.constraint(equalTo: spinnerView.trailingAnchor, constant: -30)
        ])
        
        
        spinnerView.isHidden = true
    }
    
    func performSpinnerAnimation(text: String) {
        spinnerView.isHidden = false
        overlayView.alpha = 0.5
        spinnerInfoLabel.text = text
        animationView.play()
    }
    
    func stopSpinnerAnimation() {
        spinnerView.isHidden = true
        overlayView.alpha = 0.5
        animationView.stop()
    }
    
    @objc private func deleteImage() {
        UIView.animate(withDuration: 1) {
            self.pickedImageView.image = nil
            self.blankImageViewPlaceholder.alpha = 1
        }
        recognitionInfoViewController.clearInfo()
    }
    
    private func setupLayout() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }
    
    func setupPopupView() {
        recognitionInfoViewController.view.frame.size = popupView.frame.size
        popupView.addSubview(recognitionInfoViewController.view)
        addChild(recognitionInfoViewController)
        recognitionInfoViewController.didMove(toParent: self)
    }
    
    // MARK: - Анимация нижней панели
    
    func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        
        let openConstant: CGFloat = 0
        
        guard runningAnimators.isEmpty else { return }
        
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = openConstant
                self.popupView.layer.cornerRadius = 20
                self.overlayView.alpha = 0.5
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                self.popupView.layer.cornerRadius = 0
                self.overlayView.alpha = 0
            }
            self.view.layoutIfNeeded()
        })
        
        transitionAnimator.addCompletion { position in
            
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = openConstant
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
            
            self.runningAnimators.removeAll()
        }
        
        transitionAnimator.startAnimation()
        runningAnimators.append(transitionAnimator)
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            runningAnimators.forEach { $0.pauseAnimation() }
            animationProgress = runningAnimators.map { $0.fractionComplete }
            
        case .changed:
            
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / popupOffset
            
            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
            
        case .ended:
            
            let yVelocity = recognizer.velocity(in: popupView).y
            let shouldClose = yVelocity > 0
            
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
                if !shouldClose && runningAnimators[0].isReversed { runningAnimators.forEach { $0.isReversed = !$0.isReversed } }
            }
            
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
            
        default:
            ()
        }
    }
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc func pickImage() {
        self.animateTransitionIfNeeded(to: .closed, duration: 1.0)
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }

        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Сделать фото", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Выбрать фото", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }

        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))

        present(photoSourcePicker, animated: true)
    }

    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }

    // MARK: - Handling Image Picker Selection

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        blankImageViewPlaceholder.alpha = 0
        pickedImageView.image = pickedImage
        pickedImageView.sizeToFit()
        picker.dismiss(animated: true)
        makeRecognitionRequests(with: pickedImage)
    }
    
    private func makeRecognitionRequests(with image: UIImage) {
        var responseData: [RecognitionModel] = []
        
        let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
        let dispatchGroup = DispatchGroup()
        
        performSpinnerAnimation(text: "Изображение обрабатывается.")
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let response = self.recognitionMLService.recognizeWire(on: image)
            if responseData[safeIndex: 0] != nil {
                responseData.insert(response, at: 0)
            } else {
                responseData.append(response)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        dispatchQueue.async {
            let response = self.recognitionWatsonService.recognizeWire(on: image)
            responseData.append(response)
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.stopSpinnerAnimation()
            self.updateResponseData(responseData)
        }
    }
    
    private func updateResponseData(_ response: [RecognitionModel]) {
        recognitionInfoViewController.updateInfo(response)
        self.animateTransitionIfNeeded(to: .open, duration: 1.0)
    }
}
