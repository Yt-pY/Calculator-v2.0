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
    
    case percent = "％"
    case reverse = "+/-"
    case powhalf = "√x"
    case powneg1 = "1/x"
    case powtwo = "x²"
    case sin = "sin"
    
    case mc = "mc"
    case madd = "m+"
    case msub = "m-"
    case mr = "mr"
    
    var ButtonColor: Color {
        switch self{
        case .addition, .subtract, .multiply, .divide, .equal:
            return .orange
        case .percent, .reverse, .powhalf, .powneg1, .powtwo, .sin:
            return .gray
        case .clear:
            return .purple
        case .mc, .madd, .msub, .mr:
            return .red
        default:
            return .green
        }
    }
}

enum enumOperation {
    case addition, subtract, multiply, divide, equal, none
}

struct ContentView: View {
    
    @AppStorage("CurrentValue") var CurrentValue = ""
    @AppStorage("RunningValue") var RunningValue = ""
    @State var CurrentOperation = enumOperation.none
    @State var AllClear:Bool = false
    @State var onedecimal:Bool = false
    @State var caninputzero = false
    @State var after1op = false
    
    @State var memory:Double = 0
    @State var canrewrite = false
    
    let Buttons: [[enumButtons]] =
    [
        [.mc, .madd, .msub, .mr],
        [.clear, .powtwo, .powhalf, .sin],
        [.powneg1, .reverse, .percent, .divide],
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
                    if AllClear == true || (RunningValue == "" && CurrentValue == ""){                    //在按下Clear后需要显示0，而不是RunningValue
                        Text("0")
                            .font(.system(size: 55))
                            .foregroundColor(.white)
                            .bold()
                    }
                    else {
                        Text((CurrentValue == "") ? OutputNumber(Value: RunningValue) : OutputNumber(Value: CurrentValue))
                            .font(.system(size: 55))
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
                            //Spacer()
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
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 35, height: 35)))
                                    //.border(.white)
                            })
                        }
                        //Spacer()
                    }
                    .padding(.bottom, 1)
                }
                //--------------------------------------------------------
            }
        }
    }
    
    func OutputNumber(Value: String) -> String {
        if Value[Value.index(before: Value.endIndex)] == "." {
            return Value
        }
        if Value[Value.index(before: Value.endIndex)] == "0" && onedecimal {
            return Value
        }
        
        //只保留六位小数
        let value = Double(Value) ?? 0
        var Result = String(format: "%.8f",value)
        
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
            after1op = false
        case .decimal:
            AllClear = false                 //暴力更新按下了其他键后，不需要再显示一个零
            
            if after1op {
                return
            }
            
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
            after1op = false
        case .percent:
            if CurrentValue == "" && RunningValue == "" {
                return
            }
            else if CurrentValue != ""{
                CurrentValue = String((Double(CurrentValue) ?? 0) * 0.01)
            }
            else {
                RunningValue = String((Double(RunningValue) ?? 0) * 0.01)
                CurrentValue = RunningValue
                //RunningValue = ""
                CurrentOperation = .none
            }
            after1op = true
        case .reverse:
            if CurrentValue == "" && RunningValue == "" {
                return
            }
            else if CurrentValue != ""{
                CurrentValue = String(-(Double(CurrentValue) ?? 0))
            }
            else {
                RunningValue = String(-(Double(RunningValue) ?? 0))
                CurrentValue = RunningValue
                //RunningValue = ""
                CurrentOperation = .none
            }
            after1op = true
        case .powhalf:
            if CurrentValue == "" && RunningValue == "" {
                return
            }
            else if CurrentValue != ""{
                CurrentValue = String(sqrt(Double(CurrentValue) ?? 0))
            }
            else {
                RunningValue = String(sqrt(Double(RunningValue) ?? 0))
                CurrentValue = RunningValue
                //RunningValue = ""
                CurrentOperation = .none
            }
            after1op = true
        case .powneg1:
            if CurrentValue == "" && RunningValue == "" {
                return
            }
            else if CurrentValue != ""{
                CurrentValue = String(1.0 / (Double(CurrentValue) ?? 0))
            }
            else {
                RunningValue = String(1.0 / (Double(RunningValue) ?? 0))
                CurrentValue = RunningValue
                //RunningValue = ""
                CurrentOperation = .none
            }
            after1op = true
        case .powtwo:
            if CurrentValue == "" && RunningValue == "" {
                return
            }
            else if CurrentValue != ""{
                CurrentValue = String(pow((Double(CurrentValue) ?? 0), 2))
            }
            else {
                RunningValue = String(pow((Double(RunningValue) ?? 0), 2))
                CurrentValue = RunningValue
                //RunningValue = ""
                CurrentOperation = .none
            }
            after1op = true
        case .sin:
            if CurrentValue == "" && RunningValue == "" {
                return
            }
            else if CurrentValue != ""{
                CurrentValue = String(sin((Double(CurrentValue) ?? 0) * acos(-1) / 180))
            }
            else {
                RunningValue = String(sin((Double(RunningValue) ?? 0) * acos(-1) / 180))
                CurrentValue = RunningValue
                //RunningValue = ""
                CurrentOperation = .none
            }
            after1op = true
        
        case .mc:
            memory = 0
        case .madd:
            if CurrentValue == "" {
                memory += Double(RunningValue) ?? 0
            }
            else {
                memory += Double(CurrentValue) ?? 0
            }
        case .msub:
            if CurrentValue == "" {
                memory -= Double(RunningValue) ?? 0
            }
            else {
                memory -= Double(CurrentValue) ?? 0
            }
        case .mr:
            AllClear = false
            if RunningValue != "" && CurrentValue == "" && CurrentOperation == .equal {
                RunningValue = String(memory)
            }
            else {
                CurrentValue = String(memory)
            }
            canrewrite = true
        default:
            AllClear = false                 //暴力更新按下了其他键后，不需要再显示一个零
            
            if after1op {
                return;
            }
            
            if canrewrite {
                CurrentValue = button.rawValue
                canrewrite = false
                return
            }
            
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
            return CGFloat((UIScreen.main.bounds.width - 60) / 4 * 2 + 7)
        }
        return CGFloat((UIScreen.main.bounds.width - 60) / 4)
    }
    func getheight(item: enumButtons) -> CGFloat {
        return CGFloat((UIScreen.main.bounds.height - 380) / 7)
    }
}

#Preview {
    ContentView()
}
