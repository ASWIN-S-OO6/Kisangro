import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyOrdersApp());

class MyOrdersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyOrdersPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyOrdersPage extends StatelessWidget {
  final Color orange = Color(0xFFFF7E1B);
  final Color lightOrange = Color(0xFFFFF4EC);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: lightOrange,
        appBar: AppBar(
          backgroundColor: orange,
          leading: Icon(Icons.arrow_back, color: Colors.white),
          title: Text("My Orders", style: GoogleFonts.poppins(color: Colors.white)),
          actions: [
            Icon(Icons.local_shipping, color: Colors.white),
            Stack(
              children: [
                Icon(Icons.favorite_border, color: Colors.white),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Colors.red,
                    child: Text("2", style: GoogleFonts.poppins(fontSize: 10, color: Colors.white)),
                  ),
                )
              ],
            ),
            Icon(Icons.notifications_none, color: Colors.white),
            SizedBox(width: 10),
          ],
          bottom: TabBar(
            labelColor: orange,
            unselectedLabelColor: Colors.black,
            indicatorColor: orange,
            tabs: [
              Tab(text: "Booked"),
              Tab(text: "Dispatched"),
              Tab(text: "Delivered"),
              Tab(text: "Canceled"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text("Booked")),
            DispatchedTab(),
            Center(child: Text("Delivered")),
            Center(child: Text("Canceled")),
          ],
        ),

      ),
    );
  }
}

class DispatchedTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        OrderCard(
          imagePath: 'assets/Valaxa 1.png',
          productName: "AURASTAR",
          description: "Azoxistrobin 23 % EC",
          quantity: "02",
          cost: "₹ 37,200",
          unit: "1 L",
          orderId: "1234567",
          orderedOn: "03/11/2024  2:40 pm",
        ),
        SizedBox(height: 12),
        SmallOrderCard(),
        SizedBox(height: 12),
        SmallOrderCard(),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  final String imagePath, productName, description, quantity, cost, unit, orderId, orderedOn;

  OrderCard({
    required this.imagePath,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.cost,
    required this.unit,
    required this.orderId,
    required this.orderedOn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(imagePath),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(description, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    SizedBox(height: 4),
                    Text("Ordered Units: $quantity"),
                    Text("Total Cost: $cost", style: GoogleFonts.poppins(color: Colors.orange)),
                    SizedBox(height: 4),
                    Text("Order ID: $orderId"),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(unit, style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange,
                            side: BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Track Status"),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: 12),
          Text("Ordered On: $orderedOn"),
        ],
      ),
    );
  }
}

class SmallOrderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 30,
                width: 65,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("2 Items", style: GoogleFonts.poppins(fontWeight: FontWeight.bold,fontSize: 13)),
              ),
              Spacer(),
              Text("Ordered On: 03/11/2024  2:40 pm"),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
          SizedBox(height: 8),
          Text("AURASTAR, VALAX", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          Text("Total Cost: ₹ 37,200", style: GoogleFonts.poppins(color: Colors.orange)),
          Row(
            children: [
              Text("Order ID: 1234567"),
              SizedBox(width: 60,),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: Text("Track Status"),
              )
            ],
          ),

        ],
      ),
    );
  }
}
