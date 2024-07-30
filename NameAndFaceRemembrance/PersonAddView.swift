//
//  PersonAddView.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 30/07/24.
//

import SwiftUI
import MapKit

struct PersonAddView: View {
	@Environment(\.modelContext) var modelContext
	@Environment(\.dismiss) var dismiss
	@Bindable var person: Person
	var position: MapCameraPosition?
	var location: CLLocationCoordinate2D?

	init(person: Person) {
		self.person = person
		if let location = person.location{
			self.position = MapCameraPosition.region(
				MKCoordinateRegion(
					center: location,
					span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
				)
			)
			self.location = location
		}
	}
	
	var body: some View {
		VStack {
			HStack{
				if let photoData = person.photoData, let uiImage = UIImage(data: photoData) {
					Image(uiImage: uiImage)
						.resizable()
						.scaledToFit()
						.clipShape(Circle())
				} else {
					ZStack{
						Circle()
							.foregroundColor(.gray)
						Text("no photo")
					}
				}
				if let position, let location {
					Map(initialPosition: position, interactionModes: [.zoom]){
						Marker("", coordinate: location)
					}
					.mapStyle(.standard)
					.clipShape(.circle)
				} else {
					ZStack{
						Circle()
							.foregroundColor(.gray)
						Text("no location")
					}
				}
			}
			.frame(maxHeight: 200)
			TextField("Set person's name", text: $person.name)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()
			HStack {
				Button("Save") {
					modelContext.insert(person)
					dismiss()
				}
				.padding()
				.disabled(person.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
				Button("Cancel") {
					dismiss()
				}
				.padding()
			}
		}
		.padding()
	}
}

struct PersonAddView_Previews: PreviewProvider {
	static var previews: some View {
		do {
			let previewer = try Previewer()
			return AnyView(NavigationView {
				PersonAddView(person: previewer.person)
					.modelContainer(previewer.container)
			})
		} catch {
			return AnyView(Text("Failed to create preview: \(error.localizedDescription)"))
		}
	}
}

