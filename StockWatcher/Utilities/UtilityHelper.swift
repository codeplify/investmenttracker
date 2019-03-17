//
//  UtilityHelper.swift
//  StockWatcher
//
//  Created by Loey Agdan on 2/11/19.
//  Copyright © 2019 Loey Agdan. All rights reserved.
//

import Foundation
import UIKit

extension MasterViewController {
    
    static func checkWebsite(url:String, completion: @escaping (Bool) -> Void ) {
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 1.0
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                completion(false)
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                
                completion(true)
                
            }
        }
        task.resume()
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}
