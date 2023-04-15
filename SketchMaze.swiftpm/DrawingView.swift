import SwiftUI
import Combine

struct DrawingView: UIViewControllerRepresentable {
    typealias UIViewControllerType = DrawingViewController

    @ObservedObject var contentViewModel: ContentViewModel

    func makeUIViewController(context: Context) -> DrawingViewController {
        return context.coordinator.viewController
    }

    func updateUIViewController(_ uiViewController: DrawingViewController, context: Context) {
        // 何もしない
    }

    func makeCoordinator() -> Coordinator {
        let viewController = DrawingViewController()
        return Coordinator(contentViewModel: contentViewModel, viewController: viewController)
    }

    class Coordinator: NSObject {

        var cancellables = Set<AnyCancellable>()

        var contentViewModel: ContentViewModel
        var viewController: DrawingViewController

        init(contentViewModel: ContentViewModel, viewController: DrawingViewController) {
            self.contentViewModel = contentViewModel
            self.viewController = viewController
            super.init()
            subscribeToContentViewModel()
        }

        func subscribeToContentViewModel() {
            contentViewModel.retryAction.sink { [weak self] _ in
                self?.retry()
            }.store(in: &cancellables)

            contentViewModel.addBallAction.sink { [weak self] _ in
                self?.addBall()
            }.store(in: &cancellables)
        }

        func goal() {
            contentViewModel.didGoal()
        }

        func retry() {
            viewController.retry()
        }

        func addBall() {
            viewController.addBall()
        }
    }
}
