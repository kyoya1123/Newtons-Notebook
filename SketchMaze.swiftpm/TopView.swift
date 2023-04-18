//
//  TopView.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/18.
//

import SwiftUI

struct TopView: View {

    @State var isRightHanded = true
    @State var orientation = UIDeviceOrientation.unknown

    var body: some View {
        NavigationView {
            ZStack {
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
                VStack {
                    Text("Play this game in landscape mode")
                        .font(.largeTitle)
                    Image(systemName: "rotate.right.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                        .ignoresSafeArea()
                }
                .opacity(orientation == .landscapeLeft || orientation == .landscapeRight ? 0 : 1)
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            orientation = (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)! ? .landscapeLeft : .portrait
        }
        .onRotate { newOrientation in
            if newOrientation != .unknown {
                orientation = newOrientation
            }
        }
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
