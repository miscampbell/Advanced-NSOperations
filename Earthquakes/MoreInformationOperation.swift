/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file contains the code to present more information about an earthquake as a modal sheet.
*/

import Foundation
import SafariServices

/// An `Operation` to display an `NSURL` in an app-modal `SFSafariViewController`.
class MoreInformationOperation: EQOperation {
    // MARK: Properties

    let URL: URL
    
    // MARK: Initialization
    
    init(URL: URL) {
        self.URL = URL

        super.init()
        
        addCondition(condition: MutuallyExclusive<UIViewController>())
    }
    
    // MARK: Overrides
 
    override func execute() {
        DispatchQueue.global(qos: .background).async {

            // Background Thread

            DispatchQueue.main.async {
                // Run UI Updates
                self.showSafariViewController()
            }
        }
    }
    
    private func showSafariViewController() {
        if let context = UIApplication.shared.keyWindow?.rootViewController {
            let safari = SFSafariViewController(url: URL, entersReaderIfAvailable: false)
            safari.delegate = self
            context.present(safari, animated: true, completion: nil)
        }
        else {
            finish()
        }
    }
}

extension MoreInformationOperation: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismiss(animated: true) {
            self.finish()
        }
    }
}
