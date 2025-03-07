class OrderModel {
  final String customername;
  final String pickupdate;
  final String sendercountry;
  final String receivercountry;
  final String sendernumber;
  final String cargotype;
  final String pickuplocation;
  final String remarks;

  const OrderModel ( {
    required this.customername,
    required this.pickupdate,
    required this.sendercountry,
    required this.receivercountry,
    required this.sendernumber,
    required this.cargotype,
    required this.pickuplocation,
    required this.remarks,
  });



  factory OrderModel.fromJson(Map<String,dynamic> json) {
    return switch (json) {
      {
      'customer_name': String customername,
      'pickup_date': String pickupdate,
      'sender_country': String sendercountry,
      'receiver_country': String receivercountry,
      'sender_number': String sendernumber,
      'cargo_type': String cargotype,
      'pickup_location': String pickuplocation,
      'remarks': String remarks
    } =>
      OrderModel(
          customername : customername,
          pickupdate: pickupdate,
          sendercountry: sendercountry,
          receivercountry: receivercountry,
          sendernumber: sendernumber,
          cargotype: cargotype,
          pickuplocation: pickuplocation,
          remarks: remarks
      ),
      _ => throw const FormatException('Failed to book order.'),
    };
  }
}