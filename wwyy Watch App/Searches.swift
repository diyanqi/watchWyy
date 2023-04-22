//
//  Searches.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2022/12/17.
//

import SwiftUI

struct Searches: View {
    @State var tabViewSelected3: Int = 0
    @State var content:String = "content"
    var body: some View {
        TabView(selection: $tabViewSelected3){
            SearchResultDisplay(searchWord: content)
                .navigationBarTitle("单曲")
                .tag(0)
            SearchPlaylist(searchword: content)
                .navigationBarTitle("歌单")
                .tag(1)
        }
    }
}

struct Searches_Previews: PreviewProvider {
    static var previews: some View {
        Searches()
    }
}
