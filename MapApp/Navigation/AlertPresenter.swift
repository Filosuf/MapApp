//
//  AlertPresenter.swift
//  MapApp
//
//  Created by Filosuf on 28.12.2022.
//

import UIKit
enum AlertActions {
    case addPin
    case newRoute
    case removeAll
}


final class AlertPresenter {
    // MARK: - Properties
    private weak var viewController: UIViewController?

    // MARK: - Initialiser
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    // MARK: - Methods
    func showAction(message: String, action: @escaping (AlertActions) -> Void) {
        guard let viewController = viewController else { return }

        let alert = UIAlertController(title: "Выберете действие", message: "", preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Добавить булавку \(message)", style: .default , handler:{ (UIAlertAction)in
            action(.addPin)
        }))

        alert.addAction(UIAlertAction(title: "Новый маршрут", style: .default , handler:{ (UIAlertAction)in
            action(.newRoute)
        }))

        alert.addAction(UIAlertAction(title: "Удалить все булавки", style: .destructive , handler:{ (UIAlertAction)in
            action(.removeAll)
        }))

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        alert.view.accessibilityIdentifier = "pin_alert"

        viewController.present(alert, animated: true, completion: nil)
    }

    func showRequestAuthorization(action: @escaping () -> Void) {
        guard let viewController = viewController else { return }

        let alert = UIAlertController(title: "Невозможно построить маршрут", message: "Необходимо разрешить доступ приложению к геолокациям. Для этого нужно перейти в настройки", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Перейти", style: .default , handler:{ (UIAlertAction)in
            action()
        }))

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))

        alert.view.accessibilityIdentifier = "settings_alert"

        viewController.present(alert, animated: true, completion: nil)
    }
}
