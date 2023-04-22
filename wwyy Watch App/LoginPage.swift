//
//  LoginPage.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/26.
//

import SwiftUI

struct Acc:Codable {
    var id:Int64
}

struct Account:Codable {
    var account:Acc
}

var uid:Int64 = -1

struct LoginPage: View {
    @State var loaded:Bool = false
    @State private var showAlert = false
    
    var body: some View {
        if(profile.user.logged){
            if(loaded){
                UserDisplay(uid: uid,show_logout_button: true)
            }else{
                VStack{
                    ProgressView().onAppear(perform: {self.loadProfile()})
                    Text("如果无法加载，请尝试：")
                        .font(.caption)
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
            }
        }else{
            NavigationStack{
                List{
                    NavigationLink(destination: QrcodeLogin(), label: {
                        HStack{
                            Image(systemName: "qrcode")
                            Text("二维码登录")
                        }
                    })
                    
                    Button(action: {
                        
                    }, label: {
                        HStack{
                            Image(systemName: "candybarphone")
                            Text("短信登录")
                        }
                    }).disabled(true)
                    
                    Button(action: {
                        
                    }, label: {
                        HStack{
                            Image(systemName: "envelope")
                            Text("邮箱登录")
                        }
                    }).disabled(true)
                    
                    Button(action: {
                        
                    }, label: {
                        HStack{
                            Image(systemName: "person")
                            Text("游客登录")
                        }
                    }).disabled(true)
                }
            }.navigationTitle(Text("登录"))
        }
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
    
    func loadProfile(){
        let urlstr:String = "\(apiServer)/user/account?cookie=\(profile.user.cookie)"
        let urlcoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlcoded)!
        var urlRequest = URLRequest(url:url)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let sheetData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(Account.self, from: sheetData)
                    DispatchQueue.main.async {
                        uid = decodedData.account.id
                        loaded = true
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

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
