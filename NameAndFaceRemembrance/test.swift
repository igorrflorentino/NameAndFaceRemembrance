//
//  test.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 28/07/24.
//

import SwiftUI
import PhotosUI

import SwiftUI

struct test: View {
	@State private var showSheet = false
	@State private var textFieldValue = ""
	
	var body: some View {
		VStack {
			Button("Show Sheet") {
				showSheet.toggle()
			}
		}
		.sheet(isPresented: $showSheet) {
			SheetView(textFieldValue: $textFieldValue)
		}
	}
}

struct SheetView: View {
	@Binding var textFieldValue: String
	
	var body: some View {
		VStack {
			TextField("Enter text", text: $textFieldValue)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()
			Text("You typed: \(textFieldValue)")
		}
		.padding()
	}
}

#Preview {
    test()
}
