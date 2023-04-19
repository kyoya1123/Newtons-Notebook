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
                            .frame(maxWidth: 16)
                        if viewModel.isRightHanded {
                            playRetryButton
                            Spacer()
                            collectedItemView
                        } else {
                            collectedItemView
                            Spacer()
                            playRetryButton
                        }
                        Spacer()
                            .frame(maxWidth: 16)
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
                }
                .opacity(orientation == .landscapeLeft || orientation == .landscapeRight ? 0 : 1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(.stack)
        .onAppear {
            orientation = (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)! ? .landscapeLeft : .portrait
        }
        .onRotate { isLandscape in
            orientation = isLandscape ? .landscapeLeft : .portrait
        }
        .preferredColorScheme(.light)
    }

    var playRetryButton: some View {
        Button {
            viewModel.didTapPlay()
        } label: {
            Image(viewModel.isReadyToPlay ? "play" : "retry")
                .resizable()
                .frame(width: 80, height: 80)
        }
        .opacity((viewModel.showGoalConfirm || viewModel.isPlayButtonHidden) ? 0 : 1)
    }

    var collectedItemView: some View {
        HStack {
            ForEach(Item.firstFourItems + Item.lastFourItems, id: \.self) { item in
                ZStack {
                    Image(item.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .opacity(viewModel.collectedItems.contains(item) ? 1 : 0)
                    Image(item.rawValue)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .opacity(0.2)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor.opacity(0.2))
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(isRightHanded: true))
    }
}
