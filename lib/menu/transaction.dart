import 'package:flutter/material.dart';
import 'package:kisangro/home/myorder.dart';
import 'package:kisangro/home/noti.dart';
import 'package:kisangro/menu/wishlist.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionHistoryPage extends StatefulWidget {

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int entries = 10;
  String history = '1 week';
  List<bool> expanded = [false, true, true]; // Track expanded state for each transaction

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffEB7720),
        elevation: 0,
        title:  Text(
          "Transaction History",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize:16
          ),
        ),
        leading:

        IconButton(
            onPressed: () {
              Navigator.pop(context);// handle menu
            },
            icon:Icon(Icons.arrow_back,color: Colors.white,)
        ),
        actions: [

          IconButton(
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context)=>MyOrder()));

            },
            icon: Image.asset(
              'assets/box.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10,),
          IconButton(
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context)=>WishlistPage()));
            },
            icon: Image.asset(
              'assets/heart.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context)=>noti()));
            },
            icon: Image.asset(
              'assets/noti.png',
              height: 24,
              width: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffFFD9BD),
                  Color(0xffFFFFFF),
                ]
            )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              // Filters Row
              Row(
                children: [
                  Text('Entries:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  SizedBox(width: 6),
                  Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: DropdownButton<int>(
                      value: entries,
                      underline: SizedBox(),
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                      items: [10, 20, 50, 100]
                          .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => entries = val);
                      },
                    ),
                  ),
                  Spacer(),
                  Text('History:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  SizedBox(width: 6),
                  Container(
                    height: 30,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value: history,
                      underline: SizedBox(),
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.orange),
                      items: ['1 week', '1 month', '3 months']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => history = val);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Transactions List
              Expanded(
                child: ListView(
                  children: [
                    _transactionCard(
                      avatarLetter: 'K',
                      title: 'To Kisangro Membership',
                      subtitle: 'Membership: Basic plan',
                      amount: '₹ 500',
                      paymentMethod: 'GPay',
                      dateTime: '18/11/2024 2:40 pm',
                      expanded: false,
                      onToggleExpanded: () {},
                      invoiceCallback: () {
                        // Invoice action
                      },
                    ),
                    SizedBox(height: 16),
                    _transactionCard(
                      avatarLetter: 'K',
                      title: 'To Kisangro Product',
                      subtitle: 'Order: AURASTAR',
                      amount: '₹ 37,200',
                      paymentMethod: 'GPay',
                      dateTime: '30/11/2024 2:40 pm',
                      expanded: expanded[1],
                      onToggleExpanded: () {
                        setState(() {
                          expanded[1] = !expanded[1];
                        });
                      },
                      invoiceCallback: () {
                        // Invoice action
                      },
                      detailsWidget: _productDetailsWidget(),
                    ),
                    SizedBox(height: 16),
                    _transactionCard(
                      avatarLetter: 'K',
                      title: 'To Kisangro Product',
                      subtitle: 'Order: AURASTAR',
                      amount: '₹ 37,200',
                      paymentMethod: 'GPay',
                      dateTime: '30/11/2024 2:40 pm',
                      expanded: expanded[2],
                      onToggleExpanded: () {
                        setState(() {
                          expanded[2] = !expanded[2];
                        });
                      },
                      invoiceCallback: () {
                        // Invoice action
                      },
                      detailsWidget: _multipleItemsDetailsWidget(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionCard({
    required String avatarLetter,
    required String title,
    required String subtitle,
    required String amount,
    required String paymentMethod,
    required String dateTime,
    required bool expanded,
    required VoidCallback onToggleExpanded,
    required VoidCallback invoiceCallback,
    Widget? detailsWidget,
  }) {
    return Container(

      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with avatar, title, amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  avatarLetter,
                  style: GoogleFonts.poppins(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                          color:Color(0xffEB7720),
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Paid using: ',
                            style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                  Image(image: AssetImage("assets/gpay.png"),width: 30,),
                        SizedBox(width: 4),
                        Text(paymentMethod,
                            style: GoogleFonts.poppins(color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xffEB7720)),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Invoice and date row
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: invoiceCallback,
                icon: Icon(Icons.download, size: 16,color: Colors.white,),
                label: Text(
                  'Invoice',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)
                  ),
                  backgroundColor: Color(0xffEB7720),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                ),
              ),
              Spacer(),
              Text(
                dateTime,
                style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12),
              ),
              SizedBox(width: 8),
              if (detailsWidget != null)
                GestureDetector(
                  onTap: onToggleExpanded,
                  child: Text(
                    expanded ? 'Hide Details ▲' : 'Show Details ▼',
                    style: GoogleFonts.poppins(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),

          // Expanded details
          if (expanded && detailsWidget != null) ...[
            SizedBox(height: 12),
            detailsWidget,
          ],
        ],
      ),
    );
  }

  Widget _productDetailsWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image placeholder
        Container(
          width: 150,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white),
            color: Colors.grey.shade100,
          ),
          child: Image(image: AssetImage("assets/Oxyfen.png"))
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AURASTAR',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              SizedBox(height: 4),
              Text('Azoxistrobin 23 % EC',
                  style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 12)),
              SizedBox(height: 4),
              Text('Unit Size: 12 pieces',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12)),
              SizedBox(height: 4),
              Text('₹ 1650/piece',
                  style: GoogleFonts.poppins(
                      color: Color(0xffEB7720), fontWeight: FontWeight.w600)),
              SizedBox(height: 4),
              Text('Ordered Units: 02',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12)),
              SizedBox(height: 4),
              Text('Order ID: 1234567',
                  style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12)),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Reorder action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:Color(0xffEB7720),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                child: Text(
                  'Re-order',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _multipleItemsDetailsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('2 Items', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        Text('AURASTAR, VALAX'),
        SizedBox(height: 6),
        Text('Total Cost: ₹ 87,200'),
        SizedBox(height: 6),
        Text('Order ID: 1234567'),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              // Reorder action
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffEB7720),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(
              'Re-order',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600,color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}