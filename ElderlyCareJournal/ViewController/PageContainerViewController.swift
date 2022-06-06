//
//  LandingPageViewController.swift
//  ElderlyCareJournal
//
//  Created by Rammel on 2022-05-30.
//

import UIKit

class PageContainerViewController: UIViewController {
    
    private var sideNavigationMenuVC: SideNavigationMenuViewController!
    private var sideMenuShadowView: UIView!
    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    private var tapGestureRecognizer: UIGestureRecognizer?
    
    // Expand/Collapse the side menu by changing trailing's constant
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var revealSideMenuOnTop: Bool = true
    
    //Dependency injection
    var user: User?
    var familyMember: FamilyMember?
    var defaultPageId: PageId!
    
    var gestureEnabled: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Shadow Background View
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        
        // Setup Tap Gesture Recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        self.tapGestureRecognizer = tapGestureRecognizer
        
        if self.revealSideMenuOnTop {
            view.insertSubview(self.sideMenuShadowView, at: 1)
        }

        // Side Menu
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        self.sideNavigationMenuVC = storyboard.instantiateViewController(withIdentifier: "SideMenuID") as? SideNavigationMenuViewController
        self.sideNavigationMenuVC.defaultHighlightedCell = 0 // Default Highlighted Cell
        self.sideNavigationMenuVC.delegate = self
        view.insertSubview(self.sideNavigationMenuVC!.view, at: self.revealSideMenuOnTop ? 2 : 0)
        addChild(self.sideNavigationMenuVC!)
        self.sideNavigationMenuVC!.didMove(toParent: self)
        
        // Side Menu AutoLayout
        self.sideNavigationMenuVC.view.translatesAutoresizingMaskIntoConstraints = false
        if self.revealSideMenuOnTop {
            self.sideMenuTrailingConstraint = self.sideNavigationMenuVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -self.sideMenuRevealWidth - self.paddingForRotation)
            self.sideMenuTrailingConstraint.isActive = true
        }
        NSLayoutConstraint.activate([
            self.sideNavigationMenuVC.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideNavigationMenuVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideNavigationMenuVC.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])

