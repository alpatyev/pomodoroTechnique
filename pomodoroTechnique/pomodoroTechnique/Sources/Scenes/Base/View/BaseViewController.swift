//
//  BaseViewController.swift
//  pomodoroTechnique
//
//  Created by Nikita Alpatiev on 12/24/22.
//

import UIKit

// MARK: - View protocol

protocol BaseViewProtocol {}

// MARK: - View class

final class BaseViewController: UIViewController, BaseViewProtocol {
    
    // MARK: - Helpers

    private var progress: CGFloat = 0
    private var visibleProgress: String {
        let sec = Int(5 * multiplier - progress)
        let msec = Int(100 - progress.truncatingRemainder(dividingBy: 1) * 100)
        return String(format: "%02i:%02i", sec, msec == 100 ? 00 : msec)
    }
    
    private var timer = Timer()
    private var isStarted: Bool = false
    private var isWorkingTime: Bool = true
    
    private var multiplier: CGFloat {
        isWorkingTime ? 5 : 1
    }
    private var angle: CGFloat {
        CGFloat.pi * progress / multiplier
    }
    private var radius: CGFloat {
        (circularProgressRect.frame.height > circularProgressRect.frame.width ? circularProgressRect.frame.width: circularProgressRect.frame.height) / 2
    }
    
    private var accentUIColor: UIColor {
        isWorkingTime ? UIColor.red: UIColor.green
    }
    private var accentCGColor: CGColor {
        accentUIColor.cgColor
    }
        
    // MARK: - UI
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "~ Pomodoro timer ~"
        label.font = .italicSystemFont(ofSize: 21)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0,
                                          width: 220,
                                          height: 80))
        label.numberOfLines = 1
        label.font = .monospacedDigitSystemFont(ofSize: 78, weight: .light)
        label.textAlignment = .center
        label.text = "25:00"
        return label
    }()
    
    private lazy var startStopButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0,
                                            width: 160,
                                            height: 160))
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var circularProgressRect: UIView = {
        UIView(frame: CGRect(x: 0, y: 0,
                             width: 320,
                             height: 320))
    }()
    
    private var controlImage: UIImage? {
        if let image = UIImage(named: isStarted ? "pause" : "play")?.withRenderingMode(.alwaysTemplate) {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            accentUIColor.set()
            image.draw(in: CGRect(origin: .zero, size: image.size))
            guard let imageColored = UIGraphicsGetImageFromCurrentImageContext() else {
                return nil
            }
            UIGraphicsEndImageContext()
            return imageColored
        } else {
            return nil
        }
    }
    
    private lazy var circleLayer = CAShapeLayer()
    private lazy var smallDotLayer = CAShapeLayer()
    private lazy var bigDotLayer = CAShapeLayer()
    private lazy var circularPath = UIBezierPath()
    private lazy var dotPath = UIBezierPath()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
        updateUI()
    }
    
    // MARK: - Setup view
    
    private func setupView() {
        view.backgroundColor = .black
    }
    
    private func createCircularProressBar(onView rect: UIView) {
        circularPath = UIBezierPath(arcCenter: rect.center,
                                        radius: radius,
                                        startAngle: CGFloat(-Double.pi / 2),
                                        endAngle: CGFloat(3 * Double.pi / 2),
                                        clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 6
                
        dotPath.move(to: circularPath.currentPoint)
        dotPath.addLine(to: circularPath.currentPoint)
        
        bigDotLayer.path = dotPath.cgPath
        bigDotLayer.strokeColor = UIColor.clear.cgColor
        bigDotLayer.lineCap = .round
        bigDotLayer.lineWidth = 38
        
        smallDotLayer.path = dotPath.cgPath
        smallDotLayer.strokeColor = UIColor.clear.cgColor
        smallDotLayer.lineCap = .round
        smallDotLayer.lineWidth = 32
        
        circularProgressRect.layer.addSublayer(circleLayer)
        circleLayer.addSublayer(bigDotLayer)
        circleLayer.addSublayer(smallDotLayer)
    }
    
    // MARK: - Setup hierarchy
    
    private func setupHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(circularProgressRect)
        createCircularProressBar(onView: circularProgressRect)

        view.addSubview(timerLabel)
        view.addSubview(startStopButton)
    }
    
    // MARK: - Setup layout
    
    private func setupLayout() {
        titleLabel.frame = CGRect(x: .zero,
                                  y: view.center.y - 300,
                                  width: 220,
                                  height: 80)
        titleLabel.center.x = view.center.x
        
        circularProgressRect.center = view.center
        
        timerLabel.center.x = circularProgressRect.center.x
        timerLabel.center.y = circularProgressRect.center.y - 50
        
        startStopButton.center.x = circularProgressRect.center.x
        startStopButton.center.y = circularProgressRect.center.y + 80
    }
   
    // MARK: - Actions
    
    @objc private func tapped() {
        if isStarted {
            isStarted = false
            timer.invalidate()
        } else {
            callTimer()
        }
        startStopButton.setImage(controlImage, for: .normal)
    }
    
    private func callTimer() {
        isStarted = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [unowned self] _ in
            progress += 0.05
            let currentTime = round(progress * 10) / 10
            if currentTime == 5 * multiplier {
                progress = 0
                isWorkingTime.toggle()
                updateUI()
            }
            self.timerLabel.text = visibleProgress
            self.circularProgressRect.transform = CGAffineTransform(rotationAngle: self.angle / 2.5)
        })
    }
    
    private func updateUI() {
        bigDotLayer.strokeColor = accentCGColor
        smallDotLayer.strokeColor = view.backgroundColor?.cgColor
        circleLayer.strokeColor = accentCGColor
        timerLabel.textColor = accentUIColor
        
        startStopButton.setImage(controlImage, for: .normal)
    }
}
