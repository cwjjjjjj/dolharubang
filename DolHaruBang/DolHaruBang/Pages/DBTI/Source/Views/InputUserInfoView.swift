import SwiftUI
import ComposableArchitecture

struct InputUserInfoView: View {
    let store: StoreOf<DBTIFeature>
    @FocusState private var isUsernameFieldFocused: Bool
    
    // 현재 날짜 (년/일/월 + 날 수)
    var currentYear: Int { Calendar.current.component(.year, from: Date()) }
    var currentMonth: Int { Calendar.current.component(.month, from: Date()) }
    var currentDay: Int { Calendar.current.component(.day, from: Date()) }
    
    var days: [Int] {
        if store.selectedYear == currentYear && store.selectedMonth == currentMonth {
            return Array(1...currentDay)
        } else if let year = store.selectedYear, let month = store.selectedMonth {
            let dateComponents = DateComponents(year: year, month: month)
            let date = Calendar.current.date(from: dateComponents)!
            let range = Calendar.current.range(of: .day, in: .month, for: date)!
            return Array(range)
        } else {
            return Array(1...31)
        }
    }
    
    var isFormComplete: Bool {
        store.isNameConfirmed && store.selectedYear != nil && store.selectedMonth != nil && store.selectedDay != nil
    }
    
    var body: some View {
        ZStack {
            Color.mainWhite
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack (alignment: .center, spacing: 0){
                    Spacer().frame(height: geometry.size.height * 0.2892)
                    
                    HStack {
                        Spacer()
                        CustomText(text: "돌하루방에서 사용할\n닉네임을 정하고\n생일을 입력해주세요.", font: Font.uiFont(for: Font.subtitle2)!, textColor: .coreBlack)
                            .frame(width: 187, height: 87)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }.padding(.bottom, 33)
                    
                    HStack {
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.coreLightGray)
                            .font(.system(size: 24))
                            .padding(.bottom, 72)
                        Spacer()
                    }
                    
                    HStack {
                        CustomTextField(
                            text: Binding(
                                get: { store.username },
                                set: { store.send(.setUsername($0)) }
                            ),
                            placeholder: "닉네임",
                            font: .customFont(Font.button1),
                            maxLength: 12,
                            alertTitle: "글자 수 오류",
                            alertMessage: "닉네임은 1~6자로 입력해주세요.",
                            onSubmit: { store.send(.checkUsername) }
                        )
                        .frame(width: 210, height: 48)
                        .alert(isPresented: Binding(
                                    get: { store.showAlert },
                                    set: { store.send(.setShowAlert($0)) }
                                )) {
                                    if store.showConfirmation {
                                        return Alert(
                                            title: Text(store.inputAlertTitle),
                                            message: Text(store.inputAlertMessage),
                                            primaryButton: .default(Text("네"), action: {
                                                isUsernameFieldFocused = false
                                                store.send(.setIsNameConfirmed(true))
                                            }),
                                            secondaryButton: .cancel(Text("아니요")) {
                                                store.send(.setUsername(""))
                                            }
                                        )
                                    } else {
                                        return Alert(
                                            title: Text(store.inputAlertTitle),
                                            message: Text(store.inputAlertMessage),
                                            dismissButton: .default(Text("OK"))
                                        )
                                    }
                                }
                        .cornerRadius(24)
                        
                        Spacer().frame(width: 10)
                        
                        CustomButton(
                            title: "중복확인",
                            font: .customFont(Font.button1),
                            textColor: .coreWhite,
                            action: { store.send(.checkUsername) }
                        )
                        .frame(width: 100, height: 48)
                        .background(store.username.isEmpty ? Color.disabled : Color.mainGreen)
                        .cornerRadius(24)
                        .disabled(store.username.isEmpty)
                        .onTapGesture { store.send(.checkUsername) }
                    }
                    
                    Spacer().frame(height: 16)
                    
                    HStack {
                        CustomYearButton(
                            selectedYear: Binding(
                                get: { store.selectedYear },
                                set: { store.send(.setSelectedYear($0)) }
                            ),
                            isPresented: Binding(
                                get: { store.showYearPicker },
                                set: { store.send(.setShowYearPicker($0)) }
                            ),
                            font: .customFont(Font.button1)
                        )
                        .background(Color.mainGray)
                        .frame(width: 100, height: 48)
                        .cornerRadius(24)
                        .onTapGesture { store.send(.setShowYearPicker(true)) }
                        .sheet(isPresented: Binding(
                            get: { store.showYearPicker },
                            set: { store.send(.setShowYearPicker($0)) }
                        )) {
                            YearPicker(
                                selectedYear: Binding(
                                    get: { store.selectedYear ?? 2025 },
                                    set: { store.send(.setSelectedYear($0)) }
                                ),
                                isPresented: Binding(
                                    get: { store.showYearPicker },
                                    set: { store.send(.setShowYearPicker($0)) }
                                ),
                                years: Array(1900...currentYear)
                            ) {
                                store.send(.setSelectedMonth(nil))
                                store.send(.setSelectedDay(nil))
                            }
                        }
                        
                        CustomMonthButton(
                            selectedMonth: Binding(
                                get: { store.selectedMonth },
                                set: { store.send(.setSelectedMonth($0)) }
                            ),
                            isPresented: Binding(
                                get: { store.showMonthPicker },
                                set: { store.send(.setShowMonthPicker($0)) }
                            ),
                            font: .customFont(Font.button1)
                        )
                        .background(Color.mainGray)
                        .frame(width: 100, height: 48)
                        .cornerRadius(24)
                        .onTapGesture { store.send(.setShowMonthPicker(true)) }
                        .sheet(isPresented: Binding(
                            get: { store.showMonthPicker },
                            set: { store.send(.setShowMonthPicker($0)) }
                        )) {
                            let months = (store.selectedYear == currentYear) ? Array(1...currentMonth) : Array(1...12)
                            MonthPicker(
                                selectedMonth: Binding(
                                    get: { store.selectedMonth ?? 1 },
                                    set: { store.send(.setSelectedMonth($0)) }
                                ),
                                isPresented: Binding(
                                    get: { store.showMonthPicker },
                                    set: { store.send(.setShowMonthPicker($0)) }
                                ),
                                months: months
                            ) {
                                store.send(.setSelectedDay(nil))
                            }
                        }
                        
                        CustomDayButton(
                            selectedDay: Binding(
                                get: { store.selectedDay },
                                set: { store.send(.setSelectedDay($0)) }
                            ),
                            isPresented: Binding(
                                get: { store.showDayPicker },
                                set: { store.send(.setShowDayPicker($0)) }
                            ),
                            font: .customFont(Font.button1)
                        )
                        .background(Color.mainGray)
                        .frame(width: 100, height: 48)
                        .cornerRadius(24)
                        .onTapGesture { store.send(.setShowDayPicker(true)) }
                        .sheet(isPresented: Binding(
                            get: { store.showDayPicker },
                            set: { store.send(.setShowDayPicker($0)) }
                        )) {
                            DayPicker(
                                selectedDay: Binding(
                                    get: { store.selectedDay ?? 1 },
                                    set: { store.send(.setSelectedDay($0)) }
                                ),
                                isPresented: Binding(
                                    get: { store.showDayPicker },
                                    set: { store.send(.setShowDayPicker($0)) }
                                ),
                                days: days
                            )
                        }
                    }
                    
                    Spacer().frame(height: 40)
                    
                    HStack {
                        NavigationLink(state: NavigationFeature.Path.State.DBTIGuideView(store.state)) {
                            ZStack {
                                HStack {
                                    Spacer()
                                    Text("완료")
                                        .font(.customFont(Font.button1))
                                        .foregroundColor(.mainWhite)
                                    Spacer()
                                }
                            }
                        }
                        .frame(width: 320, height: 48)
                        .background(isFormComplete ? Color.mainGreen : Color.disabled)
                        .cornerRadius(24)
                        .disabled(!isFormComplete)
//                        .simultaneousGesture(TapGesture().onEnded {
//                            if isFormComplete {
//
//                            }
//                        })
                    }
                    
                    Spacer()
                }
            }
            .alert(isPresented: Binding(
                get: { store.showAlert },
                set: { store.send(.setShowAlert($0)) }
            )) {
                // 중복 check 결과에 따라서 다르게!
                if store.showConfirmation {
                    return Alert(
                        title: Text(store.inputAlertTitle),
                        message: Text(store.inputAlertMessage),
                        primaryButton: .default(Text("네"), action: {
                            store.send(.setIsNameConfirmed(true))
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }),
                        secondaryButton: .cancel(Text("아니요")) {
                            store.send(.setUsername(""))
                        }
                    )
                } else {
                    return Alert(
                        title: Text(store.inputAlertTitle),
                        message: Text(store.inputAlertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        
                    }) {
                        Text("로그아웃")
                            .font(.customFont(Font.body3Regular))
                            .foregroundColor(.mainBlue)
                    }
                }
                .offset(x: 8, y: 8)
            }
        }
    }
}
