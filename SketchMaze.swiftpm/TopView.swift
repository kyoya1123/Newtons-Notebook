//
//  TopView.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/18.
//

import SwiftUI

struct TopView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to the Game!")
                    .font(.largeTitle)
                    .padding()

                NavigationLink(destination: ContentView(viewModel: .init())) {
                    Text("Begin")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
