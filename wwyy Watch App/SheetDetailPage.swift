//
//  SheetDetailPage.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/26.
//

import SwiftUI

private struct Playlist: Codable{
    var userId:Int64
    var name:String
    var createTime:Int64
    var updateTime:Int64
    var playCount:Int64
//    var description:String
    var tags:[String]
}

private struct OriginDetail:Codable{
    var playlist:Playlist
}

private struct Playlists:Codable,Identifiable{
    var coverImgUrl:String
    var name:String
    var id:String
}

private struct OriginRelated:Codable{
    var playlists:[Playlists]
}

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

struct SheetDetailPage: View {
    
    @State var sid:Int64 = 6957725
    @State private var details:OriginDetail=OriginDetail(playlist: Playlist(userId: 0, name:"0", createTime: 0, updateTime: 0, playCount: 0,tags:["0"]))
    @State private var related:OriginRelated=OriginRelated(playlists: [Playlists(coverImgUrl: "0", name: "0", id: "0")])
    @State var loaded:Int = 0
    @State private var loadtip:String = "拼命加载中(*ˉ︶ˉ*)……"
    
    var body: some View {
        VStack{
            if(loaded >= 2){
                NavigationStack{
                    List{
                        Text("歌单 - \(details.playlist.name)").font(.headline)
                        NavigationLink(destination: UserDisplay(uid: details.playlist.userId)) {
                            HStack{
                                VStack(alignment: .leading){
                                    Text("用户ID：\(details.playlist.userId)")
                                    Text("点击查看用户").font(.caption).foregroundColor(.gray)
                                }
                            }
                        }
                        Text("创建时间：\(timeIntervalChangeToTimeStr(timeInterval: Double(details.playlist.createTime)/1000))")
                        Text("最近更新：\(timeIntervalChangeToTimeStr(timeInterval: Double(details.playlist.updateTime)/1000))")
                        Text("播放量：\(details.playlist.playCount)")
                        Text("标签：\(details.playlist.tags.joined(separator: "，"))")
                        Text("⬇️相关歌单推荐⬇️")
                        ForEach(related.playlists){p in
                            NavigationLink(destination: SheetDetail(sid: Int64(p.id) ?? 0,sname: p.name,picurl: p.coverImgUrl.replacingOccurrences(of: "http://", with: "https://"))){
                                HStack{
                                    NetWorkImage(url:URL(string: p.coverImgUrl.replacingOccurrences(of: "http://", with: "https://"))!)
                                        .frame(maxWidth: 30,maxHeight: 30)
                                        .cornerRadius(5.0)
                                        .padding(.horizontal)
                                        .scaledToFit()
                                    Text(p.name)
                                }
                            }
                        }
                    }
                }
            }else{
                ProgressView()
            }
        }
        .navigationBarTitle("歌单详情")
        .onAppear(perform: {
            self.getDetail()
            self.getRelated()
        })
    }
    
    func getDetail(){
        let url = URL(string: "\(apiServer)/playlist/detail?id=\(String(sid))")!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let listData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(OriginDetail.self, from: listData)
                    DispatchQueue.main.async {
                        self.details = decodedData
                        self.loaded += 1
                    }
                } else {
                    print("No data")
                }
            } catch {
                self.details.playlist.name=(error.localizedDescription)
            }
        }.resume()
    }
    
    func getRelated(){
        let url = URL(string: "\(apiServer)/related/playlist?id=\(String(sid))")!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let listData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(OriginRelated.self, from: listData)
                    DispatchQueue.main.async {
                        self.related = decodedData
                        self.loaded += 1
                    }
                } else {
                    print("No data")
                }
            } catch {
                self.loadtip=(error.localizedDescription)
            }
        }.resume()
    }
    
}

//时间戳转成字符串
func timeIntervalChangeToTimeStr(timeInterval:Double, _ dateFormat:String? = "yyyy-MM-dd HH:mm:ss") -> String {
    let date:Date = Date.init(timeIntervalSince1970: timeInterval)
    let formatter = DateFormatter.init()
    if dateFormat == nil {
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }else{
        formatter.dateFormat = dateFormat
    }
    return formatter.string(from: date as Date)
}

struct SheetDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        SheetDetailPage()
    }
}
