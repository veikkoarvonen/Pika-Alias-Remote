//
//  ViewController.swift
//  Pika Alias
//
//  Created by Veikko Arvonen on 23.7.2024.
//

import UIKit

class ViewController: UIViewController {

//MARK: - Variables & UI elements

    // Constants for UI element locations
    let centerConstant: CGFloat = 40
    let buttonCenterConstant: CGFloat = 20
    
    // IBOutlets
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    // Programatically added UI elements
    var leftCircleBig = UIImageView()
    var leftCircleSmall = UIImageView()
    var rightCircleBig = UIImageView()
    var rightCircleSmall = UIImageView()
    var leftButtonImage = UIImageView()
    var rightButtonImage = UIImageView()
    
    //Game labels
    var label1 = UILabel()
    var label2 = UILabel()
    var countDownLabel = UILabel()
    
    // Game variables
    var points: Int = 0
    var shouldEndGame: Bool = false
    var words = C.words
    var currentWord: Int = 0
    var countdownTime = 3
    var timer: Timer?
 
//MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add rest of the UI programatically
        addCircles()
        addButtons()
        gameElementVisibility(hidden: true)
        setShadow(for: topLabel)
        
        
    }

    @IBAction func startPressed(_ sender: UIButton) {
        topLabel.text = "Pika Alias"
        countDownLabel.removeFromSuperview()
        startButton.isHidden = true
        topLabel.isHidden = false
        countdownTimer()
    }
    
    
    @objc private func leftButtonTapped() {
        currentWord += 1
        slideLabelLeft(label: label1)
        growLabel(label: label2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setWordLabels()
            if self.shouldEndGame {
                self.endGame()
            }
        }
        
    }
    
    @objc private func rightButtonTapped() {
        currentWord += 1
        points += 1
        topLabel.text = "Pisteet: \(points)"
        slideLabelRight(label: label1)
        growLabel(label: label2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setWordLabels()
            if self.shouldEndGame {
                self.endGame()
            }
        }
    }
    
    
//MARK: - Pan gesture
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        
        // Set translation
        let translation = sender.translation(in: view)
        sender.setTranslation(CGPoint.zero, in: view)
        
        if let label = sender.view {
            
            //Move the label on x-axis
            label.center = CGPoint(x: label.center.x + translation.x, y: label.center.y)
            
            //Rotate label 45 degrees per view's width
            label.transform = CGAffineTransform(rotationAngle: (label.center.x - view.center.x) / view.frame.width * .pi / 4)
            
            //Determine what to do at the end based on final location
            if sender.state == .ended {
                
                //Slide label if the velocity is high enough
                let velocity = sender.velocity(in: view)
                let tressholdVelocity: CGFloat = 1000
                
                if velocity.x > tressholdVelocity {
                    slideLabelRight(label: label as! UILabel)
                } else if velocity.x < -tressholdVelocity {
                    slideLabelLeft(label: label as! UILabel)
                }
                
                let width = view.frame.width
                let center = label.center.x
                
                //perform animations based on final location
                if center < width / 4 {
                    leftButtonTapped()
                } else if center > width * (3/4) {
                    rightButtonTapped()
                } else {
                    UIView.animate(withDuration: 0.4) {
                        label.center = self.view.center
                        label.transform = CGAffineTransform(rotationAngle: 0)
                    }
                }
            }
        }
    }
    
//MARK: - Start & end the game
    
    func startGame() {
        points = 0
        currentWord = 0
        countDownLabel.removeFromSuperview()
        topLabel.text = "Pisteet: \(points)"
        words.shuffle()
        gameElementVisibility(hidden: false)
        gameTimer()
        setWordLabels()
        
    }
    
    func endGame() {
        shouldEndGame = false
        topLabel.isHidden = true
        gameElementVisibility(hidden: true)
        label1.removeFromSuperview()
        label2.removeFromSuperview()
        
        countDownLabel = createCountdownLabel()
        view.addSubview(countDownLabel)
        countDownLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        countDownLabel.center.x = view.center.x
        countDownLabel.center.y = view.center.y - 100
        countDownLabel.text = ""
        setShadow(for: countDownLabel)

        // Display final points letter by letter
        let text = "Pisteet: \(points)"
        var charIndex = 0.0
        for letter in text {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in self.countDownLabel.text?.append(letter)
            }
            charIndex += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startButton.isHidden = false
        }
    }
    
  
}



extension ViewController {
    
//MARK: - Timer functionalities
    
    private func countdownTimer() {
        countdownTime = 3
        countDownLabel = createCountdownLabel()
        view.addSubview(countDownLabel)
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                    countDownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    countDownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        setShadow(for: countDownLabel)
        countdownTimerFired()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countdownTimerFired), userInfo: nil, repeats: true)
    }
    
    @objc func countdownTimerFired() {
        if countdownTime > 0 {
            countDownLabel.text = "\(countdownTime)"
            animateLabel(label: countDownLabel)
            countdownTime -= 1
        } else {
            stopTimer()
            startGame()
        }
    }
    
    private func gameTimer() {
        timeLabel.isHidden = false
        setShadow(for: timeLabel)
        countdownTime = 10
        gameTimerFired()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(gameTimerFired), userInfo: nil, repeats: true)
    }
    
    @objc func gameTimerFired() {
        if countdownTime > 0 {
            timeLabel.text = "\(countdownTime)"
            animateLabel(label: timeLabel)
            countdownTime -= 1
        } else {
            timeLabel.text = "\(countdownTime)"
            animateLabel(label: timeLabel)
            stopTimer()
            shouldEndGame = true
        }
        
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
//MARK: - Animation & shadow for labels
    
    private func animateLabel(label: UILabel) {
        label.transform = CGAffineTransform(scaleX: 2, y: 2)
        UIView.animate(withDuration: 0.4) {
        label.transform = .identity
        }
    }
    
    private func growLabel(label: UILabel) {
        label.alpha = 1
        label.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.4) {
        label.transform = .identity
        }
    }
    
    private func setShadow(for label: UILabel) {
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 0)
        label.layer.shadowOpacity = 0.7
        label.layer.shadowRadius = 5
    }
    
    private func slideLabelRight(label: UILabel) {
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            label.center.x += self.view.frame.width
            self.rotateLabel(label: label, byDegrees: 45)
        })
    }
    
    private func slideLabelLeft(label: UILabel) {
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            label.center.x -= self.view.frame.width
            self.rotateLabel(label: label, byDegrees: -45)
        })
    }
    
    func rotateLabel(label: UILabel, byDegrees degrees: CGFloat) {
            let radians = degrees * CGFloat.pi / 180
            label.transform = CGAffineTransform(rotationAngle: radians)
    }


    
