//
//  PushAccountTableViewCell.swift
//  ChatSecure
//
//  Created by Chris Ballinger on 2/12/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import UIKit

@objc(PushAccountTableViewCell)
public class PushAccountTableViewCell: ServerCapabilityTableViewCell {
    
    @IBOutlet weak var extraDataLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    public override class func cellIdentifier() -> String {
        return "PushAccountTableViewCell"
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        extraDataLabel.text = nil
        activityIndicator.stopAnimating()
    }
    
    //FIXME: unlocalized strings
    
    /// pushCapabilities must be for code == .XEP0357
    public func setPushInfo(pushInfo: PushInfo?, pushCapabilities: ServerCapabilityInfo) {
        assert(pushCapabilities.code == .XEP0357)
        
        // Common Setup
        titleLabel.text = "Push Registration"
        extraDataLabel.textColor = UIColor.lightGrayColor()
        
        // Loading Indicator
        guard let push = pushInfo else {
            extraDataLabel.text = "Loading..."
            activityIndicator.startAnimating()
            activityIndicator.hidden = false
            return
        }
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        
        // Push Info
        var checkmark = "❓"
        var status = "Inactive"
        var lowPower = false
        if #available(iOS 9.0, *) {
            lowPower = NSProcessInfo.processInfo().lowPowerModeEnabled
        }
        if  push.pushMaybeWorks() &&
            pushCapabilities.status == .Available &&
            !lowPower {
            checkmark = "✅"
            status = "Active"
        } else if (!push.pushPermitted) {
            checkmark = "❌"
            status = "Permission Disabled" // prompt user to fix
        } else if (!push.hasPushAccount) {
            checkmark = "❌"
            status = "Not Registered"
        } else if (pushCapabilities.status != .Available) {
            checkmark = "⚠️"
            status = "XMPP Server Incompatible (see XEP-0357)"
        } else if (push.numUsedTokens == 0) {
            checkmark = "⚠️"
            // this means no tokens have been uploaded to a xmpp server
            // or distributed to a buddy.
            status = "No Used Tokens"
        } else if (lowPower) {
            checkmark = "⚠️"
            status = "Turn Off Low Power Mode"
        } else {
            checkmark = "❌"
            status = "Unknown Error"
        }
        titleLabel.text = "Push Registration"
        subtitleLabel.text = "Status: " + status
        let apiEndpoint = String(format: "%@%@", push.pushAPIURL.host ?? "", push.pushAPIURL.path ?? "")
        extraDataLabel.text = String(format: "Endpoint: %@\nPubsub: %@\nTokens: %d used, %d unused", apiEndpoint, push.pubsubEndpoint ?? "Error", push.numUsedTokens, push.numUnusedTokens)
        checkLabel.text = checkmark
    }
}