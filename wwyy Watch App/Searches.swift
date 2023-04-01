//
//  Searches.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/17.
//

import SwiftUI

struct Searches: View {
    @State var tabViewSelected3: Int = 1
    @State var content:String = "content"
    var body: some View {
        TabView(selection: $tabViewSelected3){
            SearchResultDisplay(searchWord: content)
                .navigationBarTitle("单曲")
                .tag(0)
            SearchPlaylist(searchword: content)
                .navigationBarTitle("歌单")
                .tag(1)
        }.onAppear(perform: { self.refreshTab() })
    }
    func refreshTab(){
        let time: TimeInterval = 0.05
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            tabViewSelected3 = 0
        }
    }
}

struct Searches_Previews: PreviewProvider {
    static var previews: some View {
        Searches()
    }
}
