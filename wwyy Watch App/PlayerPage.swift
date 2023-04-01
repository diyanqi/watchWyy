//
//  PlayerPage.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/19.
//

import SwiftUI
import AVFoundation
import Foundation
import AVKit
import WatchKit

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
import _WatchKit_SwiftUI

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
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
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

extension Date {

    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : Int64 {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int64(timeInterval)
        return (timeStamp)
    }
}

struct Likedsongs:Decodable {
    var ids:[Int64]
}

var likedsongs:[Int64] = [114514,1919810]

struct PlayerPage: View {
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var newTask:Bool = false // 新的歌曲 or 接管之前已经在播放的
    @State var islocal:Bool = false // 播放的是本地音乐？
    @State var songid:[Int64] = [27203936]
    @State var songname:[String] = ["YMCA"]
    @State var songar:[String] = ["Village People"]
    @State var bartitle:[String] = ["歌曲播放"]
    @State var urlGot:Int = 0
    @State private var urls:[OriginForm] = [OriginForm(data: [SongDetail(url: "0", id: 0, size: 0, md5: "0", type: "0", level: "0", time: 0)])]
    @State var musicItems:[AVPlayerItem] = [AVPlayerItem(url: URL(string: "url")!)]
    @State private var mytip:String = "正在加载歌曲"
    @State var tabViewSelected: Int = 2
    @State private var myValue:Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading){
            if(urlGot >= songid.endIndex){
                ZStack {
                    Color.clear.edgesIgnoringSafeArea(.all)
                    
                    TabView(selection: $tabViewSelected){
                        ZStack {
                            Color.clear.edgesIgnoringSafeArea(.all)
                            NowPlayingView().navigationBarTitle("").background(Color.clear).edgesIgnoringSafeArea(.top)
                        }.tag(-1)
                        if(newTask){
                            PlayListShow(name: songname, ar: songar).tag(0)
                        }else{
                            PlayListShow(name: Gsn, ar: Gsa).tag(0)
                        }
                        SongDetailPage(songid: Gsongids[Gplayid]).tag(1)
                        PlayAudio(songItems: musicItems, name: songname, ar: songar, isnt: newTask, isll: islocal).tag(2)
                        LyricsShow().tag(3)
                        CommentShow().tag(4)
                    }.edgesIgnoringSafeArea(.top)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }else{
                VStack{
                    ProgressView()
                }
            }
        }
        .onAppear(perform: {
            self.getUrl()
            self.get_liked_songs()
        })
    }
    func getUrl(){
        if(newTask == false){
            urlGot = 114514
            return
        }
        if(islocal){
            for i in 0...songid.count-1{
                var lurl = NSHomeDirectory()
                lurl += "/Documents/wwyyMusic/"
                lurl += String(songid[i])
                lurl += separator
                lurl += songname[i]
                lurl += separator
                lurl += songar[i]
                musicItems.append(AVPlayerItem(url: URL(fileURLWithPath: lurl)))
                print("URL:",URL(fileURLWithPath: lurl))
                let fileManager = FileManager.default
                let filePath:String = lurl
                let exist = fileManager.fileExists(atPath: filePath)
                if(exist){
                    print("it really exists!!!")
                }else{
                    print("fuck!!!")
                }
                print("lurl = "+lurl)
                Gsongids.append(songid[i])
                GupdateTime.append(Date().timeStamp)
            }
            urlGot = 114514
        }else{
            var sid2pid:[Int64:Int] = [Int64:Int]() // 歌曲id 到 播放序号
            musicItems = []
            Gsongids = []
            GupdateTime = []
            var rurl:String = "\(apiServer)/song/url/v1?id=\(songid[0])"
            var steppp = 0
            for nowid in songid{
                musicItems.append(AVPlayerItem(url: URL(string: unavaliable)!))
                steppp += 1
                sid2pid.updateValue(steppp-1, forKey: nowid)
                Gsongids.append(nowid)
                GupdateTime.append(0)
                //            if(steppp == 1){
                //                rurl += String(nowid)
                //            }else{
                //                rurl += ","
                //                rurl += String(nowid)
                //            }
            }
            //        print(rurl + "&level=lossless")
            rurl += "&level=\(profile.defaultQuality)"
            rurl += "&cookie=\(profile.user.cookie)"
            let myurl = URL(string: rurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            var urlRequest = URLRequest(url:myurl)
            urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
            let task = URLSession.shared.welcomeTask(with: myurl) { welcome, response, error in
                if let welcome = welcome {
                    let decodedData = welcome
                    for ob in decodedData.data!{
                        let realid:Int = sid2pid[ob.id!]!
                        GupdateTime[realid] = Date().timeStamp
                        musicItems[realid] = AVPlayerItem(url: URL(string: ob.url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                        urlGot = 114514
                        print(ob.url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)
                    }
                }
            }
            task.resume()
        }
    }
    
    func get_liked_songs(){
        let urlstr:String = "\(apiServer)/likelist?uid=\(uid)&cookie=\(profile.user.cookie)"
        let urlcoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlcoded)!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(Likedsongs.self, from: sheetData)
                    DispatchQueue.main.async {
                        likedsongs = decodedData.ids
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

struct PlayerPage_Previews: PreviewProvider {
    static var previews: some View {
        PlayerPage()
    }
}

