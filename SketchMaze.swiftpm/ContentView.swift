import SwiftUI
import UIKit

struct ContentView: View {

    @ObservedObject var viewModel: ContentViewModel
    @State var orientation = UIDeviceOrientation.unknown

    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("", destination: ResultView(collectedItems: viewModel.collectedItems), isActive: $viewModel.showResult)
                    .opacity(0)
                GameSceneViewRepresentable(contentViewModel: viewModel)
                    .ignoresSafeArea()
                    .layoutPriority(2)
                VStack {
                    HStack {
                        Spacer()
                            .frame(maxWidth: viewModel.isRightHanded ? 16 : .infinity)
                        Button {
                            viewModel.didTapPlay()
                        } label: {
                            Image(viewModel.isReadyToPlay ? "play" : "retry")
                                .resizable()
                                .frame(width: 80, height: 80)
                        }
                        .opacity((viewModel.showGoalConfirm || viewModel.isPlayButtonHidden) ? 0 : 1)
                        Spacer()
                            .frame(maxWidth: viewModel.isRightHanded ? .infinity : 16)
                    }
                    Spacer()
                }
                HStack {
                    Button {
                        viewModel.showGoalConfirm = false
                        viewModel.didTapPlay()
                    } label: {
                        Image("retry")
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    Button {
                        viewModel.showGoalConfirm = false
                        viewModel.didTapGoNext()
                    } label: {
                        Image("next")
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                        .ignoresSafeArea()
                }
                .opacity(viewModel.showGoalConfirm ? 1 : 0)
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
        .navigationBarBackButtonHidden(true)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(isRightHanded: true))
    }
}
