import SwiftUI

struct DropDownDefaultView: View {

    @State var selection1: String? = nil
    @State var selection2: String? = nil

    var body: some View {

        ScrollView{

            VStack(spacing: 0){
                DropDownDefaultPicker(
                    selection: $selection1,
                    options: [
                        "Apple",
                        "Google",
                        "Amazon",
                        "Facebook",
                        "Instagram"
                    ]
                )
                DropDownDefaultPicker(
                    selection: $selection1,
                    options: [
                        "Apple",
                        "Google",
                        "Amazon",
                        "Facebook",
                        "Instagram"
                    ]
                )
                Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
                    .background(.red)
                Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
                    .background(.red)
                Text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
                    .background(.red)

//                DropDownDefaultPicker(
//                    selection: $selection2,
//                    options: [
//                        "Apple",
//                        "Google",
//                        "Amazon",
//                        "Facebook",
//                        "Instagram"
//                    ]
//                )
            }
        }
        .background(.gray)

//            DropDownDefaultPicker(
//                selection: $selection1,
//                options: [
//                    "Apple",
//                    "Google",
//                    "Amazon",
//                    "Facebook",
//                    "Instagram"
//                ]
//            )
        
    }
}

enum DropDownDefaultPickerState {
    case top
    case bottom
}

struct DropDownDefaultPicker: View {

    @Binding var selection: String?
    var state: DropDownPickerState = .bottom
    var options: [String]
    var maxWidth: CGFloat = 180

    @State var showDropdown = false

    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zindex = 1000.0

    var body: some View {
        GeometryReader {
            let size = $0.size

            VStack(spacing: 0) {


                if state == .top && showDropdown {
                    OptionsView()
                }

                HStack {
                    Text(selection == nil ? "Select" : selection!)
                        .foregroundColor(selection != nil ? .black : .gray)


                    Spacer(minLength: 0)

                    Image(systemName: state == .top ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                }
                .padding(.horizontal, 15)
                .frame(width: 180, height: 50)
                .background(.white)
                .contentShape(.rect)
                .onTapGesture {
                    index += 1
                    zindex = index
                    withAnimation(.snappy) {
                        showDropdown.toggle()
                    }
                }
                .zIndex(10)

                if state == .bottom && showDropdown {
                    OptionsView()
                }
            }
            .clipped()
            .background(.white)
            .cornerRadius(10)
//            .overlay {
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(.gray)
//            }
            
//            .frame(
//                height: size.height, alignment: state == .top ? .bottom : .top
//            )

        }
        .frame(width: maxWidth, height: 50)
        .background(Color(.systemGray))
        .zIndex(zindex)
    }


    func OptionsView() -> some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                HStack {
                    Text(option)
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(selection == option ? 1 : 0)
                }
                .foregroundStyle(selection == option ? Color.primary : Color.gray)
                .animation(.none, value: selection)
                .frame(height: 40)
                .contentShape(.rect)
                .padding(.horizontal, 15)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selection = option
                        showDropdown.toggle()
                    }
                }
            }
        }
        .transition(.move(edge: state == .top ? .bottom : .top))
        .zIndex(1)
    }
}
struct DropDownDefaultView_Previews: PreviewProvider {
    static var previews: some View {
        DropDownDefaultView()
    }
}
