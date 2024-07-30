//
//  AddPhotoView.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 29/07/24.
//

import SwiftUI
import PhotosUI

struct AddPhotoView: View {
	@Environment(\.modelContext) var modelContext
	@Environment(\.dismiss) var dismiss
	
	var selectedPhotoData: Data
	@State var name: String = ""
	
	var body: some View {
		VStack {
			if let uiImage = UIImage(data: selectedPhotoData) {
				Image(uiImage: uiImage)
					.resizable()
					.frame(width: 250, height: 250)
					.clipShape(Circle())
			} else {
				Text("Failed to load image")
			}
			TextField("Enter name for the photo", text: $name)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding()
			Button("Save") {
				addPhoto(name: name, photoData: selectedPhotoData)
				dismiss()
			}
			.padding()
			.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			Button("Cancel") {
				dismiss()
			}
		}
		.padding()
	}
	
	func addPhoto(name: String, photoData: Data) {
		let newPhoto = Person(name: name, photoData: photoData)
		modelContext.insert(newPhoto)
		try? modelContext.save()
	}
}

struct AddDetailView_Previews: PreviewProvider {
	static var previews: some View {
		do {
			let previewer = try Previewer()
			return AnyView(NavigationView {
				AddPhotoView(selectedPhotoData: previewer.photo.photoData)
					.modelContainer(previewer.container)
			})
		} catch {
			return AnyView(Text("Failed to create preview: \(error.localizedDescription)"))
		}
	}
}
