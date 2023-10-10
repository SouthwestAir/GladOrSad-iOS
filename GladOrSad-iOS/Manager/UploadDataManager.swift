//
//  UploadDataManager.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 8/7/23.
//

import Foundation
import CoreData

struct UploadUrl: Decodable {
    var url: String?
    var expires: Int?
    
    var dateExpires: Date?
    
    enum CodingKeys: CodingKey {
        case url
        case expires
    }
}

public class UploadDataManager {
    public static var shared = UploadDataManager()
    
    let dateFormatter = DateFormatter()
    
    var uploadUrl: UploadUrl?
    
}

extension UploadDataManager {
    func createAndUploadCsv(dataContext: NSManagedObjectContext, callback: @escaping ()->Void) {
        let fetchRequest: NSFetchRequest<QuizResponse> = NSFetchRequest(entityName: "QuizResponse")
        
        do {
            var csvData = ""
            let csvHead = "\"Device Name\",\"Quiz Name\",\"Location\",\"Quiz Time\",\"Quiz Caption\",\"Quiz Prompt\",\"Selected Index\",\"Selected Name\",\"Selected Title\"\n"
            csvData.append(csvHead)
            let result = try dataContext.fetch(fetchRequest)
            result.forEach { testResponse in
                csvData.append("\"\(testResponse.deviceName ?? "")\",\"\(testResponse.quizName ?? "")\",\"\(testResponse.location ?? "")\",\"\(testResponse.quizTime)\",\"\(testResponse.quizCaption ?? "")\",\"\(testResponse.quizPrompt ?? "")\",\"\(testResponse.selectedIndex)\",\"\(testResponse.selectedName ?? "")\",\"\(testResponse.selectedTitle ?? "")\"\n")
            }
            dateFormatter.dateFormat = "YYYY-MM-DD"
            let now = Date()
            let formattedDay = dateFormatter.string(from: now)
            dateFormatter.dateFormat = "HH-mm"
            let formattedHourAndMin = dateFormatter.string(from: now)
            
            let fileName = "\(formattedDay)/QuizUpload_\(formattedHourAndMin).csv"
            
            if let data = csvData.data(using: .utf8) {
                uploadToS3(file: data, forPath: fileName) {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QuizResponse")
                    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    do {
                        try dataContext.execute(batchDeleteRequest)
                        try dataContext.save()
                    } catch {
                        print("Delete all in table QuizResponse failed!")
                    }
                    callback()
                }
            }
        } catch {
            print("Error selecting QuizResponses from database")
        }
    }
}

extension UploadDataManager {
    func uploadToS3(file: Data, forPath: String, callback: @escaping ()->Void) {
        guard let uploadUrl, let dateExpires = uploadUrl.dateExpires, Date() < dateExpires else {
            getUrl(forFile: forPath) {
                self.uploadCsv(csv: file) {
                    callback()
                }
            }
            return
        }
        uploadCsv(csv: file) {
            callback()
        }
    }
    private func getUrl(forFile: String, callback: @escaping () -> Void) {
        let serviceUrl = EnvironmentService.shared.presignedUrl
        let headers: [String: String] = [
            "x-api-key": EnvironmentService.shared.apiKey,
            "Content-Type": "application/json"
        ]
        let params: [String: String] = ["filename": "\(forFile)"]
        var request = URLRequest(url: URL(string: serviceUrl)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("GET URL FAILED: \(error)")
                callback()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Server returned status code other than 2xx: \(httpResponse.statusCode)")
                callback()
                return
            }

            if let data = data {
                self.uploadUrl = UploadUrl()
                self.uploadUrl?.url = String(data: data, encoding: .utf8)
            }
            callback()
        }
        task.resume()
    }

    private func uploadCsv(csv: Data, callback: @escaping ()->Void) {
        guard let uploadUrl = self.uploadUrl, let url = uploadUrl.url, let presignedUrl = URL(string: url) else {
            callback()
            return
        }
        
        var request = URLRequest(url: presignedUrl)
        request.httpMethod = "PUT"
        request.httpBody = csv

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                if let data = data {
                    print("error: " + String(data: data, encoding: String.Encoding.utf8)!)
                }
                print(error)
                callback()
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Server returned status code other than 2xx: \(httpResponse.statusCode)")
                callback()
                return
            }

            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print(responseString ?? "")
            }
            callback()
        }
        task.resume()
    }
    
}
