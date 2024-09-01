//
//  CustomDayButton.swift
//  DolHaruBang
//
//  Created by 안상준 on 7/30/24.
//

import SwiftUI
import UIKit

struct CustomDayButton: UIViewRepresentable {
    class Coordinator: NSObject {
        var parent: CustomDayButton

        init(parent: CustomDayButton) {
            self.parent = parent
        }

        @objc func buttonTapped() {
            parent.isPresented = true
        }
    }

    @Binding var selectedDay: Int?
    @Binding var isPresented: Bool
    var font: Font
    var textColor: UIColor?
    var action: () -> Void = {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(selectedDay != nil ? "\(selectedDay!)" : "일", for: .normal)
        button.titleLabel?.font = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        button.setTitleColor(textColor ?? UIColor(Color.black), for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 8

        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.setTitle(selectedDay != nil ? "\(selectedDay!)" : "일", for: .normal)
        uiView.titleLabel?.font = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        uiView.setTitleColor(textColor ?? UIColor(Color.black), for: .normal)
    }
}

struct DayPicker: View {
    @Binding var selectedDay: Int
    @Binding var isPresented: Bool
    var days: [Int]

    var body: some View {
        VStack {
            Text("태어난 일을 골라주세요!")
                .font(.customFont(Font.h6))
                .padding()
            
            Picker("selectedDay", selection: $selectedDay) {
                ForEach(days, id: \.self) { day in
                    Text("\(day)").tag(day)
                }
            }
            .pickerStyle(WheelPickerStyle())

            Button("선택") {
                isPresented = false
            }
            .font(.customFont(Font.h7))
            .tint(.coreGreen)
            .padding()
        }
    }
}

