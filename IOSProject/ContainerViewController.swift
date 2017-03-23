//
//  ContainerViewController.swift
//  IOSProject
//
//  Created by Mehul Gore on 3/14/17.
//  Copyright © 2017 Mehul Gore. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    let sidebarWidth:CGFloat = 260

    override func viewDidLoad() {
        DispatchQueue.main.async {
            self.closeMenu(animated: false)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.closeMenuOnNotification), name: NSNotification.Name(rawValue: "close"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContainerViewController.toggleMenu), name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleMenu () {
        scrollView.contentOffset.x == 0 ? closeMenu() : openMenu()
    }
    
    private func openMenu () {
        //print("menu open")
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        //print("offset now \(scrollView.contentOffset.x)")
    }
    
    private func closeMenu (animated: Bool = true) {
        //print("menu close")
        scrollView.setContentOffset(CGPoint(x: sidebarWidth, y:0), animated: animated)
        //print("offset now \(scrollView.contentOffset.x)")
    }
    
    func closeMenuOnNotification () {
        closeMenu()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ContainerViewController : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = true
    }
        
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = false
    }
}

