class GMNotificationDelegate: MCENotificationDelegate {
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let payload = response.notification.request.content.userInfo
        
        // check for something in the payload
        print("payload:",String(describing: payload))
        // If special payload key is not found, call the MCE superclass to handle the action
        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
}
