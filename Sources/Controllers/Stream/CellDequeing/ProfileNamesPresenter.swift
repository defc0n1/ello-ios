////
///  ProfileNamesPresenter.swift
//

import Foundation


public struct ProfileNamesPresenter {

    public static func configure(
        view: ProfileNamesView,
        user: User,
        currentUser: User?)
    {
        view.name = user.name
        view.username = user.atName
    }
}
