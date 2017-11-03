//
//  ViewController.swift
//  DragToResize
//
//  Created by Nikola Minov on 03.11.17.
//  Copyright © 2017 nikmin. All rights reserved.
//

import UIKit

private let viewMinHeight: CGFloat = 200.0

class ViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var tableViewHeightConstraint: NSLayoutConstraint!

    private let items: [String] = ["1", "2", "3", "4", "5"]
    private var isSnappedSize: Bool {
        return (tableViewHeightConstraint.constant == view.frame.height) || (tableViewHeightConstraint.constant == viewMinHeight)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("DID SELECT ROW: \(indexPath.row)")
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollView.isDecelerating else { return }

        var contentOffset = scrollView.contentOffset
        if tableViewHeightConstraint.constant < view.superview!.frame.height && contentOffset.y > 0.0 {
            tableViewHeightConstraint.constant = min(contentOffset.y + tableViewHeightConstraint.constant, view.superview!.frame.height)
            contentOffset.y = 0.0
            scrollView.setContentOffset(contentOffset, animated: false)
            return
        }

        let minViewHeight = viewMinHeight
        if tableViewHeightConstraint.constant > minViewHeight && contentOffset.y <= 0.0 {
            tableViewHeightConstraint.constant = max(tableViewHeightConstraint.constant + contentOffset.y, minViewHeight)
            contentOffset.y = 0.0
            scrollView.setContentOffset(contentOffset, animated: false)
        }
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard velocity.y < 0 || !isSnappedSize else { return }

        let defaultAnimationDuration = CGFloat(0.25)
        let calculatedVelocityOffset = -velocity.y * defaultAnimationDuration * 0.4
        let viewSnappingOffsetBoundary = ((view.frame.height - viewMinHeight) / 2.0) + viewMinHeight
        let newConstraintHeight = (tableViewHeightConstraint.constant + calculatedVelocityOffset > viewSnappingOffsetBoundary) ? view.frame.height
                                                                                                                               : viewMinHeight
        let remainingDistance = tableViewHeightConstraint.constant - newConstraintHeight
        var calculatedAnimationDuration = fabs(remainingDistance / velocity.y) + (defaultAnimationDuration * 0.6)
        calculatedAnimationDuration = min(defaultAnimationDuration, calculatedAnimationDuration)

        tableViewHeightConstraint.constant = newConstraintHeight

        UIView.animate(withDuration: TimeInterval(calculatedAnimationDuration), delay: 0.0, options: .curveEaseOut, animations: {
            self.view.superview?.layoutIfNeeded()
        }, completion: nil)
    }
}
