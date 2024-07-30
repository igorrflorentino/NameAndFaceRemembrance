//
//  Photo.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 27/07/24.
//

import Foundation
import SwiftData
import MapKit

@Model
class Person {
	var id: UUID
	var name: String
	@Attribute(.externalStorage) var photoData: Data?
	var locationData: Data?
	
	var location: CLLocationCoordinate2D? {
		get {
			guard let locationData = locationData else { return nil }
			return try? JSONDecoder().decode(CLLocationCoordinate2D.self, from: locationData)
		}
		set {
			locationData = try? JSONEncoder().encode(newValue)
		}
	}
	
	init(id: UUID = UUID(), name: String, photoData: Data?, location: CLLocationCoordinate2D?) {
		self.id = id
		self.name = name
		self.photoData = photoData
		self.location = location
	}
}
