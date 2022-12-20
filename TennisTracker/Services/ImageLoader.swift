//
//  ImageLoader.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-05.
//

import Foundation
import UIKit

//class ImageLoader {
//    static let shared = ImageLoader()
//    private init() {}
//    
//    func getImages(playerList: [Player]) async throws -> [UIImage?] {
//        var images: [UIImage?] = []
//        for player in playerList {
//            if player.profilePicUrl != "" {
//                guard let url = URL(string: player.profilePicUrl) else {
//                    throw(URLError(.badURL))
//                }
//                let (data, _) = try await URLSession.shared.data(from: url)
//                if let image = UIImage(data: data) {
//                    images.append(image)
//                } else {
//                    images.append(nil)
//                }
//            } else {
//                images.append(nil)
//            }
//        }
//        return images
//    }
//    
//    func getImage(urlString: String) async throws -> UIImage? {
//        do {
//            guard let url = URL(string: urlString) else { return nil }
//            let (data, _) = try await URLSession.shared.data(from: url)
//            if let image = UIImage(data: data) {
//                return image
//            } else {
//                return nil
//            }
//        } catch {
//            throw error
//        }
//    }
//    
//}
