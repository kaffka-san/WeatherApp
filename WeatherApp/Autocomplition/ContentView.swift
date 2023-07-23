import SwiftUI

/*struct ContentView: View {

    /// Autocompletion for the input text
    @ObservedObject private var autocomplete = AutocompleteObject()
    /// Input text in the text field
    @State var input: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                List {
                }
                    .onChange(of: input) { newValue in
                        autocomplete.autocomplete(input)
                        print(input)
                    }
            }
            .searchable(text: $input, suggestions: {
                ForEach(autocomplete.suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .searchCompletion(suggestion)
                        .foregroundColor(.black)
                }
            }
            )
        }
    }
}*/


