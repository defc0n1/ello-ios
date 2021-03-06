////
///  ProfileStatsPresenter.swift
//

import Foundation


public struct ProfileStatsPresenter {

    public static func configure(
        view: ProfileStatsView,
        user: User,
        currentUser: User?)
    {
        view.postsCount = (user.postsCount ?? 0).numberToHuman(rounding: 2, showZero: true)
        view.followingCount = (user.followingCount ?? 0).numberToHuman(rounding: 2, showZero: true)
        if let
            string = user.followersCount,
            followersCount = Int(string)
        {
            view.followersCount = followersCount.numberToHuman(rounding: 2, showZero: true)
        }
        else {
            view.followersCount = user.followersCount ?? ""
        }
        view.lovesCount = (user.lovesCount ?? 0).numberToHuman(rounding: 2, showZero: true)
    }
}
