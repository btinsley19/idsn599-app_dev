import SwiftUI

struct ContentView: View {
    @State private var mood: Double = 5
    @State private var feeling: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // profile image person icon
            Image(systemName: "person.circle.fill")
            // make it resizeable so we can change dimensions
                .resizable()
                .frame(width: 120, height: 120)
            // and make it blue
                .foregroundColor(.blue)
            
            // write name below
            Text("Brian Tinsley")
            // change font to be a little more big / bold
                .font(.title)
            
            VStack {
                Text("How I feel today: \(Int(mood)) / 10")
                // slider to adjust how you feel scaled from 1-10
                Slider(value: $mood, in: 0...10, step: 1)
            }
            .padding(.horizontal)
            
            
            // wanted texteditor to be taller which is what the texteditor is for

            VStack(alignment: .leading) { // align to left
                // adding a title above box
                Text("Explain how you are feeling")
                    .font(.headline)
                    .foregroundColor(.gray)

                TextEditor(text: $feeling)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .padding(.horizontal)

            
            // button for submit
            Button(action: {
                // does nothing
            }) {
                Text("Submit")
                // let the button stretch wider
                    .frame(maxWidth: .infinity)
                // padding to make button bigger
                    .padding()
                // change colors
                    .background(Color.blue)
                    .foregroundColor(.white)
                // round it a little bit
                    .cornerRadius(8)
            }
            // add some padding on sides of the button
            .padding(.horizontal)
        }
        // padding to the entire content from sides
        .padding()
    }
}

#Preview {
    ContentView()
}
