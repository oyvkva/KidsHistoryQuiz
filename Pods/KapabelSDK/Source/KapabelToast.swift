//
//  KapabelToast.swift
//  Kapabel SDK
//
//  Created by Oyvind Kvanes on 06/08/16.
//  Copyright © 2016 Kvanes AS. All rights reserved.
//

import UIKit

class KapabelToast: Foundation.Operation {
    
    var view: KapabelToastView = KapabelToastView()
    var delay: TimeInterval = 0.2
    var duration: TimeInterval = 4.0
    
    var text: String? {
        get {
            return self.view.textLabel.text
        }
        set {
            self.view.textLabel.text = newValue
        }
    }
    fileprivate var _executing = false
    override var isExecuting: Bool {
        get {
            return self._executing
        }
        set {
            self.willChangeValue(forKey: "isExecuting")
            self._executing = newValue
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    fileprivate var _finished = false
    override var isFinished: Bool {
        get {
            return self._finished
        }
        set {
            self.willChangeValue(forKey: "isFinished")
            self._finished = newValue
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    class func make(_ text: String) -> KapabelToast {
        logMs(text)
        let toast = KapabelToast()
        toast.text = text
        return toast
    }
    
    func show() {
        KapabelToastManager.center().addToast(self)
    }
    
    override func start() {
        if !Thread.isMainThread {
            DispatchQueue.main.async(execute: {
                self.start()
            })
        } else {
            super.start()
        }
    }
    
    override func main() {
        self.isExecuting = true
        
        DispatchQueue.main.async(execute: {
            self.view.updateView()
            self.view.alpha = 0
            UIApplication.shared.windows.first?.addSubview(self.view)
            UIView.animate(
                withDuration: 0.5,
                delay: self.delay,
                options: .beginFromCurrentState,
                animations: {
                    self.view.alpha = 1
                },
                completion: { completed in
                    UIView.animate(
                        withDuration: self.duration,
                        animations: {
                            self.view.alpha = 1.0001
                        },
                        completion: { completed in
                            self.finish()
                            UIView.animate(withDuration: 0.5, animations: {
                                self.view.alpha = 0
                            })
                        }
                    )
                }
            )
        })
    }
    
    func finish() {
        self.isExecuting = false
        self.isFinished = true
    }
}
