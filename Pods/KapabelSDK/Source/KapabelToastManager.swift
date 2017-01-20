//
//  KapabelToastManager.swift
//  Kapabel SDK
//
//  Created by Oyvind Kvanes on 06/08/16.
//  Copyright © 2016 Kvanes AS. All rights reserved.
//

import UIKit

class KapabelToastManager: NSObject {
    
    fileprivate var _queue: OperationQueue!
    
    fileprivate struct Singleton {
        static let center = KapabelToastManager()
    }
    
    class func center() -> KapabelToastManager {
        return Singleton.center
    }
    
    override init() {
        super.init()
        self._queue = OperationQueue()
        self._queue.maxConcurrentOperationCount = 1
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(KapabelToastManager.deviceOrientationDidChange(_:)),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil
        )
    }
    
    func addToast(_ toast: KapabelToast) {
        self._queue.addOperation(toast)
    }
    
    func deviceOrientationDidChange(_ sender: AnyObject?) {
        if self._queue.operations.count > 0 {
            let lastToast: KapabelToast = _queue.operations[0] as! KapabelToast
            lastToast.view.updateView()
        }
    }
}
