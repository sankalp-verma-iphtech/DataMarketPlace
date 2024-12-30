// The Swift Programming Language
// https://docs.swift.org/swift-book




import Foundation

public class DataMarketplace {
    
    // Update data to the server
    public static func updateDataToServer(fileURL: URL,serverURL: URL, completion: @escaping @Sendable (Result<Data, Error>) -> Void) {
        // Prepare the parameters for the network request
        let parameters: [String: Any] = [
            "file_name": fileURL.lastPathComponent, // Use the file's name
            "file_size": "\(fileURL.fileSize())", // Assuming you have a method to get the file size
            "file_url": fileURL.absoluteString
        ]
        
        // Prepare the request URL
        let url = serverURL
        
        // Prepare the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert parameters to JSON data
        do {
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = postData
        } catch {
            completion(.failure(error)) // Handle JSON serialization error
            return
        }
        
        // Perform the network request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for any errors during the request
            if let error = error {
                completion(.failure(error)) // Handle request error
                return
            }
            
            // Ensure that we have valid data in the response
            guard let data = data else {
                let error = NSError(domain: "YourAppDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data returned from server"])
                completion(.failure(error))
                return
            }
            
            // Process the successful response (e.g., parsing the data)
            // In this case, we are returning the raw response data, but you can customize this
            completion(.success(data))
        }
        
        task.resume() // Start the network task
    }
    
    // Send URL data to the server with additional metadata
    public static func sendUrlToServer(
        dataHash: String,
        dataIpfs: String,
        fileSize: String,
        fileName: String,
        fileExtension: String,
        buyerOrderId: String,
        serverURL: URL, // Accept URL as a parameter
        completionBlock: @escaping @Sendable (String) -> Void
    ) {
        // Assuming you have access to user session info
        let address = UserSession.shared.getAddress()
        
        // Fetch country and state info based on the user's address
        UserSession.shared.fetchCountryAndStateNameFromAddress(address: address) { countryName, stateName in
            if let countryName = countryName, let stateName = stateName {
                print("Country: \(countryName), State: \(stateName)")
                
                // Prepare the parameters for the API request
                let parameters = """
                {
                    "orderId": "\(buyerOrderId)",
                    "data_url": "\(dataIpfs)",
                    "data_hash": "\(dataHash)",
                    "data_name": "\(fileName)-\(UserSession.shared.getZipCode())-\(countryName)",
                    "data_size": "\(fileSize)",
                    "data_type": "\(fileExtension)",
                    "data_from": "\(Config.dateFormatter1.string(from: Date()))",
                    "data_to": "\(Config.dateFormatter1.string(from: Date()))",
                    "userId": "\(UserSession.shared.user?.uid ?? -1)",
                    "data_detail": {
                        "price": 1,
                        "status": "pending",
                        "country": "\(countryName)",
                        "state": "\(stateName)",
                        "zipcode": "\(UserSession.shared.getZipCode())",
                        "gender": "\(UserSession.shared.getGender())",
                        "age": "\(getAge(dateString: UserSession.shared.getDOB()))",
                        "category": "\(fileName)"
                    }
                }
                """
                
                // Convert the parameters to data
                let postData = parameters.data(using: .utf8)
                
                // Use the serverURL passed as a parameter
                var request = URLRequest(url: serverURL, timeoutInterval: Double.infinity)
                request.addValue("Bearer \(UserSession.shared.user?.jwt_token ?? "")", forHTTPHeaderField: "Authorization")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = postData
                
                // Create the data task
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    // Ensure to capture errors and data correctly
                    guard let data = data else {
                        DispatchQueue.main.async {
                            completionBlock("Error: \(String(describing: error))")
                        }
                        return
                    }
                    
                    // Print the server response for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    
                    // Call the completion block safely on the main thread
                    DispatchQueue.main.async {
                        completionBlock("Success")
                    }
                }
                
                task.resume() // Start the network task
            } else {
                print("Failed to fetch country and state.")
                DispatchQueue.main.async {
                    completionBlock("Failed to fetch country and state.")
                }
            }
        }
    }


}

// Extension to fetch file size from URL
extension URL {
    func fileSize() -> UInt64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: self.path)
            if let size = attributes[.size] as? UInt64 {
                return size
            }
        } catch {
            print("Error fetching file size: \(error)")
        }
        return 0 // Return 0 if unable to fetch size
    }
}

// Dummy UserSession and Config classes to simulate user data
class UserSession {
    nonisolated(unsafe) static let shared = UserSession()
    
    func getAddress() -> String {
        return "Some Address"
    }
    
    func getZipCode() -> String {
        return "12345"
    }
    
    func getGender() -> String {
        return "Male"
    }
    
    func getDOB() -> String {
        return "1990-01-01"
    }
    
    var user: User? {
        return User(uid: 34, jwt_token: "someJwtToken")
    }
    
    func fetchCountryAndStateNameFromAddress(address: String, completion: @escaping (String?, String?) -> Void) {
        // Simulate fetching country and state from an address
        completion("USA", "California")
    }
}

class User {
    var uid: Int
    var jwt_token: String
    
    init(uid: Int, jwt_token: String) {
        self.uid = uid
        self.jwt_token = jwt_token
    }
}

class Config {
    static let dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// Dummy function to calculate age
func getAge(dateString: String) -> Int {
    // Implement actual age calculation from DOB string
    return 30
}
