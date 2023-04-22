//
//  LocalMusic.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2023/2/5.
//

import SwiftUI

struct LocalMusic: View {
    
    @State private var showAlert = false
    @State private var songList = [[String: String]]()
    @State private var loaded = false
    
    @State private var ids:[Int64] = []
    @State private var nams:[String] = []
    @State private var ars:[String] = []
    
    var body: some View {
        VStack {
            VStack {
                if(loaded){
                    NavigationStack{
                        List {
                            NavigationLink(destination: PlayerPage(newTask: true, islocal: true, songid: ids,songname: nams,songar: ars)) {
                                HStack{
                                    Image(systemName: "play.fill")
                                        .padding(.horizontal)
                                    Text("播放全部 (\(nams.endIndex)首)")
                                }
                            }
                            // ForEach 中的 VStack
                            ForEach(songList, id: \.self) { song in
                                NavigationLink(destination: PlayerPage(newTask: true, islocal: true, songid:[Int64(song["songid"]!)!],songname: [song["name"]!],songar: [song["singer"]!],bartitle:  ["本地音乐"])) {
                                    VStack(alignment:.leading){
                                        Text("\(song["name"] ?? "")")
                                            .font(.headline)
                                        VStack(alignment: .leading) {
                                            Text("\(song["singer"] ?? "")")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                            Text(getFileSize(path: NSHomeDirectory() + "/Documents/wwyyMusic/" + String(song["songid"]!) + ".mp3"))
                                                .font(.system(.footnote))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }.onDelete {
                                $0.forEach { index in
                                    let song = songList[index]
                                    deleteSong(song: song)
                                }
                            }
                            Button(action: {
                                showAlert.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    Text("清空本地音乐")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }else{
                    ProgressView()
                }
            }
            .onAppear {
                songList = [[String: String]]()
                ids = []
                nams = []
                ars = []
                
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let musicPath = "\(documentsPath)/wwyyMusic"
                let dataPath = "\(musicPath)/Data.json"
                
                // 判断wwyyMusic目录是否存在，不存在则创建
                if !FileManager.default.fileExists(atPath: musicPath) {
                    do {
                        try FileManager.default.createDirectory(atPath: musicPath, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                // 判断Data.json是否存在，不存在则创建
                if !FileManager.default.fileExists(atPath: dataPath) {
                    let jsonData = try! JSONSerialization.data(withJSONObject: [], options: .prettyPrinted)
                    FileManager.default.createFile(atPath: dataPath, contents: jsonData, attributes: nil)
                }
                
                // 读取Data.json文件
                let jsonData = try! Data(contentsOf: URL(fileURLWithPath: dataPath))
                if let jsonArray = try! JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as? [NSDictionary] {
                    for jsonObject in jsonArray {
                        if let song = jsonObject as? [String: String] {
                            songList.append(song)
                            ids.append(Int64(song["songid"]!)!)
                            nams.append(song["name"]!)
                            ars.append(song["singer"]!)
                            print(song)
                        }
                    }
                    print(songList)
                    loaded = true
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("提示"), message: Text("确认删除所有本地音乐吗？该操作无法撤销。"), primaryButton: .destructive(Text("确定")) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let musicPath = "\(documentsPath)/wwyyMusic"
                do {
                    try FileManager.default.removeItem(atPath: musicPath)
                    print("wwyyMusic文件夹删除成功！")
                } catch {
                    print(error.localizedDescription)
                }
            }, secondaryButton: .cancel(Text("取消")))
        }.navigationTitle("本地音乐")
    }
    
    func getFileSize(path: String) -> String {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            let size = attr[.size] as! UInt64
            let unitArray = ["B", "KB", "MB", "GB", "TB"]
            var index = 0
            var fileSize = Double(size)
            while (fileSize > 1024 && index < unitArray.count-1) {
                fileSize /= 1024
                index += 1
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: fileSize))! + unitArray[index]
        } catch {
            print("Error: \(error)")
            return ""
        }
    }
    
    /// 删除歌曲及相关数据
    func deleteSong(song: [String: String]) {
        guard let songId = song["songid"], let songName = song["name"], let songSinger = song["singer"] else {
            return
        }

        // 更新Data.json
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let musicPath = "\(documentsPath)/wwyyMusic/"
        let dataPath = "\(musicPath)/Data.json"
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: dataPath))
        var jsonArray = try! JSONSerialization.jsonObject(with: jsonData, options : .allowFragments) as! [NSDictionary]
        for index in 0..<jsonArray.count {
            if let jsonSong = jsonArray[index] as? [String: String], jsonSong["songid"] == songId {
                jsonArray.remove(at: index)
                break
            }
        }
        let newData = try! JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
        try? newData.write(to: URL(fileURLWithPath: dataPath))
        
        // 刷新列表
        songList.removeAll { $0["songid"] == songId }
        
        // 删除歌曲文件
        let mp3File = "\(musicPath)\(songId).mp3"
        if FileManager.default.fileExists(atPath: mp3File) {
            do {
                try FileManager.default.removeItem(atPath: mp3File)
                print("\(songName) - \(songSinger) 文件删除成功！")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct LocalMusic_Previews: PreviewProvider {
    static var previews: some View {
        LocalMusic()
    }
}
