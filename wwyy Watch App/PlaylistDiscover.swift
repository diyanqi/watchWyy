//
//  PlaylistDiscover.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/11.
//

import SwiftUI

struct PlaylistDiscover: View {
    @State var tabViewSelected2: Int = 1
    var body: some View {
        TabView(selection: $tabViewSelected2){
            RecommendedSongs()
                .navigationBarTitle("推荐歌单")
                .tag(0)
            TopPlaylist()
                .navigationBarTitle("网友精选碟")
                .tag(1)
            HighQualityPlaylist()
                .navigationBarTitle("精品歌单")
                .tag(2)
        }.onAppear(perform: { self.refreshTab() })
    }
    func refreshTab(){
        let time: TimeInterval = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            tabViewSelected2 = 0
        }
    }
}

struct PlaylistDiscover_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistDiscover()
    }
}
