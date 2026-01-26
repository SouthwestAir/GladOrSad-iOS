//
//  UploadDataManager.swift
//  GladOrSad-iOS
//
//  Created by Michael Roth on 8/7/23.
//

import Foundation
import CoreData

enum UploadDataError: Error {
    // these only get logged as \(error.localizedDescription), so no special case is needed to handle them
    // feel free to add as needed
    case urlMissing
    case urlFailed
    case csvGenerationFailed
    case csvUploadFailed
    case dataCleanupFailed
}

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
    var csvData: String?
    
}

extension UploadDataManager {
    func formatUnixDate(from unix: Int64) -> String {
        let isMilliseconds = unix > 9_999_999_999
        let seconds = isMilliseconds ? TimeInterval(unix) / 1000.0 : TimeInterval(unix)
        let date = Date(timeIntervalSince1970: seconds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        return (dateFormatter.string(from: date))
    }
    
    func generateCsvData(from context: NSManagedObjectContext) -> String? {
        let fetchRequest: NSFetchRequest<QuizResponse> = NSFetchRequest(entityName: "QuizResponse")
        
        do {
            csvData = ""
            let csvHead = "\"Device Name\",\"Quiz Name\",\"Location\",\"Quiz Time\",\"Quiz Caption\",\"Quiz Prompt\",\"Selected Index\",\"Selected Name\",\"Selected Title\"\n"
            csvData?.append(csvHead)
            let result = try context.fetch(fetchRequest)
            result.forEach { testResponse in
                csvData?.append("\"\(testResponse.deviceName ?? "")\",\"\(testResponse.quizName ?? "")\",\"\(testResponse.location ?? "")\",\"\(formatUnixDate(from: testResponse.quizTime))\",\"\(testResponse.quizCaption ?? "")\",\"\(testResponse.quizPrompt ?? "")\",\"\(testResponse.selectedIndex)\",\"\(testResponse.selectedName ?? "")\",\"\(testResponse.selectedTitle ?? "")\"\n")
            }
            return csvData
        } catch {
            print("Error loading QuizResponses from database")
            return nil
        }
    }
    
    func createAndUploadCsv(dataContext: NSManagedObjectContext, callback: @escaping (UploadDataError?)->Void) {
        let fetchRequest: NSFetchRequest<QuizResponse> = NSFetchRequest(entityName: "QuizResponse")
        
        guard let csvData = UploadDataManager.shared.generateCsvData(from: dataContext) else {
            callback(UploadDataError.csvGenerationFailed)
            return
        }
        
        print (csvData)
        
        dateFormatter.dateFormat = "YYYY-MM-DD"
        let now = Date()
        let formattedDay = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "HH-mm"
        let formattedHourAndMin = dateFormatter.string(from: now)
        
        let fileName = "\(formattedDay)/QuizUpload_\(formattedHourAndMin).csv"
        
        if let data = csvData.data(using: .utf8) {
            uploadToS3(file: data, forPath: fileName) { error in
                if let error = error {
                    callback(error)
                    return
                }
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "QuizResponse")
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try dataContext.execute(batchDeleteRequest)
                    try dataContext.save()
                } catch {
                    callback(UploadDataError.dataCleanupFailed)
                    print("Delete all in table QuizResponse failed!")
                }
                callback(nil)
            }
        }
    }
}

extension UploadDataManager {
    func uploadToS3(file: Data, forPath: String, callback: @escaping (UploadDataError?)->Void) {
        guard let uploadUrl, let dateExpires = uploadUrl.dateExpires, Date() < dateExpires else {
            getUrl(forFile: forPath) { error in
                if let error = error {
                    callback(error)
                    return
                }
                self.uploadCsv(csv: file) { error in
                    callback(nil)
                }
            }
            return
        }
        uploadCsv(csv: file) { error in
            if let error = error {
                callback(error)
                return
            }
            callback(nil)
        }
    }
    private func getUrl(forFile: String, callback: @escaping (UploadDataError?) -> Void) {
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
                callback(UploadDataError.urlFailed)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Server returned status code other than 2xx: \(httpResponse.statusCode)")
                callback(UploadDataError.urlFailed)
                return
            }

            if let data = data {
                self.uploadUrl = UploadUrl()
                self.uploadUrl?.url = String(data: data, encoding: .utf8)
            }
            callback(nil)
        }
        task.resume()
    }

    private func uploadCsv(csv: Data, callback: @escaping (UploadDataError?)->Void) {
        guard let uploadUrl = self.uploadUrl, let url = uploadUrl.url, let presignedUrl = URL(string: url) else {
            callback(UploadDataError.urlMissing)
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
                callback(UploadDataError.csvUploadFailed)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                print("Server returned status code other than 2xx: \(httpResponse.statusCode)")
                callback(UploadDataError.csvUploadFailed)
                return
            }

            if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print(responseString ?? "")
            }
            callback(nil)
        }
        task.resume()
    }
    
}
