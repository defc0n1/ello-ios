////
///  DrawerViewController.swift
//

import Crashlytics

public class DrawerViewController: StreamableViewController {
    @IBOutlet weak open var tableView: UITableView!
    weak open var navigationBar: ElloNavigationBar!
    open var isLoggingOut = false

    override var backGestureEdges: UIRectEdge { return .right }

    open let dataSource = DrawerViewDataSource()

    required public init() {
        super.init(nibName: "DrawerViewController", bundle: .none)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Using a StreamableViewController to gain access to the InviteResponder
    // Not a great longterm setup.
    override func setupStreamController() {
        // noop
    }
}

// MARK: View Lifecycle
extension DrawerViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()

        addLeftButtons()
        setupTableView()
        setupNavigationBar()
        registerCells()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        postNotification(StatusBarNotifications.statusBarShouldChange, value: (false, .slide))
        Crashlytics.sharedInstance().setObjectValue("Drawer", forKey: CrashlyticsKey.streamName.rawValue)
    }
}

// MARK: UITableViewDelegate
extension DrawerViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSource.itemForIndexPath(indexPath) {
            switch item.type {
            case let .external(link):
                postNotification(ExternalWebNotification, value: link)
            case .invite:
                let responder = target(forAction: #selector(InviteResponder.onInviteFriends), withSender: self) as? InviteResponder
                responder?.onInviteFriends()
            case .logout:
                isLoggingOut = true
                nextTick {
                    self.dismiss(animated: true, completion: { _ in
                         postNotification(AuthenticationNotifications.userLoggedOut, value: ())
                    })
                }
            default: break
            }
        }
    }
}

// MARK: View Helpers
private extension DrawerViewController {
    func setupTableView() {
        tableView.backgroundColor = .grey6()
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    func setupNavigationBar() {
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height)
        navigationBar.items = [elloNavigationItem]
        navigationBar.tintColor = .greyA()

        let color = UIColor.grey6()
        navigationBar.backgroundColor = color
        navigationBar.shadowImage = nil
        navigationBar.barTintColor = color
    }

    func addLeftButtons() {
        let logoView = UIImageView(image: InterfaceImage.elloLogo.normalImage)
        logoView.frame = CGRect(x: 15, y: 30, width: 24, height: 24)
        navigationBar.addSubview(logoView)
    }

    func registerCells() {
        tableView.register(DrawerCell.nib(), forCellReuseIdentifier: DrawerCell.reuseIdentifier)
    }
}
