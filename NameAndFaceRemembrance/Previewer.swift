//
//  Previewer.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 29/07/24.
//

import SwiftData
import PhotosUI

@MainActor
struct Previewer {
	let container: ModelContainer
	let person: Person
	
	init() throws {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		container = try ModelContainer(for: Person.self, configurations: config)
		
		let samplePhotoData = UIImage(named: "sample_image")!.jpegData(compressionQuality: 1.0)!
		person = Person(name: "Sample Photo", photoData: samplePhotoData, location: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275))
		
		container.mainContext.insert(person)
	}
}
