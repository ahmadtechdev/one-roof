import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api_service_group_tickets.dart';
import 'package:oneroof/utility/colors.dart';
import 'package:oneroof/views/group_ticket/flight_pkg/select_pkg.dart';

class GroupTicket extends StatefulWidget {
  const GroupTicket({super.key});

  @override
  State<GroupTicket> createState() => _GroupTicketState();
}

class _GroupTicketState extends State<GroupTicket> {
  final GroupTicketingController controller = Get.put(
    GroupTicketingController(),
    permanent: true,
  );
  
  // Track loading states for each destination
  final Map<String, bool> _loadingStates = {};
  bool _isAnyLoading = false;

  // Helper method to handle destination tap
  Future<void> _handleDestinationTap(String destination, String title, String apiParam) async {
    // Prevent multiple taps
    if (_isAnyLoading) return;
    
    setState(() {
      _loadingStates[destination] = true;
      _isAnyLoading = true;
    });

    try {
      // Show loading snackbar
      Get.snackbar(
        "Loading",
        "Loading $title data...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: TColors.primary.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Fetch data
      await controller.fetchCombinedGroups(destination, apiParam);
      
      // Navigate to next screen
      if (mounted) {
        Get.to(() => SelectPkgScreen());
      }
      
    } catch (e) {
      // Show error message
      if (mounted) {
        Get.snackbar(
          "Error",
          "Failed to load $title data. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _loadingStates[destination] = false;
          _isAnyLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/sky.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Back button with loading indicator
                Row(
                  children: [
                    GestureDetector(
                      onTap: _isAnyLoading ? null : () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: const Alignment(-1, 0),
                        child: Icon(
                          Icons.arrow_back, 
                          color: _isAnyLoading ? Colors.white.withOpacity(0.5) : Colors.white
                        ),
                      ),
                    ),
                    if (_isAnyLoading) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Loading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                // Header
                const Text(
                  'Airline Groups',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black38,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                // Subheader
                const Text(
                  'Groups you need...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black38,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // First row of cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/1.png',
                          title: 'UAE One Way Groups',
                          isLoading: _loadingStates['UAE'] ?? false,
                          onTap: () => _handleDestinationTap('UAE', 'UAE One Way Groups', 'UAE     '),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/2.png',
                          title: 'KSA One Way Groups',
                          isLoading: _loadingStates['KSA'] ?? false,
                          onTap: () => _handleDestinationTap('KSA', 'KSA One Way Groups', 'KSA ONEWAY'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Second row of cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/4.png',
                          title: 'OMAN One Way Groups',
                          isLoading: _loadingStates['OMAN'] ?? false,
                          onTap: () => _handleDestinationTap('OMAN', 'OMAN One Way Groups', ' OMANN    '),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/4.png',
                          title: 'UK One Way Groups',
                          isLoading: _loadingStates['UK'] ?? false,
                          onTap: () => _handleDestinationTap('UK', 'UK One Way Groups', 'UK '),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Third row of cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/5.png',
                          title: 'UMRAH',
                          isLoading: _loadingStates['UMRAH'] ?? false,
                          onTap: () => _handleDestinationTap('UMRAH', 'UMRAH', 'UMRAH'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DestinationCard(
                          image: 'assets/images/6.png',
                          title: 'All Types',
                          isLoading: _loadingStates['ALL'] ?? false,
                          onTap: () => _handleDestinationTap('ALL', 'All Types', '     '),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced DestinationCard with loading state
class DestinationCard extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;
  final bool isLoading;

  // ignore: use_super_parameters
  const DestinationCard({
    Key? key,
    required this.image,
    required this.title,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap, // Disable tap when loading
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isLoading ? TColors.primary : TColors.secondary, 
            width: 2
          ),
          boxShadow: [
            BoxShadow(
              color: isLoading 
                ? TColors.primary.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
              blurRadius: isLoading ? 8 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image with loading overlay
              Positioned.fill(
                child: Image.asset(
                  image, 
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Title section
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isLoading 
                      ? TColors.primary.withOpacity(0.9)
                      : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isLoading ? Colors.white : TColors.secondary, 
                        width: 1
                      ),
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isLoading ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
