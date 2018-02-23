//
//  TimeInterval+Extension.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/16.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation

extension TimeInterval {
    private var seconds: Int {
        return Int(Double(self).rounded()) % 60
    }
    
    private var minutes: Int {
        return (Int(Double(self).rounded()) / 60 ) % 60
    }
    
    private var hours: Int {
        return Int(Double(self).rounded()) / 3600
    }
    
    var stringTime: String {
        if hours != 0 {
            return String(format: "%d:%.2d:%.2d", hours, minutes, seconds)
        } else if minutes != 0 {
            return String(format: "%d:%.2d", minutes, seconds)
        } else if seconds != 0 {
            return String(format: "0:%.2d", seconds)
        } else {
            return "0:00"
        }
    }
}
