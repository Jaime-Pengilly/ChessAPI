//
//  ContentView.swift
//  CoolChessAPI
//
//  Created by PENGILLY, JAIME on 4/15/24.
//

import SwiftUI



struct User: Codable {
    let main: Main
    let name: String

    struct Main: Codable {
        let temp: Double
    }

    private enum CodingKeys: String, CodingKey {
        case main, name
    }
}


struct Result: Codable {
    var items: User
}

struct ContentView: View {
    @State var user = User(main: User.Main(temp: 0.0), name: "")
    @State var searchText = ""
    @State var api_key = "42da2bce0e78133bf8511ed50e693b10"
    
    
    var body: some View {
        NavigationStack{
            TextField("", text: $searchText)
            Button(action: {
                Task {
                    try await getUsers()
                }
            }, label: {Text("Button")})
                VStack{
//                    Link(destination:URL(string:user.url ?? URL(""))){
                        
                        HStack(alignment:.top){
                            AsyncImage(url:URL(string: user.name)){ response
                                in
                                switch response {
                                case .success(let image):
                                    image.resizable()
                                        .frame(width:50, height: 50)
                                default:
                                    Image(systemName:"nosign")
                            }
                        }
                        VStack(alignment: .leading) {
//                            Text(user.temp)
                            Text("\(user.name)")
                                .font(.system(size:11))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
//                }
        }.searchable(text:$searchText)
            .onSubmit(of: .search){
                Task {
                    try await getUsers()
                }
        }
    }
    
    
    func getUsers() async throws {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSearchText.isEmpty else {
            return
        }
        guard let apiURL =
            URL(string: "https://api.openweathermap.org/data/2.5/weather?zip=\(trimmedSearchText),us&appid=\(api_key)&units=imperial") else{
            throw UserError.invalidURL
        }
            var request = URLRequest(url:apiURL)
            request.httpMethod = "GET"
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let user = try JSONDecoder().decode(User.self, from: data)
            print(user)
        } catch let decodingError {
            print("Decoding Error:", decodingError)
        } catch {
            print("Error:", error)
            throw error
        }
                
        
                //                print(error)
                
                
                
            }
        
    }
    enum UserError: Error {
        case invalidURL
        case decodingFailed
    }


#Preview {
    ContentView()
}
