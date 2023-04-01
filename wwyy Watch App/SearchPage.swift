//
//  SearchPage.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/11/21.
//

import SwiftUI

private struct HotDetail: Codable,Hashable{
    var searchWord:String
    var score:Int
}

private struct OriginHot: Codable{
    var data: [HotDetail]
}

struct SearchPage: View {
    @FocusState private var emailFieldIsFocused: Bool
    @State private var hots:OriginHot = OriginHot(data: [HotDetail(searchWord: "kksk", score: 114514)])
    @State private var loaded:Bool = false
    @State private var username: String = ""
    @State var resultPagePresented: Bool = false
    @State var searchWordWhole: String = "出错了，请重试一次"
    
    var body: some View {
        VStack{
            NavigationStack{
                HStack{
                    TextField(
                        "搜些什么……",
                        text: $username
                    )
                    .focused($emailFieldIsFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    NavigationLink {
                        Searches(content: username)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }.frame(maxWidth: 50)
                }
                List{
                    VStack(alignment: .leading){
                        HStack{
                            Image(systemName: "flame")
                            Text("热门搜索")
                                .font(.headline)
                                .frame(maxWidth: .infinity,alignment: .leading)
                        }.padding(.leading)
                    }
                    if(loaded){
                        ForEach(hots.data,id: \.self){d in
                            NavigationLink {
                                Searches(content: (d.searchWord))
                            } label: {
                                Text(d.searchWord).font(.caption).frame(maxWidth: .infinity,alignment: .leading).padding(.leading)
                            }
                        }
                    }else{
                        ProgressView()
                    }
                }
            }
        }.onAppear(perform: { self.getHot() })
    }
    func getHot(){
        let myurl = URL(string: "\(apiServer)/search/hot/detail")!
        var urlRequest = URLRequest(url:myurl)
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                if let listData = data {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(OriginHot.self, from: listData)
                    DispatchQueue.main.async {
                        hots = decodedData
                        loaded = true
                    }
                } else {
                    print("No data")
                }
            } catch {
                self.hots.data[0].searchWord=(error.localizedDescription)
            }
        }.resume()
    }
}

struct SearchPage_Previews: PreviewProvider {
    static var previews: some View {
        SearchPage()
    }
}
