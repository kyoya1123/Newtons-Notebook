import SwiftUI

struct DrawingView: UIViewControllerRepresentable {
    typealias UIViewControllerType = DrawingViewController

    @ObservedObject var viewModel: ContentViewModel

    func makeUIViewController(context: Context) -> DrawingViewController {
        let viewController = DrawingViewController()
        viewController.coordinator = context.coordinator
        viewModel.didTapReset = viewController.clearAll
        return viewController
    }

    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
        // 何もしない
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: DrawingView

        init(_ parent: DrawingView) {
            self.parent = parent
        }
    }
}
