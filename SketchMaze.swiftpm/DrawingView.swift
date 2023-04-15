import SwiftUI

struct DrawingView: UIViewControllerRepresentable {
    typealias UIViewControllerType = DrawingViewController

    func makeUIViewController(context: Context) -> DrawingViewController {
        let viewController = DrawingViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
        // 何もしない
    }
}
