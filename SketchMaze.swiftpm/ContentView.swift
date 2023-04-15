import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        ZStack {
            DrawingView()
                .ignoresSafeArea()
                .layoutPriority(2)
            VStack {
                HStack {
//                    Button {
//                        viewModel.resetButtonTapped()
//                    } label: {
//                        Image("retry")
//                            .resizable()
//                            .frame(width: 80, height: 80)
//                    }
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
