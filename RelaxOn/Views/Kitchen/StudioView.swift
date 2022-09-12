//
//  StudioView.swift
//  RelaxOn
//
//  Created by 김연호 on 2022/07/23.
//

import SwiftUI

struct StudioView: View {
    // MARK: - State Properties
    @State var select: Int = 0
    @State var showingConfirm = false
    @State var selectedBaseSound: Sound = Sound(id: 0,
                                                name: "Empty",
                                                soundType: .base,
                                                audioVolume: 0.5,
                                                fileName: "")
    @State var selectedMelodySound: Sound = Sound(id: 10,
                                                  name: "Empty",
                                                  soundType: .melody,
                                                  audioVolume: 0.5,
                                                  fileName: "")
    @State var selectedWhiteNoiseSound: Sound = Sound(id: 20,
                                                      name: "Empty",
                                                      soundType: .whiteNoise,
                                                      audioVolume: 0.5,
                                                      fileName: "")
    @State var selectedImageNames: (base: String, melody: String, whiteNoise: String) = (
        base: "",
        melody: "",
        whiteNoise: ""
    )
    
    @State var opacityAnimationValues = [0.0, 0.0, 0.0]
    @State var navigateActive = false
    @State var volumes: [Float] = [0.5, 0.5, 0.5]
    @State var mixedSound: MixedSound?
    @Binding var rootIsActive: Bool
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    // MARK: - General Properties
    let baseAudioManager = AudioManager()
    let melodyAudioManager = AudioManager()
    let whiteNoiseAudioManager = AudioManager()
    var items = ["BASE", "MELODY", "WHITE NOISE"]
    
    // MARK: - Life Cycles
    var body: some View {
        ZStack{
            Color.relaxBlack.ignoresSafeArea()
            VStack {
                StudioBackButton()
                HStack{
                    Text("STUDIO")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                    Spacer()
                    MixButton()
                }.padding(.horizontal)
                
                CDCoverImageView(selectedImageNames: selectedImageNames)
                    .addWhiteBackground()
                    .DeviceFrame()
                
                CustomSegmentControlView(items: items, selection: $select)
                switch select {
                case 1:
                    SoundSelectView(sectionTitle: "Melody",
                                    soundType: .melody)
                case 2:
                    SoundSelectView(sectionTitle: "WhiteNoise Sound",
                                    soundType: .whiteNoise)
                default:
                    SoundSelectView(sectionTitle: "Base Sound",
                                    soundType: .base)
                }
            }
            .navigationBarItems(leading: Text("STUDIO").bold())
            .navigationBarHidden(true)
        }
    }
}

