//
//  LyricsShow.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/10.
//

import SwiftUI
import AVFoundation
import Foundation
import AVKit

extension String{

    //MARK:-返回string的长度
    var length:Int{
        get {
            return self.count;
        }
    }
    //MARK:-截取字符串从开始到 index
    func substring(to index: Int) -> String {
        guard let end_Index = validEndIndex(original: index) else {
            return self;
        }

        return String(self[startIndex..<end_Index]);
    }
    //MARK:-截取字符串从index到结束
    func substring(from index: Int) -> String {
        guard let start_index = validStartIndex(original: index)  else {
            return self
        }
        return String(self[start_index..<endIndex])
    }
    //MARK:-切割字符串(区间范围 前闭后开)
    func sliceString(_ range:CountableRange<Int>)->String{

        guard
            let startIndex = validStartIndex(original: range.lowerBound),
            let endIndex   = validEndIndex(original: range.upperBound),
            startIndex <= endIndex
            else {
                return ""
        }

        return String(self[startIndex..<endIndex])
    }
     //MARK:-切割字符串(区间范围 前闭后闭)
    func sliceString(_ range:CountableClosedRange<Int>)->String{

        guard
            let start_Index = validStartIndex(original: range.lowerBound),
            let end_Index   = validEndIndex(original: range.upperBound),
            startIndex <= endIndex
            else {
                return ""
        }
        if(endIndex.encodedOffset <= end_Index.encodedOffset){
            return String(self[start_Index..<endIndex])
        }
        return String(self[start_Index...end_Index])

    }
     //MARK:-校验字符串位置 是否合理，并返回String.Index
    private func validIndex(original: Int) -> String.Index {

        switch original {
        case ...startIndex.encodedOffset : return startIndex
        case endIndex.encodedOffset...   : return endIndex
        default                          : return index(startIndex, offsetBy: original)
        }
    }
  //MARK:-校验是否是合法的起始位置
    private func validStartIndex(original: Int) -> String.Index? {
        guard original <= endIndex.encodedOffset else { return nil }
        return validIndex(original:original)
    }
    //MARK:-校验是否是合法的结束位置
    private func validEndIndex(original: Int) -> String.Index? {
        guard original >= startIndex.encodedOffset else { return nil }
        return validIndex(original:original)
    }
}

private struct Lrc: Codable{
    var lyric:String
}

private struct OriginSheet: Codable{
    var lrc: Lrc
}

private struct MyLrc: Codable, Hashable{
    var lrc:String
    var pos:String
}

struct LyricsShow: View {
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var oLrc:String = "努力加载歌词中……"
    @State private var pLrc:[MyLrc] = []
    @State private var position:Int = 0
    @State private var nb:String = "歌词"
    @State private var time:String = ""
    @State private var nowpos:String = "none"
    @State private var loaded:Bool = false
    @State private var lastSelected:String = ""
    var body: some View {
        HStack {
            if(loaded){
                ScrollView{
                    ScrollViewReader{ proxy in
                        Text("").id("mytop")
                        LazyVStack{
                            ForEach(pLrc, id: \.self) { lrc in
                                if(lrc.pos == nowpos){
                                    
                                }
                                Text(lrc.lrc)
                                    .font(.headline)
                                    .foregroundColor( (lrc.pos == nowpos) ? (.white) : (.gray) )
                                    .frame(alignment: .center)
                                    .id(lrc.pos)
                                Text("")
                            }
                        }
                        .onReceive(timer) { _ in
                            let  currentTime =  CMTimeGetSeconds ( player.currentTime())
                            //一个小算法，来实现00：00这种格式的播放时间
                            var all:Int = 0
                            if(currentTime == .infinity || currentTime == .nan){
                                all = 0
                            }else{
                                all = Int (currentTime)
                            }
                            let  m: Int = all % 60
                            let  f: Int = Int (all/60)
                            time = ""
                            if  f<10{
                                time = "0\(f):"
                            } else  {
                                time = "\(f)"
                            }
                            if  m<10{
                                time += "0\(m)"
                            } else  {
                                time += "\(m)"
                            }
                            //更新播放时间
                            var lastid = "mytop"
                            for t in pLrc{
                                if(t.pos.sliceString(0..<5) == time){
                                    let id = t.pos
                                    nowpos = id
                                    if(nowpos == lastSelected){
                                        break
                                    }
                                    lastSelected = nowpos
                                    withAnimation(Animation.easeInOut){
                                        proxy.scrollTo(lastid,anchor:.top)
                                    }
                                    break
                                }
                                lastid = t.pos
                            }
                            
                        }
                    }
                }
            }else{
                ProgressView()
            }
        }.onAppear(perform: { self.myload2() })
            .navigationBarTitle("歌词")
    }
    func myload2(){
        //设置需要获取的网址
        let urlstr:String = "\(apiServer)/lyric?id=\(String(Gsongids[(Gplayid)]))"
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
                        self.oLrc = decodedData.lrc.lyric
                        let splitedLrc = decodedData.lrc.lyric.split{$0 == "\n"}.map(String.init)
                        pLrc = []
                        for l in splitedLrc{
                            let range: Range = l.range(of: "]")!
                            let rp = l.distance(from: l.startIndex, to: range.lowerBound)
                            let t:String = l.sliceString(1..<rp)
                            let ly:String = l.substring(from: rp+1)
                            pLrc.append(MyLrc(lrc: ly, pos: t))
                        }
                        loaded = true
                    }
                } else {
                    //如果数据是空的，在控制台输出下面的文本
                    print("No data")
                }
            } catch {
//                sheets.result[0].name=(error.localizedDescription.debugDescription)+(error.localizedDescription.description)
            }
        }.resume()
    }
}

struct LyricsShow_Previews: PreviewProvider {
    static var previews: some View {
        LyricsShow()
    }
}
