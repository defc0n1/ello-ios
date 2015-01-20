//
//  ElloNavigationController.swift
//  Ello
//
//  Created by Sean on 1/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

class ElloNavigationController: UINavigationController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        delegate = self
    }
    
    var interactionController: UIPercentDrivenInteractiveTransition?
    
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ForwardAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BackAnimator()
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .Push {
            return ForwardAnimator()
        } else if operation == .Pop {
            return BackAnimator()
        }
        return nil
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
}

class ForwardAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        let fromView = context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        
        if let toView = toView {
            if let fromView = fromView {
                let from = fromView.frame
                let to = toView.frame
                toView.frame = CGRect(x: from.origin.x + from.size.width, y: from.origin.y, width: to.size.width, height: to.size.height)
                context.containerView().addSubview(toView)
                
                UIView.animateWithDuration(transitionDuration(context),
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {
                        toView.frame = from
                        fromView.frame = CGRect(x: from.origin.x - from.size.width, y: from.origin.y, width: from.size.width, height: from.size.height)
                    },
                    completion: { finished in
                        context.completeTransition(!context.transitionWasCancelled())
                    })
            }
        }
    }
}

class BackAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(context: UIViewControllerContextTransitioning) {
        let toView = context.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
        let fromView = context.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view
        
        context.containerView().insertSubview(toView!, belowSubview: fromView!)
        
        if let toView = toView {
            if let fromView = fromView {
                let from = fromView.frame
                let to = toView.frame
                toView.frame = CGRect(x: from.origin.x - from.size.width, y: from.origin.y, width: to.size.width, height: to.size.height)
                context.containerView().addSubview(toView)
                
                UIView.animateWithDuration(transitionDuration(context),
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: {
                        toView.frame = from
                        fromView.frame = CGRect(x: from.origin.x + from.size.width, y: from.origin.y, width: from.size.width, height: from.size.height)
                    }, completion: { finished in
                        context.completeTransition(!context.transitionWasCancelled())
                    })
            }
        }
    }
}
