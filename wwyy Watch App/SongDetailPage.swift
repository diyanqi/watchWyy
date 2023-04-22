//
//  SongDetailPage.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2023/2/5.
//

import SwiftUI

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

private struct Ar:Codable,Identifiable {
    var id:Int64
    var name:String
}

private struct Al:Codable {
    var id:Int64
    var name:String
    var picUrl:String
}

private struct SongForm:Codable {
    var name:String
    var id:Int64
    var ar:[Ar]
    var al:Al
    var dt:Int64 // 歌曲时长
    var publishTime:Int64
}

private struct DetailForm:Codable {
    var code:Int
    var songs:[SongForm]
}

public var songimgUrl = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAABTUlEQVR42j2QS0sCURiGzz/J8paSkzbqiFAhhdGii9Ki2iXkDygTy42BbVxq9gcCa+NeV5LmLncKhnjZDKgwMqPObN/mnCEX7+Kc74Xv+R4yn8+xXC6haRqLKIqQZRmSJGGxWKz+CX3QjEYjNJtNVKtVlEofqFQqrDwej42iqqqsVCy+4fryCh5uG077JgSvH5nMMzqdjlFUFAWNxjeikSjcLg7mNdMqHs6NfL6AyWQCQhkLhVcEhQCiZ+fIcVv43A3iwGzGhl6O38bR+mmBUPD7uwR8OzwEfe27y4mkzYK4zYrIySliNzF0u78gs9kMtVoNft7H1l04HEgGBOzxXhyHj5BKPbKjCAUdDAZIP6XhsNpXfBbTOsKHYdS/6sYx1CHl7Pf7yGZfENoPIaKzPiSSKJfLGA6HbE7+hU6nUya71+sxn+22oYWq01QNf1LyGv5cLlNDAAAAAElFTkSuQmCC"

struct SongDetailPage: View {
    @State private var loaded = false
    @State var songid:Int64 = 347230
    @State private var songd:DetailForm = DetailForm(code: 200, songs: [SongForm(name: "name", id: 114514, ar: [Ar(id: 1919, name: "name")], al: Al(id: 810, name: "name", picUrl: "picUrl"), dt: 25, publishTime: 2333)])
    @Environment(\.dismiss) private var dismiss
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack{
            if(loaded){
                NavigationStack{
                    List{
                        Text(songd.songs[0].name)
                            .font(.headline)
                        VStack(alignment: .leading){
                            Text("歌曲 ID")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(String(songd.songs[0].id))
                        }
//                        Button(action: {
//                            dismiss()
//                        }, label: {
//                            Text("返回")
//                        })
                        NetWorkImage(url:URL(string: songd.songs[0].al.picUrl.replacingOccurrences(of: "http://", with: "https://"))!)
                            .scaledToFill()
                        VStack(alignment: .leading, content: {
                            Text("歌曲时长")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(showRecodeTime(recordTimeNum:songd.songs[0].dt/1000))
                        })
                        ForEach(songd.songs[0].ar){ artist in
                            VStack(alignment: .leading, content: {
                                Text("歌手 ID \(String(artist.id))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text(artist.name)
                            })
                        }
                        VStack(alignment: .leading, content: {
                            Text("收录至专辑 ID \(String(songd.songs[0].al.id))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(songd.songs[0].al.name)
                        })
                        VStack(alignment: .leading, content: {
                            Text("发布时间")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(timeIntervalChangeToTimeStr(timeInterval:Double(songd.songs[0].publishTime/1000)))
                        })
                    }
                }.onAppear(perform: {
                    self.songdet()
                    songid = Gsongids[Gplayid]
                })
            }else{
                ProgressView().onAppear(perform: {
                    self.songdet()
                    songid = Gsongids[Gplayid]
                })
            }
        }
        .navigationTitle("歌曲详情")
//        .navigationBarBackButtonHidden()
        .foregroundColor(.white)
        .onReceive(timer) { _ in
            if(songid != Gsongids[Gplayid]){
                songid = Gsongids[Gplayid]
                songdet()
            }
        }
    }
    
    func songdet() {
        let url = URL(string: "\(apiServer)/song/detail?ids=\(songid)")!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(DetailForm.self, from: sheetData)
                    DispatchQueue.main.async {
                        songd = decodedData
                        songimgUrl = songd.songs[0].al.picUrl.replacingOccurrences(of: "http://", with: "https://")
                        loaded = true
                    }
                } else {
                    print("No data")
                }
            } catch {
                songd.songs[0].name = error.localizedDescription
                loaded = true
            }
        }.resume()
    }
}

//struct SongDetailPage_Previews: PreviewProvider {
//    static var previews: some View {
//        SongDetailPage()
//    }
//}

private func showRecodeTime(recordTimeNum:Int64)->String {
    var str = ""
    var num = recordTimeNum
    if num > 3599 {
        str = num / 3600 < 10 ? "0\(num/3600)" : "\(num/3600)"
        num = recordTimeNum % 3600
    } else {
        str = "00"
    }
    if num > 59 {
        str = num / 60 < 10 ? str+":0\(num/60)" : str+":\(num/60)"
        num = recordTimeNum % 60
    } else {
        str = "00:00"
    }
    str = num < 10 ? str+":0\(num)" : str+":\(num)"
    return str
}

//时间戳转成字符串
func timeIntervalChangeToTimeStr(timeInterval:TimeInterval, dateFormat:String?) -> String {
    let date:NSDate = NSDate.init(timeIntervalSince1970: timeInterval/1000)
    let formatter = DateFormatter.init()
    if dateFormat == nil {
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }else{
        formatter.dateFormat = dateFormat
    }
    return formatter.string(from: date as Date)
}
