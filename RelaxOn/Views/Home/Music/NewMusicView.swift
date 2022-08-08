//
//  NewMusicView.swift
//  RelaxOn
//
//  Created by 최동권 on 2022/08/06.
//

import SwiftUI

struct NewMusicView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isActive = false
    
    @StateObject var viewModel = MusicViewModel()
    @State var animatedValue : CGFloat = 55
    @State var maxWidth = UIScreen.main.bounds.width / 2.2
    @State var showVolumeControl: Bool = false
    @State private var cdViewPadding = 81.0
    @State private var cdViewWidth = UIScreen.main.bounds.width
    @State private var cdViewHeight = UIScreen.main.bounds.height * 0.63
    @State private var cdNameFontSize = 28.0
    @State private var musicControlButtonWidth = 49.0
    @State private var musicPlayButtonWidth = 44.0
    
    @State private var offsetYOfControlView = UIScreen.main.bounds.height * 0.83 {
        didSet {
            if offsetYOfControlView < UIScreen.main.bounds.height * 0.5 {
                offsetYOfControlView = UIScreen.main.bounds.height * 0.5
            } else if offsetYOfControlView > UIScreen.main.bounds.height * 0.83 {
                offsetYOfControlView = UIScreen.main.bounds.height * 0.83
            }
        }
    }
    
    var data: MixedSound
    
    @Binding var audioVolumes: (baseVolume: Float, melodyVolume: Float, naturalVolume: Float)
    @Binding var userRepositoriesState: [MixedSound]
    var body: some View {
        NavigationView {
            ZStack {
                CDCoverView()
                    .frame(width: .infinity, height: .infinity)
                    .ignoresSafeArea()
                    .blur(radius: 5)
                
                VStack {
                    CustomNavigationBar()
                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 27, trailing: 20))
                    Spacer()
                }
                
                VStack {
                    VStack(spacing: 0) {
                        CDCoverView()
                            .padding(.horizontal, 20)
                            .frame(width: cdViewWidth, height: cdViewWidth - 40)
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text(viewModel.mixedSound?.name ?? "")
                            .font(.system(size: cdNameFontSize, design: .default))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        MusicContollerView()
                            .padding(.top, 54)
                    }
                    .frame(width: cdViewWidth, height: cdViewHeight)
                    .padding(.bottom, cdViewPadding)
                    
                    Spacer()
                }
                .padding(.top, UIScreen.main.bounds.height * 0.1)
                
                VolumeControlView(showVolumeControl: $showVolumeControl,
                                  audioVolumes: $audioVolumes,
                                  data: data)
                .cornerRadius(20)
                .offset(y: offsetYOfControlView)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let draggedHeight = value.translation.height
                            let deviceHalfHeight = UIScreen.main.bounds.height * 0.5
                            let gradient = draggedHeight / deviceHalfHeight
                            
                            offsetYOfControlView += draggedHeight / 5
                            
                            if value.translation.height > 0 {
                                cdViewWidth = UIScreen.main.bounds.width * 0.54 * gradient + UIScreen.main.bounds.width * 0.46
                                cdViewHeight = UIScreen.main.bounds.height * 0.3 * gradient + UIScreen.main.bounds.height * 0.33
                                cdNameFontSize = 6.0 * gradient + 22.0
                                musicPlayButtonWidth = 18 * gradient + 26.0
                                musicControlButtonWidth = 26 * gradient + 23
                            } else {
                                cdViewWidth = UIScreen.main.bounds.width * 0.54 * (gradient) + UIScreen.main.bounds.width
                                cdViewHeight = UIScreen.main.bounds.height * 0.3 * (gradient) + UIScreen.main.bounds.height * 0.63
                                cdNameFontSize = 6.0 * (gradient) + 28.0
                                musicPlayButtonWidth = 18.0 * (gradient) + 44
                                musicControlButtonWidth = 26 * (gradient) + 49
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                let draggedHeight = value.predictedEndTranslation.height
                                if draggedHeight < -10 {
                                    offsetYOfControlView = UIScreen.main.bounds.height * 0.5
                                    cdViewWidth = UIScreen.main.bounds.width * 0.46
                                    cdViewHeight = UIScreen.main.bounds.height * 0.33
                                    cdNameFontSize = 22.0
                                    musicPlayButtonWidth = 26.0
                                    musicControlButtonWidth = 23
                                } else if draggedHeight > 10 {
                                    offsetYOfControlView = UIScreen.main.bounds.height * 0.83
                                    cdViewWidth = UIScreen.main.bounds.width
                                    cdViewHeight = UIScreen.main.bounds.height * 0.63
                                    cdNameFontSize = 28.0
                                    musicPlayButtonWidth = 44
                                    musicControlButtonWidth = 49
                                    print("1")
                                    saveNewVolume()
                                    print("2")
                                } else {
                                    offsetYOfControlView = UIScreen.main.bounds.height * 0.83
                                    cdViewWidth = UIScreen.main.bounds.width
                                    cdViewHeight = UIScreen.main.bounds.height * 0.63
                                    cdNameFontSize = 28.0
                                    musicPlayButtonWidth = 44
                                    musicControlButtonWidth = 49
                                    saveNewVolume()
                                }
                            }
                        }
                )
            }
            .onAppear {
                viewModel.fetchData(data: data)
            }
            .onDisappear {
                viewModel.stop()
            }
            .background(
                NavigationLink(destination: MusicRenameView(mixedSound: data), isActive: $isActive) {
                    Text("")
                }
            )
            .navigationTitle("Studio")
            .navigationBarHidden(true)
            //            .toolbar {
            //                ToolbarItem(placement: .navigationBarLeading) {
            //                    Button {
            //                        print("하이")
            //                    } label: {
            //                        Image(systemName: "shevron.down")
            //                            .tint(.systemGrey1)
            //                    }
            //                }
            //                ToolbarItem(placement: .navigationBarTrailing) {
            //                    Menu {
            //                        Button {
            //                            self.isActive.toggle()
            //                        } label: {
            //                            HStack{
            //                                Text("Rename")
            //                                Image(systemName: "pencil")
            //                            }
            //                        }
            //
            //                        Button(role: .destructive) {
            //                            print("하이")
            //                        } label: {
            //                            HStack{
            //                                Text("Delete")
            //                                    .foregroundColor(.red)
            //                                Image(systemName: "trash")
            //                                    .tint(.red)
            //                            }
            //                        }
            //                    } label: {
            //                        Image(systemName: "ellipsis")
            //                            .rotationEffect(.degrees(90))
            //                            .tint(.systemGrey1)
            //                    }
            //                }
            //            }
        }
    }
    
    private func getEncodedData(data: [MixedSound]) -> Data? {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            return encodedData
        } catch {
            print("Unable to Encode Note (\(error))")
        }
        return nil
    }
    
    private func saveNewVolume() {
        print("시작")
        guard let localBaseSound = data.baseSound,
              let localMelodySound = data.melodySound,
              let localNaturalSound = data.naturalSound else { return }
        print("여기")
        let newBaseSound = Sound(id: localBaseSound.id,
                                 name: localBaseSound.name,
                                 soundType: localBaseSound.soundType,
                                 audioVolume: audioVolumes.baseVolume,
                                 imageName: localBaseSound.imageName)
        let newMelodySound = Sound(id: localMelodySound.id,
                                   name: localMelodySound.name,
                                   soundType: localMelodySound.soundType,
                                   audioVolume: audioVolumes.melodyVolume,
                                   imageName: localMelodySound.imageName)
        
        let newNaturalSound = Sound(id: localNaturalSound.id,
                                    name: localNaturalSound.name,
                                    soundType: localNaturalSound.soundType,
                                    audioVolume: audioVolumes.naturalVolume,
                                    imageName: localNaturalSound.imageName)
        
        let newMixedSound = MixedSound(id: data.id,
                                       name: data.name,
                                       baseSound: newBaseSound,
                                       melodySound: newMelodySound,
                                       naturalSound: newNaturalSound,
                                       imageName: data.imageName)
        
        userRepositories.remove(at: data.id)
        userRepositories.insert(newMixedSound, at: data.id)
        let data = getEncodedData(data: userRepositories)
        UserDefaultsManager.shared.standard.set(data, forKey: UserDefaultsManager.shared.recipes)
        print("저장됐지롱")
    }
}

