//
//  Track.swift
//  
//  Created by Amr Al-Refae on 2020-08-26.
//  Copyright © 2020 Amr Al-Refae. All rights reserved.
//

import Foundation

public struct Track {
    
    var image: String?
    var title: String?
    var subtitle: String?
    var recording: String?
    var streamURL: String?
    var favourited: Bool?
    
    public init(image: String, title: String, subtitle: String, recording: String, streamURL: String, favourited: Bool) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.recording = recording
        self.streamURL = streamURL
        self.favourited = favourited
        
    }
}
