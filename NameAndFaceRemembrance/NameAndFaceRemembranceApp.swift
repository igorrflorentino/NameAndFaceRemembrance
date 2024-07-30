//
//  NameAndFaceRemembranceApp.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 27/07/24.
//

import SwiftUI
import SwiftData

@main
struct NameAndFaceRemembranceApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.modelContainer(for: Person.self)
		}
	}
}


