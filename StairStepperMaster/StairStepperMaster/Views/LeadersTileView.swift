//
//  LeadersTileView.swift
//  StairStepperMaster
//
//  Created by Saamer Mansoor on 6/5/22.
//

import SwiftUI
import GameKit
import CoreMotion

struct Player: Hashable {
    let id = UUID()
    let name: String
    let score: String
    let image: UIImage?
}

struct LeadersTileView: View {
    @AppStorage("GKGameCenterViewControllerState") var gameCenterViewControllerState:GKGameCenterViewControllerState = .default
    @AppStorage("IsGameCenterActive") var isGKActive:Bool = false
    var leaderboardIdentifier = "com.tfp.stairsteppermaster.flights"
    @State var playersList: [Player] = []
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                
                Text("COMPETITION")
                    .font(Font.custom("Avenir", size: 25))
                    .fontWeight(.heavy)
                    .padding(.leading, 20)
                    .foregroundColor(.white)
                Spacer()
                Text("Show More")
                    .font(Font.custom("Avenir", size: 14))
                    .padding(.trailing, 20)
                    .foregroundColor(Color("MoreYellow"))
                
            }
            
            VStack{
                HStack{
                    ForEach(playersList, id: \.self) { item in
                        VStack{
                            Image(uiImage: item.image!)
                                .resizable()
                                .frame(width: 72, height: 72, alignment: .center)
                                .clipShape(Circle())
                            Text(item.name)
                                .font(Font.custom("Avenir",size: 10))
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                            Text(item.score)
                                .font(Font.custom("Avenir",size: 10))
                                .foregroundColor(.white)
                        }.padding(5)
                    }
                }
                
            }
            .padding(5)
            .frame(minWidth:350, minHeight: 113)
            .background(Color("TileBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear(){
            if !GKLocalPlayer.local.isAuthenticated {
                authenticateUser()
            } else if playersList.count == 0 {
                Task{
                    await loadLeaderboard(source: 1)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                // 7.
                withAnimation {
                    if !GKLocalPlayer.local.isAuthenticated {
                        authenticateUser()
                    } else if playersList.count == 0 {
                        Task{
                            await loadLeaderboard(source: 2)
                        }
                    }
                }
            }
        }
        .onTapGesture {
            gameCenterViewControllerState = .leaderboards
            simpleSuccessHaptic()
            isGKActive = true
        }
    }
    
    func authenticateUser() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            Task{
                await loadLeaderboard(source: 3)
            }
        }
    }
    
    func loadLeaderboard(source: Int = 0) async {
        print(source)
        print("source")
        playersList.removeAll()
        Task{
            let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardIdentifier])
            if let leaderboard = leaderboards.filter ({ $0.baseLeaderboardID == self.leaderboardIdentifier }).first {
                leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(1...3)) { (_, allPlayers, _, error) in
                    if let allPlayers = allPlayers {
                        allPlayers.forEach { leaderboardEntry in
                            leaderboardEntry.player.loadPhoto(for: .small) { image, error in
                                self.playersList.append(Player(name: leaderboardEntry.player.displayName, score:leaderboardEntry.formattedScore, image: image))
                            }
                        }
                    }
                }
            }
        }

//        GKLeaderboard.loadLeaderboards(IDs: [leaderboardIdentifier]) { (leaderboards, error) in
//            if let leaderboard = leaderboards?.filter ({ $0.baseLeaderboardID == self.leaderboardIdentifier }).first {
//                leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(1...3)) { (_, allPlayers, _, error) in
//                    if let allPlayers = allPlayers {
//                        allPlayers.forEach { leaderboardEntry in
//                            leaderboardEntry.player.loadPhoto(for: .small) { image, error in
//                                self.playersList.append(Player(name: leaderboardEntry.player.displayName, score:leaderboardEntry.formattedScore, image: image))
//                            }
//                        }
//                    }
//                }
//            }
//        }
        playersList.sort{
            $0.score > $1.score
        }
    }
}

struct LeadersTileView_Previews: PreviewProvider {
    static var previews: some View {
        LeadersTileView()
    }
}
