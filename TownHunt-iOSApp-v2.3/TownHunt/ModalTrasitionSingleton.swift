//
//  ModalTrasitionSingleton.swift
//  TownHunt App
//
//  Created by Alvin Lee.
//  Copyright © 2017 Alvin Lee. All rights reserved.
//
//  This file defines the modal view transition listeners

import Foundation // Allows structures to be defined

protocol ModalTransitionListener {
    func modalViewDismissed()
}

class ModalTransitionMediator {
    /* Singleton */
    class var instance: ModalTransitionMediator {
        struct Static {
            static let instance: ModalTransitionMediator = ModalTransitionMediator()
        }
        return Static.instance
    }
    
    private var listener: ModalTransitionListener?
    
    private init() {
        
    }
    
    func setListener(listener: ModalTransitionListener) {
        self.listener = listener
    }
    
    func sendModalViewDismissed(modelChanged: Bool) {
        listener?.modalViewDismissed()
    }
}
