//
//  PlayListShow.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/10.
//

import SwiftUI
import MediaPlayer

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

import Foundation

// MARK: - Welcome
private struct Welcome: Codable {
    let data: [Datum]?
    let code: Int?
}
// MARK: - Datum
private struct Datum: Codable {
    let id: Int64?
    let url: String?
}

private enum EncodeTypeEnum: String, Codable {
    case mp3 = "mp3"
}
// MARK: - FreeTimeTrialPrivilege
private struct FreeTimeTrialPrivilege: Codable {
    let resConsumable, userConsumable: Bool?
    let type, remainTime: Int?
}
// MARK: - FreeTrialInfo
private struct FreeTrialInfo: Codable {
    let start, end: Int?
}
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

struct kk: Codable,Identifiable{
    var id: Int
    var songname:String
    var singer:String
}

var order:String = "repeat"

struct PlayListShow: View {
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State var mylist:[kk]
    @State var mysn:[String]
    @State var mysa:[String]
    @State var thisplayid:Int = Gplayid
    @State var ordershow = "repeat"
    
    static private func getSongUrl(replayid:Int) async throws -> Welcome {
        let url = URL(string: "\(apiServer)/song/url/v1?id=\(String(Gsongids[replayid]))&level=lossless")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let iTunesResult = try JSONDecoder().decode(Welcome.self, from: data)
        return iTunesResult
    }
    
    public init(name:[String], ar:[String]){
        mysn = name
        mysa = ar
        mylist = []
        for i in 0...mysn.endIndex-1{
            mylist.append(kk(id:Int(i), songname: mysn[i], singer: mysa[i]))
        }
    }
    
    var body: some View {
        VStack{
            NavigationView {
                VStack{
                    HStack{
                        Spacer()
                        if(ordershow=="random"){
                            Button(action: {
                                order = ("random")
                                ordershow = "random"
                            }) {
                                Image(systemName: "shuffle")
                            }.foregroundColor(.accentColor)
                        }else{
                            Button(action: {
                                order = ("random")
                                ordershow = "random"
                            }) {
                                Image(systemName: "shuffle")
                            }
                        }
                        Spacer()
                        if(ordershow=="repeat"){
                            Button(action: {
                                order = ("repeat")
                                ordershow = "repeat"
                            }) {
                                Image(systemName: "repeat")
                            }.foregroundColor(.accentColor)
                        }else{
                            Button(action: {
                                order = ("repeat")
                                ordershow = "repeat"
                            }) {
                                Image(systemName: "repeat")
                            }
                        }
                        Spacer()
                        if(ordershow=="repeat.1"){
                            Button(action: {
                                order = ("repeat.1")
                                ordershow = "repeat.1"
                            }) {
                                Image(systemName: "repeat.1")
                            }.foregroundColor(.accentColor)
                        }else{
                            Button(action: {
                                order = ("repeat.1")
                                ordershow = "repeat.1"
                            }) {
                                Image(systemName: "repeat.1")
                            }
                        }
                        Spacer()
                    }
                    List {
                        ForEach(mylist) { cont in
                            if(cont.id == thisplayid){
                                Button(action: {
                                    Gplayid = cont.id
                                    thisplayid = cont.id
                                }) {
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text("\(cont.id+1). \(cont.songname)")
                                                .foregroundColor(.white)
                                            Text(cont.singer)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }.frame(maxWidth: .infinity)
                                        Image(systemName: "play.square")
                                            .padding(.horizontal)
                                    }
                                }.buttonStyle(BorderlessButtonStyle())
                            }else{
                                Button(action: {
                                    Task{
                                        if(!isl){
                                            let decodedData = try await PlayListShow.getSongUrl(replayid: cont.id)
                                            for ob in decodedData.data!{
                                                Gsi[cont.id]=AVPlayerItem(url: URL(string: ob.url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                                                si[cont.id]=AVPlayerItem(url: URL(string: ob.url?.replacingOccurrences(of: "http://", with: "https://") ?? unavaliable)!)
                                                GupdateTime[cont.id] = Date().timeStamp
                                            }
                                        }else{
                                            Gsi[cont.id]=AVPlayerItem(url: URL(string: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(Gsongids[cont.id]) + ".mp3")!)
                                            si[cont.id]=AVPlayerItem(url: URL(string: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(Gsongids[cont.id]) + ".mp3")!)
                                            GupdateTime[cont.id] = Date().timeStamp
                                        }
                                        Gplayid = cont.id
                                        thisplayid = cont.id
                                        change_by_playlist = true
                                    }
                                    nowPlayingInfoCenter.nowPlayingInfo = [
                                        MPMediaItemPropertyTitle: Gsn[cont.id],
                                        MPMediaItemPropertyArtist: Gsa[cont.id],
                                    ]
                                }) {
                                    VStack(alignment: .leading){
                                        Text("\(cont.id+1). \(cont.songname)")
                                            .foregroundColor(.white)
                                        Text(cont.singer)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }.frame(maxWidth: .infinity)
                                }.buttonStyle(BorderlessButtonStyle())
                            }
                            
                        }
                    }
                }
            }
            .onAppear(perform: { self.myload() })
            .navigationBarTitle("播放列表")
            .onReceive(timer) { _ in
                thisplayid = Gplayid
            }
        }
    }
    
    func myload(){
        mylist = []
        for i in 0...mysn.endIndex-1{
            mylist.append(kk(id:i, songname: mysn[i], singer: mysa[i]))
        }
    }
}

struct PlayListShow_Previews: PreviewProvider {
    static var previews: some View {
        PlayListShow(name: ["songname"], ar: ["songar"])
    }
}
