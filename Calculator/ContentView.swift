//
//  ContentView.swift
//  Calculator
//
//  Created by lpy on 2023/10/1.
//

import SwiftUI

enum enumButtons: String {
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case zero = "0"
    case decimal = "."
    case addition = "➕"
    case subtract = "➖"
    case multiply = "✖️ "
    case divide = "➗"
    case clear = "AC"
    case equal = "🟰"
    
    var ButtonColor: Color {
        switch self{
        case .addition, .subtract, .multiply, .divide, .equal:
            return .orange
        case .clear:
            return .gray
        default:
            return .green
        }
    }
}

enum enumOperation {
    case addition, subtract, multiply, divide, equal, none
}

struct ContentView: View {
    
    @State var CurrentValue = ""
    @State var RunningValue = ""
    @State var CurrentOperation = enumOperation.none
    @State var AllClear:Bool = true
    @State var onedecimal:Bool = false
    @State var caninputzero = false
    
    let Buttons: [[enumButtons]] =
    [
        [.clear, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .addition],
        [.zero, .decimal, .equal]
    ]
    
    var body: some View {
        ZStack() {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            VStack {
                Spacer()
                //计算数值显示
                //--------------------------------------------------------
                HStack {
                    Spacer()
                    if AllClear == true {                    //在按下Clear后需要显示0，而不是RunningValue
                        Text("0")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .bold()
                    }
                    else {
                        Text((CurrentValue == "") ? OutputNumber(Value: RunningValue) : OutputNumber(Value: CurrentValue))
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                .padding(16)
                //---------------------------------------------------
                
                //按钮显示
                //---------------------------------------------------
                ForEach(Buttons, id: \.self) { row in
                    HStack() {
                        ForEach(row, id: \.self) { item in   //枚举所有按钮item
                            Button(action: {                 //使用Button封装
                                TapButton(button: item)      //按下按钮后的逻辑
                            }, label: { //按钮UI
                                Text(item.rawValue)
                                    .bold()
                                    .font(.system(size: 45))
                                    .frame(
                                        width: getwidth(item: item),
                                        height: getheight(item: item)
                                    )
                                    .background(item.ButtonColor)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 40, height: 40)))
                                    //.border(.white)
                            })
                        }
                    }
                    //.padding(.bottom)
                }
                //--------------------------------------------------------
            }
        }
    }
    
    func OutputNumber(Value: String) -> String {
        //不完整数据，如12.，直接返回
        if Value[Value.index(before: Value.endIndex)] == "." {
            return Value
        }
        
        //只保留六位小数
        let value = Double(Value) ?? 0
        var Result = String(format: "%.10f",value)
        
        //删除多余零
        var metdecimal:Bool = false
        for character in Result {
            if character == "." {
                metdecimal = true
                break
            }
        }
        if !metdecimal {
            return Result
        }
        while Result[Result.index(before: Result.endIndex)] == "0" {
            Result.removeLast()
        }
        if Result[Result.index(before: Result.endIndex)] == "." {
            Result.removeLast()
        }
        return Result
    }
    
    func DoOneCalculation() {
        if CurrentOperation == .addition {
            CurrentValue = String((Double(RunningValue) ?? 0) + (Double(CurrentValue) ?? 0))
        }
        if CurrentOperation == .subtract {
            CurrentValue = String((Double(RunningValue) ?? 0) - (Double(CurrentValue) ?? 0))
        }
        if CurrentOperation == .multiply {
            CurrentValue = String((Double(RunningValue) ?? 0) * (Double(CurrentValue) ?? 0))
        }
        if CurrentOperation == .divide {
            CurrentValue = String((Double(RunningValue) ?? 0) / (Double(CurrentValue) ?? 0))
        }
    }
    
    func updatecurrentoperation(button: enumButtons) {
        if button == .addition {
            CurrentOperation = .addition
        }
        else if button == .subtract {
            CurrentOperation = .subtract
        }
        else if button == .multiply {
            CurrentOperation = .multiply
        }
        else if button == .divide {
            CurrentOperation = .divide
        }
        else if button == .equal {
            CurrentOperation = .equal
        }
    }
    
    func TapButton(button: enumButtons) {
        switch button {
        case .addition, .subtract, .multiply, .divide, .equal:
            AllClear = false                      //暴力更新按下了其他键后，不需要再显示一个零
            if CurrentOperation != .none {
                if CurrentValue == "" {
                    updatecurrentoperation(button: button)
                    return
                }
                DoOneCalculation()
            }
            RunningValue = (CurrentValue == "") ? "0": CurrentValue
            CurrentValue = ""
            updatecurrentoperation(button: button)
            onedecimal = false
            caninputzero = false
        case .decimal:
            AllClear = false                 //暴力更新按下了其他键后，不需要再显示一个零
            if onedecimal {
                return;
            }
            onedecimal = true
            if CurrentValue == "" {
                CurrentValue = "0."
            }
            else {
                CurrentValue += "."
            }
            caninputzero = true
        case .clear:
            CurrentValue = ""
            RunningValue = ""
            CurrentOperation = .none
            AllClear = true                  //已经按下了Clear
            onedecimal = false
            caninputzero = false
        default:
            AllClear = false                 //暴力更新按下了其他键后，不需要再显示一个零
            let num = button.rawValue
            if caninputzero {
                CurrentValue = CurrentValue + num
            }
            else {
                if num != "0" {
                    caninputzero = true
                    CurrentValue =  num
                }
                else {
                    CurrentValue = "0"
                }
            }
        }
    }
    
    func getwidth(item: enumButtons) -> CGFloat {
        if item == .zero {
            return CGFloat(Int(UIScreen.main.bounds.width - 50) / 4 * 2)
        }
        if item == .clear {
            return CGFloat(Int(UIScreen.main.bounds.width - 50) / 4 * 3)
        }
        return CGFloat(Int(UIScreen.main.bounds.width - 50) / 4)
    }
    func getheight(item: enumButtons) -> CGFloat {
        return CGFloat(Int(UIScreen.main.bounds.width - 50) / 4)
    }
}

#Preview {
    ContentView()
}

//miemiemie
