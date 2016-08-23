////
///  StartupScreen.swift
//

import SnapKit


public class StartupScreen: Screen {
    struct Size {
        static let topLogoOffset: CGFloat = 110
    }

    let logoImage = FLAnimatedImageView()
    let loginButton = UIButton()
    let signUpButton = UIButton()

    override func arrange() {
        addSubview(logoImage)
        addSubview(loginButton)
        addSubview(signUpButton)

        logoImage.snp_makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self.snp_top).offset(Size.topLogoOffset).priorityMedium()
            make.bottom.lessThanOrEqualTo(signUpButton.snp_top).offset(15).priorityHigh()
        }

        loginButton
    }
}
