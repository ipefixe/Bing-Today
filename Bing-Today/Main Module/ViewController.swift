import UIKit
import os.log
import SwiftSoup

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
        
    var image: UIImage? = nil {
        didSet {
            if let image = image {
                self.imageView.image = image
                self.backgroundImageView.image = image.applyBlurEffect()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startActivityIndicator()
        
        BingBackgroundImageProvider.getImage(completionHandler: { backgroundImage in
            DispatchQueue.main.async {
                if let backgroundImage = backgroundImage {
                    self.image = backgroundImage
                    self.addButton.isHidden = false
                } else {
                    self.noImageFound()
                }
                self.stopActivityIndicator()
            }
        })
    }
    
    private func noImageFound() {
        let alertController = UIAlertController(title: "error_title".localized, message: "no_image_error_message".localized, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addToGallery() {
        if let image = image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let alertController = UIAlertController(title: "error_title".localized, message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "image_saved_title".localized, message: "image_saved_message".localized, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}
