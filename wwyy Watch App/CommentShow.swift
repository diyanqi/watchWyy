//
//  CommentShow.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/10.
//

import SwiftUI

private struct MyUser: Codable, Hashable{
    var nickname:String
    var userId:Int64
}

private struct Cmt: Codable, Hashable{
    var content:String
    var timeStr:String
    var user:MyUser
}

private struct OriginSheet: Codable{
    var hotComments: [Cmt]
}

struct CommentShow: View {
    
    @State private var commentdata:[Cmt] = [Cmt(content: "加载中……", timeStr: "马上就好", user: MyUser(nickname: "稍安勿躁", userId: 114514))]
    @State private var loaded:Bool = false
    
    var body: some View {
        HStack{
            if(loaded){
                NavigationStack{
                    List{
                        ForEach(commentdata, id:\.self) { cmt in
                            VStack{
                                Text(cmt.content)
                                Text("\(cmt.user.nickname)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("\(cmt.timeStr)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }else{
                ProgressView()
            }
        }.onAppear(perform: { self.myload3() })
            .navigationBarTitle("评论区")
    }
    func myload3(){
        //设置需要获取的网址
        let urlstr:String = "\(apiServer)/comment/music?id=\(Gsongids[Gplayid])&limit=100"
//        let urlstr:String = "https://www.oiso.cf/fake"
        let urlcoded = urlstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: urlcoded)!
        print(urlcoded)
        //请求网址
        var urlRequest = URLRequest(url:url)
        //请求获取的类型是application/json（也就是JSON类型）
        urlRequest.addValue("application/json",forHTTPHeaderField: "Accept")
        //检查获取到的数据
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            do {
                //将数据赋值给jokeDate，并且判断数据不为空的话
                if let sheetData = data {
                    //设置解码器为JSONDecoder()
                    let decoder = JSONDecoder()
                    //按照我们之前创建的Joke结构体的数据结构解码获取到的数据（如果我们打算放到数组中，给这里的Joke加个中括号）
                    let decodedData = try decoder.decode(OriginSheet.self, from: sheetData)
                    //为了防止数据过多，加载时间过长，这里使用异步加载
                    DispatchQueue.main.async {
                        //将解码后的数据赋值给之前准备好的空变量
                        self.commentdata = decodedData.hotComments
                        loaded = true
                    }
                } else {
                    //如果数据是空的，在控制台输出下面的文本
                    print("No data")
                }
            } catch {
                commentdata[0].content = error.localizedDescription
//                sheets.result[0].name=(error.localizedDescription.debugDescription)+(error.localizedDescription.description)
            }
        }.resume()
    }
}

struct CommentShow_Previews: PreviewProvider {
    static var previews: some View {
        CommentShow()
    }
}
