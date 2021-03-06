/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to implement the OperationObserver protocol.
*/

import Foundation

/**
    The `BlockObserver` is a way to attach arbitrary blocks to significant events
    in an `Operation`'s lifecycle.
*/
struct BlockObserver: OperationObserver {
    // MARK: Properties
    
    private let startHandler: ((EQOperation) -> Void)?
    private let produceHandler: ((EQOperation, Operation) -> Void)?
    private let finishHandler: ((EQOperation, [NSError]) -> Void)?
    
    init(startHandler: ((EQOperation) -> Void)? = nil, produceHandler: ((EQOperation, Operation) -> Void)? = nil, finishHandler: ((EQOperation, [NSError]) -> Void)? = nil) {
        self.startHandler = startHandler
        self.produceHandler = produceHandler
        self.finishHandler = finishHandler
    }
    
    // MARK: OperationObserver
    
    func operationDidStart(operation: EQOperation) {
        startHandler?(operation)
    }
    
    func operation(operation: EQOperation, didProduceOperation newOperation: Operation) {
        produceHandler?(operation, newOperation)
    }
    
    func operationDidFinish(operation: EQOperation, errors: [NSError]) {
        finishHandler?(operation, errors)
    }
}
