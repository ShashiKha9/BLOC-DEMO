class MessagesConst {
  static const String internalServerError =
      "Something went wrong. Please try again later.";

  //Login Screen Messages
  static const String loginInvalidCredentials = "Invalid login credentials.";

  //Coupon Screen Messages
  //Listing
  static const String couponNotFound = "Promo Code Not Found.";
  static const String couponInvalid =
      "Promo code is expired and cannot be shared.";
  //Adding Coupon
  static const String couponCreateSuccess = "Promo Code created successfully.";
  //Share Coupon
  static const String couponShareSuccess = "Promo Code shared successfully.";
  static const String couponShareFailed =
      "Promo Code failed to share with below values.";
  static const String getCouponSharesFailed = "Error fetching coupon shares";

  //Customer Management Messages
  //Listing
  static const String customersNotFound = "No records found.";
  static const String customerUpdateSuccess = "Record updated successfully.";
  static const String customerUpdateNotAllowed =
      "Can not modify terminated account.";
  //Delete
  static const String customerDeleted = "Account terminated successfully.";
  //View
  static const String customerAddressError =
      "Error fetching customer addresses.";
  static const String customerSubscriptionsError =
      "Error fetching customer subscriptions.";
  static const String customerPaymentMethodsError =
      "Error fetching customer payment methods.";
  static const String customerDispatchHistoryError =
      "Error fetching Dispatch History.";

  //Broadcast Messages
  static const String broadCastSuccess = "Message broadcasted successfully.";

  //Custom Messages
  static const String customMessageEmailsFetchError =
      "Error fetching custom message emails.";
  static const String customMessageSuccess = "Notification sent successfully.";
  static const String customMessageCancelAutoRenewalSuccess =
      "Subscription successfully cancelled. You may resume the subscription at any time before the expiration.";
  static const String customMessageAutoRenewalSuccess =
      "Subscription resumed successfully.";

  // Reset Password Messages
  static const String resetPasswordSuccess =
      "Password has been reset and shared with the user";
  static const String resetPasswordFailed = "Error resetting password";
}