//        // Side Menu Gestures
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
//        panGestureRecognizer.delegate = self
//        view.addGestureRecognizer(panGestureRecognizer)

        // Show default view
        switch self.defaultPageId {
            case .FamilyMemberList:
                showFamilyMemberList()
            case .FamilyMemberDetail:
                showFamilyMemberDetail()
            case .ClientList:
                showClientList()
            case .MyAccount:
                return
            case .Login:
                showInitialScreen()
            case .none:
                return
        }
        
    }

    // Keep the state of the side menu (expanded or collapse) in rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = self.isExpanded ? 0 : (-self.sideMenuRevealWidth - self.paddingForRotation)
            }
        }
    }
    
    func addGestureRecognizer() {
        view.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func removeGestureRecognizer() {
        view.removeGestureRecognizer(tapGestureRecognizer!)
    }

    func animateShadow(targetPosition: CGFloat) {
        UIView.animate(withDuration: 0.5) {
            // When targetPosition is 0, which means side menu is expanded, the shadow opacity is 0.6
            self.sideMenuShadowView.alpha = (targetPosition == 0) ? 0.6 : 0.0
        }
    }

    // Call this Button Action from the View Controller you want to Expand/Collapse when you tap a button
    @IBAction open func revealSideMenu() {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
    
    // Call this Button Action from the View Controller you want to Expand/Collapse when you tap a button
    @IBAction open func logout() {
        let initialScreen = storyboard?.instantiateViewController(withIdentifier: "InitialScreen") as! MainViewController
        view.window?.rootViewController = initialScreen
        view.window?.makeKeyAndVisible()
    }

    func sideMenuState(expanded: Bool) {
        if expanded {
            addGestureRecognizer()
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : self.sideMenuRevealWidth) { _ in
                self.isExpanded = true
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            removeGestureRecognizer()
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? (-self.sideMenuRevealWidth - self.paddingForRotation) : 0) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            }
            else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension PageContainerViewController: SideNavigationMenuDelegate {
    func selectedCell(_ pageId: PageId) {
        switch pageId {
            case .FamilyMemberList:
                self.showFamilyMemberList()
            case .FamilyMemberDetail:
                self.showFamilyMemberDetail()
            case .ClientList:
                self.showClientList()
            case .MyAccount:
                // Profile
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let userProfileNav = storyboard.instantiateViewController(withIdentifier: "UserProfileNavId") as! UINavigationController
                let userProfileVC = userProfileNav.topViewController as! UserProfileDetailController
                userProfileVC.user = self.user
                userProfileVC.delegate = self
                self.present(userProfileNav, animated: true, completion: nil)
            case .Login:
                let initialScreen = storyboard?.instantiateViewController(withIdentifier: "InitialScreen") as! UINavigationController
                view.window?.rootViewController = initialScreen
                view.window?.makeKeyAndVisible()
            }
        
            // Collapse side menu with animation
            DispatchQueue.main.async { self.sideMenuState(expanded: false) }
    }

    func showViewController<T: UIViewController>(viewController: T.Type, storyboardId: String) -> () {
        // Remove the previous View
        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        vc.view.tag = 99
        view.insertSubview(vc.view, at: self.revealSideMenuOnTop ? 0 : 1)
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            vc.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            vc.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            vc.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        if !self.revealSideMenuOnTop {
            if isExpanded {
                vc.view.frame.origin.x = self.sideMenuRevealWidth
            }
            if self.sideMenuShadowView != nil {
                vc.view.addSubview(self.sideMenuShadowView)
            }
        }
        vc.didMove(toParent: self)
    }
    
    func showFamilyMemberList() -> () {
        // Remove the previous View
        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: "FamilyMemberListNavVC") as! UINavigationController
        let vc = navVC.topViewController as! FamilyMemberListController
        vc.user = self.user
        navVC.view.tag = 99
        view.insertSubview(navVC.view, at: self.revealSideMenuOnTop ? 0 : 1)
        addChild(navVC)
        navVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            navVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            navVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        if !self.revealSideMenuOnTop {
            if isExpanded {
                navVC.view.frame.origin.x = self.sideMenuRevealWidth
            }
            if self.sideMenuShadowView != nil {
                navVC.view.addSubview(self.sideMenuShadowView)
            }
        }
        navVC.didMove(toParent: self)
    }
    
    func showClientList() -> () {
        // Remove the previous View
        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navVC = storyboard.instantiateViewController(withIdentifier: "ClientListNavVC") as! UINavigationController
        let vc = navVC.topViewController as! ClientListViewController
        vc.user = self.user
        navVC.view.tag = 99
        view.insertSubview(navVC.view, at: self.revealSideMenuOnTop ? 0 : 1)
        addChild(navVC)
        navVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            navVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            navVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            navVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        if !self.revealSideMenuOnTop {
            if isExpanded {
                navVC.view.frame.origin.x = self.sideMenuRevealWidth
            }
            if self.sideMenuShadowView != nil {
                navVC.view.addSubview(self.sideMenuShadowView)
            }
        }
        navVC.didMove(toParent: self)
    }
    
    func showFamilyMemberDetail() -> () {
        // Remove the previous View
        for subview in view.subviews {
            if subview.tag == 99 {
                subview.removeFromSuperview()
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let familyMemberTabBarController = storyboard.instantiateViewController(withIdentifier: "FamilyMemberGuardian") as! UITabBarController
        
        let navControllers = familyMemberTabBarController.viewControllers
        let memberDetailNavVC = navControllers?[0] as! UINavigationController
        let memberDetailVC = memberDetailNavVC.topViewController as! FamilyMemberDetailController
        memberDetailVC.user = self.user
        memberDetailVC.familyMember = self.familyMember
        if user!.userType != UserType.Guardian.rawValue {
            memberDetailVC.isEditable = false
        }
        
        let shiftListNavVC = navControllers?[1] as! UINavigationController
        let shiftListVC = shiftListNavVC.topViewController as! ShiftListViewController
        shiftListVC.user = user
        shiftListVC.familyMember = familyMember
        
        let documentListNavVC = navControllers?[2] as! UINavigationController
        let documentlistVC = documentListNavVC.topViewController as! DocumentListViewController
        documentlistVC.familyMember = familyMember
        documentlistVC.delegate = self
        
        familyMemberTabBarController.view.tag = 99
        view.insertSubview(familyMemberTabBarController.view, at: self.revealSideMenuOnTop ? 0 : 1)
        addChild(familyMemberTabBarController)
        familyMemberTabBarController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            familyMemberTabBarController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            familyMemberTabBarController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            familyMemberTabBarController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            familyMemberTabBarController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        if !self.revealSideMenuOnTop {
            if isExpanded {
                familyMemberTabBarController.view.frame.origin.x = self.sideMenuRevealWidth
            }
            if self.sideMenuShadowView != nil {
                familyMemberTabBarController.view.addSubview(self.sideMenuShadowView)
            }
        }
        familyMemberTabBarController.didMove(toParent: self)
    }
    
    func showInitialScreen() {
        let initialScreen = storyboard?.instantiateViewController(withIdentifier: "InitialScreen") as! UINavigationController
        view.window?.rootViewController = initialScreen
        view.window?.makeKeyAndVisible()
    }
}

extension PageContainerViewController: UIGestureRecognizerDelegate {
    @objc func TapGestureRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isExpanded {
                self.sideMenuState(expanded: false)
            }
        }
    }

    // Close side menu when you tap on the shadow background view
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.sideNavigationMenuVC.view))! {
            return false
        }
        return true
    }
    
    // Dragging Side Menu
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        guard gestureEnabled == true else { return }

        let position: CGFloat = sender.translation(in: self.view).x
        let velocity: CGFloat = sender.velocity(in: self.view).x

        switch sender.state {
        case .began:

            // If the user tries to expand the menu more than the reveal width, then cancel the pan gesture
            if velocity > 0, self.isExpanded {
                sender.state = .cancelled
            }

            // If the user swipes right but the side menu hasn't expanded yet, enable dragging
            if velocity > 0, !self.isExpanded {
                self.draggingIsEnabled = true
            }
            // If user swipes left and the side menu is already expanded, enable dragging
            else if velocity < 0, self.isExpanded {
                self.draggingIsEnabled = true
            }

            if self.draggingIsEnabled {
                // If swipe is fast, Expand/Collapse the side menu with animation instead of dragging
                let velocityThreshold: CGFloat = 550
                if abs(velocity) > velocityThreshold {
                    self.sideMenuState(expanded: self.isExpanded ? false : true)
                    self.draggingIsEnabled = false
                    return
                }

                if self.revealSideMenuOnTop {
                    self.panBaseLocation = 0.0
                    if self.isExpanded {
                        self.panBaseLocation = self.sideMenuRevealWidth
                    }
                }
            }

        case .changed:

            // Expand/Collapse side menu while dragging
            if self.draggingIsEnabled {
                if self.revealSideMenuOnTop {
                    // Show/Hide shadow background view while dragging
                    let xLocation: CGFloat = self.panBaseLocation + position
                    let percentage = (xLocation * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth

                    let alpha = percentage >= 0.6 ? 0.6 : percentage
                    self.sideMenuShadowView.alpha = alpha

                    // Move side menu while dragging
                    if xLocation <= self.sideMenuRevealWidth {
                        self.sideMenuTrailingConstraint.constant = xLocation - self.sideMenuRevealWidth
                    }
                }
                else {
                    if let recogView = sender.view?.subviews[1] {
                        // Show/Hide shadow background view while dragging
                        let percentage = (recogView.frame.origin.x * 150 / self.sideMenuRevealWidth) / self.sideMenuRevealWidth

                        let alpha = percentage >= 0.6 ? 0.6 : percentage
                        self.sideMenuShadowView.alpha = alpha

                        // Move side menu while dragging
                        if recogView.frame.origin.x <= self.sideMenuRevealWidth, recogView.frame.origin.x >= 0 {
                            recogView.frame.origin.x = recogView.frame.origin.x + position
                            sender.setTranslation(CGPoint.zero, in: view)
                        }
                    }
                }
            }
        case .ended:
            self.draggingIsEnabled = false
            // If the side menu is half Open/Close, then Expand/Collapse with animation
            if self.revealSideMenuOnTop {
                let movedMoreThanHalf = self.sideMenuTrailingConstraint.constant > -(self.sideMenuRevealWidth * 0.5)
                self.sideMenuState(expanded: movedMoreThanHalf)
            }
            else {
                if let recogView = sender.view?.subviews[1] {
                    let movedMoreThanHalf = recogView.frame.origin.x > self.sideMenuRevealWidth * 0.5
                    self.sideMenuState(expanded: movedMoreThanHalf)
                }
            }
        default:
            break
        }
    }
}

extension PageContainerViewController: UserProfileDelegate {
    func updateUser(user: User) {
        self.user = user
    }
}

extension PageContainerViewController: DocumentListDelegate {
    func removeDocument(at index: Int) {
        familyMember?.documents.remove(at: index)
    }
    
    func addDocument(document: Document) {
        familyMember?.documents.append(document)
    }
}

extension UIViewController {
    
    // With this extension you can access the PageContainerViewController from the child view controllers.
    func revealViewController() -> PageContainerViewController? {
        var viewController: UIViewController? = self
        
        if viewController != nil && viewController is PageContainerViewController {
            return viewController! as? PageContainerViewController
        }
        while (!(viewController is PageContainerViewController) && viewController?.parent != nil) {
            viewController = viewController?.parent
        }
        if viewController is PageContainerViewController {
            return viewController as? PageContainerViewController
        }
        return nil
    }
}
