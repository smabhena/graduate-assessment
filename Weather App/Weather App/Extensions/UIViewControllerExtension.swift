//
//  UIViewControllerExtension.swift
//  Weather App
//
//  Created by Sinothando Mabhena on 2022/04/25.
//

import Foundation
import UIKit

extension UIViewController {
    func displayAlert(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
