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
    var t:Double
}

// 定义渐变颜色数组
let colors: [Color] = [.red, .yellow, .green]

// 定义渐变起始和终止位置
let startPoint = UnitPoint(x: 0, y: 0)
let endPoint = UnitPoint(x: 1, y: 0)

// 构建渐变背景
let gradient = LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint)

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
    @State private var currentID = Gsongids[(Gplayid)]
    
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
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .id(lrc.pos)
                                    .onTapGesture {
                                        let time = lrc.t
                                        let currentTime = player.currentTime().seconds
                                        let duration = player.currentItem?.duration.seconds ?? 0
                                        let targetTime = min(duration, max(0, time))
                                        player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 1000))
                                    }
                                Text("")
                            }
                        }
                        .onReceive(timer) { _ in
                            let currentTime = player.currentTime() // 假设 player 是 AVPlayer 对象
                            let currentTimeValue = currentTime.value
                            let currentTimeScale = currentTime.timescale
                            let currentTimeInSeconds = Double(currentTimeValue) / Double(currentTimeScale)
                            let currentTimeInMilliseconds = currentTimeInSeconds * 1000.0
                            let formatter = DateComponentsFormatter()
                            formatter.zeroFormattingBehavior = .pad
                            formatter.allowedUnits = [.minute, .second, .nanosecond]
                            formatter.unitsStyle = .positional
                            let time = formatter.string(from: currentTimeInSeconds)!
                            
                            var foundIndex = -1 // 初始化为 -1，若无法找到合适的位置，则不会滚动
                            
                            // 二分查找
                            var leftIndex = 0
                            var rightIndex = pLrc.count - 1
                            while leftIndex <= rightIndex {
                                let midIndex = (leftIndex + rightIndex) / 2
                                let midTime = pLrc[midIndex].t
                                if midTime <= currentTimeInSeconds {
                                    foundIndex = midIndex
                                    leftIndex = midIndex + 1
                                } else {
                                    rightIndex = midIndex - 1
                                }
                            }
                            
                            if foundIndex != -1 && foundIndex < pLrc.count {
                                let id = pLrc[foundIndex].pos
                                if(nowpos != id){
                                    nowpos = id
                                    lastSelected = nowpos
                                    withAnimation(Animation.easeInOut){
                                        proxy.scrollTo(nowpos, anchor:.center)
                                    }
                                }
                            }
                            
                            if(currentID != Gsongids[(Gplayid)]){
                                myload2()
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
    
    func getTimeFromString(str: String) -> Double? {
        let pattern = "\\[([0-9]+:[0-9]+(\\.[0-9]+)?)\\]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: str, options: [], range: NSRange(location: 0, length: str.utf16.count))
        guard let match = matches.first else { return nil }
        let timeRange = match.range(at: 1)
        let timeString = NSString(string: str).substring(with: timeRange)
        let timeParts = timeString.components(separatedBy: ":")
        guard timeParts.count == 2, let minutes = Double(timeParts[0]), let seconds = Double(timeParts[1]) else {
            return nil
        }
        if timeParts[1].contains(".") {
            return minutes * 60 + seconds
        } else {
            return minutes * 60 + seconds.rounded()
        }
    }
    
    func getLyrics(from lyricsLine: String) -> String? {
        let separator = "]"
        if let separatorIndex = lyricsLine.firstIndex(of: Character(separator)) {
            return String(lyricsLine[separatorIndex..<lyricsLine.endIndex].dropFirst())
        }
        return nil
    }
    
    func myload2(){
        //设置需要获取的网址
        let urlstr:String = "\(apiServer)/lyric?id=\(String(Gsongids[(Gplayid)]))"
        currentID = Gsongids[(Gplayid)]
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
                            pLrc.append(MyLrc(lrc: getLyrics(from: l)!, pos: String(getTimeFromString(str: l)!), t: getTimeFromString(str: l)!))
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
