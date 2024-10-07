import ComposableArchitecture
import Foundation

struct Friend: Identifiable, Equatable {
    let id: UUID
    let nickname: String
    let roomName: String
    let profileImageURL: URL?
}

struct UnsplashPhotoResponse: Codable {
    let urls: PhotoURLs
}

struct PhotoURLs: Codable {
    let small: String
}

enum UnsplashAPIError: Error, CustomStringConvertible {
    case invalidResponse(statusCode: Int, message: String)
    case decodingError(message: String)
    case networkError(Error)

    var description: String {
        switch self {
        case .invalidResponse(let statusCode, let message):
            return "올바르지 않은 응답 - 상태코드 [\(statusCode)] : \(message)"
        case .decodingError(let message):
            return "디코딩 오류: \(message)"
        case .networkError(let error):
            return "네트워크 오류: \(error.localizedDescription)"
        }
    }
}

struct UnsplashAPI {
    static func getRandomImageURL() async throws -> URL? {
        let baseURL = "https://api.unsplash.com/photos/random"
        let clientID = ""
        
        guard let url = URL(string: "\(baseURL)?client_id=\(clientID)") else {
                throw UnsplashAPIError.invalidResponse(statusCode: 0, message: "Invalid URL")
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
    
            print("------------data------------")
            dump(data)
        
            print("------------response------------")
            dump(response)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw UnsplashAPIError.invalidResponse(statusCode: 0, message: "Not an HTTP response")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let message = String(data: data, encoding: .utf8) ?? "No error message"
                throw UnsplashAPIError.invalidResponse(statusCode: httpResponse.statusCode, message: message)
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(UnsplashPhotoResponse.self, from: data)
                print("decodedResponse")
                dump(decodedResponse)
                return URL(string: decodedResponse.urls.small)
            } catch {
                throw UnsplashAPIError.decodingError(message: error.localizedDescription)
            }
    }
}

@Reducer
struct FriendListFeature {
  
    @ObservableState
    struct State: Equatable {
        var searchKeyword: String = ""
        var friendsList: [Friend] = []
        var isLoading: Bool = true
    }

    // 액션 정의
    enum Action: BindableAction {
        case loadFriends
        case friendsLoaded([Friend])
        case binding(BindingAction<State>)
    }

    // 리듀서 정의
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
                case .binding(\.searchKeyword):
//                   print ("writing searchKeyword: " , state.searchKeyword)
                   return .none
                case .binding:
                    return .none
                
                    // 미리보기용
//                case .loadFriends:
//                    state.isLoading = true
//                    return .run { send in
//                        do {
//                            var dummyFriends = [Friend]()
//                            for i in 0..<6 {
//                                let imageURL = try await UnsplashAPI.getRandomImageURL()
//                                let friend = Friend(
//                                    id: UUID(),
//                                    nickname: ["해인", "우진", "희태", "상준", "성재", "영규"][i],
//                                    roomName: ["돌돌이방", "돌돌이의 방", "돌멩이네", "돌봄방", "돌핀", "돌다리"][i],
//                                    profileImageURL: imageURL
//                                )
//                                dummyFriends.append(friend)
//                            }
//                            await send(.friendsLoaded(dummyFriends))
//                        } catch {
//                            print("Error loading friends: \(error)")
//                            await send(.friendsLoaded([]))
//                        }
//                    }
                
                    // 테스트용! (50개 limit 때문에 1개만 되는 지 테스트!)
                case .loadFriends:
                    state.isLoading = true
                    return .run { send in
                        do {
                            var dummyFriends = [Friend]()
                            // 첫 번째 이미지만 API에서 가져옴
                            let firstImageURL = try await UnsplashAPI.getRandomImageURL()
                            
                            for i in 0..<6 {
                                let imageURL: URL?
                                if i == 0 {
                                    imageURL = firstImageURL
                                } else {
                                    imageURL = nil // 나머지는 빈 URL
                                }
                                
                                let friend = Friend(
                                    id: UUID(),
                                    nickname: ["해인", "우진", "희태", "상준", "성재", "영규"][i],
                                    roomName: ["돌돌이방", "돌돌이의 방", "돌멩이네", "돌봄방", "돌핀", "돌다리"][i],
                                    profileImageURL: imageURL
                                )
                                dummyFriends.append(friend)
                            }
                            await send(.friendsLoaded(dummyFriends))
                        } catch let unsplashError as UnsplashAPIError {
                            print("Unsplash API Error: \(unsplashError)")
                            // API 오류 발생 시에도 더미 데이터를 생성하여 UI에 표시
                            let dummyFriends = (0..<6).map { i in
                                Friend(
                                    id: UUID(),
                                    nickname: ["해인", "우진", "희태", "상준", "성재", "영규"][i],
                                    roomName: ["돌돌이방", "돌돌이의 방", "돌멩이네", "돌봄방", "돌핀", "돌다리"][i],
                                    profileImageURL: nil
                                )
                            }
                            await send(.friendsLoaded(dummyFriends))
                        } catch {
                            print("Unknown error: \(error)")
                            await send(.friendsLoaded([]))
                        }
                    }
                    
                case let .friendsLoaded(loadedFriends):
                    state.friendsList = loadedFriends
                    state.isLoading = false
                    return .none
            }
        }
    }
}
