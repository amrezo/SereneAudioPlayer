//
//  AVPlayerExtension.swift
//  
//
//  Created by Amr Al-Refae on 2020-08-26.
//

import Foundation
import AVFoundation
import MediaPlayer

extension AVPlayer {
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
    
}
