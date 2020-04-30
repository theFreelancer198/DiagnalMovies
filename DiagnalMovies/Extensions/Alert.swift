//
//  Alert.swift
//  DiagnalMovies
//
//  Created by Abhishek on 30/04/20.
//  Copyright © 2020 Abhishek. All rights reserved.
//
import Foundation
import UIKit

protocol AlertHandler {
    func displayAlert(with title: String, message: String, actions: [UIAlertAction]?)
}

extension AlertHandler where Self: UIViewController {
    func displayAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
        guard presentedViewController == nil else {
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions?.forEach { action in
            alertController.addAction(action)
        }
        present(alertController, animated: true)
    }
}
