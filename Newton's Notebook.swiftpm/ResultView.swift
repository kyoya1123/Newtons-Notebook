//
//  ResultView.swift
//  SketchMaze
//
//  Created by Kyoya Yamaguchi on 2023/04/18.
//

import UIKit
import SwiftUI

struct ResultView: View {

    var collectedItems: [Item]
    @State var selectedItem = Item.atom
    @State var showExplanation = false

    var body: some View {
        ZStack {
            Image("note")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            VStack {
                Text("🎉 You've collected all of the fallen apples!! 🎉")
                    .font(.largeTitle)
                    .bold()
                Image("basketWithApple")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                Spacer()
                    .frame(maxHeight: 50)
                Text("Learn more about physics")
                    .font(.title)
                    .bold()
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach(Item.firstFourItems, id: \.self) { item in
                            ZStack {
                                Button {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        selectedItem = item
                                        showExplanation = true
                                    }
                                } label: {
                                    Image(item.rawValue)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                }
                                .opacity(collectedItems.contains(item) ? 1 : 0)
                                Image(item.rawValue)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .opacity(0.2)
                            }
                        }
                    }
                    HStack(spacing: 8) {
                        ForEach(Item.lastFourItems, id: \.self) { item in
                            ZStack {
                                Button {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        selectedItem = item
                                        showExplanation = true
                                    }
                                } label: {
                                    Image(item.rawValue)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                }
                                .opacity(collectedItems.contains(item) ? 1 : 0)
                                Image(item.rawValue)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .opacity(0.2)
                            }
                        }
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.accentColor.opacity(0.2))
                )
            }
            HStack {
                Spacer(minLength: 200)
                VStack(spacing: 32) {
                    Image(selectedItem.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    Text(selectedItem.displayName)
                        .font(.title)
                        .bold()
                    Text(selectedItem.description)
                        .font(.title2)
                }
                Spacer(minLength: 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .regular))
                    .ignoresSafeArea()
            )
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.2)) {
                    showExplanation = false
                }
            }
            .opacity(showExplanation ? 1 : 0)
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(collectedItems: [.magnet, .astronomy])
    }
}
