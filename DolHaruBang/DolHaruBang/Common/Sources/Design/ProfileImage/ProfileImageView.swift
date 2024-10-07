//
//  ProfileImageView.swift
//  DolHaruBang
//
//  Created by 안상준 on 10/7/24.
//

import SwiftUI

struct ProfileImageView: View {
    let imageURL: URL?
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(.coreGray)
                    .shimmering()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(.coreGray)
            @unknown default:
                EmptyView()
            }
        }
    }
}
