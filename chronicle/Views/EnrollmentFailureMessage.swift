//
//  EnrollmentFailureMessage.swift
//  EnrollmentFailureMessage
//
//  Created by Giulia Campana on 8/18/21.
//

import SwiftUI

let failureMessage = """
Failed to enroll device. Please double check that the Organization ID, Study ID and the Participant ID are correct. If the problem persists, please contact your study administrator.
"""

struct EnrollmentFailureMessage: View {
    var body: some View {
        Text(failureMessage)
            .padding(.top)
    }
}

struct EnrollmentFailureMessage_Previews: PreviewProvider {
    static var previews: some View {
        EnrollmentFailureMessage()
    }
}
