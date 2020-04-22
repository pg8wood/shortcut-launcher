//
//  UItableView+Gaze.swift
//  Vocable AAC
//
//  Created by Chris Stroud on 2/3/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

private class UItableViewGazeTarget: Equatable {

    let indexPath: IndexPath
    let beginDate: Date
    var isCancelled = false
    init(beginDate: Date, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.beginDate = beginDate
    }

    static func == (lhs: UItableViewGazeTarget, rhs: UItableViewGazeTarget) -> Bool {
        return lhs.indexPath == rhs.indexPath
    }
}

// Big hacked version of Chris' UICollectionView extension
extension UITableView {
    
    override var canReceiveGaze: Bool {
        true
    }

    private struct AssociatedKeys {
        static var gazeTarget: UInt8 = 0
    }

    var indexPathForGazedItem: IndexPath? {
        return gazeTarget?.indexPath
    }

    private var gazeTarget: UItableViewGazeTarget? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gazeTarget) as? UItableViewGazeTarget
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.gazeTarget, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    override func gazeableHitTest(_ point: CGPoint, with event: UIHeadGazeEvent?) -> UIView? {
        guard !isHidden else { return nil }
        for view in subviews.reversed() {
            let point = view.convert(point, from: self)
            if let result = view.gazeableHitTest(point, with: event) {
                return result
            }
        }
        if self.point(inside: point, with: event) && canReceiveGaze {
            return self
        }
        return nil
    }

    private func setItemHighlighted(_ highlighted: Bool, at indexPath: IndexPath) {
        if let cell = cellForRow(at: indexPath) {
            if highlighted {
                guard delegate?.tableView?(self, shouldHighlightRowAt: indexPath) ?? true else {
                    return
                }
                
                cell.isHighlighted = true
                delegate?.tableView?(self, didHighlightRowAt: indexPath)
            } else {
                cell.isHighlighted = false
                delegate?.tableView?(self, didUnhighlightRowAt: indexPath)
            }
        }

        if !highlighted,
            indexPathIsSelected(indexPath) {
//            delegate?.tableView?(self, shouldDeselecRowAt: indexPath) ?? true {
            deselectRow(at: indexPath, animated: true)
            delegate?.tableView?(self, didDeselectRowAt: indexPath)
        }
    }

    private func indexPathIsSelected(_ indexPath: IndexPath) -> Bool {
        return indexPathsForSelectedRows?.contains(indexPath) ?? false
    }

    
    // Hack to prevent app from selecting things quickly when switching back from Shortcuts
    private struct Storage {
        static var _timeElapsedSinceGazeBegan: TimeInterval = .zero
    }
    private var timeElapsedSinceGazeBegan: TimeInterval {
        get {
            Storage._timeElapsedSinceGazeBegan
        } set {
            Storage._timeElapsedSinceGazeBegan = newValue
        }
    }
    @objc func appWillMoveToForeground() {
        timeElapsedSinceGazeBegan = .zero
    }
    
    private func updateGazeTarget(for gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        let newTarget = target(for: gaze, with: event)
        let oldTarget = gazeTarget
        if newTarget == oldTarget {
            
            

            // Update the existing target's selection state if needed
            if let oldTarget = gazeTarget, !oldTarget.isCancelled, !indexPathIsSelected(oldTarget.indexPath) {
                timeElapsedSinceGazeBegan = Date().timeIntervalSince(oldTarget.beginDate)
               
                NotificationCenter.default.addObserver(self, selector: #selector(appWillMoveToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
                
                
                if timeElapsedSinceGazeBegan >= AppConfig.selectionHoldDuration {
//                    guard delegate?.tableView?(self, shouldSelectRowAt: oldTarget.indexPath) ?? true else {
//                        return
//                    }
                    (self.window as? HeadGazeWindow)?.animateCursorSelection()
                    selectRow(at: oldTarget.indexPath, animated: true, scrollPosition: .none)
                    delegate?.tableView?(self, didSelectRowAt: oldTarget.indexPath)
                }
            }
            return
        }

        if let oldTarget = oldTarget {
            setItemHighlighted(false, at: oldTarget.indexPath)
            gazeTarget = nil
        }

        if let newTarget = newTarget {
            setItemHighlighted(true, at: newTarget.indexPath)
            gazeTarget = newTarget
        }
    }

    private func target(for gaze: UIHeadGaze, with event: UIHeadGazeEvent?) -> UItableViewGazeTarget? {
        let point = gaze.location(in: self)
        guard let indexPath = indexPathForRow(at: point) else {
            return nil
        }
        return UItableViewGazeTarget(beginDate: Date(), indexPath: indexPath)
    }

    override func gazeBegan(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        updateGazeTarget(for: gaze, with: event)
    }

    override func gazeMoved(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        updateGazeTarget(for: gaze, with: event)
    }

    override func gazeEnded(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        if let oldTarget = gazeTarget, !oldTarget.isCancelled {
            setItemHighlighted(false, at: oldTarget.indexPath)
            gazeTarget = nil
        }
    }

    override func gazeCancelled(_ gaze: UIHeadGaze, with event: UIHeadGazeEvent?) {
        guard let target = gazeTarget else { return }
        target.isCancelled = true
        setItemHighlighted(false, at: target.indexPath)
    }
}