//MARK: - Hide and show UI elements
    
    private func gameElementVisibility(hidden: Bool) {
        leftCircleBig.isHidden = hidden
        leftCircleSmall.isHidden = hidden
        rightCircleBig.isHidden = hidden
        rightCircleSmall.isHidden = hidden
        leftButtonImage.isHidden = hidden
        rightButtonImage.isHidden = hidden
        timeLabel.isHidden = hidden
    }
 
//MARK: - Add UI
    
    private func setWordLabels() {
        
        label1.removeFromSuperview()
        label2.removeFromSuperview()
        
        let labels = [createWordLabel(word: words[currentWord]), createWordLabel(word: words[currentWord + 1])]
        let width = view.frame.width - 200
        let height = width * (3/2)
        
        for label in labels {
            view.addSubview(label)
            label.frame = CGRect(x: 0, y: 0, width: width, height: height)
            label.center = view.center
            label.clipsToBounds = true
            label.layer.cornerRadius = 10
        }
        
        label1 = labels[0]
        label2 = labels[1]
        label2.alpha = 0
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        label1.addGestureRecognizer(panGestureRecognizer)
        label1.isUserInteractionEnabled = true
    
    }
    
    private func addButtons() {
        
        let leftButton = UIImageView()
        leftButton.image = UIImage(named: C.wrong)
        leftButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        leftButton.center.x = leftCircleCenter().x + buttonCenterConstant
        leftButton.center.y = leftCircleCenter().y - buttonCenterConstant
        view.addSubview(leftButton)
        leftButtonImage = leftButton
        leftButton.isUserInteractionEnabled = true
        
        let leftTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(leftButtonTapped))
        leftButtonImage.addGestureRecognizer(leftTapGestureRecognizer)
        
        let rightButton = UIImageView()
        rightButton.image = UIImage(named: C.right)
        rightButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        rightButton.center.x = rightCircleCenter().x - buttonCenterConstant
        rightButton.center.y = rightCircleCenter().y - buttonCenterConstant
        view.addSubview(rightButton)
        rightButtonImage = rightButton
        rightButton.isUserInteractionEnabled = true
        
        let rightTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rightButtonTapped))
        rightButtonImage.addGestureRecognizer(rightTapGestureRecognizer)
        
    }
    
    private func addCircles() {
        let bigSize = view.frame.width * (2 / 3)
        let smallSize = bigSize - 50
        
        let leftCenter = leftCircleCenter()
        let rightCenter = rightCircleCenter()
        
        let leftCircle = createCircle()
        leftCircle.frame = CGRect(x: 0, y: 0, width: bigSize, height: bigSize)
        leftCircle.center = leftCenter
        view.addSubview(leftCircle)
        leftCircleBig = leftCircle
        
        let rightCircle = createCircle()
        rightCircle.frame = CGRect(x: 0, y: 0, width: bigSize, height: bigSize)
        rightCircle.center = rightCenter
        view.addSubview(rightCircle)
        rightCircleBig = rightCircle
        
        let leftRound = createRound()
        leftRound.frame = CGRect(x: 0, y: 0, width: smallSize, height: smallSize)
        leftRound.center = leftCenter
        view.addSubview(leftRound)
        leftCircleSmall = leftRound
        
        let rightRound = createRound()
        rightRound.frame = CGRect(x: 0, y: 0, width: smallSize, height: smallSize)
        rightRound.center = rightCenter
        view.addSubview(rightRound)
        rightCircleSmall = rightRound
        
        
    }
  
//MARK: - Create UI elements
    
    private func createCircle() -> UIImageView {
        let imageView = UIImageView()
        
        imageView.image = UIImage(systemName: "circle")
        imageView.tintColor = UIColor(named: C.green)
        
        return imageView
        
    }
   
    private func createRound() -> UIImageView {
        let imageView = UIImageView()
        
        imageView.image = UIImage(systemName: "circle.fill")
        imageView.tintColor = .white
        
        return imageView
    }
    
    private func createCountdownLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: C.font, size: 50)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }
    
    private func createWordLabel(word: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "Optima", size: 25)
        label.backgroundColor = .white
        label.textAlignment = .center
        label.text = word
        return label
    }
    
//MARK: - Determine locations for elements
    
    private func leftCircleCenter() -> CGPoint {
        let left = centerConstant
        let bottom = view.frame.height - centerConstant
        let point = CGPoint(x: left, y: bottom)
        return point
    }
    
    private func rightCircleCenter() -> CGPoint {
        let right = view.frame.width - centerConstant
        let bottom = view.frame.height - centerConstant
        let point = CGPoint(x: right, y: bottom)
        return point
    }
    
}

