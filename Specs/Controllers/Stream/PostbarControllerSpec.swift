////
///  PostbarControllerSpec.swift
//

@testable
import Ello
import Quick
import Nimble
import Moya


class PostbarControllerSpec: QuickSpec {
    class ReplyAllCreatePostDelegate: CreatePostDelegate {
        var post: Post?
        var comment: ElloComment?
        var text: String?

        func createPost(text text: String?, fromController: UIViewController) {
            self.text = text
        }
        func createComment(post: Post, text: String?, fromController: UIViewController) {
            self.post = post
            self.text = text
        }
        func editComment(comment: ElloComment, fromController: UIViewController) {
            self.comment = comment
        }
        func editPost(post: Post, fromController: UIViewController) {
            self.post = post
        }
    }

    override func spec() {
        var subject: PostbarController!
        let currentUser: User = User.stub([
            "id": "user500",
            "lovesCount": 5,
            ])
        var controller: StreamViewController!
        let streamKind: StreamKind = .PostDetail(postParam: "post")

        beforeEach {
            let textSizeCalculator = FakeStreamTextCellSizeCalculator(webView: UIWebView())
            let notificationSizeCalculator = FakeStreamNotificationCellSizeCalculator(webView: UIWebView())
            let profileHeaderSizeCalculator = FakeProfileHeaderCellSizeCalculator()
            let imageSizeCalculator = StreamImageCellSizeCalculator()
            let categoryHeaderSizeCalculator = CategoryHeaderCellSizeCalculator()

            let dataSource = StreamDataSource(streamKind: streamKind,
                textSizeCalculator: textSizeCalculator,
                notificationSizeCalculator: notificationSizeCalculator,
                profileHeaderSizeCalculator: profileHeaderSizeCalculator,
                imageSizeCalculator: imageSizeCalculator,
                categoryHeaderSizeCalculator: categoryHeaderSizeCalculator
            )

            controller = StreamViewController.instantiateFromStoryboard()
            controller.streamKind = streamKind
            controller.dataSource = dataSource
            controller.collectionView.dataSource = dataSource

            subject = PostbarController(collectionView: controller.collectionView, dataSource: dataSource, presentingController: controller)
            subject.currentUser = currentUser
            dataSource.postbarDelegate = subject

            showController(controller)
        }

        describe("PostbarController") {
            describe("replyToAllButtonTapped(_:)") {
                var delegate: ReplyAllCreatePostDelegate!
                var indexPath: NSIndexPath!

                beforeEach {
                    let post: Post = stub([
                        "id": "post1",
                        "authorId" : "user1",
                    ])
                    let parser = StreamCellItemParser()
                    var postCellItems = parser.parse([post], streamKind: streamKind)
                    let newComment = ElloComment.newCommentForPost(post, currentUser: currentUser)
                    postCellItems += [StreamCellItem(jsonable: newComment, type: .CreateComment)]
                    indexPath = NSIndexPath(forItem: postCellItems.count - 1, inSection: 0)
                    delegate = ReplyAllCreatePostDelegate()
                    controller.createPostDelegate = delegate
                    controller.dataSource.appendUnsizedCellItems(postCellItems, withWidth: 320.0) { cellCount in
                        controller.collectionView.reloadData()
                    }
                }
                context("tapping replyToAll") {
                    it("opens an OmnibarViewController with usernames set") {
                        subject.replyToAllButtonTapped(indexPath)
                        expect(delegate.text) == "@user1 @user2 "
                    }
                }
            }

            describe("watchPostTapped(_:cell:)") {
                var cell: StreamCreateCommentCell!
                var indexPath: NSIndexPath!

                beforeEach {
                    let post: Post = stub([
                        "id": "post1",
                        "authorId" : "user1",
                    ])
                    let parser = StreamCellItemParser()
                    var postCellItems = parser.parse([post], streamKind: streamKind)
                    let newComment = ElloComment.newCommentForPost(post, currentUser: currentUser)
                    postCellItems += [StreamCellItem(jsonable: newComment, type: .CreateComment)]
                    indexPath = NSIndexPath(forItem: postCellItems.count - 1, inSection: 0)
                    cell = StreamCreateCommentCell()
                    controller.dataSource.appendUnsizedCellItems(postCellItems, withWidth: 320.0) { cellCount in
                        controller.collectionView.reloadData()
                    }
                }

                it("should disable the cell during submission") {
                    ElloProvider.sharedProvider = ElloProvider.DelayedStubbingProvider()
                    cell.userInteractionEnabled = true
                    subject.watchPostTapped(true, cell: cell, indexPath: indexPath)
                    expect(cell.userInteractionEnabled) == false
                }
                it("should set the cell.watching property") {
                    ElloProvider.sharedProvider = ElloProvider.DelayedStubbingProvider()
                    cell.watching = false
                    subject.watchPostTapped(true, cell: cell, indexPath: indexPath)
                    expect(cell.watching) == true
                }
                it("should enable the cell after failure") {
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    cell.userInteractionEnabled = false
                    subject.watchPostTapped(true, cell: cell, indexPath: indexPath)
                    expect(cell.userInteractionEnabled) == true
                }
                it("should restore the cell.watching property after failure") {
                    ElloProvider.sharedProvider = ElloProvider.ErrorStubbingProvider()
                    cell.watching = false
                    subject.watchPostTapped(true, cell: cell, indexPath: indexPath)
                    expect(cell.watching) == false
                }
                it("should enable the cell after success") {
                    cell.userInteractionEnabled = false
                    subject.watchPostTapped(true, cell: cell, indexPath: indexPath)
                    expect(cell.userInteractionEnabled) == true
                }
                it("should post a notification after success") {
                    var postedNotification = false
                    let observer = NotificationObserver(notification: PostChangedNotification) { (post, contentChange) in
                        postedNotification = true
                    }
                    subject.watchPostTapped(true, cell: cell, indexPath: indexPath)
                    expect(postedNotification) == true
                    observer.removeObserver()
                }
            }

            describe("loveButtonTapped(_:)") {

                let stubCellItems: (loved: Bool) -> Void = { loved in
                    let post: Post = stub([
                        "id": "post1",
                        "authorId" : "user1",
                        "lovesCount" : 5,
                        "loved" : loved
                    ])
                    let parser = StreamCellItemParser()
                    let postCellItems = parser.parse([post], streamKind: streamKind)
                    controller.dataSource.appendUnsizedCellItems(postCellItems, withWidth: 320.0) { cellCount in
                        controller.collectionView.reloadData()
                    }
                }

                context("post has not been loved") {
                    it("loves the post") {
                        stubCellItems(loved: false)
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        var lovesCount = 0
                        var contentChange: ContentChange?
                        let observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            lovesCount = post.lovesCount!
                            contentChange = change
                        }
                        subject.lovesButtonTapped(cell, indexPath: indexPath)
                        observer.removeObserver()

                        expect(lovesCount) == 6
                        expect(contentChange) == .Loved
                    }

                    it("increases currentUser lovesCount") {
                        stubCellItems(loved: false)
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        let prevLovesCount = currentUser.lovesCount!
                        var lovesCount = 0
                        let observer = NotificationObserver(notification: CurrentUserChangedNotification) { (user) in
                            lovesCount = user.lovesCount!
                        }
                        subject.lovesButtonTapped(cell, indexPath: indexPath)
                        observer.removeObserver()

                        expect(lovesCount) == prevLovesCount + 1
                    }
                }

                context("post has already been loved") {
                    it("unloves the post") {
                        stubCellItems(loved: true)
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        var lovesCount = 0
                        var contentChange: ContentChange?
                        let observer = NotificationObserver(notification: PostChangedNotification) { (post, change) in
                            lovesCount = post.lovesCount!
                            contentChange = change
                        }
                        subject.lovesButtonTapped(cell, indexPath: indexPath)
                        observer.removeObserver()

                        expect(lovesCount) == 4
                        expect(contentChange) == .Loved
                    }

                    it("decreases currentUser lovesCount") {
                        stubCellItems(loved: true)
                        let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                        let cell = StreamFooterCell.loadFromNib() as StreamFooterCell

                        let prevLovesCount = currentUser.lovesCount!
                        var lovesCount = 0
                        let observer = NotificationObserver(notification: CurrentUserChangedNotification) { (user) in
                            lovesCount = user.lovesCount!
                        }
                        subject.lovesButtonTapped(cell, indexPath: indexPath)
                        observer.removeObserver()

                        expect(lovesCount) == prevLovesCount - 1
                    }
                }
            }
        }
    }
}
