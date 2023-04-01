//
//  TopPlaylist.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/11.
//

import SwiftUI

private struct Sheet: Codable,Identifiable{
//    var myid = UUID()
    var id: Int64
    var name: String
    var coverImgUrl: String
    var playCount: Int64
}

private struct OriginSheet: Codable{
//    var id = UUID()
    var playlists: [Sheet]
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

struct TopPlaylist: View {
    @State private var sheets: OriginSheet = OriginSheet(playlists: [Sheet(id: 0, name: "加载中……", coverImgUrl: "0", playCount: 0)])
    @State private var loaded:Bool = false
    var body: some View {
        VStack{
            if(loaded){
                NavigationView {
                    List {
                        ForEach(sheets.playlists) { pl in
                            NavigationLink(destination: SheetDetail(sid: pl.id,sname: pl.name,picurl: pl.coverImgUrl.replacingOccurrences(of: "http://", with: "https://"))) {
                                HStack{
                                    NetWorkImage(url:URL(string: pl.coverImgUrl.replacingOccurrences(of: "http://", with: "https://"))!)
                                        .frame(maxWidth: 30,maxHeight: 30)
                                        .cornerRadius(5.0)
                                        .padding(.horizontal)
                                        .scaledToFit()
                                    Text(pl.name)
                                }
                            }
                        }
                    }
                }
            }else{
                ProgressView()
            }
        }
        .onAppear(perform: { self.getSheet() })
    }
    func getSheet() {
        //设置需要获取的网址
        let urlstr:String = "\(apiServer)/top/playlist?cookie=\(profile.user.cookie)"
        let urlcoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlcoded)!
        print(urlcoded)
        //请求网址
        var urlRequest = URLRequest(url:url)
        //请求获取的类型是application/json（也就是JSON类型）
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        //检查获取到的数据
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                //将数据赋值给jokeDate，并且判断数据不为空的话
                if let sheetData = data {
                    //设置解码器为JSONDecoder()
                    let decoder = JSONDecoder()
                    //按照我们之前创建的Joke结构体的数据结构解码获取到的数据（如果我们打算放到数组中，给这里的Joke加个中括号）
                    let decodedData = try decoder.decode(OriginSheet.self, from: sheetData)
                    //为了防止数据过多，加载时间过长，这里使用异步加载
                    DispatchQueue.main.async {
                        //将解码后的数据赋值给之前准备好的空变量
                        self.sheets = decodedData
                        loaded = true
                    }
                } else {
                    //如果数据是空的，在控制台输出下面的文本
                    print("No data")
                }
            } catch {
                sheets.playlists[0].name=(error.localizedDescription.debugDescription)+(error.localizedDescription.description)
            }
        }.resume()
    }
}

struct TopPlaylist_Previews: PreviewProvider {
    static var previews: some View {
        TopPlaylist()
    }
}
