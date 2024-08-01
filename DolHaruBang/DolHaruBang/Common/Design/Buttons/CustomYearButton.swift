//
//  CustomYearButton.swift
//  DolHaruBang
//
//  Created by 안상준 on 7/30/24.
//

import SwiftUI
import UIKit

struct CustomYearButton: UIViewRepresentable {
    class Coordinator: NSObject {
        var parent: CustomYearButton

        init(parent: CustomYearButton) {
            self.parent = parent
        }

        @objc func buttonTapped() {
            parent.isPresented = true
        }
    }

    @Binding var selectedYear: Int?
    @Binding var isPresented: Bool
    var font: Font
    var textColor: UIColor?
    var action: () -> Void = {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(selectedYear != nil ? "\(selectedYear!)" : "년", for: .normal)
        button.titleLabel?.font = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: defaultTextSize)
        button.setTitleColor(textColor ?? UIColor(Color.mainBlack), for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 24

        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.setTitle(selectedYear != nil ? "\(selectedYear!)" : "년", for: .normal)
        uiView.titleLabel?.font = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: defaultTextSize)
        uiView.setTitleColor(textColor ?? UIColor(Color.mainBlack), for: .normal)
    }
}

struct YearPicker: View {
    @Binding var selectedYear: Int
    @Binding var isPresented: Bool
    var years: [Int]
    var onSelect: () -> Void

    var body: some View {
        VStack {
            Text("태어난 년도를 골라주세요!")
                .font(.customFont(Font.h6))
                .padding()
            
            Picker("Select Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text("\(year)").tag(year)
                }
            }
            .pickerStyle(WheelPickerStyle())

            Button("선택") {
                onSelect()
                isPresented = false
            }
            .font(.customFont(Font.h7))
            .tint(.coreGreen)
            .padding()
        }
    }
}

