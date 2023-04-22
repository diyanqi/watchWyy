//
//  LrcPlayer.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/10.
//

import SwiftUI
import Combine
import AVFoundation

var cancellables = Set<AnyCancellable>()

public struct LrcData: Codable {
    public var lrc: Lrc
    
    public struct Lrc: Codable {
        public var lyric: String
        
        public init(lyric: String) {
            self.lyric = lyric
        }
        
        public var lines: [Line] {
            let pattern = "\\[(\\d{2}):(\\d{2})\\.?(\\d{0,3})\\]"
            let regex = try! NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: lyric, range: NSRange(location: 0, length: lyric.utf16.count))
            var lines: [Line] = []
            var previousTime: TimeInterval = 0
            
            for match in matches {
                let timeString = (lyric as NSString).substring(with: match.range)
                let seconds = timeStringToSeconds(timeString)
                let text = (lyric as NSString).substring(from: match.range.upperBound).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if seconds > previousTime {
                    lines.append(Line(time: seconds, text: text))
                    previousTime = seconds
                }
            }
            
            return lines
        }
        
        private func timeStringToSeconds(_ timeString: String) -> TimeInterval {
            let components = timeString.components(separatedBy: CharacterSet(charactersIn: "[]:."))
            
            let minutes = TimeInterval(components[1]) ?? 0
            let seconds = TimeInterval(components[2]) ?? 0
            let milliseconds = TimeInterval(components[3]) ?? 0
            
            return (minutes * 60 + seconds + milliseconds / 1000)
        }
        
        public struct Line: Identifiable {
            public var id = UUID()
            public var time: TimeInterval
            public var text: String
        }
    }
}

struct FramePreferenceKey: PreferenceKey {
    typealias Value = [CGRect]

    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct LrcPlayer: View {
    var url: String = "https://pi.amzcd.top:3001/lyric?id=\(Gsongids[(Gplayid)])"
    
    @State var lrcData: LrcData?
        
    @State var currentIndex = 0
    
    @State var txt = "Loading..."
    
    let interval: TimeInterval = 0.1
    
    @State private var scrollViewHeight: CGFloat = .zero
    @State private var lineFrames: [CGRect] = []
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                        ForEach(lrcData?.lrc.lines ?? []) { line in
                            GeometryReader { geometry -> Text in // 显式指定 Content 类型为 Text
                                let text = Text(line.text)
                                    .font(.headline)
                                    .foregroundColor(line.id == lrcData?.lrc.lines[currentIndex].id ? .green : .secondary)
                                
                                DispatchQueue.main.async {
                                    scrollViewHeight = geometry.size.height
                                    let frame = geometry.frame(in: .global)
                                    guard let index = lrcData?.lrc.lines.firstIndex(where: { $0.id == line.id }) else { return }
                                    lineFrames[index] = frame
                                }
                                
                                return text
                            }
                            .background(Color.clear)
                            .id(line.id)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                        }
                        .onPreferenceChange(FramePreferenceKey.self) { frames in
                            lineFrames = frames
                        }
                    }
                    .onChange(of: currentIndex) { value in
                        withAnimation {
                            proxy.scrollTo(lrcData?.lrc.lines[currentIndex].id, anchor: .center)
                        }
                    }
                }
            }


            Spacer()
        }
        .onAppear {
            fetchLrc()
            
            Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                updateLrc()
            }
        }
    }

    @State private var lrcHeight: CGFloat = .zero
    @State private var scrollViewOffset: CGFloat = .zero

    func fetchLrc() {
        guard let url = URL(string: self.url) else { return }
        txt = "1"
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                txt = "1.5"
                if let lrcData = try? JSONDecoder().decode(LrcData.self, from: data) {
                    txt = "2"
                    DispatchQueue.main.async {
                        self.lrcData = lrcData
                        txt = "ok"
                    }
                }
            }
        }.resume()
    }

    func updateLrc() {
        guard let lines = lrcData?.lrc.lines else { return }
        
        let currentTime = player.currentTime().seconds
        
        for i in 0 ..< lines.count {
            if i + 1 < lines.count {
                let currentLineTime = lines[i].time
                let nextLineTime = lines[i + 1].time
                
                if currentTime >= currentLineTime && currentTime < nextLineTime && i != currentIndex {
                    currentIndex = i
                }
            } else {
                let currentLineTime = lines[i].time
                
                if currentTime >= currentLineTime && i != currentIndex {
                    currentIndex = i
                }
            }
        }
    }
}

struct LrcPlayer_Previews: PreviewProvider {
    static var previews: some View {
        LrcPlayer()
    }
}
