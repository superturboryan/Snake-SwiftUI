//
//  Haptics.swift
//  Genre
//
//  Created by Ryan David Forsyth on 2019-12-03.
//  Copyright © 2019 Ryan F. All rights reserved.
//

import UIKit

class Haptics: NSObject {
    
    static func impact(forStyle style: UIImpactFeedbackGenerator.FeedbackStyle) {
        var generator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: style)
        generator?.impactOccurred()
        generator = nil
    }
    
    static func notification(forType type: UINotificationFeedbackGenerator.FeedbackType) {
        var generator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
        generator?.notificationOccurred(type)
        generator = nil
    }
     
    static func selection() {
        var generator: UISelectionFeedbackGenerator? = UISelectionFeedbackGenerator()
        generator?.selectionChanged()
        generator = nil
    }

}
