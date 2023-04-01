//
//  UserDisplay.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/26.
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

private struct Profile: Codable{
    var avatarUrl:String
    var nickname:String
}

private struct Origin: Codable{
    var level: Int
    var listenSongs: Int64
    var createTime:Int64
    var createDays:Int64
    var profile:Profile
}

private struct Playlist: Codable,Hashable{
    var id:Int64
    var name:String
    var coverImgUrl:String
}

private struct OriginPL: Codable{
    var playlist:[Playlist]
}

struct UserDisplay: View {
    @State var uid:Int64 = 32953014
    @State var show_logout_button:Bool = false
    @State private var userapi:Origin=Origin(level: 0, listenSongs: 0, createTime: 0, createDays: 0, profile: Profile(avatarUrl: "0", nickname: "加载中……"))
    @State private var pl:OriginPL=OriginPL(playlist: [Playlist(id:0, name: "0", coverImgUrl: "0")])
    @State private var loaded:Bool = false
    @State private var showAlert = false
    var body: some View {
        VStack{
            if(loaded){
                NavigationStack{
                    List{
                        HStack{
                            NetWorkImage(url:URL(string: userapi.profile.avatarUrl.replacingOccurrences(of: "http://", with: "https://"))!)
                                .frame(maxWidth: 30,maxHeight: 30)
                                .cornerRadius(5.0)
                                .padding(.horizontal)
                                .scaledToFit()
                            Text("\(userapi.profile.nickname)").font(.headline)
                        }
                        if(show_logout_button){
                            Button(
                                action: {
                                    self.showAlert = true
                                },
                                label: { Text("退出登录") }
                            ).alert(isPresented: $showAlert){
                                Alert(
                                    title: Text("退出登录"),
                                    message: Text("您真的要退出登录吗？"),
                                    primaryButton: .default(
                                        Text("取消")
                                    ),
                                    secondaryButton: .destructive(
                                        Text("退出登录"),
                                        action: {
                                            print("logout button")
                                            logout()
                                        }
                                    )
                                )
                            }
                        }
                        Text("用户id：\(uid)")
                        Text("等级：\(userapi.level)")
                        Text("听过的歌：\(userapi.listenSongs)首")
                        Text("注册时间：\(timeIntervalChangeToTimeStr(timeInterval: Double(userapi.createTime)/1000))，距今已有\(userapi.createDays)天")
                        ForEach(pl.playlist, id: \.self){p in
                            NavigationLink(destination: SheetDetail(sid: p.id,sname: p.name,picurl: p.coverImgUrl)) {
                                HStack{
                                    NetWorkImage(url:URL(string: p.coverImgUrl)!)
                                        .frame(maxWidth: 30,maxHeight: 30)
                                        .cornerRadius(5.0)
                                        .padding(.horizontal)
                                        .scaledToFit()
                                    Text(p.name)
                                    //                                Text(String(p.id)).font(.caption).foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }else{
                ProgressView()
            }
        }.onAppear(perform: {
            self.getUser()
            self.getPL()
        }).navigationBarTitle("用户详情")
    }
    
    private func saveSettings(){
        let jsonString = profile.getString()
        let pathString = NSHomeDirectory() + "/Documents/wwyyData.json"
        try! jsonString.write(toFile: pathString, atomically: true, encoding: String.Encoding.utf8)
    }
    
    private func logout() {
        profile.user.logged = false
        profile.user.cookie = "none"
        profile.user.nickname = "none"
        saveSettings()
    }
    
    func getUser() {
        let url = URL(string: "\(apiServer)/user/detail?uid=\(uid)")!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(Origin.self, from: sheetData)
                    DispatchQueue.main.async {
                        self.userapi = decodedData
                        if(show_logout_button){
                            profile.user.nickname = userapi.profile.nickname
                        }
                        loaded = true
                    }
                } else {
                    print("No data")
                }
            } catch {
//                sheets.result[0].name=(error.localizedDescription)
            }
        }.resume()
    }
    func getPL() {
        let url = URL(string: "\(apiServer)/user/playlist?uid=\(uid)")!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(OriginPL.self, from: sheetData)
                    DispatchQueue.main.async {
                        self.pl = decodedData
                    }
                } else {
                    print("No data")
                }
            } catch {
//                sheets.result[0].name=(error.localizedDescription)
            }
        }.resume()
    }
}

struct UserDisplay_Previews: PreviewProvider {
    static var previews: some View {
        UserDisplay()
    }
}
