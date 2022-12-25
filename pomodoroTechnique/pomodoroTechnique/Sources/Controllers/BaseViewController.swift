//
//  BaseViewController.swift
//  pomodoroTechnique
//
//  Created by Nikita Alpatiev on 12/24/22.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Helpers
    
    private var workLap: CGFloat = 25
    private var relaxLap: CGFloat = 5
    private var progress: CGFloat = 0
    
    private var timer = Timer()
    private var isStarted: Bool = false
    private var isWorkingTime: Bool = true
    private var isRelaxingTime: Bool {
        !isWorkingTime
    }
    
    private var angle: CGFloat {
        CGFloat.pi * progress
    }
    private var radius: CGFloat {
        (circularProgressRect.frame.height > circularProgressRect.frame.width ? circularProgressRect.frame.width: circularProgressRect.frame.height) / 2
    }
    
    // MARK: - UI
    
    private var timerLabel: UILabel = {
       let label = UILabel()
        label.text = "0"
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private var startStopButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        return button
    }()
    
    private var circularProgressRect: UIView = {
        UIView(frame: CGRect(x: 0, y: 0,
                             width: 300,
                             height: 300))
    }()
    
    private var circleLayer = CAShapeLayer()
    private var smallDotLayer = CAShapeLayer()
    private var bigDotLayer = CAShapeLayer()
    private var circularPath = UIBezierPath()
    private var dotPath = UIBezierPath()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHierarchy()
        setupLayout()
        
    }
    
    // MARK: - Setup view
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func createCircularProressBar(onView rect: UIView) {
        circularPath = UIBezierPath(arcCenter: rect.center,
                                        radius: radius,
                                        startAngle: CGFloat(-Double.pi / 2),
                                        endAngle: CGFloat(3 * Double.pi / 2),
                                        clockwise: true)
        circleLayer.path = circularPath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.purple.cgColor
        circleLayer.lineWidth = 8
                
        dotPath.move(to: circularPath.currentPoint)
        dotPath.addLine(to: circularPath.currentPoint)
        
    
        bigDotLayer.path = dotPath.cgPath
        bigDotLayer.strokeColor = UIColor.purple.cgColor
        bigDotLayer.lineCap = .round
        bigDotLayer.lineWidth = 32
        
        smallDotLayer.path = dotPath.cgPath
        smallDotLayer.strokeColor = UIColor.white.cgColor
        smallDotLayer.lineCap = .round
        smallDotLayer.lineWidth = 24
        
        circularProgressRect.layer.addSublayer(circleLayer)
        circleLayer.addSublayer(bigDotLayer)
        circleLayer.addSublayer(smallDotLayer)
    }
    
    // MARK: - Setup hierarchy
    
    private func setupHierarchy() {
        view.addSubview(circularProgressRect)
        view.addSubview(startStopButton)
        startStopButton.frame = CGRect(x: 0, y: 500, width: 100, height: 50)
        startStopButton.backgroundColor = .purple
        startStopButton.setTitle("ON/OFF", for: .normal)
        startStopButton.setTitleColor(.white, for: .normal)
        startStopButton.layer.cornerRadius = 25
        startStopButton.center.x = view.center.x
        createCircularProressBar(onView: circularProgressRect)
        timerLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        timerLabel.center = view.center
        timerLabel.font = .boldSystemFont(ofSize: 40)
        timerLabel.textColor = .purple
        view.addSubview(timerLabel)
    }
    
    // MARK: - Setup layout
    
    private func setupLayout() {
        circularProgressRect.center = view.center

    }
   
    // MARK: - Actions
    
    @objc func tapped() {
        if isStarted {
            isStarted = false
            timer.invalidate()
        } else {
            callTimer(5)
        }
       
    }
    
    func callTimer(_ seconds: CGFloat) {
        isStarted = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [unowned self] _ in
            progress += 0.05
            self.circularProgressRect.transform = CGAffineTransform(rotationAngle: self.angle / 2)
            self.timerLabel.text = "\(round(progress * 10) / 10)"
            
        })
    }
    
    func getRandomColor() -> UIColor {
         //Generate between 0 to 1
         let red:CGFloat = CGFloat(drand48())
         let green:CGFloat = CGFloat(drand48())
         let blue:CGFloat = CGFloat(drand48())

         return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
    }

}
    
    /*
    func rotate(_ to: CGFloat) {
        UIView.animateKeyframes(withDuration: timeInterval, delay: 0) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: timeInterval) {
                self.circularProgressRect.transform = CGAffineTransform(rotationAngle: self.angle)
            }
        }
    }
    */


