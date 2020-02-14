import UIKit

extension UIImage {
    
    func applyBlurEffect() -> UIImage? {
        if let originalCIImage = CIImage(image: self) {
            let transformedCIImage = originalCIImage.clampedToExtent()
                .applyingGaussianBlur(sigma: 50)
                .cropped(to: originalCIImage.extent)
            return UIImage(ciImage: transformedCIImage)
        }
        return nil
    }
}
