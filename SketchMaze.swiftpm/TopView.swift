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
                HStack {
                    Text("Left")
                    Toggle("", isOn: $isRightHanded)
                        .labelsHidden()
                        .toggleStyle(ColorfulToggleStyle())
                    Text("Right")
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

struct ColorfulToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.blue : Color.blue)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .padding(3)
                        .offset(x: configuration.isOn ? 10 : -10)
                )
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
        }
    }
}