// MARK: - ViewBuilder
extension StudioView {
    @ViewBuilder
    func SoundSelectView(sectionTitle: String,
                         soundType: SoundType) -> some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "speaker.wave.1.fill")
                    .frame(width: 18.0, height: 18.0)
                    .foregroundColor(.white)
                
                VolumeSlider(value: $volumes[select], range: (0, 1), knobWidth: 14) { modifiers in
                  ZStack {
                    Color.white.cornerRadius(3).frame(height: 2).modifier(modifiers.barLeft)
                    Color.white.opacity(0.4).cornerRadius(3).frame(height: 2).modifier(modifiers.barRight)
                    ZStack {
                      Circle().fill(Color.white)
                    }.modifier(modifiers.knob)
                  }
                }
                .frame(height: 25)
                .onChange(of: volumes[0]) { volume in
                    selectedBaseSound.audioVolume = volume
                    baseAudioManager.changeVolume(track: selectedBaseSound.fileName, volume: volume)
                }
                .onChange(of: volumes[1]) { volume in
                    selectedMelodySound.audioVolume = volume
                    melodyAudioManager.changeVolume(track: selectedMelodySound.fileName, volume: volume)
                }
                .onChange(of: volumes[2]) { volume in
                    selectedWhiteNoiseSound.audioVolume = volume
                    whiteNoiseAudioManager.changeVolume(track: selectedWhiteNoiseSound.fileName, volume: volume)
                }
                
                Text("\(Int(volumes[select] * 100))")
                    .font(.body)
                    .foregroundColor(.systemGrey1)
                    .frame(maxWidth: 30)
            }
            .padding([.horizontal])
            
            ScrollView(.vertical,
                       showsIndicators: false) {
                HStack(spacing: 30) {
                    switch soundType {
                    case .base:
                        RadioButtonGroupView(selectedId: soundType.rawValue,
                                             items: baseSounds) { baseSelected in
                            selectedBaseSound = baseSelected
                            // play music
                            
                            if selectedBaseSound.name == "Empty" {
                                baseAudioManager.stop()
                                
                                opacityAnimationValues[0] = 0.0
                            } else {
                                baseAudioManager.startPlayer(track: selectedBaseSound.fileName, volume: volumes[select])
                                opacityAnimationValues[0] = 1.0
                            }
                            selectedImageNames.base = selectedBaseSound.fileName
                        }
                    case .melody:
                        RadioButtonGroupView(selectedId: soundType.rawValue,
                                             items: melodySounds) { melodySounds in
                            selectedMelodySound = melodySounds
                            
                            if selectedMelodySound.name == "Empty" {
                                melodyAudioManager.stop()
                                
                                opacityAnimationValues[1] = 0.0
                            } else {
                                melodyAudioManager.startPlayer(track: selectedMelodySound.fileName, volume: volumes[select])
                                opacityAnimationValues[1] = 1.0
                            }
                            selectedImageNames.melody = selectedMelodySound.fileName
                        }
                    case .whiteNoise:
                        RadioButtonGroupView(selectedId: soundType.rawValue,
                                             items: whiteNoiseSounds) { whiteNoiseSounds in
                            selectedWhiteNoiseSound = whiteNoiseSounds
                            
                            if selectedWhiteNoiseSound.name == "Empty" {
                                whiteNoiseAudioManager.stop()
                                
                                opacityAnimationValues[2] = 0.0
                            } else {
                                whiteNoiseAudioManager.startPlayer(track: selectedWhiteNoiseSound.fileName, volume: volumes[select])
                                opacityAnimationValues[2] = 1.0
                            }
                            selectedImageNames.whiteNoise = selectedWhiteNoiseSound.fileName
                        }
                    }
                }
            }.padding(.horizontal, 15)
        }
    }
    
    @ViewBuilder
    func MixButton() -> some View {
        NavigationLink(isActive: $navigateActive) {
            if let mixedSound = self.mixedSound {
                CDNamingView(goToPreviousView: self.$rootIsActive,
                             mixedSound: mixedSound,
                             previousView: .studio)
            }
        } label: {
            Text("Mix")
                .font(.system(size: 24, weight: .regular))
                .foregroundColor( ($selectedBaseSound.id == 0 && $selectedMelodySound.id == 10 && $selectedWhiteNoiseSound.id == 20) ? Color.gray : Color.relaxDimPurple )
                .onTapGesture {
                    baseSound = selectedBaseSound
                    melodySound = selectedMelodySound
                    whiteNoiseSound = selectedWhiteNoiseSound

                    mixedSound = MixedSound(name: "",
                                              baseSound: baseSound,
                                              melodySound: melodySound,
                                              whiteNoiseSound: whiteNoiseSound,
                                              fileName: recipeRandomName.randomElement()!)
                    
                    baseAudioManager.stop()
                    melodyAudioManager.stop()
                    whiteNoiseAudioManager.stop()
                    navigateActive = true
                }
        }
        .disabled(($selectedBaseSound.id == 0 && $selectedMelodySound.id == 10 && $selectedWhiteNoiseSound.id == 20) ? true : false)
    }

    @ViewBuilder
    func StudioBackButton() -> some View {
        HStack{
            Button(action: {
                showingConfirm = true
            }, label: {
                HStack {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.relaxDimPurple)
                    Text("CD LIBRARY")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.relaxDimPurple)
                }
            })
            .confirmationDialog("나가면 사라집니다...", isPresented: $showingConfirm, titleVisibility: .visible) {
                Button("Leave Studio", role: .destructive){
                    presentationMode.wrappedValue.dismiss()
                    baseAudioManager.stop()
                    melodyAudioManager.stop()
                    whiteNoiseAudioManager.stop()
                }
                Button("Cancel", role: .cancel){}
            }
            
            Spacer()
        }.padding()
    }
}
