//
//  QrcodeLogin.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/20.
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

extension Date {
    var tStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
}

private struct Unikey:Decodable {
    var unikey:String
}

private struct Key:Decodable {
    var data:Unikey
}

private struct Qrcodeurl:Decodable {
    var qrurl:String
    var qrimg:String
}

private struct Qrurl:Decodable {
    var data:Qrcodeurl
}

private struct CheckStat:Decodable {
    var code:Int
    var cookie:String
    var message:String
}

struct QrcodeLogin: View {
    @State private var loaded:Bool = false
    @State private var qrurl:String = "base64img"
    @State private var tipText:String = "加载中"
    @State private var key:String = "key"
    @State private var showAlert = false
    @State private var cookie:String = "cookie"
    @State private var message:String = "正在查询登录状态，请稍后……"
    @State private var code:Int = -1

    var body: some View {
        VStack{
            if(loaded){
                NetWorkImage(url:URL(string: qrurl)!)
                    .scaledToFit()
                Button(
                    action: {
                        message = "正在查询登录状态，请稍后……"
                        code = -1
                        check_login()
                        self.showAlert = true
                    },
                    label: { Text("登陆后请点击") }
                ).alert(isPresented: $showAlert){
                    Alert(title: Text("提示"), message: Text("状态码：\(code)\n\(message)"), dismissButton: .default(Text("好")))
                }
            }else{
                ProgressView().onAppear(perform: {self.loadQrcode()})
            }
        }.navigationBarTitle(tipText)
    }
    
    private func saveSettings(){
        let jsonString = profile.getString()
        let pathString = NSHomeDirectory() + "/Documents/wwyyData.json"
        try! jsonString.write(toFile: pathString, atomically: true, encoding: String.Encoding.utf8)
    }
    
    func save_cookie(){
        let pathString = NSHomeDirectory() + "/Documents/wwyyData.json"
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
                        profile.user.cookie = cookie
                        profile.user.logged = true
                        saveSettings()
                    }
                } else {
//                    print("No data")
//                    self.loaded = true
                }
            } catch {
//                self.loaded = true
            }
        }.resume()
    }
    
    func check_login(){
        let urlstr:String = "\(apiServer)/login/qr/check?key=\(key)&timerstamp=\(Date().tStamp)"
        let urlcoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlcoded)!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(CheckStat.self, from: sheetData)
                    DispatchQueue.main.async {
                        code = decodedData.code
                        cookie = decodedData.cookie
                        message = decodedData.message
                        if(code == 803) {
                            save_cookie()
                            message += "\n现在可以退出本页面了"
                        }
                    }
                } else {
                    print("No data")
                }
            } catch {
//                commentdata[0].content = error.localizedDescription
            }
        }.resume()
    }
    
    func loadQrcode(){
        let urlstr:String = "\(apiServer)/login/qr/key?timerstamp=\(Date().tStamp)"
        let urlcoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlcoded)!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(Key.self, from: sheetData)
                    DispatchQueue.main.async {
                        key = decodedData.data.unikey
                        let urlstr2:String = "\(apiServer)/login/qr/create?key=\(key)&timerstamp=\(Date().tStamp)&qrimg=true"
                        let urlcoded2 = urlstr2.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                        let url2 = URL(string: urlcoded2)!
                        var urlRequest2 = URLRequest(url:url2)
                        urlRequest2.addValue("application/json",forHTTPHeaderField: "Accept")
                        URLSession.shared.dataTask(with: urlRequest2) { data, response, error in
                            do {
                                if let sheetData = data {
                                    let decoder = JSONDecoder()
                                    let decodedData = try decoder.decode(Qrurl.self, from: sheetData)
                                    DispatchQueue.main.async {
                                        qrurl = decodedData.data.qrimg
                                        loaded = true
                                        tipText = "扫码登录"
                                    }
                                } else {
                                    print("No data")
                                }
                            } catch {
                //                commentdata[0].content = error.localizedDescription
                            }
                        }.resume()
                    }
                } else {
                    print("No data")
                }
            } catch {
//                commentdata[0].content = error.localizedDescription
            }
        }.resume()
    }
}

struct QrcodeLogin_Previews: PreviewProvider {
    static var previews: some View {
        QrcodeLogin()
    }
}
