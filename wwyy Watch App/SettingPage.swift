//
//  SettingPage.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/20.
//

import SwiftUI

struct User:Decodable,Encodable{
    var logged:Bool
    var nickname:String
    var cookie:String
}

struct Settings:Decodable,Encodable{
    var user:User
    var defaultQuality:String
    var api:String
}

extension Settings {
    //在协议里面实现方法getString,这样就可以让所有继承ConvertToStringable协议的类,都有默认实现方法getString
    func getString()->String {
        //把按照json编码成流数据
        let data = try? JSONEncoder().encode(self)
        guard let jsonData = data else { return "" }
        //流数据转字符串
        guard let jsonStr = String.init(data: jsonData, encoding: .utf8) else { return "" }
        return jsonStr
    }
}

var profile:Settings = Settings(user: User(logged: false, nickname: "nickname", cookie: "cookie"), defaultQuality: "defaultQuality", api: "https://example.com")

private struct Selection:Hashable,Decodable{
    var value:String
    var text:String
    var icon:String
}

struct SettingPage: View {
    @State var loaded:Bool = false
    @State var test:String = ""
    @State private var selectedQuality = 0
    private let qualities:[Selection] = [
        Selection(value: "standard", text: "标准", icon: "1.lane"),
        Selection(value: "higher", text: "较高", icon: "2.lane"),
        Selection(value: "exhigh", text: "极高", icon: "3.lane"),
        Selection(value: "lossless", text: "无损", icon: "4.lane"),
        Selection(value: "hires", text: "Hi-Res", icon: "5.lane")
    ]
    @State private var apiAddress = profile.api
    @FocusState private var apiFieldIsFocused
    
    var body: some View {
        HStack{
            if(!loaded){
                ProgressView()
            }else{
                NavigationStack{
                    List{
                        Picker("默认音质", selection: $selectedQuality) {
                            ForEach(0 ..< qualities.count) {
                                Label(qualities[$0].text, systemImage: qualities[$0].icon)
                            }
                        }.onChange(of: selectedQuality, perform: {value in
                            profile.defaultQuality = qualities[selectedQuality].value
                            saveSettings()
                        })
                        VStack(alignment: .leading){
                            Text("接口服务器")
                                .font(.caption)
                            Text("( 地址末尾无 / )")
                                .font(.caption)
                            TextField(
                                "https://wwyy.amzcd.top",
                                text: $apiAddress,
                                onCommit: {
                                    profile.api = apiAddress
                                    saveSettings()
                                }
                            )
                            .focused($apiFieldIsFocused)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top,-15)
                            .padding(.bottom,-10)
                        }
                    }
                }
            }
        }
        .navigationTitle("设置")
        .onAppear(perform: { self.loadSettings() })
    }
    private func saveSettings(){
        let jsonString = profile.getString()
        let pathString = NSHomeDirectory() + "/Documents/wwyyData.json"
        try! jsonString.write(toFile: pathString, atomically: true, encoding: String.Encoding.utf8)
    }
    private func loadSettings(){
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
                        var cnt:Int = 0
                        for i in qualities{
                            if(i.value == profile.defaultQuality){
                                selectedQuality = cnt
                                break
                            }
                            cnt += 1
                        }
                        apiAddress = profile.api
                        self.loaded = true
                    }
                } else {
                    print("No data")
                    self.loaded = true
                }
            } catch {
                self.test=(error.localizedDescription)
                self.loaded = true
            }
        }.resume()
    }
}

struct SettingPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingPage()
    }
}
