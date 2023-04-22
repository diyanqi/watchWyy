//
//  EverydaySongs.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2023/2/8.
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

private struct OriginData: Codable{
    var dailySongs: [Song]
}

private struct OriginList: Codable{
    var data: OriginData
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


struct EverydaySongs: View {
    @State private var lists:OriginList=OriginList(data: OriginData(dailySongs: []))
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
                if(loaded){
                    ForEach(lists.data.dailySongs) { s in
                        NavigationLink(destination: PlayerPage(newTask: true, songid: [s.id],songname: [s.name],songar: [s.ar[0].name],bartitle: ["title"])) {
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
        .onAppear(perform: {
            self.getList()
        })
    }
    func getList() {
        let url = URL(string: "\(apiServer)/recommend/songs?cookie=\(profile.user.cookie)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
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
                        for i in decodedData.data.dailySongs{
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
                self.lists.data.dailySongs[0].name=(error.localizedDescription)
            }
        }.resume()
    }
}

struct EverydaySongs_Previews: PreviewProvider {
    static var previews: some View {
        EverydaySongs()
    }
}
