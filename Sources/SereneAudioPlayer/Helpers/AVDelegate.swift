//
//  AVDelegate.swift
//  
//  Created by Amr Al-Refae on 2020-08-26.
//  Copyright © 2020 Amr Al-Refae. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

public class AVDelegate: NSObject, AVAudioPlayerDelegate{
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
    }
}

