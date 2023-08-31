//
//  InputFieldView.swift
//  InputFieldView
//
//  Created by Giulia Campana on 8/18/21.
//

import SwiftUI

struct InputFieldView: View {
    let label: String
    let placeholder: String
    @Binding var inputId: String
    @Binding var invalidInput: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.semibold)
            ZStack {
                RoundedRectangle(cornerRadius: 8).strokeBorder(lineWidth: 0.3).foregroundColor(Color(invalidInput ? .red : .gray)).frame(minHeight: 40, maxHeight: 40)
                TextField(placeholder, text: $inputId)
                    .padding(.leading)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
        }.padding(.bottom)
    }
}

struct InputFieldView_Previews: PreviewProvider {
    static var model = EnrollmentViewModel()
    static var previews: some View {
        InputFieldView(
            label: "Organization ID",
            placeholder: "Enter your Organization ID",
            inputId: .constant(""),
            invalidInput: .constant(false)
        ).previewLayout(.sizeThatFits)
    }
}

