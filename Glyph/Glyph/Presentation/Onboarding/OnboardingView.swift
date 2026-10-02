//
//  OnboardingView.swift
//  SmartGallery
//
//  Created by PradheepNarendran on 01/10/26.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            // MARK: - Custom Animated Backgrounds
            Group {
                switch currentStep {
                case 0:
                  Image("launchScreenBg")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case 1:
                  Image("ocrBg")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case 2:
                  Image("photoSearchBg")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                default:
                    Color.black
                }
            }
            .ignoresSafeArea()
            //.animation(.easeInOut(duration: 0.5), value: currentStep)
            
            VStack {
                // MARK: - Swipeable Content
                TabView(selection: $currentStep) {
                    
                    // SCREEN 1
                    VStack(spacing: 32) {
                        Spacer()
                        // Row 1 - App Logo
                        Image("brand")
                        .resizable()
                        .frame(width: 160, height: 160)
                            .foregroundColor(.black)
                            .padding()
                        
                        // Row 2 - Brand Image
                        Image("wordMark")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .foregroundColor(.black)
                        
                        // Row 3 - Headline
                        Text("Find text in your photos instantly")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                    .tag(0)
                    
                    // SCREEN 2
                    VStack(spacing: 32) {
                        Spacer()
                        // Row 1
                        Text("Find text in Receipts, Bills & Photos")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Row 2
                        Text("Quick OCR search from your gallery or camera")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                      
                      // Brand Image for Screen 2
                      Image("billScanner")
                          .resizable()
                          .frame(maxWidth: .infinity)
                          .foregroundColor(.black)
                      
                        Spacer()
                    }
                    .tag(1)
                    
                    // SCREEN 3
                    VStack(spacing: 32) {
                        Spacer()
                        // Row 1
                        Text("Search anything in your photos")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        // Row 2
                        Text("Find text from bills, vouchers, receipts and more")
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                      
                      // Brand Image for Screen 3
                      Image("appSearching")
                          .resizable()
                          .scaledToFit()
                          .foregroundColor(.black)
                        Spacer()
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // MARK: - Bottom Controls
                VStack(spacing: 24) {
                    // Page Indicators (Above CTA)
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Capsule()
                                .fill(currentStep == index ? Color.black : Color.black.opacity(0.3))
                                .frame(width: currentStep == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)
                        }
                    }
                    
                    // CTA Button
                    Button(action: {
                        withAnimation {
                            if currentStep < 2 {
                                currentStep += 1
                            } else {
                                // Final step: trigger navigation to the grid view
                                hasSeenOnboarding = true
                            }
                        }
                    }) {
                        HStack {
                            Text(currentStep == 2 ? "Alright, let's begin" : "Next")
                                .font(.headline)
                            
                            if currentStep < 2 {
                                Image(systemName: "arrow.right")
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 34)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}
