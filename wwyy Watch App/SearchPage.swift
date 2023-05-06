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
    @State var hasSth: Bool = false
    
    var body: some View {
        VStack {
            List {
                Section() {
                    HStack {
                        TextField(
                            "搜些什么……",
                            text: $username, onCommit: {
                                if(username != ""){
                                    hasSth = true
                                }
                            }
                        )
                        .focused($emailFieldIsFocused)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    }
                    if(hasSth){
                        NavigationLink {
                            Searches(content: username)
                        } label: {
                            HStack{
                                Image(systemName: "magnifyingglass")
                                    .frame(maxWidth: 50)
                                Text("搜索")
                            }
                        }
                    }
                }
                Section(header: Text("热门搜索")) {
                    if loaded {
                        ForEach(hots.data, id: \.self) { d in
                            NavigationLink(destination: Searches(content: (d.searchWord))) {
                                Text(d.searchWord)
                                    .font(.caption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
        }.onAppear(perform: { self.getHot() })
            .navigationTitle(Text("搜索"))
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
