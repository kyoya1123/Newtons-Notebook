import SwiftUI
import Combine

struct GameSceneViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = GameSceneViewController

    @ObservedObject var contentViewModel: ContentViewModel

    func makeUIViewController(context: Context) -> GameSceneViewController {
        return context.coordinator.viewController
    }

    func updateUIViewController(_ uiViewController: GameSceneViewController, context: Context) {
        // 何もしない
    }

    func makeCoordinator() -> Coordinator {
        let viewController = GameSceneViewController()
        return Coordinator(contentViewModel: contentViewModel, viewController: viewController)
    }

    class Coordinator: NSObject {

        var cancellables = Set<AnyCancellable>()

        var contentViewModel: ContentViewModel
        var viewController: GameSceneViewController

        init(contentViewModel: ContentViewModel, viewController: GameSceneViewController) {
            self.contentViewModel = contentViewModel
            self.viewController = viewController
            super.init()
            viewController.coordinator = self
            subscribeToContentViewModel()
        }

        func subscribeToContentViewModel() {
            contentViewModel.retryAction.sink { [weak self] _ in
                self?.retry()
            }.store(in: &cancellables)

            contentViewModel.addBallAction.sink { [weak self] _ in
                self?.addBall()
            }.store(in: &cancellables)

            contentViewModel.goNextAction.sink { [weak self] _ in
                self?.goNext()
            }.store(in: &cancellables)
        }

        func retry() {
            viewController.retry()
        }

        func addBall() {
            viewController.addBall()
        }

        func goNext() {
            viewController.setupNextScene()
        }

        func showResultView(collectedItems: [Item]) {
            contentViewModel.showResultView(collectedItems: collectedItems)
        }

        func showGoalConfirm() {
            contentViewModel.showGoalConfirm = true
        }
    }
}
