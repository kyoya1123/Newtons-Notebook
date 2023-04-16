import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        ZStack {
            
            GameSceneViewRepresentable(contentViewModel: viewModel)
                .ignoresSafeArea()
                .layoutPriority(2)
            Text("GOAL!!")
                .font(.title)
                .foregroundColor(viewModel.isTextHidden ? .clear : .black)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
