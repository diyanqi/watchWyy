//
//  SearchResultDisplay.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/21.
//

import SwiftUI

private struct Artist: Codable{
    var id:Int64
    var name:String
}

private struct Al: Codable{
    var id:Int64
    var name:String
    var picUrl:String
}

private struct Song: Codable,Identifiable{
    var name:String
    var id:Int64
    var ar:[Artist]
    var al:Al
}

private struct Res: Codable{
    var songs: [Song]
}

private struct OriginSearch: Codable{
    var result: Res
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

struct SearchResultDisplay: View {
    @State var searchWord:String = "只因你太美"
    @State private var loaded:Bool = false
    @State var tip:String = "努力搜索中……"
//    @Binding var resultPagePresented: Bool
    @State private var res:OriginSearch=OriginSearch(result: Res(songs: [Song(name: "0", id: 0, ar: [Artist(id: 0, name: "0")], al: Al(id: 0, name: "0", picUrl: "0"))]))
//    @State private var res:OriginSearch=OriginSearch(result: Res(songs: [Song(name: "0", id: 0)]))
    
    var body: some View {
        if(searchWord=="出错了，请重试一次"){
            Text("出错了，请重试一次")
                .font(.headline)
        }else{
            if(loaded){
                NavigationView {
                    List{
                        ForEach(res.result.songs) { s in
                            NavigationLink(destination: PlayerPage(newTask: true, songid: [s.id],songname: [s.name],songar: [s.ar[0].name],bartitle: [s.name])) {
                                VStack(alignment: .leading){
                                    Text(s.name)
                                    Text(s.ar[0].name)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }else{
                ProgressView()
                    .onAppear(perform: {self.getRes()})
            }
        }
    }
    
    func getRes(){
        let myurl = URL(string: "\(apiServer)/cloudsearch?keywords=\(searchWord)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        var urlRequest = URLRequest(url:myurl)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let listData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(OriginSearch.self, from: listData)
                    DispatchQueue.main.async {
                        res = decodedData
                        loaded = true
                    }
                } else {
                    print("No data")
                }
            } catch {
                self.tip=(error.localizedDescription)
            }
        }.resume()
    }
    
}

//struct SearchResultDisplay_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchResultDisplay(resultPagePresented: $(true))
//    }
//}
