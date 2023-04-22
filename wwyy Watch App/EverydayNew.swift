//
//  EverydayNew.swift
//  wwyy Watch App
//
//  Created by diyanqi on 2023/2/8.
//

import SwiftUI

struct EverydayNew: View {
    @State var tabViewSelected: Int = 1
    var body: some View {
        TabView(selection: $tabViewSelected){
            EverydaySonglist().tag(1).navigationTitle(Text("日推歌单"))
            EverydaySongs().tag(2).navigationTitle(Text("日推单曲"))
        }
    }
}

struct EverydayNew_Previews: PreviewProvider {
    static var previews: some View {
        EverydayNew()
    }
}
