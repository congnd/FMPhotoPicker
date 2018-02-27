//
//  FMImageEditorViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/27.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMImageEditorViewController: UIViewController {
    
    @IBOutlet weak var topMenuTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomMenuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topMenuContainter: UIView!
    @IBOutlet weak var bottomMenuContainer: UIView!
    @IBOutlet weak var subMenuContainer: UIView!
    
    private let filterSubMenuView = FMFiltersListView()
    
    // MARK - Init
    public init(selectMode: FMSelectMode, dataSource: FMPhotosDataSource, initialPhotoIndex: Int) {
        super.init(nibName: "FMImageEditorViewController", bundle: Bundle(for: FMImageEditorViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subMenuContainer.addSubview(filterSubMenuView)
        filterSubMenuView.translatesAutoresizingMaskIntoConstraints = false
        filterSubMenuView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        filterSubMenuView.rightAnchor.constraint(equalTo: subMenuContainer.rightAnchor).isActive = true
        filterSubMenuView.leftAnchor.constraint(equalTo: subMenuContainer.leftAnchor).isActive = true
        filterSubMenuView.bottomAnchor.constraint(equalTo: subMenuContainer.bottomAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimatedMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK -
    private func showAnimatedMenu() {
        topMenuTopConstraint.constant = topMenuContainter.frame.height
        bottomMenuBottomConstraint.constant = bottomMenuContainer.frame.height
        topMenuContainter.alpha = 0
        bottomMenuContainer.alpha = 0
        UIView.animate(withDuration: 0.375,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.topMenuContainter.alpha = 1
                        self.bottomMenuContainer.alpha = 1
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
        
        self.topMenuTopConstraint.constant = 0
        self.bottomMenuBottomConstraint.constant = 0
    }

    @IBAction func onTapCancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
