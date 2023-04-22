//
//  EverydaySonglist.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2023/2/8.
//

import SwiftUI

private struct Sheet: Codable,Identifiable{
//    var myid = UUID()
    var id: Int64
    var name: String
    var picUrl: String
}

private struct OriginSheet: Codable{
//    var id = UUID()
    var recommend: [Sheet]
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


struct EverydaySonglist: View {
    @State private var sheets: OriginSheet = OriginSheet(recommend: [Sheet(id: 0, name: "加载中……", picUrl: "0")])
    @State private var loaded:Bool = false
    @State private var showingAlert = false
    @State private var showedOnce = false
    
    var body: some View {
        VStack{
            if(loaded){
                NavigationView {
                    List {
                        ForEach(sheets.recommend) { sheet in
                            NavigationLink(destination: SheetDetail(sid: sheet.id,sname: sheet.name,picurl: sheet.picUrl)) {
                                HStack{
                                    NetWorkImage(url:URL(string: sheet.picUrl)!)
                                        .frame(maxWidth: 30,maxHeight: 30)
                                        .cornerRadius(5.0)
                                        .padding(.horizontal)
                                        .scaledToFit()
                                    Text(sheet.name)
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
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("出错了"),
                message: Text("日推歌单/歌曲需登录后方可使用。"),
                dismissButton: .default(Text("好的"), action: {showingAlert = false; showedOnce = true})
            )
        }
    }
    func getSheet() {
        //设置需要获取的网址
        let urlstr:String = "\(apiServer)/recommend/resource?cookie=\(profile.user.cookie)"
        let urlcoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlcoded)!
        print(urlcoded)
        //请求网址
        var urlRequest = URLRequest(url:url)
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let str = String(data:sheetData, encoding: String.Encoding.utf8)
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
                if(!showedOnce){
                    showingAlert = true
                }
                sheets.recommend[0].name=(error.localizedDescription.debugDescription)+(error.localizedDescription.description)
            }
        }.resume()
    }
}

struct EverydaySonglist_Previews: PreviewProvider {
    static var previews: some View {
        EverydaySonglist()
    }
}
