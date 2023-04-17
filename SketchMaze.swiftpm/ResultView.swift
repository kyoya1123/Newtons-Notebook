//
//  ResultView.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/18.
//

import SwiftUI

struct ResultView: View {

    var collectedItems: [Item]

    var body: some View {
        ZStack {
            Text("End")
            let _ = print(collectedItems)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(collectedItems: [.magnet, .astronomy])
    }
}
