//
//  NetworkService.swift
//  QRScanner
//
//  Created by Roman Korobskoy on 08.10.2022.
//

import Foundation

protocol NetworkServiceType {
    func getData(url: URL, completion: @escaping (Result<Data,Error>) -> Void)
}

final class NetworkService: NetworkServiceType {
    static let shared = NetworkService()

    private init() {}

    func getData(url: URL, completion: @escaping (Result<Data,Error>) -> Void) {
        let bgQueue = DispatchQueue(label: "background", qos: .background)

        bgQueue.async {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                let tmpURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(response?.suggestedFilename ?? "fileName.png")
                do {
                    try data.write(to: tmpURL)
                    completion(.success(data))
                } catch {
                    completion(.failure(error))
                    print(error)
                }
            }.resume()
        }
    }
}
