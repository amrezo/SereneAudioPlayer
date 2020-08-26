//
//  SereneAudioStreamPlayer.swift
//
//  Created by Amr Al-Refae on 2020-05-31.
//  Copyright © 2020 Amr Al-Refae. All rights reserved.
//

import SwiftUI
import AVFoundation
import MediaPlayer
import ActivityIndicatorView

public struct SereneAudioStreamPlayer: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    public var track: Track
    public var folderName: String
    
    @State var trackFavourited: Bool = false
    
    @State var player : AVPlayer!
    @State var playing = false
    @State var width: CGFloat = 0
    @State var finish = false
    
    @State var downloaded = false
    @State var disableDownload = false
    @State var showingAlert = false
    
    @State var isDownloading = false
    
    public init(track: Track, folderName: String) {
        self.track = track
        self.folderName = folderName
    }
    
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
                        .gesture(DragGesture()
                            .onChanged({ (value) in
                                
                                let x = value.location.x
                                
                                self.width = x
                                
                            }).onEnded({ (value) in
                                
                                let x = value.location.x
                                
                                let screen = UIScreen.main.bounds.width - 30
                                
                                let percent = x / screen
                                
                                let seek = Double(percent) * self.player.currentItem!.asset.duration.seconds
                                
                                self.player.seek(to: CMTime(seconds: seek, preferredTimescale: self.player.currentTime().timescale))
                                
                            }))
                }
                .padding(.horizontal, 30)
                
                HStack {
                    Text("Streaming Live")
                        .foregroundColor(Color.white.opacity(0.6))
                        .font(.custom("Quicksand Regular", size: 14))
                    
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .padding(.bottom, 30)
                
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        self.player.pause()
                        self.player.seek(to: .zero)
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
                        // self.player.currentTime -= 15
                    }) {
                        Image(systemName: "gobackward.15")
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .font(.headline)
                            .padding()
                    }
                    .disabled(true)
                    
                    Spacer()
                    
                    
                    Button(action: {
                        if InternetConnectionManager.isConnectedToNetwork() {
                            print("Internet connection OK")
                            
                            
                            if self.player.isPlaying {
                                
                                self.player.pause()
                                self.playing = false
                            } else {
                                
                                if self.finish {
                                    
                                    self.player.seek(to: .zero)
                                    self.width = 0
                                    self.finish = false
                                    
                                }
                                
                                self.player.play()
                                self.playing = true
                                
                            }
                        } else {
                            print("Internet connection FAILED")
                            
                            self.showingAlert = true
                            
                        }
                    }) {
                        
                        Image(systemName: self.playing && !self.finish ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .padding()
                        
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        var timeForward = self.player.currentTime().seconds
                        timeForward += 5.0
                        if (timeForward > (self.player.currentItem?.asset.duration.seconds)!) {
                            self.player.seek(to: CMTime(seconds: timeForward, preferredTimescale: self.player.currentTime().timescale))
                        } else {
                            self.player.seek(to: (self.player.currentItem?.asset.duration)!)
                        }
                    }) {
                        Image(systemName: "goforward.15")
                            .foregroundColor(.white)
                            .opacity(0.5)
                            .font(.headline)
                            .padding()
                    }
                    .disabled(true)
                    
                    Spacer()
                    
                    Button(action: {
                        let urlString = self.track.streamURL ?? ""
                        
                        let encodedSoundString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
                        
                        self.downloadAndSaveAudioFile(encodedSoundString!) { (url) in
                            self.downloaded = true
                            self.disableDownload = true
                        }
                    }) {
                        
                        if isDownloading {
                            ActivityIndicatorView(isVisible: $isDownloading, type: .default)
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding()
                        } else {
                            if downloaded {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding()
                            } else {
                                
                                Image(systemName: "icloud.and.arrow.down.fill")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding()
                            }
                        }
                        
                        
                    }
                    .disabled(disableDownload)
                    
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
                .onAppear {
                    
                    
                    if InternetConnectionManager.isConnectedToNetwork() {
                        print("Internet connection OK")
                    } else {
                        print("Internet connection FAILED")
                        
                        self.showingAlert = true
                        
                    }
                    
                    let urlString = self.track.streamURL ?? ""
                    
                    let encodedSoundString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
                    
                    let url = URL(string: encodedSoundString!)
                    
                    let playerItem = AVPlayerItem(url: url!)
                    
                    self.player = AVPlayer.init(playerItem: playerItem)
                    
                    self.player.automaticallyWaitsToMinimizeStalling = false
                    
                    
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
                        
                        if self.player.isPlaying{
                            
                            let screen = UIScreen.main.bounds.width - 30
                            
                            let value = self.player.currentItem!.currentTime().seconds / self.player.currentItem!.asset.duration.seconds
                            
                            self.width = screen * CGFloat(value)
                        }
                    }
                    
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { (_) in
                        
                        self.finish = true
                    }
                    
                    self.setupRemoteTransportControls()
                    self.setupNowPlaying(track: self.track)
                    
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("No Internet Connection"), message: Text("Please ensure your device is connected to the internet."), dismissButton: .default(Text("Got it!")))
                    
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
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem!.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func downloadAndSaveAudioFile(_ audioFile: String, completion: @escaping (String) -> Void) {
        
        self.isDownloading.toggle()
        
        //Create directory if not present
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths.first! as NSString
        let soundDirPathString = documentDirectory.appendingPathComponent(folderName)
        
        do {
            try FileManager.default.createDirectory(atPath: soundDirPathString, withIntermediateDirectories: true, attributes:nil)
            print("directory created at \(soundDirPathString)")
        } catch let error as NSError {
            print("error while creating dir : \(error.localizedDescription)");
        }
        
        if let audioUrl = URL(string: audioFile) {
            // create your document folder url
            let documentsUrl =  FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first! as URL
            let documentsFolderUrl = documentsUrl.appendingPathComponent(folderName)
            // your destination file url
            let destinationUrl = documentsFolderUrl.appendingPathComponent(audioUrl.lastPathComponent)
            
            print(destinationUrl)
            // check if it exists before downloading it
            if FileManager().fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path")
                self.isDownloading.toggle()
            } else {
                //  if the file doesn't exist
                //  just download the data from your url
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async(execute: {
                    if let myAudioDataFromUrl = try? Data(contentsOf: audioUrl){
                        // after downloading your data you need to save it to your destination url
                        if (try? myAudioDataFromUrl.write(to: destinationUrl, options: [.atomic])) != nil {
                            print("file saved")
                            completion(destinationUrl.absoluteString)
                            self.isDownloading.toggle()
                        } else {
                            print("error saving file")
                            completion("")
                        }
                    }
                })
            }
        }
    }
    
}
