import UIKit
import os
import SwiftSoup

class BingBackgroundImageProvider {
    
    private struct Constants {
        static let baseUrl       = "https://www.bing.com/"
        static let elementName   = "downloadLink"
        static let attributeName = "href"
    }
    
    private init() {}
    
    static func getImage(completionHandler: @escaping (UIImage?) -> Void) {
        guard let sourceCode = getSourceCodeOf(urlWebsite: Constants.baseUrl) else {
            completionHandler(nil)
            return
        }
        
        guard let imageURL = getImageURLFrom(html: sourceCode) else {
            completionHandler(nil)
            return
        }
        
        getImageFrom(imageURL: imageURL, completionHandler: completionHandler)
    }
    
    private static func getSourceCodeOf(urlWebsite: String) -> String? {
        guard let bingURL = URL(string: urlWebsite) else {
            os_log(.error, "Incorrect URL: %s", urlWebsite)
            return nil
        }
        
        guard let bingHTML = try? String(contentsOf: bingURL) else {
            os_log(.error, "No content for this URL: %s", urlWebsite)
            return nil
        }
        
        return bingHTML
    }
    
    private static func getImageURLFrom(html: String) -> URL? {
        guard let doc = try? SwiftSoup.parse(html) else {
            os_log(.error, "Impossible to parse HTML to create Document. \n%s", html)
            return nil
        }
        
        guard let element = try? doc.getElementById(Constants.elementName) else {
            os_log(.error, "No %s element in the HTML. \n%s", Constants.elementName, html)
            return nil
        }
        
        guard let attribute = element.getAttributes()?.first(where: { (attribute) -> Bool in
            return attribute.getKey() == Constants.attributeName
        }) else {
            os_log(.error, "No %s attribute in %s element. \n%s", Constants.attributeName, Constants.elementName, html)
            return nil
        }
        
        let imageURLString = Constants.baseUrl + attribute.getValue()
        
        return URL(string: imageURLString)
    }
    
    private static func getImageFrom(imageURL: URL, completionHandler: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
            if let error = error {
                os_log(.error, "%s", error.localizedDescription)
                completionHandler(nil)
                return
            }
            
            if let data = data {
                completionHandler(UIImage(data: data))
            } else {
                os_log(.error, "No image!")
                completionHandler(nil)
            }
        }
        
        task.resume()
    }
}
