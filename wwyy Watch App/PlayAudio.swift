//
//  PlayAudio.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/20.
//

import SwiftUI
import AVFoundation
import Foundation
import AVKit
import MediaPlayer
import UIKit

private struct SongDetail: Codable{
    var url:String?
    var id:Int64
    var size:Int64
    var md5:String
    var type:String
    var level:String
    var time:Int
}

private struct OriginForm: Codable{
    var data: [SongDetail]
}

// ==========================================================================
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

//
// To read values from URLs:
//
//   let task = URLSession.shared.welcomeTask(with: url) { welcome, response, error in
//     if let welcome = welcome {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - Welcome
private struct Welcome: Codable {
    let data: [Datum]?
    let code: Int?
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.datumTask(with: url) { datum, response, error in
//     if let datum = datum {
//       ...
//     }
//   }
//   task.resume()

// MARK: - Datum
private struct Datum: Codable {
    let id: Int64?
    let url: String?
//    let br, size: Int?
//    let md5: String?
//    let code, expi: Int?
//    let type: EncodeTypeEnum?
//    let gain: Double?
//    let peak: Double?
//    let fee: Int?
//    let uf: JSONNull?
//    let payed, flag: Int?
//    let canExtend: Bool?
//    let freeTrialInfo: FreeTrialInfo?
//    let level: Level?
//    let encodeType: EncodeTypeEnum?
//    let freeTrialPrivilege: FreeTrialPrivilege?
//    let freeTimeTrialPrivilege: FreeTimeTrialPrivilege?
//    let urlSource, rightSource: Int?
//    let podcastCtrp, effectTypes: JSONNull?
//    let time: Int?
}

private enum EncodeTypeEnum: String, Codable {
    case mp3 = "mp3"
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.freeTimeTrialPrivilegeTask(with: url) { freeTimeTrialPrivilege, response, error in
//     if let freeTimeTrialPrivilege = freeTimeTrialPrivilege {
//       ...
//     }
//   }
//   task.resume()

// MARK: - FreeTimeTrialPrivilege
private struct FreeTimeTrialPrivilege: Codable {
    let resConsumable, userConsumable: Bool?
    let type, remainTime: Int?
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.freeTrialInfoTask(with: url) { freeTrialInfo, response, error in
//     if let freeTrialInfo = freeTrialInfo {
//       ...
//     }
//   }
//   task.resume()

// MARK: - FreeTrialInfo
private struct FreeTrialInfo: Codable {
    let start, end: Int?
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.freeTrialPrivilegeTask(with: url) { freeTrialPrivilege, response, error in
//     if let freeTrialPrivilege = freeTrialPrivilege {
//       ...
//     }
//   }
//   task.resume()

// MARK: - FreeTrialPrivilege
private struct FreeTrialPrivilege: Codable {
    let resConsumable, userConsumable: Bool?
    let listenType: JSONNull?
}

private enum Level: String, Codable {
    case exhigh = "exhigh"
    case higher = "higher"
    case standard = "standard"
}

// MARK: - Helper functions for creating encoders and decoders

private func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

private func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

private extension URLSession {
    func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func welcomeTask(with url: URL, completionHandler: @escaping (Welcome?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}

// MARK: - Encode/decode helpers

private class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

// ==================================================================

private struct NetWorkImage: View {
    init(url: URL) {
        self.imageLoader = Loader(url)
    }

    @ObservedObject private var imageLoader: Loader
    var image: UIImage? {
        imageLoader.data.flatMap(UIImage.init)
    }

    var body: some View {
        VStack {
            if image != nil  {
                Image(uiImage: image!)
                    .resizable()
            } else {
                EmptyView()
            }
        }
    }
}

private final class Loader: ObservableObject {

    var task: URLSessionDataTask!
    @Published var data: Data? = nil

    init(_ url: URL) {
        task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
            DispatchQueue.main.async {
                self.data = data
            }
        })
        task.resume()
    }
    deinit {
        task.cancel()
    }
}

extension String {
    var `extension`: String {
        if let index = self.lastIndex(of: ".") {
            return String(self[index...])
        } else {
            return ""
        }
    }
}

var sn:[String] = ["🐔你太美"]
var sa:[String] = ["坤坤"]
var si:[AVPlayerItem] = [AVPlayerItem(url: URL(string: unavaliable)!)]

struct Like: Codable {
    var code:Int
}

var isl:Bool = false

struct PlayAudio: View {
    
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private let timer2 = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isNewTask:Bool
    @State var isPlaying:Bool = false
    @State var isLoading:Bool = true
    @State var playProgress:Double = 0.0
    @State var playTime:String = "--:--"
    @State var totalTime:String = "--:--"
    var screenWidth:Double = 90
    @State var tipText = "正在播放"
    
    @State var playid:Int = 0
    @State var bottomText:String = "--:--/--:--"
    @State var scrollAmount:Double = 1.0
    @State var lastAmount:Double = 1.0
    @State var waitingTime:Int = 0
    
    @State var like_this_song:Bool = false
    @State private var showAlert = false
    @State private var detailPagePresented = false
    
    public init(songItems:[AVPlayerItem], name:[String], ar:[String], isnt:Bool,isll:Bool){
        isNewTask = isnt
        isl = isll
        if(isNewTask == false){
            playid = Gplayid
            isPlaying = (player.timeControlStatus == .playing)
            sn = Gsn
            sa = Gsa
            si = Gsi
            isLoading = false
            return
        }
        
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(AVAudioSession.Category.playback,
                                    mode: .default,
                                    policy: .longFormAudio,
                                    options: [])
        } catch let error {
            fatalError("*** Unable to set up the audio session: \(error.localizedDescription) ***")
        }
        
        // Activate and request the route.
        session.activate(options: []) { (success, error) in
            guard error == nil else {
                print("*** An error occurred: \(error!.localizedDescription) ***")
                // Handle the error here.
                return
            }
        }
        
        nowPlayingInfoCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: "wwyy",
            MPMediaItemPropertyArtist: "Not Playing",
        ]
        
        sn = name
        sa = ar
        si = songItems
        playid = 0
        Gsn = name
        Gsa = ar
        Gsi = songItems
        Gplayid = 0
        player = AVQueuePlayer(items: [songItems[0]])
//        player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 10))
        player.rate = 1.0
        player.play()
        print("shit:::"+String(player.reasonForWaitingToPlay?.rawValue ?? "no shit"))
        print(songItems[0])
        nowPlayingInfoCenter.playbackState = .playing
        updateNowPlaying()
        
        remoteCommandCenter.pauseCommand.addTarget { event in
            player.pause()
            return .success
        }
        remoteCommandCenter.playCommand.addTarget { event in
            player.play()
            return .success
        }
        remoteCommandCenter.previousTrackCommand.addTarget { _ in
            if(order=="repeat" || order=="repeat.1"){
                if(Gplayid > 0){
                    //
                }else{
                    Gplayid = Gsongids.count
                }
            }else if(order=="random"){
                Gplayid = Int(arc4random()) % Gsongids.count;
                Gplayid = Gplayid + 1
            }
            if(!isl){
                let myurl = URL(string: "\(apiServer)/song/url/v1?id=\(Gsongids[Gplayid-1])&level=\(profile.defaultQuality)")!
                var urlRequest = URLRequest(url:myurl)
                urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
                let task = URLSession.shared.welcomeTask(with: myurl) { welcome, response, error in
                    if let welcome = welcome {
                        let decodedData = welcome
                        Gsi[Gplayid-1] = AVPlayerItem(url: URL(string: decodedData.data![0].url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                        si[Gplayid-1] = Gsi[Gplayid-1]
                        GupdateTime[Gplayid-1] = Date().timeStamp
                        player.removeAllItems()
                        player.insert(Gsi[Gplayid-1], after: nil)
                        Gplayid -= 1
                        change_by_playlist = true
                        nowPlayingInfoCenter.nowPlayingInfo = [
                            MPMediaItemPropertyTitle: Gsn[Gplayid],
                            MPMediaItemPropertyArtist: Gsa[Gplayid]
                        ]
                        player.seek(to: CMTime.zero)
                    }
                }
                task.resume()
            }else{
                Gsi[Gplayid-1] = AVPlayerItem(url: URL(string: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(Gsongids[Gplayid-1]) + separator + Gsn[Gplayid-1] + separator + Gsa[Gplayid-1])!)
                si[Gplayid-1] = Gsi[Gplayid-1]
                GupdateTime[Gplayid-1] = Date().timeStamp
                player.removeAllItems()
                player.insert(Gsi[Gplayid-1], after: nil)
                Gplayid -= 1
                change_by_playlist = true
                nowPlayingInfoCenter.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: Gsn[Gplayid],
                    MPMediaItemPropertyArtist: Gsa[Gplayid]
                ]
                player.seek(to: CMTime.zero)
            }
            return .success
        }
        remoteCommandCenter.nextTrackCommand.addTarget { _ in
            if(order=="repeat" || order=="repeat.1"){
                if(Gplayid < Gsi.endIndex - 1){
                    //
                }else{
                    Gplayid = -1
                }
            }else if(order=="random"){
                Gplayid = Int(arc4random()) % Gsongids.count;
                Gplayid = Gplayid - 1
            }
            if(!isl){
                let myurl = URL(string: "\(apiServer)/song/url/v1?id=\(Gsongids[Gplayid+1])&level=\(profile.defaultQuality)")!
                var urlRequest = URLRequest(url:myurl)
                urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
                let task = URLSession.shared.welcomeTask(with: myurl) { welcome, response, error in
                    if let welcome = welcome {
                        let decodedData = welcome
                        Gsi[Gplayid+1] = AVPlayerItem(url: URL(string: decodedData.data![0].url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                        si[Gplayid+1] = Gsi[Gplayid+1]
                        GupdateTime[Gplayid+1] = Date().timeStamp
                        player.removeAllItems()
                        player.insert(Gsi[Gplayid+1], after: nil)
                        Gplayid += 1
                        change_by_playlist = true
                        nowPlayingInfoCenter.nowPlayingInfo = [
                            MPMediaItemPropertyTitle: Gsn[Gplayid],
                            MPMediaItemPropertyArtist: Gsa[Gplayid]
                        ]
                        player.seek(to: CMTime.zero)
                    }
                }
                task.resume()
            }else{
                Gsi[Gplayid+1] = AVPlayerItem(url: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(Gsongids[Gplayid+1]) + separator + Gsn[Gplayid+1] + separator + Gsa[Gplayid+1]))
                si[Gplayid+1] = Gsi[Gplayid+1]
                GupdateTime[Gplayid+1] = Date().timeStamp
                player.removeAllItems()
                player.insert(Gsi[Gplayid+1], after: nil)
                Gplayid += 1
                change_by_playlist = true
                nowPlayingInfoCenter.nowPlayingInfo = [
                    MPMediaItemPropertyTitle: Gsn[Gplayid],
                    MPMediaItemPropertyArtist: Gsa[Gplayid]
                ]
                player.seek(to: CMTime.zero)
            }
            return .success
        }
        
        player.actionAtItemEnd = .none
        
        isPlaying=true
        isLoading=false
    }

    static private func getSongUrl(replayid:Int) async throws -> Welcome {
        let url = URL(string: "\(apiServer)/song/url/v1?id=\(String(Gsongids[replayid]))&level=\(profile.defaultQuality)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let iTunesResult = try JSONDecoder().decode(Welcome.self, from: data)
        return iTunesResult
    }
    
    private func updateNowPlaying(){
        nowPlayingInfoCenter.nowPlayingInfo = [
            MPMediaItemPropertyTitle: sn[playid],
            MPMediaItemPropertyArtist: sa[playid]
        ]
    }
    
    private func goto_previous() async{
        Task{
            if(order=="repeat" || order=="repeat.1"){
                if(playid > 0){
                    //
                }else{
                    playid = Gsongids.count
                }
            }else if(order=="random"){
                playid = Int(arc4random()) % Gsongids.count;
                playid = playid + 1
            }
            player.pause()
            isPlaying = false
            if(!isl){
                let decodedData = try await PlayAudio.getSongUrl(replayid: playid-1)
                for ob in decodedData.data!{
                    Gsi[playid-1]=AVPlayerItem(url: URL(string: ob.url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                    si[playid-1]=AVPlayerItem(url: URL(string: ob.url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                    GupdateTime[playid-1] = Date().timeStamp
                }
            }else{
                Gsi[playid-1]=(AVPlayerItem(url: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(Gsongids[playid-1]) + separator + sn[playid-1] + separator + sa[playid-1])))
                si[playid-1]=(AVPlayerItem(url: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(Gsongids[playid-1]) + separator + sn[playid-1] + separator + sa[playid-1])))
                GupdateTime[playid-1] = Date().timeStamp
            }
            player.removeAllItems()
            player.insert(si[playid-1], after: nil)
            playid -= 1
            Gplayid = playid
            updateNowPlaying()
            await player.seek(to: CMTime.zero)
            player.play()
            isPlaying = true
        }
    }
    
    private func goto_next() async{
        if(order=="repeat" || order=="repeat.1"){
            if(playid < si.endIndex - 1){
                //
            }else{
                playid = -1
            }
        }else if(order=="random"){
            playid = Int(arc4random()) % Gsongids.count;
            playid = playid - 1
        }
        do{
            player.pause()
            isPlaying = false
            if(!isl){
                let decodedData = try await PlayAudio.getSongUrl(replayid: playid+1)
                for ob in decodedData.data!{
                    Gsi[playid+1]=AVPlayerItem(url: URL(string: ob.url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                    si[playid+1]=AVPlayerItem(url: URL(string: ob.url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                    GupdateTime[playid+1] = Date().timeStamp
                }
            }else{
                Gsi[playid+1]=(AVPlayerItem(url: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(Gsongids[playid+1]) + separator + sn[playid+1] + separator + sa[playid+1])))
                si[playid-1]=(AVPlayerItem(url: URL(fileURLWithPath: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(Gsongids[playid+1]) + separator + sn[playid+1] + separator + sa[playid+1])))
                GupdateTime[playid+1] = Date().timeStamp
            }
            playid += 1
            Gplayid = playid
            player.removeAllItems()
            player.insert(si[playid], after: nil)
            updateNowPlaying()
            await player.seek(to: CMTime.zero)
            player.play()
            isPlaying = true
        }catch{
//                sa[0] = error.localizedDescription.substring(from: 40)
        }
    }

    public var body: some View {
        
        ZStack{
//            NetWorkImage(url:URL(string: "https://p4.music.126.net/W7Rt5cguIA51XAmQNpWIUg==/109951164924777613.jpg")!)
//                .frame(maxWidth: .infinity,maxHeight: .infinity)
//                .scaledToFill()
//                .scaleEffect(1.3)
//                .blur(radius: 2)
//
//            Color.black.frame(alignment: .center)
//                .scaleEffect(1.5)
//                .opacity(0.65)
            
            VStack(alignment: .leading){
                // 标题 & 歌手
                VStack(alignment: .leading){
                    Text(sn[playid])
                        .font(.headline)
                        .frame(alignment: .leading)
                    Text(sa[playid]).font(.caption).foregroundColor(.gray)
                }.padding(.horizontal)
                
                Spacer()
                
                HStack{
                    if(playid > 0){
                        Button(action: {
                            Task{
                                await goto_previous()
                            }
                        }, label: {
                            HStack{
                                Image(systemName: "backward.fill")
                                    .padding(.horizontal)
                            }
                        })
                    }else{
                        Button(action: {
                            //
                        }, label: {
                            HStack{
                                Image(systemName: "backward.fill")
                                    .padding(.horizontal)
                            }
                        })
                    }
                    // =======================
                    if(isLoading){
                        if(isPlaying){
                            Button(action: {
                                player.pause()
                                isPlaying = !isPlaying
                            }) {
                                Image(systemName: "pause.circle.fill").resizable()
                                    .frame(width: 50, height: 50)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                            }.buttonStyle(BorderlessButtonStyle())
                        }else{
                            Button(action: {
                                player.play()
                                isPlaying = !isPlaying
                            }) {
                                Image(systemName: "play.circle.fill").resizable()
                                    .frame(width: 50, height: 50)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.white)
                            }.buttonStyle(BorderlessButtonStyle())
                        }
                    }else{
                        Button(action: {
                            
                        }) {
                            Image(systemName: "play.circle").resizable()
                                .frame(width: 50, height: 50)
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                    // =======================
                    if(playid < si.endIndex-1){
                        Button(action: {
                            Task{
                                await goto_next()
                            }
                        }, label: {
                            HStack{
                                Image(systemName: "forward.fill")
                                    .padding(.horizontal)
                            }
                        })
                    }else{
                        Button(action: {
                            //
                        }, label: {
                            HStack{
                                Image(systemName: "forward.fill")
                                    .padding(.horizontal)
                            }
                        })
                    }
                }
                
                Spacer()
                
                HStack{
                    Button(action: {
                        player.seek(to: CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentTime())-5, preferredTimescale: player.currentItem!.duration.timescale))
                    }, label: {
                        Image(systemName: "gobackward.5")
                            .padding(.horizontal)
                            .foregroundColor(.white)
                    }).buttonStyle(BorderlessButtonStyle())
                    ZStack{
                        HStack{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.white)
                                .frame(maxWidth: screenWidth*playProgress, maxHeight: 5)
                                .padding(.trailing, 0)
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                                .frame(maxWidth: screenWidth*(1.0-playProgress), maxHeight: 5)
                                .padding(.trailing, 0)
                        }.frame(alignment: .center)
                    }
                    .frame(alignment: .center)
                    .onReceive(timer) { _ in
                        isPlaying = (player.timeControlStatus == .playing)
                        if(player.timeControlStatus == .playing){
                            nowPlayingInfoCenter.playbackState = .playing
                        }else{
                            nowPlayingInfoCenter.playbackState = .paused
                        }
                        if(playid != Gplayid){
                            playid = Gplayid
                            if(change_by_playlist){
                                change_by_playlist = false
                                player.removeAllItems()
                                player.insert(si[playid], after: nil)
                                player.seek(to: CMTime.zero)
                            }
                        }
                        if(player.timeControlStatus == .playing){
                            if(CMTimeGetSeconds(player.currentTime()) >= CMTimeGetSeconds(si[playid].duration)){
                                if(playid < si.endIndex-1){
                                    Task{
                                        if(order=="random" || order=="repeat"){
                                            await goto_next()
                                        }else if(order=="repeat.1"){
                                            await player.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: player.currentItem!.duration.timescale))
                                            print("repeat.1")
                                        }
                                    }
                                }else{
                                    player.pause()
                                }
                            }else{
                                playProgress = 1.0 * CMTimeGetSeconds(player.currentTime()) / CMTimeGetSeconds(player.currentItem!.duration)
                                nowPlayingInfoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyIsLiveStream] = NSNumber(value: 0)
//                                nowPlayingInfoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackProgress] = NSNumber(value: playProgress)
                                nowPlayingInfoCenter.nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value:CMTimeGetSeconds(player.currentTime()))
                                nowPlayingInfoCenter.nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = NSNumber(value:CMTimeGetSeconds(si[playid].duration))
                                let  currentTime =  CMTimeGetSeconds ( player.currentTime())
                                //一个小算法，来实现00：00这种格式的播放时间
                                var all:Int = 0
                                if(!currentTime.isNaN){
                                    all = Int (currentTime);
                                }
                                let  m: Int = all % 60
                                let  f: Int = Int (all/60)
                                var  time: String = ""
                                if  f<10{
                                    time = "0\(f):"
                                } else  {
                                    time = "\(f)"
                                }
                                if  m<10{
                                    time += "0\(m)"
                                } else  {
                                    time += "\(m)"
                                }
                                //更新播放时间
                                playTime=time
                                if(playProgress > 0.0000001){
                                    let  currentTime =  CMTimeGetSeconds ( player.currentItem!.duration)
                                    //一个小算法，来实现00：00这种格式的播放时间
                                    let  all: Int = Int (currentTime)
                                    let  m: Int = all % 60
                                    let  f: Int = Int (all/60)
                                    var  time: String = ""
                                    if  f<10{
                                        time = "0\(f):"
                                    } else  {
                                        time = "\(f)"
                                    }
                                    if  m<10{
                                        time += "0\(m)"
                                    } else  {
                                        time += "\(m)"
                                    }
                                    //更新播放时间
                                    totalTime=time
                                }
                            }
                        }
                    }
                    Button(action: {
                        player.seek(to: CMTimeMakeWithSeconds(CMTimeGetSeconds(player.currentTime())+5, preferredTimescale: player.currentItem!.duration.timescale))
                    }, label: {
                        Image(systemName: "goforward.5")
                            .padding(.horizontal)
                            .foregroundColor(.white)
                    }).buttonStyle(BorderlessButtonStyle())
                }
                
                Spacer()
                Spacer()
                
                // 底部控制栏
                HStack{
                    Button(action: {
                        like_song()
                    }, label: {
                        HStack{
                            if(like_this_song){
                                Image(systemName: "heart.fill")
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                            }else{
                                Image(systemName: "heart")
                                    .padding(.horizontal)
                                    .foregroundColor(.white)
                            }
                        }.alert(isPresented: $showAlert){
                            Alert(title: Text("提示"), message: Text("请登录后再使用”喜欢音乐“功能"), dismissButton: .default(Text("好")))
                        }
                    }).buttonStyle(BorderlessButtonStyle())
                        .onReceive(timer2) { _ in
                            let nowid = Gsongids[playid]
                            if(likedsongs.contains(nowid)){
                                like_this_song = true
                            }else{
                                like_this_song = false
                            }
                        }
                    Spacer()
                    Text(bottomText)
                        .font(.caption)
                        .focusable(true)
                        .digitalCrownRotation($scrollAmount, from: 0, through: 1, by: 0.01, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
                        .onReceive(timer) { _ in
                            if(scrollAmount != lastAmount){
                                lastAmount = scrollAmount
                                bottomText = "音量：\(Int(scrollAmount*100))%"
                                player.volume = Float(scrollAmount)
                                waitingTime = 0
                            }else{
                                if(waitingTime < 20){
                                    waitingTime += 1
                                }else{
                                    bottomText = "\(playTime)/\(totalTime)"
                                    waitingTime = 0
                                }
                            }
                        }
//                        .onTapGesture {
//                            downloadMusic(mid:Gsongids[playid],artist: Gsa[playid],name: Gsn[playid])
//                        }
                    Spacer()
                    Button(action: {
                        detailPagePresented = true
                    }, label: {
                        HStack{
                            Image(systemName: "ellipsis")
                                .padding(.horizontal)
                                .foregroundColor(.white)
//                                .sheet(isPresented: $detailPagePresented) {
//                                    SongDetailPage(songid: Gsongids[playid])
//                                }
                        }
                    }).buttonStyle(BorderlessButtonStyle())
                }
                
            }.navigationBarTitle(tipText)
        }
    }
    
    func like_song(){
        var urllike:String
        if(like_this_song){
            urllike = "false"
        }else{
            urllike = "true"
        }
        let nowid = Gsongids[playid]
        print("nowid = \(nowid)")
        let urlstr:String = "\(apiServer)/like?id=\(nowid)&like=\(urllike)&cookie=\(profile.user.cookie)"
        let urlcoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlcoded)!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(Like.self, from: sheetData)
                    DispatchQueue.main.async {
                        let code = decodedData.code
                        if(code == 200){
                            if(like_this_song==true){
                                likedsongs.removeAll(where: {$0 == nowid})
                            }else{
                                likedsongs.append(nowid)
                            }
                            like_this_song.toggle()
                        }else{
                            showAlert = true
                        }
                    }
                } else {
                    print("No data")
                }
            } catch {
//                commentdata[0].content = error.localizedDescription
            }
        }.resume()
    }
}

//struct PlayAudio_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayAudio(songItems: [AVPlayerItem(url: URL(string: unavaliable)!)], name:["你干嘛"], ar:["坤坤"], isnt: true)
//    }
//}

func downloadMusic(mid:Int64,artist:String,name:String) {
    check_music_folder()
    var rurl:String = "\(apiServer)/song/url/v1?id=\(mid)&level=\(profile.defaultQuality)&cookie=\(profile.user.cookie)"
    let myurl = URL(string: rurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    var urlRequest = URLRequest(url:myurl)
    urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
    let task = URLSession.shared.welcomeTask(with: myurl) { welcome, response, error in
        if let welcome = welcome {
            let decodedData = welcome
            var httpurl = decodedData.data?[0].url
            var murl = httpurl!.replacingOccurrences(of: "http://", with: "https://")
            let url = URL(string: murl)
            print("musicURL = "+murl)
            let request = URLRequest(url: url!)
            let session = URLSession.shared
            let downloadTask = session.downloadTask(with: request,
                   completionHandler: { (location:URL?, response:URLResponse?, error:Error?)
                    -> Void in
                    print("location:\(String(describing: location))")
                    let locationPath = location!.path
                    var documnets:String = NSHomeDirectory() + "/Documents/wwyyMusic/\(String(mid))\(separator)\(name)\(separator)\(artist)\(murl.extension)"
//                    documnets = documnets.replacingOccurrences(of: " ", with: "_")
                    let fileManager = FileManager.default
                    try! fileManager.moveItem(atPath: locationPath, toPath: documnets)
                    print("new location:\(documnets)")
            })
            downloadTask.resume()
        }
    }
    task.resume()
}

func check_music_folder(){
    let fileManager = FileManager.default
    let filePath:String = NSHomeDirectory() + "/Documents/wwyyMusic"
    let exist = fileManager.fileExists(atPath: filePath)
    if(!exist){
        let myDirectory:String = NSHomeDirectory() + "/Documents/wwyyMusic"
        let fileManager = FileManager.default
        try! fileManager.createDirectory(atPath: myDirectory,
                                                 withIntermediateDirectories: true, attributes: nil)
    }
}

// /Users/diyanqi/Library/Developer/CoreSimulator/Devices/C3D8D920-7138-4A71-BC55-E9B0ACECF6D2/data/Containers/Data/Application/0D67358C-7935-4DEB-A3F0-20F23870BD5E/Documents/wwyyMusic/1390601339`Flames`11:11.mp3

// /Users/diyanqi/Library/Developer/CoreSimulator/Devices/C3D8D920-7138-4A71-BC55-E9B0ACECF6D2/data/Containers/Data/Application/0D67358C-7935-4DEB-A3F0-20F23870BD5E/Documents/wwyyMusic/1390601339`Flames`11:11.mp3
