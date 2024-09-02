//
//  Demo.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/2/24.
//

import SwiftUI
import ComposableArchitecture

struct Demo<State, Action, Content: View>: View {
  @SwiftUI.State var store: Store<State, Action>
  let content: (Store<State, Action>) -> Content

  init(
    store: Store<State, Action>,
    @ViewBuilder content: @escaping (Store<State, Action>) -> Content
  ) {
    self.store = store
    self.content = content
  }

  var body: some View {
    content(store)
  }
}
