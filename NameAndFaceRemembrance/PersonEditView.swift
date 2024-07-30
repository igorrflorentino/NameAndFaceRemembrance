//
//  PhotoDetailView.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 27/07/24.
//

import SwiftUI
import SwiftData
import PhotosUI
import MapKit


struct PersonEditView: View {
	@Environment(\.modelContext) var modelContext
	@Environment(\.presentationMode) var presentationMode
	@Bindable var person: Person
	@State private var showShareSheet = false
	@State private var showAlert = false
	@State private var name: String
	@State private var selectedItem: PhotosPickerItem?
	@State private var photo: Data?
	@State private var position: MapCameraPosition?
	@State private var location: CLLocationCoordinate2D?
	@State private var newLocation: CLLocationCoordinate2D?
	let locationFetcher = LocationFetcher()
	
	init(person: Person) {
		self.person = person
		self._name = State(initialValue: person.name)
		self._photo = State(initialValue: person.photoData)
		if let location = person.location{
			self._position = State(initialValue: MapCameraPosition.region(
				MKCoordinateRegion(
					center: location,
					span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
				)
			))
			self._location = State(initialValue: location)
		}
	}
	
	var body: some View {
		VStack {
			HStack{
				VStack{
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
					Section {
						PhotosPicker(selection: $selectedItem, matching: .images) {
							Label("Change photo", systemImage: "person")
						}
					}
				}
				VStack{
					if let position, let location {
						Map(initialPosition: position, interactionModes: [.zoom, .pan]){
							Marker("", coordinate: location)
						}
						.mapStyle(.standard)
						.clipShape(.circle)
						.onMapCameraChange { context in
							newLocation = context.region.center
						}
						Section {
							Button("Change Location") {
								self.location = newLocation
							}
						}
					} else {
						ZStack{
							Circle()
								.foregroundColor(.gray)
							Text("no location")
						}
						Section {
							Button("Get Location") {
								locationFetcher.start()
								if let location = locationFetcher.lastKnownLocation{
									self.position = MapCameraPosition.region(
										MKCoordinateRegion(
											center: location,
											span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
										)
									)
									self.location = location
								}
							}
						}
					}
				}.frame(maxHeight: 200)

			}
			TextField("Set person's name", text: $name)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()
			
			.padding()
			Button(action: {
				person.name = name
				person.photoData = photo
				person.location = location
				try? modelContext.save()
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Save")
			}.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			.padding()
		}
		.padding()
		.navigationTitle(person.name)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}) {
			Text("< People")
		}.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
		)
		.navigationBarItems(trailing: HStack {
			Button("Delete") {
				showAlert = true
			}
			.foregroundColor(.red) // Indicate destructive action
			ShareLink(item: person.photoData!, preview: SharePreview("Selected Photo", image: Image(uiImage: UIImage(data: person.photoData!)!)))
		})
		.alert("Confirm Deletion", isPresented: $showAlert) {
			Button("Delete", role: .destructive) {
				modelContext.delete(person)
				try? modelContext.save()
				self.presentationMode.wrappedValue.dismiss()
			}
			Button("Cancel", role: .cancel) { }
		} message: {
			Text("Are you sure you want to delete this photo?")
		}
		.onChange(of: selectedItem){
			Task { @MainActor in
				photo = try await selectedItem?.loadTransferable(type: Data.self)
			}
		}
	}
}

struct PersonEditView_Previews: PreviewProvider {
	static var previews: some View {
		do {
			let previewer = try Previewer()
			return AnyView(NavigationView {
				PersonEditView(person: previewer.person)
					.modelContainer(previewer.container)
			})
		} catch {
			return AnyView(Text("Failed to create preview: \(error.localizedDescription)"))
		}
	}
}
