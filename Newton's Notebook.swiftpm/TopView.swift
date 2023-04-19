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
                Image("note")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                VStack {
                    Text("Welcome to Newton's Notebook!")
                        .font(.largeTitle)
                        .bold()
                    Image("basket")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Spacer()
                        .frame(maxHeight: 50)
                    NavigationLink(destination: ContentView(viewModel: .init(isRightHanded: isRightHanded))) {
                        Text("Play")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32))
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    Spacer()
                        .frame(maxHeight: 32)
                    Text("Which is your dominant hand?")
                        .font(.title)
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
            print(UIScreen.main.bounds)
        }
        .onRotate { isLandscape in
            orientation = isLandscape ? .landscapeLeft : .portrait
        }
        .preferredColorScheme(.light)
    }
}

struct TopView_Previews: PreviewProvider {
    static var previews: some View {
        TopView()
    }
}
