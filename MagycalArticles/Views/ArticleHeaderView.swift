//
//  ArticleHeaderView.swift
//  MagycalArticles
//
//  Created by Palla Kumar on 04/12/26.
//


import SwiftUI

struct ArticleHeaderView: View {

    let isGrid: Bool
    let onToggleLayout: () -> Void
    let onSearch: () -> Void

    var body: some View {
        HStack(spacing: 20) {

            Text("Articles")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.black)

            Spacer()

            Button {
                onToggleLayout()
            } label: {
                Image(systemName: isGrid
                      ? "list.bullet"
                      : "square.grid.2x2.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                onSearch()
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Search articles")
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}
