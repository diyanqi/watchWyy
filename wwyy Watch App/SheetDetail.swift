//
//  SheetDetail.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/19.
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

private struct OriginList: Codable{
    var songs: [Song]
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

struct SheetDetail: View {
    @State var sid:Int64=6957785
    @State var sname:String="Maestro Ziikos"
    @State var picurl:String="http://p4.music.126.net/W7Rt5cguIA51XAmQNpWIUg==/109951164924777613.jpg?param=200y200"
    @State private var lists:OriginList=OriginList(songs: [Song(name: "加载中……", id: 2, ar: [Artist(id: 3, name: "稍安勿躁～")], al: Al(id: 0, name: "0", picUrl: "0"))])
    @State private var ids:[Int64] = [0]
    @State private var nams:[String] = ["0"]
    @State private var ars:[String] = ["0"]
    @State private var loaded:Bool = false
    var body: some View {
        NavigationView {
            List {
                if(loaded){
                    NavigationLink(destination: PlayerPage(newTask: true, songid: ids,songname: nams,songar: ars)) {
                        HStack{
                            Image(systemName: "play.fill")
                                .padding(.horizontal)
                            Text("播放全部 (\(nams.endIndex)首)")
                        }
                    }
                }else{
                    NavigationLink(destination: PlayerPage(newTask: true, songid: ids,songname: nams,songar: ars)) {
                        HStack{
                            Image(systemName: "play.fill")
                                .padding(.horizontal)
                            Text("正在加载中……")
                        }
                    }.disabled(true)
                }
                
                NavigationLink(destination: SheetDetailPage(sid: sid)) {
                    HStack{
                        Image(systemName: "ellipsis.circle")
                            .padding(.horizontal)
                        Text("更多")
                    }
                }
                
                NetWorkImage(url:URL(string: picurl)!)
                    .frame(maxWidth: .infinity,maxHeight: .infinity)
                    .cornerRadius(5.0)
                    .scaledToFill()
                    .cornerRadius(5.0)
                if(loaded){
                    ForEach(lists.songs) { s in
                        NavigationLink(destination: PlayerPage(newTask: true, songid: [s.id],songname: [s.name],songar: [s.ar[0].name],bartitle: [sname])) {
                            HStack{
                                NetWorkImage(url:URL(string: s.al.picUrl)!)
                                    .frame(maxWidth: 23,maxHeight: 23)
                                    .scaledToFit()
                                    .cornerRadius(5.0)
                                VStack(alignment: .leading){
                                    Text(s.name)
                                    Text(s.ar[0].name)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }else{
                    ProgressView()
                }
            }
        }
        .navigationBarTitle(sname)
        .onAppear(perform: {
            self.getList()
        })
    }
    func getList() {
        let url = URL(string: "\(apiServer)/playlist/track/all?id=\(String(sid))")!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let listData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(OriginList.self, from: listData)
                    DispatchQueue.main.async {
                        self.lists = decodedData
                        ids=[]
                        ars=[]
                        nams=[]
                        for i in decodedData.songs{
                            ids.append(i.id)
                            ars.append(i.ar[0].name)
                            nams.append(i.name)
//                            print(i.id,i.ar[0].name,i.name)
                        }
                        loaded = true
                        print(ids)
                    }
                } else {
                    print("No data")
                }
            } catch {
                self.lists.songs[0].name=(error.localizedDescription)
            }
        }.resume()
    }
}

struct SheetDetail_Previews: PreviewProvider {
    static var previews: some View {
        SheetDetail()
    }
}
