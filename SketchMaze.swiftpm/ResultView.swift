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
            VStack {
                Text("You've collected all apples!!!")
                    .font(.largeTitle)
                HStack {
                    ForEach([Item.astronomy, Item.atom, Item.electricity, Item.fluid], id: \.self) { item in
                        ZStack {
                            Button {
                                selectedItem = item
                                showExplanation = true
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
                HStack {
                    ForEach([Item.gravity, Item.magnet, Item.sound, Item.wave], id: \.self) { item in
                        ZStack {
                            Button {
                                selectedItem = item
                                showExplanation = true
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
            VStack {
                Image(selectedItem.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                Text(selectedItem.displayName)
                    .font(.title)
                    .bold()
                Text(selectedItem.description)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .regular))
                    .ignoresSafeArea()
            )
            .onTapGesture {
                showExplanation = false
            }
            .opacity(showExplanation ? 1 : 0)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(collectedItems: [.magnet, .astronomy])
    }
}
