//
//  LocalMusic.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2023/2/5.
//

import SwiftUI

struct LocalMusic: View {
    @State private var loaded = false
    @State private var filenames:[String] = []
    
    var body: some View {
        if(loaded){
            NavigationStack{
                List{
                    ForEach(filenames, id: \.self){ i in
                        NavigationLink(destination: PlayerPage(newTask: true, islocal: true, songid:[Int64(get_name(wholename:i)[0])!],songname: [get_name(wholename:i)[1]],songar: [get_name(wholename:i)[2]],bartitle:  ["本地音乐"])) {
                            HStack{
                                Text(get_name(wholename:i)[1])
                            }
                        }
                    }
                }
            }.navigationTitle("本地音乐")
        }else{
            ProgressView().onAppear(perform: {
                self.loc()
            })
        }
    }
    
    private func loc(){
        let files = getAllFilePath(NSHomeDirectory() + "/Documents/wwyyMusic")!
        print(files)
        for i in files {
            var thisname = URL(fileURLWithPath: i).lastPathComponent
            if(thisname.contains(separator) && thisname != ".DS_Store"){
                filenames.append(thisname)
            }
        }
        loaded = true
    }
}

struct LocalMusic_Previews: PreviewProvider {
    static var previews: some View {
        LocalMusic()
    }
}

func getAllFilePath(_ dirPath: String) -> [String]? {
    var filePaths = [String]()
    print("searching in path: "+dirPath)
    do {
        let array = try FileManager.default.contentsOfDirectory(atPath: dirPath)
        
        for fileName in array {
            var isDir: ObjCBool = true
            
            let fullPath = "\(dirPath)/\(fileName)"
            
            if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                if !isDir.boolValue {
                    filePaths.append(fullPath)
                }
            }
        }
        
    } catch let error as NSError {
        print("get file path error: \(error)")
    }
    
    return filePaths;
}

func get_name(wholename:String) -> [String] {
    let components = wholename.components(separatedBy: separator)
    return components
}
