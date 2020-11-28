//
//  ViewController.swift
//  BetterRest
//
//  Created by Vlastimir Radojevic on 18/3/19.
//  Copyright © 2019 Vlastimir Radojevic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var wakeUpTime: UIDatePicker!
    
    var sleepAmountTime: UIStepper!
    var sleepAmountLabel: UILabel!
    
    var coffeeAmounteStepp: UIStepper!
    var coffeeAmountLabel: UILabel!

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
                mainStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 20),
                mainStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                mainStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
            ])
        
        let wakeUpTitle = UILabel()
        wakeUpTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        wakeUpTitle.numberOfLines = 0
        wakeUpTitle.text = "When do you want to wake up?"
        mainStackView.addArrangedSubview(wakeUpTitle)
        
        wakeUpTime = UIDatePicker()
        wakeUpTime.datePickerMode = .time
        wakeUpTime.minuteInterval = 15
        mainStackView.addArrangedSubview(wakeUpTime)
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.hour = 8
        components.minute = 0
        wakeUpTime.date = Calendar.current.date(from: components) ?? Date()
        
        let sleepTitle = UILabel()
        sleepTitle.font = UIFont.preferredFont(forTextStyle: .headline)
        sleepTitle.numberOfLines = 0
        sleepTitle.text = "What's the minimum of sleep you need?"
        mainStackView.addArrangedSubview(sleepTitle)
        
        sleepAmountTime = UIStepper()
        sleepAmountTime.addTarget(self, action: #selector(sleepAmountChanged), for: .valueChanged)
        sleepAmountTime.stepValue = 0.25
        sleepAmountTime.value = 8
        sleepAmountTime.minimumValue = 4
        sleepAmountTime.maximumValue = 12
        
        sleepAmountLabel = UILabel()
        sleepAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        let sleepStackView = UIStackView()
        sleepStackView.spacing = 20
        sleepStackView.addArrangedSubview(sleepAmountTime)
        sleepStackView.addArrangedSubview(sleepAmountLabel)
        mainStackView.addArrangedSubview(sleepStackView)
        
        let coffeeTitleLabel = UILabel()
        coffeeTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        coffeeTitleLabel.numberOfLines = 0
        coffeeTitleLabel.text = "How much coffee do you drink each day"
        mainStackView.addArrangedSubview(coffeeTitleLabel)
        
        coffeeAmounteStepp = UIStepper()
        coffeeAmounteStepp.addTarget(self, action: #selector(coffeeAmountChanged), for: .valueChanged)
        coffeeAmounteStepp.minimumValue = 1
        coffeeAmounteStepp.maximumValue = 20
        
        coffeeAmountLabel = UILabel()
        coffeeAmountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        let coffeStackView = UIStackView()
        coffeStackView.spacing = 20
        coffeStackView.addArrangedSubview(coffeeAmounteStepp)
        coffeStackView.addArrangedSubview(coffeeAmountLabel)
        mainStackView.addArrangedSubview(coffeStackView)
        
        mainStackView.setCustomSpacing(10, after: sleepTitle)
        mainStackView.setCustomSpacing(20, after: sleepStackView)
        mainStackView.setCustomSpacing(10, after: coffeeTitleLabel)
        
        sleepAmountChanged()
        coffeeAmountChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Better Rest"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Calculate", style: .plain, target: self, action: #selector(calculateBedTime))
    }

    @objc func sleepAmountChanged() {
        sleepAmountLabel.text = String(format: "%g hours", sleepAmountTime.value)
    }
    
    @objc func coffeeAmountChanged() {
        if coffeeAmounteStepp.value == 1 {
            coffeeAmountLabel.text = "1 cup"
        } else {
            coffeeAmountLabel.text = "\(Int(coffeeAmounteStepp.value)) cups"
        }
    }
    
    @objc func calculateBedTime() {
        let model = SleepCalculator()
        
        let title: String
        let message: String
        
        do {
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime.date)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(coffee: coffeeAmounteStepp.value, estimatedSleep: sleepAmountTime.value, wake: Double(hour + minute))
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            let wakeDate = wakeUpTime.date - prediction.actualSleep
            message = formatter.string(from: wakeDate)
            
            title = "Your ideal bedtime is…"
        } catch {
            title = "Error"
            message = "Sorry, there was a problem calculating your bedtime."
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true, completion: nil)
    }

}

