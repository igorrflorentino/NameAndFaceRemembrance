import SwiftUI
import SwiftData
import PhotosUI
import MapKit

struct ContentView: View {
	@Query(sort: \Person.name) var persons: [Person]
	@Environment(\.modelContext) var modelContext
	@State private var isPickerPresented = false
	@State private var selectedPhotoItem: PhotosPickerItem?
	@State private var selectedPhotoData: Data?
	@State private var searchText = ""
	@State private var sortOrder = [SortDescriptor(\Person.name)]
	let locationFetcher = LocationFetcher()
	@State private var location: CLLocationCoordinate2D?
	
	var body: some View {
		NavigationStack() {
			PeopleView(searchString: searchText, sortOrder: sortOrder)
			.navigationTitle("Photos")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						locationFetcher.start()
						isPickerPresented = true
					}) {
						Label("Add Photo", systemImage: "plus")
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu("Sort", systemImage: "arrow.up.arrow.down") {
						Picker("Sort", selection: $sortOrder) {
							Text("Name (A-Z)")
								.tag([SortDescriptor(\Person.name)])
							
							Text("Name (Z-A)")
								.tag([SortDescriptor(\Person.name, order: .reverse)])
						}
					}
				}
			}
			.searchable(text: $searchText)
			.photosPicker(isPresented: $isPickerPresented, selection: $selectedPhotoItem, matching: .images)
			.onChange(of: selectedPhotoItem) { _, newValue in
				if let selectedPhotoItem = newValue {
					Task {
						do {
							if let data = try await selectedPhotoItem.loadTransferable(type: Data.self) {
								await MainActor.run {
									selectedPhotoData = data
									location = locationFetcher.lastKnownLocation
								}
							} else {
								print("Failed to load image data or convert to UIImage")
							}
						} catch {
							print("Error loading image: \(error.localizedDescription)")
						}
					}
				}
			}
			.sheet(item: $selectedPhotoData) { photoData in
				let person = Person(name: "", photoData: photoData, location: location)
				PersonAddView(person: person)
			}
			
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		do {
			let previewer = try Previewer()
			return AnyView(NavigationView {
				ContentView()
					.modelContainer(previewer.container)
			})
		} catch {
			return AnyView(Text("Failed to create preview: \(error.localizedDescription)"))
		}
	}
}
