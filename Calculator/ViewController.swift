//
//  ViewController.swift
//  Calculator
//
//  Created by Alex Perez Martinez on 27/10/2017.
//  Copyright © 2017 Alex Perez Martinez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var userTypedDot = false
    private var brain = CalculatorBrain()

    var displayValue: Double {
        get {
            return Double(display!.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display!.text!
        if (userIsInTheMiddleOfTyping) {
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func touchDecimal(_ sender: UIButton) {
        let dot = sender.currentTitle!
        let textCurrentlyInDisplay = display!.text!
        if (userTypedDot == false) {
            if (userIsInTheMiddleOfTyping) {
                display.text = textCurrentlyInDisplay + dot
            } else {
                display.text = "0" + dot
                userIsInTheMiddleOfTyping = true
            }
            userTypedDot = true
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        displayValue = 0
        descriptionLabel.text = " "
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            userTypedDot = false
            descriptionLabel.text = brain.description
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        if let description = brain.description {
            descriptionLabel.text = description + (brain.resultIsPending ? ( (description.characters.last != " ") ? " …" : "…") : " =")
        }
    }
}

