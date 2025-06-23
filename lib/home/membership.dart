import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisangro/payment/payment3.dart'; // Import the PaymentPage from payment3.dart
import 'package:shared_preferences/shared_preferences.dart'; // For SharedPreferences
import 'package:flutter/foundation.dart'; // For debugPrint

class MembershipDetailsScreen extends StatefulWidget {
  const MembershipDetailsScreen({super.key});

  @override
  State<MembershipDetailsScreen> createState() => _MembershipDetailsScreenState();
}

class _MembershipDetailsScreenState extends State<MembershipDetailsScreen> with WidgetsBindingObserver {
  bool _isMembershipActive = false; // Local state to control which UI to show

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for lifecycle events
    _checkMembershipStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // This method is called when the app's lifecycle state changes
    if (state == AppLifecycleState.resumed) {
      // When the app resumes (e.g., coming back from another screen like payment)
      debugPrint('App resumed, re-checking membership status...');
      _checkMembershipStatus();
    }
  }

  // Method to check membership status from SharedPreferences
  Future<void> _checkMembershipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isMembershipActive = prefs.getBool('isMembershipActive') ?? false;
    });
    debugPrint('Membership status loaded: $_isMembershipActive');
  }

  // Method to activate membership (called after successful payment) - now directly tied to SharedPreferences
  // This method is primarily for internal state updates if you were to call it without pop/push.
  // In the current flow, payment3.dart will set the flag, and didChangeAppLifecycleState will trigger refresh.
  Future<void> _activateMembership() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMembershipActive', true);
    setState(() {
      _isMembershipActive = true;
    });
    debugPrint('Membership activated!');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Congratulations! Your membership is now active!', style: GoogleFonts.poppins())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Text('Membership Details', style: GoogleFonts.poppins(color: Colors.white)),
        actions: const [
          Icon(Icons.inventory_2_outlined, color: Colors.white),
          SizedBox(width: 10),
          Icon(Icons.favorite_border, color: Colors.white),
          SizedBox(width: 10),
          Icon(Icons.notifications_outlined, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/mem.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
              child: _isMembershipActive ? _buildMembershipActiveUI(context) : _buildMembershipOfferUI(context),
            ),
          ),
        ],
      ),
    );
  }

  // UI for when membership is NOT active (your original UI)
  Widget _buildMembershipOfferUI(BuildContext context) {
    return Column(
      children: [
        Text(
          '“Be A Part Of Something Bigger”',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            Text(
              'Join Our Membership',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.yellow,
              ),
            ),
            Text(
              'Today!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.yellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 120,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1),
            ),
            child: Row(
              children: [
                Image.asset('assets/logo.png', height: 90),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Agri-Products Delivered\nTo Your Door Step',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Effortless Bulk Ordering With\nExclusive Membership Discounts.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () async {
            // Navigate to the PaymentPage to process membership fee
            await Navigator.push( // Await the navigation to know when it returns
              context,
              MaterialPageRoute(
                builder: (context) => PaymentPage(orderId: 'MEMBERSHIP_ORDER_ID_ABC'),
              ),
            );
            // After returning from PaymentPage, check membership status again
            // This will be handled by didChangeAppLifecycleState when the screen resumes.
          },
          icon: const Icon(Icons.lock_open, color: Colors.white),
          label: Text('Unlock', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Your Membership @ ₹ 500',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '2% Membership Discount For Every\nProduct You Purchase',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          'For',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
        ),
        Text(
          '1 YEAR',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 70),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(orderId: 'MEMBERSHIP_ORDER_ID_ABC'),
                ),
              );
              // After returning from PaymentPage, check membership status again
              // This will be handled by didChangeAppLifecycleState when the screen resumes.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'Proceed to Payment',
              style: GoogleFonts.poppins(
                color: Colors.indigo,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // UI for when membership IS active (your new sample UI)
  Widget _buildMembershipActiveUI(BuildContext context) {
    return Column(
      children: [
        // Top motivational text
        Text(
          '"Be A Part Of Something Bigger"',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Success message
        Column(
          children: [
            Text(
              'You Are A Member Now!',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Colors.yellow,
              ),
            ),
            const SizedBox(height: 5),
            // Yellow underline
            Container(
              height: 3,
              width: 100,
              color: Colors.yellow,
            ),
          ],
        ),
        const SizedBox(height: 30),

        // White info card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1),
          ),
          child: Row(
            children: [
              Image.asset('assets/logo.png', height: 90),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Agri-Products ',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Delivered\nTo Your ',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Door Step',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Effortless Bulk Ordering With\nExclusive ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          TextSpan(
                            text: 'Membership ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Discounts.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Membership status section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Membership',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_open, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Unlocked',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Benefits text
        Text(
          '2% Membership Discount For Every\nProduct You Purchase',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),

        // Year plan and community section
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    'YEAR',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'PLAN',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'You Are A Part Of\nOur Community Now!',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),

        // Expiry date
        Text(
          'Plan Expires On: 23rd Dec, 2025',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),

        // Continue button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () {
              // Navigate back to home or previous screen
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(
                color: Colors.indigo,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
