import SwiftUI
import ComposableArchitecture

struct InputUserInfoView: View {
    @EnvironmentObject var userManager: UserManager // 닉네임 전역변수로 기억
    @Environment(\.presentationMode) var presentationMode // 뒤로가기 동작을 위한 환경 변수
    
    @State var name: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showConfirmation: Bool = false

    @State private var isNameConfirmed: Bool = false // 닉네임 중복 확인 여부를 추적하는 상태 변수
    
    // 모든 입력이 완료되었는지 확인하는 변수
    var isFormComplete: Bool {
        return isNameConfirmed && selectedYear != nil && selectedMonth != nil && selectedDay != nil
    }

    @State private var selectedYear: Int?
    @State private var showYearPicker: Bool = false

    @State private var selectedMonth: Int?
    @State private var showMonthPicker: Bool = false

    @State private var selectedDay: Int?
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
                            text: $name,
//                            textColor: .coreGreen,
                            placeholder: "닉네임",
//                            placeholderColor: ,
                            font: .customFont(Font.button1), maxLength: 12, 
                            alertTitle: "글자 수 오류",
                            alertMessage: "닉네임은 1~6자로 입력해주세요.",
                            onSubmit: {checkUsername()}
                        )
                        .frame(width: 210, height: 48)
                        .cornerRadius(24)
                        
                        Spacer().frame(width: 10)
                        
                        CustomButton(
                            title: "중복확인",
                            font: .customFont(Font.button1),
                            textColor: .coreWhite,
                            action: {
                                checkUsername()
                            }
                        )
                        .frame(width: 100, height: 48)
                        .background(name.isEmpty ? Color.disabled : Color.mainGreen)
                        .cornerRadius(24)
                        .disabled(name.isEmpty)
                        .onTapGesture {
                            checkUsername()
                        }
                    }
                    
                    Spacer().frame(height: 16)
                    
                    HStack {
                        CustomYearButton(
                            selectedYear: $selectedYear,
                            isPresented: $showYearPicker,
                            font: .customFont(Font.button1)
                        )
                        .background(Color.mainGray)
                        .frame(width: 100, height: 48)
                        .cornerRadius(24)
                        .onTapGesture {
                            self.showYearPicker = true
                        }
                        .sheet(isPresented: $showYearPicker) {
                            YearPicker(
                                selectedYear: Binding(
                                    get: { selectedYear ?? 2024 },
                                    set: { newValue in selectedYear = newValue }
                                ),
                                isPresented: $showYearPicker,
                                years: Array(1900...currentYear)
                            ) {
                                self.selectedMonth = nil
                                self.selectedDay = nil
                            }
                        }
                        
                        CustomMonthButton(
                            selectedMonth: $selectedMonth,
                            isPresented: $showMonthPicker,
                            font: .customFont(Font.button1)
                        )
                        .background(Color.mainGray)
                        .frame(width: 100, height: 48)
                        .cornerRadius(24)
                        .onTapGesture {
                            self.showMonthPicker = true
                        }
                        .sheet(isPresented: $showMonthPicker) {
                            let months = (selectedYear == currentYear) ? Array(1...currentMonth) : Array(1...12)
                            MonthPicker(
                                selectedMonth: Binding(
                                    get: { selectedMonth ?? 1 },
                                    set: { newValue in selectedMonth = newValue }
                                ),
                                isPresented: $showMonthPicker,
                                months: months
                            ) {
                                self.selectedDay = nil
                            }
                        }

                        CustomDayButton(
                            selectedDay: $selectedDay,
                            isPresented: $showDayPicker,
                            font: .customFont(Font.button1)
                        )
                        .background(Color.mainGray)
                        .frame(width: 100, height: 48)
                        .cornerRadius(24)
                        .onTapGesture {
                            self.showDayPicker = true
                        }
                        .sheet(isPresented: $showDayPicker) {
                            DayPicker(
                                selectedDay: Binding(
                                    get: { selectedDay ?? 1 },
                                    set: { newValue in selectedDay = newValue }
                                ),
                                isPresented: $showDayPicker,
                                days: days
                            )
                        }

                    }
                    
                    Spacer().frame(height: 40)
                    
                    HStack {
                        NavigationLink(destination: Demo(store: Store(initialState: NavigationFeature.State()) { NavigationFeature() }) { nav in
                            DBTIGuideView( nav: nav)
                        }) {
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
                        .simultaneousGesture(TapGesture().onEnded {
                            if isFormComplete {
                                userManager.nickname = name
//                                print(userManager.nickname ?? "닉네임 세팅 안 됨")
                            }
                        })
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
                            self.hideKeyboard()
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
            .contentShape(Rectangle())
            .onTapGesture {
                self.hideKeyboard()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
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

    func checkUsername() {
        let existingUsernames = ["상준", "희태", "우진", "성재", "영규", "해인"]
        
        if (name == "") {
            alertTitle = "글자 수 오류"
            alertMessage = "닉네임은 1~12자로 입력해주세요."
            showConfirmation = false
            isNameConfirmed = false
        }
        else if existingUsernames.contains(name) {
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
