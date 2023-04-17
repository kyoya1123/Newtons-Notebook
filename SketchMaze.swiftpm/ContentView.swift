import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: ContentViewModel

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
                        Button {
                            viewModel.didTapRetry()
                        } label: {
                            Image("retry")
                                .resizable()
                                .frame(width: 80, height: 80)
                        }

                        Button {
                            viewModel.didTapAddBall()
                        } label: {
                            Text("🍎")
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onAppear {
                viewModel.setupScene()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
