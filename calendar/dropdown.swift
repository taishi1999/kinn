import SwiftUI

struct DropDownView: View {
    @State var selection1: String? = nil
    @State private var date1 = Date()
    @State private var date2 = Date()
    @State private var selectedPickerIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            DropDownPicker(index: 0, selectedPickerIndex: $selectedPickerIndex, title: "開始", date: $date1)
            DropDownPicker(index: 1, selectedPickerIndex: $selectedPickerIndex, title: "終了", date: $date2)
        }
        .cornerRadius(16)
        .padding()
    }
}

enum DropDownPickerState {
    case top
    case bottom
}

struct DropDownPicker: View {
    var index: Int
    @Binding var selectedPickerIndex: Int?
    var title: String
    @Binding var date: Date
    var state: DropDownPickerState = .bottom

    @State private var showDropdown = false
    @SceneStorage("drop_down_zindex") private var indexZ = 1000.0
    @State private var zindex = 1000.0

    var body: some View {
        VStack(spacing: 0) {
            if state == .top && showDropdown {
                OptionsView(date: $date)
            }

            HStack {
                Text(title)
                Spacer(minLength: 0)
                Text(formattedTime(from: date))
                    .foregroundColor(.gray)
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .medium))
                    .fontWeight(.regular)
                    .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                    .foregroundColor(Color(.systemGray2))
                    .frame(width: 20, height: 20)
            }
            .padding()
            .background(.white)
            .onTapGesture {
                indexZ += 1
                zindex = indexZ
//                withAnimation(.easeOut(duration: 0.2)) {
                    if selectedPickerIndex == index {
                        showDropdown.toggle()
                    } else {
                        selectedPickerIndex = index
                        showDropdown = true
                    }
//                }
            }

            if state == .bottom && showDropdown {
                OptionsView(date: $date)
            }
        }
        .clipped()
        .background(.white)
        .onChange(of: selectedPickerIndex) { newValue in
            if newValue != index {
                withAnimation(.easeOut(duration: 0.2)) {
                                   showDropdown = false
                               }
            }
        }
    }

    struct OptionsView: View {
        @Binding var date: Date

        var body: some View {
            VStack(spacing: 0) {
                DatePicker(
                    "Select Time",
                    selection: $date,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .frame(width: 0, height: 200)
                .labelsHidden()
                .padding(.horizontal, 16)
            }
            .transition(.opacity)
            .transition(.move(edge: .top))
            .zIndex(1)
        }
    }

    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct DropDownView_Previews: PreviewProvider {
    static var previews: some View {
        DropDownView()
    }
}
