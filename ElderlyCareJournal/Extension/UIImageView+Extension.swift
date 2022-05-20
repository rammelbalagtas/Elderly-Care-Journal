//
//  UIImageView+Extension.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-20.
//

import Foundation
import UIKit

extension UIImageView {
  public func maskCircle() {
    self.contentMode = UIView.ContentMode.scaleAspectFill
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.masksToBounds = false
    self.clipsToBounds = true
  }
}
