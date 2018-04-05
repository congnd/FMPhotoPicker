//
//  AVPlayer+Extension.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/22.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import AVKit

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
