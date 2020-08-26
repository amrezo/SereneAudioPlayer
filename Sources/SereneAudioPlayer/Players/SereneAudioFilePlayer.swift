//
//  SereneAudioFilePlayer.swift
//
//  Created by Amr Al-Refae on 2020-08-26.
//  Copyright © 2020 Amr Al-Refae. All rights reserved.
//

import SwiftUI
import AVFoundation
import MediaPlayer

public struct SereneAudioFilePlayer: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    public var track: Track
    public var folderName: String
    
    @State var trackFavourited: Bool = false
    
    @State var player: AVAudioPlayer!
    @State var playing = false
    @State var width: CGFloat = 0
    @State var finish = false
    @State var del = AVDelegate()
    
    public var body: some View {
        ZStack {
            
            // Background Image of current track
            Image(track.image ?? "")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width)
                .edgesIgnoringSafeArea(.vertical)
            
            // Gradient Overlay (Clear to Black)
            VStack {
                Spacer()
                Rectangle()
                    .foregroundColor(.clear)
                    .background(LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .top, endPoint: .bottom))
                    .edgesIgnoringSafeArea(.bottom)
                    .frame(height: UIScreen.main.bounds.height / 1.5)
            }
            
            VStack {
                Spacer()
                
                VStack(alignment: .center) {
                    Text(track.title ?? "No track title")
                        .foregroundColor(.white)
                        .font(.custom("Quicksand SemiBold", size: 18))
                        .padding(.bottom, 10)
                        .padding(.horizontal, 30)
                        .multilineTextAlignment(.center)
                    
                    Text(track.subtitle ?? "No track subtitle")
                        .foregroundColor(Color.white.opacity(0.6))
                        .font(.custom("Quicksand SemiBold", size: 16))
                        .padding(.bottom, 30)
                }
                
                ZStack(alignment: .leading) {
                    
                    Capsule().fill(Color.white.opacity(0.08)).frame(height: 5)
                    
                    Capsule().fill(Color.white).frame(width: self.width, height: 5)
                        .gesture(DragGesture().onChanged({ (value) in
                            
                            let x = value.location.x
                            
                            self.width = x
                            
                        }).onEnded({ (value) in
                            
                            let x = value.location.x
                            
                            let screen = UIScreen.main.bounds.width - 30
                            
                            let percent = x / screen
                            
                            self.player.currentTime = Double(percent) * self.player.duration
                        }))
                }
                .padding(.horizontal, 30)
                
                HStack {
                    
                    if player != nil {
                        Text(String(format: "%02d:%02d", ((Int)((player.currentTime))) / 60, ((Int)((player.currentTime))) % 60))
                            .foregroundColor(Color.white.opacity(0.6))
                            .font(.custom("Quicksand Regular", size: 14))
                    } else {
                        Text("0:00")
                            .foregroundColor(Color.white.opacity(0.6))
                            .font(.custom("Quicksand Regular", size: 14))
                    }
                    
                    Spacer()
                    
                    if player != nil {
                        Text(String(format: "%02d:%02d", ((Int)((player.duration))) / 60, ((Int)((player.duration))) % 60))
                            .foregroundColor(Color.white.opacity(0.6))
                            .font(.custom("Quicksand Regular", size: 14))
                    } else {
                        Text("0:00")
                            .foregroundColor(Color.white.opacity(0.6))
                            .font(.custom("Quicksand Regular", size: 14))
                    }
                    
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .padding(.bottom, 30)
                
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        self.player.stop()
                        MPRemoteCommandCenter.shared().playCommand.removeTarget(nil)
                        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(nil)
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        VStack(alignment: .center) {
                            Image(systemName: "stop.fill")
                                .foregroundColor(.white)
                                .font(.title)
                                .padding()
                            Text("Stop")
                                .foregroundColor(Color.white)
                                .font(.custom("Quicksand Regular", size: 14))
                        }
                    }
                    
                    
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                
                HStack {
                    
                    Button(action: {
                        
                        self.trackFavourited.toggle()
                        
                    }) {
                        
                        if track.favourited == true {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding()
                        } else {
                            Image(systemName: "heart")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                        }
                        
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.player.currentTime -= 15
                    }) {
                        Image(systemName: "gobackward.15")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if self.player.isPlaying {
                            
                            self.player.pause()
                            self.playing = false
                        }
                        else{
                            
                            if self.finish{
                                
                                self.player.currentTime = 0
                                self.width = 0
                                self.finish = false
                                
                            }
                            
                            self.player.play()
                            self.playing = true
                        }
                    }) {
                        Image(systemName: self.playing && !self.finish ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        let increase = self.player.currentTime + 15
                        
                        if increase < self.player.duration {
                            
                            self.player.currentTime = increase
                        }
                    }) {
                        Image(systemName: "goforward.15")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .onAppear {
                    let documentsUrl =  FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first! as URL
                    let documentsFolderUrl = documentsUrl.appendingPathComponent(self.folderName)
                    let destinationUrl = documentsFolderUrl.appendingPathComponent(self.track.recording ?? "")
                    
                    self.player = try! AVAudioPlayer(contentsOf: destinationUrl)
                    
                    self.player.delegate = self.del
                    
                    self.player.prepareToPlay()
                    
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                        
                        if self.player.isPlaying {
                            
                            let screen = UIScreen.main.bounds.width - 30
                            
                            let value = self.player.currentTime / self.player.duration
                            
                            self.width = screen * CGFloat(value)
                        }
                    }
                    
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { (_) in
                        
                        self.finish = true
                    }
                    
                    self.setupRemoteTransportControls()
                    self.setupNowPlaying(track: self.track)
                    
                }
            }
            
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [self] event in
            print("Play command - is playing: \(self.player.isPlaying)")
            if !self.player.isPlaying {
                self.player.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [self] event in
            print("Pause command - is playing: \(self.player.isPlaying)")
            if self.player.isPlaying {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    func setupNowPlaying(track: Track) {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        
        if let image = UIImage(named: track.image ?? "") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
