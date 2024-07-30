import SwiftUI

struct InputUserInfoView: View {
    @State var name: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showConfirmation: Bool = false

    @State private var isNameConfirmed: Bool = false // 닉네임 중복 확인 여부를 추적하는 상태 변수

    @State private var selectedYear: Int = 2023
    @State private var showYearPicker: Bool = false

    @State private var selectedMonth: Int = 1
    @State private var showMonthPicker: Bool = false

    @State private var selectedDay: Int = 1
    @State private var showDayPicker: Bool = false

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }
    
    var currentDay: Int {
        Calendar.current.component(.day, from: Date())
    }
    
    var days: [Int] {
        if selectedYear == currentYear && selectedMonth == currentMonth {
            return Array(1...currentDay)
        } else {
            let dateComponents = DateComponents(year: selectedYear, month: selectedMonth)
            let date = Calendar.current.date(from: dateComponents)!
            let range = Calendar.current.range(of: .day, in: .month, for: date)!
            return Array(range)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        Text("돌하루방에서 사용할\n닉네임을 정하고\n생일을 입력해주세요.")
                            .font(.customFont(Font.subtitle2))
                            .foregroundColor(.mainBlack)
                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.top, 50)
                            .padding(.bottom, 50)
                        
                        Spacer()
                        
                        HStack {
                            CustomTextField(
                                text: $name,
                                placeholder: "닉네임",
                                font: .customFont(Font.button1)
                            )
                            .frame(width: geometry.size.width * 0.6, height: 48)
                            .cornerRadius(24)
                            
                            CustomButton(
                                title: "중복확인",
                                font: .customFont(Font.button1),
                                textColor: .white,
                                action: {
                                    checkUsername()
                                }
                            )
                            .background(name.isEmpty ? Color.disabled : Color.mainGreen)
                            .frame(width: geometry.size.width * 0.25, height: 48)
                            .cornerRadius(24)
                            .disabled(name.isEmpty)
                            .onTapGesture {
                                checkUsername()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        HStack {
                            CustomYearButton(
                                selectedYear: $selectedYear,
                                isPresented: $showYearPicker,
                                font: .customFont(Font.button1)
                            )
                            .background(Color.mainGray)
                            .frame(width: geometry.size.width * 0.27, height: 48)
                            .cornerRadius(24)
                            .onTapGesture {
                                self.showYearPicker = true
                            }
                            .sheet(isPresented: $showYearPicker) {
                                YearPicker(selectedYear: $selectedYear, isPresented: $showYearPicker, years: Array(1900...currentYear)) {
                                    self.selectedMonth = 1
                                    self.selectedDay = 1
                                }
                            }
                            
                            CustomMonthButton(
                                selectedMonth: $selectedMonth,
                                isPresented: $showMonthPicker,
                                font: .customFont(Font.button1)
                            )
                            .background(Color.mainGray)
                            .frame(width: geometry.size.width * 0.27, height: 48)
                            .cornerRadius(24)
                            .onTapGesture {
                                self.showMonthPicker = true
                            }
                            .sheet(isPresented: $showMonthPicker) {
                                let months = selectedYear == currentYear ? Array(1...currentMonth) : Array(1...12)
                                MonthPicker(selectedMonth: $selectedMonth, isPresented: $showMonthPicker, months: months) {
                                    self.selectedDay = 1
                                }
                            }
                            
                            CustomDayButton(
                                selectedDay: $selectedDay,
                                isPresented: $showDayPicker,
                                font: .customFont(Font.button1)
                            )
                            .background(Color.mainGray)
                            .frame(width: geometry.size.width * 0.27, height: 48)
                            .cornerRadius(24)
                            .onTapGesture {
                                self.showDayPicker = true
                            }
                            .sheet(isPresented: $showDayPicker) {
                                DayPicker(selectedDay: $selectedDay, isPresented: $showDayPicker, days: days)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        HStack {
                            NavigationLink(destination: DBTIGuideView()) {
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
                            .frame(width: min(geometry.size.width * 0.9, 450), height: 48)
                            .background(isNameConfirmed ? Color.mainGreen : Color.disabled) // 닉네임 중복 확인이 완료되었을 때만 활성화
                            .cornerRadius(24)
                            .disabled(!isNameConfirmed) // 닉네임 중복 확인이 완료되었을 때만 활성화
                        }
                        
                        Spacer()
                    }
                }
                .alert(isPresented: $showAlert) {
                    if showConfirmation {
                        return Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            primaryButton: .default(Text("Confirm"), action: {
                                isNameConfirmed = true // 닉네임 중복 확인 완료
                            }),
                            secondaryButton: .cancel()
                        )
                    } else {
                        return Alert(
                            title: Text(alertTitle),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .contentShape(Rectangle()) // Make the entire view tappable
                .onTapGesture {
                    self.hideKeyboard()
                }
            }
        }
    }

    func checkUsername() {
        let existingUsernames = ["상준", "희태", "우진", "성재", "영규", "해인"]
        
        if existingUsernames.contains(name) {
            alertTitle = "닉네임 중복"
            alertMessage = "이 닉네임은 이미 사용 중입니다. 다른 닉네임을 선택해주세요."
            showConfirmation = false
            isNameConfirmed = false // 닉네임 중복 확인 실패
        } else {
            alertTitle = "닉네임 사용 가능"
            alertMessage = "\(name)으로 하시겠습니까?"
            showConfirmation = true
        }
        
        showAlert = true
    }
}

struct InputUserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        InputUserInfoView()
    }
}
