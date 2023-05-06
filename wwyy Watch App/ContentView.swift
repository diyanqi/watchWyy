//
//  ContentView.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/18.
//

import SwiftUI
import AVFoundation
import Foundation
import WatchKit
import AVKit
import MediaPlayer

let unavaliable:String = "https://636f-codenav-8grj8px727565176-1256524210.tcb.qcloud.la/ikun-audio/niganma.aac"
var apiServer:String = "https://wwyy.amzcd.top"

var player : AVQueuePlayer = AVQueuePlayer(items: [AVPlayerItem(url: URL(string: "url")!)])
var Gsn:[String] = ["🐔你太美"]
var Gsa:[String] = ["坤坤"]
var Gsi:[AVPlayerItem] = [AVPlayerItem(url: URL(string: unavaliable)!)]
var Gplayid:Int = 0
var Gsongids:[Int64] = [-114514]
var GupdateTime:[Int64] = [0]
var change_by_playlist:Bool = false
var remoteCommandCenter: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
var nowPlayingInfoCenter: MPNowPlayingInfoCenter = .default()
var toogleIsplaying:Bool = false
var separator = "_"

struct ContentView: View {
    
    var body: some View {
        VStack{
            NavigationStack {
                List{
                    NavigationLink(destination: PlayerPage(newTask: false)) {
                        HStack{
                            Image(systemName: "play.circle")
                                .foregroundColor(.orange)
                            Text("今在播放")
                        }
                    }
                    NavigationLink(destination: SearchPage()) {
                        HStack{
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.yellow)
                            Text("寻索新乐")
                        }
                    }
                    NavigationLink(destination: EverydayNew()) {
                        HStack{
                            Image(systemName: "heart.circle")
                                .foregroundColor(Color(red: 219/255, green: 112/255, blue: 147/255))
                            Text("日日一新")
                        }
                    }
                    NavigationLink(destination: PlaylistDiscover()) {
                        HStack{
                            Image(systemName: "list.clipboard")
                                .foregroundColor(.green)
                            Text("乐府集成")
                        }
                    }
                    NavigationLink(destination: SongDiscover()) {
                        HStack{
                            Image(systemName: "flame.circle")
                                .foregroundColor(.cyan)
                            Text("乐榜题名")
                        }
                    }
                    NavigationLink(destination: LocalMusic()) {
                        HStack{
                            Image(systemName: "arrow.down.app")
                                .foregroundColor(.blue)
                            Text("本地雅集")
                        }
                    }
                    NavigationLink(destination: LoginPage()) {
                        HStack{
                            Image(systemName: "person.circle")
                                .foregroundColor(.purple)
                            Text("个人简策")
                        }
                    }
                    NavigationLink(destination: SettingPage()) {
                        HStack{
                            Image(systemName: "gearshape.circle")
                                .foregroundColor(.gray)
                            Text("偏好设定")
                        }
                    }
                }
                .navigationTitle(Text("腕上广陵乐"))
                .onAppear(perform: { self.loadSettings() })
            }
        }
    }
    private func loadSettings(){
        let fileManager = FileManager.default
        let pathString = NSHomeDirectory() + "/Documents/wwyyData.json"
        let exist = fileManager.fileExists(atPath: pathString)
        print("pathString is: "+pathString)
        if(!exist){
            print("creating file")
            let url = URL(fileURLWithPath: pathString)
            createFile(name: "Data.json", fileBaseUrl: url)
        }
        let url = URL(fileURLWithPath: pathString)
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let listData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(Settings.self, from: listData)
                    DispatchQueue.main.async {
                        profile = decodedData
                        apiServer = profile.api
                    }
                } else {
                    print("No data")
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func createFile(name:String, fileBaseUrl:URL){
        let manager = FileManager.default
        let file = fileBaseUrl
        print("文件: \(file)")
        let exist = manager.fileExists(atPath: file.path)
        if !exist {
            let data = Data(base64Encoded:"ewogICAgInVzZXIiOnsKICAgICAgICAibG9nZ2VkIjpmYWxzZSwKICAgICAgICAibmlja25hbWUiOiJub25lIiwKICAgICAgICAiY29va2llIjoibm9uZSIKICAgIH0sCiAgICAiZGVmYXVsdFF1YWxpdHkiOiJsb3NzbGVzcyIsCiAgICAiYXBpIjoiaHR0cHM6Ly9jbnd3eXkuYW16Y2QudG9wOjIwODMiCn0K" ,options:.ignoreUnknownCharacters)
            let createSuccess = manager.createFile(atPath: file.path,contents:data,attributes:nil)
            print("文件创建结果: \(createSuccess)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct NewTestView: View {
    var body: some View {
        List(0..<100) { item in
            Text("\(item)")
        }
        .navigationBarTitle("NavigationNew")
    }
}
