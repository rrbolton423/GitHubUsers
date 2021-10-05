//
//  ContentView.swift
//  GitHubUsers
//
//  Created by Romell Bolton on 10/5/21.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var networkController = NetworkController()
    @State private var search = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search users", text: $search)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if search.isEmpty {
                    List(networkController.users, id: \.login) { user in
                        Text(user.login)
                    }
                } else {
                    List(networkController.users.filter {
                        $0.login.contains(search.lowercased())
                    }, id: \.login) { user in
                        Text(user.login)
                    }
                }
            }
            .navigationBarTitle("GitHub Users")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Networking
class NetworkController: ObservableObject {
    private var cancellable: AnyCancellable?
    
    let url = URL(string: "https://api.github.com/users")!
    @Published var users = [User(login: "", repos_url: "")]
    
    init() {
        self.cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .decode(type: [User].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .sink(receiveValue: { users in
                self.users = users
            })
    }
}

struct User: Decodable {
    var login: String
    var repos_url: String
}

