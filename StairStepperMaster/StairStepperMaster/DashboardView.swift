//
//  DashboardView.swift
//  StairStepperMaster
//
//  Created by Saamer Mansoor on 5/27/22.
//

import SwiftUI
import GameKit
import Foundation

struct DashboardView: View {
    @AppStorage("VO2Max") var vo2Max:Double = 0
    @AppStorage("IsSettingsActive") var isSettingsActive:Bool = false
    @AppStorage("GKGameCenterViewControllerState") var gameCenterViewControllerState:GKGameCenterViewControllerState = .default
    @AppStorage("IsGameCenterActive") var isGKActive:Bool = false
    @AppStorage("ActivityGoal") var activityGoal:Int = 8
    var body: some View {
        NavigationView{
            if isGKActive{
                GameCenterView(format: gameCenterViewControllerState)
            }else{
                VStack(alignment: .leading){
                    HStack(alignment: .top){
                        HeaderSubView()
                        
                        NavigationLink(destination: SettingsView(), isActive: $isSettingsActive) {
                            Image(systemName: "gearshape")
                                .padding([.top, .trailing])
                                .foregroundColor(.white)
                        }
                        
//                        NavigationLink(
//                            destination: SettingsView()
//                        ) {
//                            Image(systemName: "gearshape")
//                                .padding([.top, .trailing])
//                                .foregroundColor(.white)
//                        }

                    }
                    ScrollView{
                        if #available(iOS 16.0, *) {
                            FlightsChartTileView()
                        }
                        FlightsTileView()
                        LeadersTileView()
                        AchievementTileView()
                        VO2MaxTileView()
                        MachineTileView()
                    }
                }
                .background(ZStack{
                    Image("ScreenBackground").aspectRatio(contentMode: .fit).border(.black)
                })
                .padding(.bottom)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
