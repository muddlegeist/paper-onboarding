//
//  OnboardingContentView.swift
//  AnimatedPageView
//
//  Created by Alex K. on 21/04/16.
//  Copyright © 2016 Alex K. All rights reserved.
//

import UIKit

public protocol OnboardingContentViewDelegate: class {

    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo?
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int)
}

open class OnboardingContentView: UIView {

     struct Constants {
        static let dyOffsetAnimation: CGFloat = 110
        static let showDuration: Double = 0.8
        static let hideDuration: Double = 0.2
    }

    open var currentItem: OnboardingContentViewItem?
    open weak var delegate: OnboardingContentViewDelegate?

    public init(itemsCount _: Int, delegate: OnboardingContentViewDelegate) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)

        commonInit()
    }

    required override public init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: public

    open func currentItem(_ index: Int, animated _: Bool) {

        let showItem = createItem(index)
        showItemView(showItem, duration: Constants.showDuration)

        hideItemView(currentItem, duration: Constants.hideDuration)

        currentItem = showItem
    }

// MARK: life cicle

    open class func contentViewOnView(_ view: UIView, delegate: OnboardingContentViewDelegate, itemsCount: Int, bottomConstant: CGFloat) -> OnboardingContentView {
        let contentView = Init(OnboardingContentView(itemsCount: itemsCount, delegate: delegate)) {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(contentView)

        // add constraints
        for attribute in [NSLayoutConstraint.Attribute.left, NSLayoutConstraint.Attribute.right, NSLayoutConstraint.Attribute.top] {
            (view, contentView) >>>- { $0.attribute = attribute; return }
        }
        (view, contentView) >>>- {
            $0.attribute = .bottom
            $0.constant = bottomConstant
            return
        }
        return contentView
    }

// MARK: create

     open func commonInit() {

        currentItem = createItem(0)
    }

     open func createItem(_ index: Int) -> OnboardingContentViewItem {

        guard let info = delegate?.onboardingItemAtIndex(index) else {
            return OnboardingContentViewItem.itemOnView(self)
        }

        let item = Init(OnboardingContentViewItem.itemOnView(self)) {
            $0.imageView?.image = info.informationImage
            $0.titleLabel?.text = info.title
            $0.titleLabel?.font = info.titleFont
            $0.titleLabel?.textColor = info.titleColor
            $0.descriptionLabel?.text = info.description
            $0.descriptionLabel?.font = info.descriptionFont
            $0.descriptionLabel?.textColor = info.descriptionColor
        }

        delegate?.onboardingConfigurationItem(item, index: index)
        return item
    }

// MARK: animations

     open func hideItemView(_ item: OnboardingContentViewItem?, duration: Double) {
        guard let item = item else {
            return
        }

        item.descriptionBottomConstraint?.constant -= Constants.dyOffsetAnimation
        item.titleCenterConstraint?.constant *= 1.3

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut, animations: {
                           item.alpha = 0
                           self.layoutIfNeeded()
                       },
                       completion: { _ in
                           item.removeFromSuperview()
        })
    }

     open func showItemView(_ item: OnboardingContentViewItem, duration: Double) {
        item.descriptionBottomConstraint?.constant = Constants.dyOffsetAnimation
        item.titleCenterConstraint?.constant /= 2
        item.alpha = 0
        layoutIfNeeded()

        item.descriptionBottomConstraint?.constant = 0
        item.titleCenterConstraint?.constant *= 2

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut, animations: {
                           item.alpha = 0
                           item.alpha = 1
                           self.layoutIfNeeded()
        }, completion: nil)
    }
}
