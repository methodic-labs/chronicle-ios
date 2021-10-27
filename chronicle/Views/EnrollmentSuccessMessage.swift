//
//  EnrollmentSuccessMessage.swift
//  EnrollmentSuccessMessage
//
//  Created by Giulia Campana on 8/18/21.
//

import SwiftUI

let successMessage = """
Your device has been enrolled! Thank you for participating in our study!

You have successfully installed Chronicle and may now close the application. Chronicle will continue to function as a background process on your device while the application is closed. To stop sending information to the researchers - for instance, at the end of the study - simply uninstall this app. If you have questions or concerns, please contact a member of your research team.
"""

struct EnrollmentSuccessMessage: View {
    var enrollmentViewModel: EnrollmentViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(successMessage)
            // later, add "Done" button which navigates to home page
            // button action should be enrollmentViewModel.onShowEnrollmentDetails()

            Spacer()
        }.padding()
    }
}

struct EnrollmentSuccessMessage_Previews: PreviewProvider {
    static var previews: some View {
        EnrollmentSuccessMessage(enrollmentViewModel: EnrollmentViewModel())
    }
}
