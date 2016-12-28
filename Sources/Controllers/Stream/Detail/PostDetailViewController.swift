////
///  PostDetailViewController.swift
//
public final class PostDetailViewController: StreamableViewController {
    var post: Post?
    var postParam: String!
    var scrollToComment: ElloComment?

    var navigationBar: ElloNavigationBar!
    var localToken: String!
    var deeplinkPath: String?
    var generator: PostDetailGenerator?

    required public init(postParam: String) {
        self.postParam = postParam
        super.init(nibName: nil, bundle: nil)
        if self.post == nil {
            if let post = ElloLinkedStore.sharedInstance.getObject(self.postParam, type: .postsType) as? Post {
                self.post = post
            }
        }
        self.localToken = streamViewController.loadingToken.resetInitialPageLoadingToken()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        streamViewController.streamKind = .postDetail(postParam: postParam)
        view.backgroundColor = .white
        self.generator = PostDetailGenerator(
            currentUser: self.currentUser,
            postParam: postParam,
            post: self.post,
            streamKind: self.streamViewController.streamKind,
            destination: self
        )
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.initialLoadClosure = { [unowned self] in self.loadEntirePostDetail() }
        streamViewController.reloadClosure = { [unowned self] in self.reloadEntirePostDetail() }

        streamViewController.loadInitialPage()
    }

    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return view
    }

    fileprivate func updateInsets() {
        updateInsets(navBar: navigationBar, streamController: streamViewController)
    }

    override public func didSetCurrentUser() {
        generator?.currentUser = currentUser
        super.didSetCurrentUser()
    }

    override public func showNavBars(_ scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false)
        updateInsets()
    }

    // MARK : private

    fileprivate func loadEntirePostDetail() {
        generator?.load()
    }

    fileprivate func reloadEntirePostDetail() {
        generator?.load(reload: true)
    }

    fileprivate func showPostLoadFailure() {
        let message = InterfaceString.GenericError
        let alertController = AlertViewController(error: message) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.addSubview(navigationBar)

        setupNavigationItems()
    }

    fileprivate func setupNavigationItems() {
        let backItem = UIBarButtonItem.backChevron(withController: self)
        elloNavigationItem.leftBarButtonItems = [backItem]
        elloNavigationItem.fixNavBarItemPadding()
        navigationBar.items = [elloNavigationItem]

        guard post != nil else {
            elloNavigationItem.rightBarButtonItems = []
            return
        }

        var rightBarButtonItems: [UIBarButtonItem] = []

        if isOwnPost() {
            rightBarButtonItems = [
                UIBarButtonItem(image: .xBox, target: self, action: #selector(PostDetailViewController.deletePost)),
                UIBarButtonItem(image: .pencil, target: self, action: #selector(PostDetailViewController.editPostAction)),
            ]
        }
        else {
            rightBarButtonItems = [
                UIBarButtonItem(image: .search, target: self, action: #selector(BaseElloViewController.searchButtonTapped)),
                UIBarButtonItem(image: .dots, target: self, action: #selector(PostDetailViewController.flagPost)),
            ]
        }

        if !elloNavigationItem.areRightButtonsTheSame(rightBarButtonItems) {
            elloNavigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }

    fileprivate func scrollToComment(_ comment: ElloComment) {
        let commentItem = streamViewController.dataSource.visibleCellItems.find { item in
            return (item.jsonable as? ElloComment)?.id == comment.id
        } ?? streamViewController.dataSource.visibleCellItems.last

        if let commentItem = commentItem, let indexPath = self.streamViewController.dataSource.indexPathForItem(commentItem) {
            self.streamViewController.collectionView.scrollToItem(
                at: indexPath,
                at: .top,
                animated: true
            )
        }
    }

    override public func postTapped(_ post: Post) {
        if let selfPost = self.post, post.id != selfPost.id {
            super.postTapped(post)
        }
    }

    fileprivate func isOwnPost() -> Bool {
        guard let post = post, let currentUser = currentUser else {
            return false
        }
        return currentUser.isOwn(post: post)
    }

    public func flagPost() {
        guard let post = post else { return }

        let flagger = ContentFlagger(presentingController: self,
            flaggableId: post.id,
            contentType: .post)
        flagger.displayFlaggingSheet()
    }

    public func editPostAction() {
        guard let post = post, isOwnPost() else {
            return
        }

        // This is a bit dirty, we should not call a method on a compositionally held
        // controller's createPostDelegate. Can this use the responder chain when we have
        // parameters to pass?
        editPost(post, fromController: self)
    }

    public func deletePost() {
        guard let post = post, let currentUser = currentUser, isOwnPost() else {
            return
        }

        let message = InterfaceString.Post.DeletePostConfirm
        let alertController = AlertViewController(message: message)

        let yesAction = AlertAction(title: InterfaceString.Yes, style: .dark) { _ in
            if let userPostCount = currentUser.postsCount {
                currentUser.postsCount = userPostCount - 1
                postNotification(CurrentUserChangedNotification, value: currentUser)
            }

            postNotification(PostChangedNotification, value: (post, .delete))
            PostService().deletePost(post.id,
                success: {},
                failure: { (error, statusCode)  in
                    // TODO: add error handling
                    print("failed to delete post, error: \(error.elloErrorMessage ?? error.localizedDescription)")
                })
        }
        let noAction = AlertAction(title: InterfaceString.No, style: .light, handler: .none)

        alertController.addAction(yesAction)
        alertController.addAction(noAction)

        logPresentingAlert("PostDetailViewController")
        self.present(alertController, animated: true, completion: .none)
    }

}

// MARK: PostDetailViewController: StreamDestination
extension PostDetailViewController: StreamDestination {

    public var pagingEnabled: Bool {
        get { return streamViewController.pagingEnabled }
        set { streamViewController.pagingEnabled = newValue }
    }

    public func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping ElloEmptyCompletion) {
        streamViewController.replacePlaceholder(type, with: items, completion: completion)
    }

    public func setPlaceholders(items: [StreamCellItem]) {
        streamViewController.clearForInitialLoad()
        streamViewController.appendUnsizedCellItems(items, withWidth: view.frame.width) { _ in
            if let scrollToComment = self.scrollToComment {
                // nextTick didn't work, the collection view hadn't shown its
                // cells or updated contentView.  so this.
                delay(0.1) {
                    self.scrollToComment(scrollToComment)
                }
            }
        }
    }

    public func setPrimary(jsonable: JSONAble) {
        guard let post = jsonable as? Post else { return }

        self.post = post

        // need to reassign the userParam to the id for paging
        self.postParam = post.id

        /*
         - need to reassign the streamKind so that the comments
         can page based off the post.id from the ElloAPI.path

         - same for when tapping on a post token in a post this
         will replace '~CRAZY-TOKEN' with the correct id for
         paging to work
         */

        streamViewController.streamKind = .postDetail(postParam: postParam)

        self.title = post.author?.atName ?? InterfaceString.Post.DefaultTitle

        setupNavigationItems()

        if isOwnPost() {
            showNavBars(false)
        }

        Tracker.sharedTracker.postLoaded(post.id)
    }

    public func setPagingConfig(responseConfig: ResponseConfig) {
        streamViewController.responseConfig = responseConfig
    }

    public func primaryJSONAbleNotFound() {
        if let deeplinkPath = self.deeplinkPath,
            let deeplinkURL = URL(string: deeplinkPath)
        {
            UIApplication.shared.openURL(deeplinkURL)
            self.deeplinkPath = nil
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            self.showPostLoadFailure()
        }
        self.streamViewController.doneLoading()
    }
}
