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
    
    var body: some View {
        if(profile.user.logged){
            if(loaded){
                UserDisplay(uid: uid,show_logout_button: true)
            }else{
                ProgressView().onAppear(perform: {self.loadProfile()})
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
