//
//  ImageLoader.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-05.
//

import Foundation
import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private init() {}
    
    func getImages(playerList: [Player]) async throws -> [UIImage?] {
        var images: [UIImage?] = []
        for player in playerList {
            guard let url = URL(string: player.profilePicUrl) else {
                throw(URLError(.badURL))
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                images.append(image)
            } else {
                images.append(nil)
            }
        }
        return images
    }		
    
    func getImage(urlString: String, CompletionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        let url = URL(string: urlString)!
        URLSession.shared.dataTask(with: url) { data, _, err in
           guard let data = data,
                 let image = UIImage(data: data) else {
               CompletionHandler(nil, err)
               return
           }
            CompletionHandler(image, nil)
        }.resume()
    }
}
