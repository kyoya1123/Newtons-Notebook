import SwiftUI

struct DrawingView: UIViewControllerRepresentable {
    typealias UIViewControllerType = DrawingViewController

    func makeUIViewController(context: Context) -> DrawingViewController {
        return DrawingViewController()
    }

    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
        // 何もしない
    }
}
