//
//  ContentView.swift
//  Сreation wrapping
//
//  Created by Алексей Ходаков on 21.08.2022.
//

import SwiftUI

// MARK: ContentView
struct ContentView: View {
    
    @State var style: TextStyle = .noStyle
    @StateObject var viewModel = TextFieldViewModel()
    
    var body: some View {
        VStack {
            CustomTextField(viewModel: viewModel)
                .padding()
                .border(.gray)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: CustomTextField
struct CustomTextField: View {
    
    @StateObject var viewModel: TextFieldViewModel
    
    var body: some View {
        return (
            VStack {
                TextField("Введите текст", text: $viewModel.text)
            }
        )
    }
}

class TextFieldViewModel: ObservableObject {
    
    /// Доступные параметры `CodingStyle`
    /// - Parameter style: .camelCase, .kebabCase, .snakeCase
    @CodingStyle(style: .snakeCase) var newText: String = ""
    
    @Published var text = ""
    {
        didSet {
            if oldValue.count > newText.count {
                newText = text
                text = newText
            }
        }
    }
}

// MARK: TextStyle
enum TextStyle {
    case camelCase, snakeCase, kebabCase, noStyle
}

// MARK: Wrapper CodingStyle
@propertyWrapper
struct CodingStyle {
    
    var _value: String
    var style: TextStyle
    
    init(wrappedValue: String, style: TextStyle = .noStyle) {
        _value = wrappedValue
        self.style = style
    }
    
    var wrappedValue: String {
        get { _value }
        set {
            switch style {
            case .camelCase:
                _value = textCorrector(text: newValue, sombol: newValue)
            case .snakeCase:
                _value = textCorrector(text: newValue, sombol: "_")
            case .kebabCase:
                _value = textCorrector(text: newValue, sombol: "-")
            case .noStyle:
                _value = newValue
            }
        }
    }
    
    func textCorrector(text: String, sombol: String) -> String {
        var index = 0
        var newText = ""
        let replaced = String(text.map {
            index += 1
            switch String($0) {
            case " ":
                if text[text.index(before: text.endIndex)] == " " {
                    return $0
                } else {
                    if style == .camelCase {
                        newText = text.camelCase()
                    }
                    return style == .camelCase ? $0 : Character(sombol)
                }
            case "-":
                return text[text.index(before: text.endIndex)] == " " ? $0 : Character(sombol)
            case "_":
                return Character(sombol)
            case String($0).uppercased() :
                if style == .camelCase {
                    return Character(String($0).uppercased())
                } else {
                    return index <= 1 ? $0 : Character(sombol)
                }
            default:
                return $0
            }
        })
        return newText.isEmpty ? replaced : newText
    }
}

// MARK: extension String
extension String {
    func camelCase() -> String {
        return self.components(separatedBy: CharacterSet.letters.inverted)
            .filter { !$0.isEmpty }
            .map { $0.capitalized }
            .joined()
    }
}
