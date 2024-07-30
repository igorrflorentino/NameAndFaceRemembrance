//
//  PeopleView.swift
//  NameAndFaceRemembrance
//
//  Created by Igor Florentino on 30/07/24.
//

import SwiftUI
import SwiftData

struct PeopleView: View {
	@Environment(\.modelContext) var modelContext
	@Query(sort: \Person.name) var people: [Person]
	
	init(searchString: String = "", sortOrder: [SortDescriptor<Person>] = []) {
		_people = Query(filter: #Predicate { person in
			if searchString.isEmpty {
				true
			} else {
				person.name.localizedStandardContains(searchString)
			}
		}, sort: sortOrder)
	}
	
    var body: some View {
		List{
			ForEach(people) { person in
				NavigationLink(value: person) {
					HStack {
						if let photoData = person.photoData, let uiImage = UIImage(data: photoData) {
							Image(uiImage: uiImage)
								.resizable()
								.frame(width: 90, height: 90)
								.clipShape(Circle())
						} else {
							Circle()
								.frame(width: 90, height: 90)
								.foregroundColor(.gray)
						}
						Text(person.name)
							.font(.headline)
					}
				}
				
			}.onDelete(perform: deletePeople)
		}.navigationDestination(for: Person.self) { person in
			PersonEditView(person: person)
		}
    }
	func deletePeople(at offsets: IndexSet) {
		for offset in offsets {
			let person = people[offset]
			modelContext.delete(person)
		}
	}
}

struct PeopleView_Previews: PreviewProvider {
	static var previews: some View {
		do {
			let previewer = try Previewer()
			return AnyView(NavigationView {
				PeopleView()
					.modelContainer(previewer.container)
			})
		} catch {
			return AnyView(Text("Failed to create preview: \(error.localizedDescription)"))
		}
	}
}
