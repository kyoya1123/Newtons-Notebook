//
//  TopView.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/18.
//

import SwiftUI

struct TopView: View {

    @State var isRightHanded = true

    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to the Game!")
                    .font(.largeTitle)
                    .padding()
                NavigationLink(destination: ContentView(viewModel: .init(isRightHanded: isRightHanded))) {
                    Text("Begin")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Text("Which is your dominant hand?")
                    .font(.title3)
                    .bold()
                Picker("", selection: $isRightHanded) {
                    Text("Left")
                        .tag(false)
                    Text("Right")
                        .tag(true)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 200)
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
