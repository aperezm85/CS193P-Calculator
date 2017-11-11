//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Alex Perez Martinez on 28/10/2017.
//  Copyright © 2017 Alex Perez Martinez. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    private var accumulatorString: String?
    
    var resultIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    var description: String? {
        get {
            if pendingBinaryOperation != nil {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand, accumulatorString ?? "")
            } else {
                return accumulatorString
            }
        }
    }
 
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        let descriptionFunction: (String, String) -> String
        let descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func buildDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
    }
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "x²": Operation.unaryOperation({ $0 * $0 }, { "\($0)²" }),
        "x³": Operation.unaryOperation({ $0 * $0 * $0 }, { "(\($0))³" }),
        "xⁿ": Operation.binaryOperation({ pow($0, $1) }, { "(\($0))exp\($1)" }),
        "√": Operation.unaryOperation(sqrt, { "√\($0)" }),
        "cos": Operation.unaryOperation(cos, { "cos(\($0))" }),
        "±": Operation.unaryOperation({ -$0 }, { "±\($0)" }),
        "+": Operation.binaryOperation({ $0 + $1 }, { "\($0) + \($1)" }),
        "−": Operation.binaryOperation({ $0 - $1}, { "\($0) - \($1)" }),
        "×": Operation.binaryOperation({ $0 * $1 }, { "\($0) × \($1)" }),
        "÷": Operation.binaryOperation({ $0 / $1 }, { "\($0) ÷ \($1)" }),
        "=": Operation.equals
    ]
    
    var result: Double? {
        get {
            return accumulator
        }
    }

    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                accumulatorString = symbol
            case .unaryOperation(let function, let descriptionFunction):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    accumulatorString = descriptionFunction(accumulatorString!)
                }
            case .binaryOperation(let function, let descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function:function, firstOperand: accumulator!, descriptionFunction: descriptionFunction, descriptionOperand: accumulatorString!)
                    accumulator = nil
                    accumulatorString = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            accumulatorString = pendingBinaryOperation!.buildDescription(with: accumulatorString!)
            pendingBinaryOperation = nil
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.maximumFractionDigits = 6
        accumulatorString = numberFormatter.string(from: NSNumber(value: operand))
    }
}
