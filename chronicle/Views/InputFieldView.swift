//
//  InputFieldView.swift
//  InputFieldView
//
//  Created by Giulia Campana on 8/18/21.
//

import SwiftUI

struct InputFieldView: View {
    let label: String
    @Binding var inputId: String
    @Binding var invalidInput: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).strokeBorder(lineWidth: 0.3).foregroundColor(Color(invalidInput ? .red : .gray)).frame(minHeight: 40, maxHeight: 40)
            TextField(label, text: $inputId)
                .padding(.leading)
                .textFieldStyle(.plain)
                .disableAutocorrection(true)
        }.padding([.top, .bottom])
        
    }
}