// MARK: ViewBuilder
extension NewMusicView {
    @ViewBuilder
    func MusicContollerView() -> some View {
        HStack (spacing: 56) {
            Button {
                viewModel.setupPreviousTrack(mixedSound: viewModel.mixedSound ?? emptyMixedSound)
            } label: {
                Image(systemName: "backward.fill")
                    .resizable()
                    .frame(width: musicControlButtonWidth, height: musicControlButtonWidth * 0.71)
                    .tint(.white)
            }
            
            Button {
                viewModel.playPause()
                viewModel.isPlaying.toggle()
            } label: {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: musicPlayButtonWidth, height: musicPlayButtonWidth * 1.25) //1.25
                    .tint(.white)
            }
            
            Button {
                viewModel.setupNextTrack(mixedSound: viewModel.mixedSound ?? emptyMixedSound)
            } label: {
                Image(systemName: "forward.fill")
                    .resizable()
                    .frame(width: musicControlButtonWidth, height: musicControlButtonWidth * 0.71)
                    .tint(.white)
            }
        }
    }
    
    // TODO: CDCover만들 곳
    @ViewBuilder
    func CDCoverView() -> some View {
        ZStack {
            Image(data.baseSound?.imageName ?? "")
                .resizable()
                .opacity(0.5)
                .frame(width: .infinity, height: .infinity)
            Image(data.melodySound?.imageName ?? "")
                .resizable()
                .opacity(0.5)
                .frame(width: .infinity, height: .infinity)
            Image(data.naturalSound?.imageName ?? "")
                .resizable()
                .opacity(0.5)
                .frame(width: .infinity, height: .infinity)
        }
    }
    
    @ViewBuilder
    func CustomNavigationBar() -> some View {
        HStack {
            Button {
                withAnimation {
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 20)
                    .tint(.systemGrey1)
            }
            
            Spacer()
            
            Menu {
                Button {
                    self.isActive.toggle()
                } label: {
                    HStack{
                        Text("Rename")
                        Image(systemName: "pencil")
                    }
                }
                
                Button(role: .destructive) {
                    userRepositories.remove(at: data.id)
                    let data = getEncodedData(data: userRepositories)
                    UserDefaultsManager.shared.standard.set(data, forKey: UserDefaultsManager.shared.recipes)
                    userRepositoriesState = userRepositories
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack{
                        Text("Delete")
                            .foregroundColor(.red)
                        Image(systemName: "trash")
                            .tint(.red)
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 20)
                    .rotationEffect(.degrees(90))
                    .tint(.systemGrey1)
            }
        }
    }
}
//
//struct NewMusicView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewMusicView()
//    }
//}
