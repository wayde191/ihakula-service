module StatusCodes
  OK = 200
  CREATED = 201
  UPDATED = 204
  MALFORMED_REQUEST = 400
  OPP_NOT_FOUND = 440
  NOT_FOUND = 404
  FAILURE = 500
  DUPLICATE = 409

  ACTIVITY_IS_GOING = 600
  ACTIVITY_NOT_FOUND = 601
  ACTIVITY_IS_OVER = 602
  ACTIVITY_NOT_START = 603
  ACTIVITY_HAS_JOINED = 604

  INVITE_CODE_ERROR = 701
  HOUSE_NOT_AVAILABLE = 702
  HOUSE_AVAILABLE = 703

  WX_GUEST = 720
  WX_HOST = 721
  WX_ADMIN = 795

  ACTIVITY_CREATE_SUCC = 900

  COUPON_EXPIRED = 1004
  COUPON_USED = 1005

  ORDER_CREATED = 1
  ORDER_CONFIRMED = 2
  ORDER_DELIVERED = 3
  ORDER_PAID = 4
  ORDER_FINISHED = 5
  ORDER_CANCELLED = 6
  ORDER_REMOVED = 7

end